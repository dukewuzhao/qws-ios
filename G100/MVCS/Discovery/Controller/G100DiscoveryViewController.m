//
//  G100DiscoveryViewController.m
//  G100
//
//  Created by 天奕 on 15/12/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100DiscoveryViewController.h"
#import "G100SearchView.h"
#import "G100SearchViewController.h"
#import "G100CityPickViewController.h"
#import "G100DiscoveryShopDetailCell.h"
#import "G100DropDownMenu.h"
#import "G100LocationResultManager.h"
#import "G100ShopApi.h"
#import "G100CityDataManager.h"
#import "G100ServiceCityDataDomain.h"
#import "G100ShopDomain.h"

#import "G100ShopMapViewController.h"

@interface G100DiscoveryViewController () <UITableViewDataSource, UITableViewDelegate,G100DropDownMenuDataSource, G100DropDownMenuDelegate, AMapLocationManagerDelegate, UIAlertViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource> {
    G100ShopSearchMode _kSearchSearchtype; //!< 搜索方式
    NSArray * _kSearchType; //!< 店铺类型
    G100ShopSortbyMode _kSearchSortby;
    G100ShopSorttypeDirection _kSearchSorttype;
    NSInteger _kSearchRadius;
    NSInteger _kSearchPageSize;
    NSInteger _kSearchPageNum;
}

@property (weak, nonatomic) IBOutlet UIButton *cityPickButton;
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UIView *searchContentView;

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) IBOutlet UIView *noUsedCityView;

@property (nonatomic, strong) G100SearchView *searchView;

@property (nonatomic, strong) NSArray *filterTitles;

@property (nonatomic, strong) NSArray *distance;

@property (nonatomic, strong) NSArray *classifys;
@property (nonatomic, strong) NSMutableArray *classifysXuanze;
@property (nonatomic, strong) G100DropDownMenu *menu;

@property (strong, nonatomic) NSString *currentCityCode;
@property (strong, nonatomic) G100ServiceCityDomain *selectedCity;
@property (strong, nonatomic) AMapLocationManager *locationManager;

@property (strong, nonatomic) G100ServiceCityDataDomain *serviceCityDataDomain;

@property (strong, nonatomic) NSMutableArray *cityDistricts;

@property (strong, nonatomic) NSArray *pickedMenuArray;

@property (strong, nonatomic) NSMutableArray *dataArray;/* G100ShopDomain */

@property (assign, nonatomic) BOOL hasGetCityLists;

@property (strong, nonatomic) G100DiscoveryLocationModel *selectedModel;

@property (strong, nonatomic) G100DiscoveryLocationModel *locatedModel;

- (IBAction)changeCity:(UIButton *)sender;

@end

@implementation G100DiscoveryViewController

- (void)dealloc {
    DLog(@"行业地图已释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationTitle:@"行业地图"];
    
    // 初始化搜索类型
    [self initializationData];
    
    self.searchView = [[G100SearchView alloc]initWithEnableClick:NO];
    [self.searchContentView addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(@0);
        make.leading.and.trailing.equalTo(@0);
    }];
    __weak G100DiscoveryViewController *wself = self;
    self.searchView.clickWithoutInput = ^(){
      //跳转搜索页面
        G100SearchViewController *searchViewController = [[G100SearchViewController alloc]initWithNibName:@"G100SearchViewController" bundle:nil];
        [wself.navigationController pushViewController:searchViewController animated:YES];
    };
    
    G100DropDownMenu *menu = [[G100DropDownMenu alloc] initWithOrigin:CGPointMake(0, 36) andHeight:44];
    menu.dataSource = self;
    menu.delegate = self;
    menu.openMenuBlock = ^(){
        self.pickedMenuArray = [NSArray arrayWithArray:self.classifysXuanze];
    };
    __weak typeof(G100DropDownMenu) *weakMenu = menu;
    menu.menuCancelPick = ^(){
        self.classifysXuanze = self.pickedMenuArray.mutableCopy;
        [weakMenu refreshData];
    };
    [self.substanceView addSubview:menu];
    _menu = menu;
    
    [self.view insertSubview:self.noUsedCityView aboveSubview:self.substanceView];
    [self.noUsedCityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(kNavigationBarHeight);
        make.leading.and.trailing.and.bottom.equalTo(@0);
    }];
    self.noUsedCityView.hidden = YES;
    [self getServiceCityList];
    
    self.contentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _kSearchPageNum = 1;
        [wself getCurrentCityDataWithRefreshType:YES];
    }];
    self.contentTableView.mj_header.lastUpdatedTimeKey = NSStringFromClass([self class]);
    
    self.contentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _kSearchPageNum++;
        [wself getCurrentCityDataWithRefreshType:NO];
    }];
    self.contentTableView.mj_footer.automaticallyHidden = YES;
    
    self.contentTableView.emptyDataSetSource = self;
    self.contentTableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.contentTableView.tableFooterView = [UIView new];
    
    self.hasGetCityLists = NO;
}

- (void)initializationData {
    _kSearchSearchtype = G100ShopSearchModeAutomatic;
    _kSearchType = @[@(1), @(2), @(3)];
    _kSearchSortby = G100ShopSortbyModeDistance;
    _kSearchSorttype = G100ShopSorttypeDirectionAscend;
    _kSearchRadius = 10000;
    _kSearchPageSize = 10;
    _kSearchPageNum = 1;
    
    self.filterTitles = @[@"附近", @"分类"];
    
    self.cityDistricts = @[@"附近"].mutableCopy;
    self.distance = @[@"附近(智能范围)", @"500米", @"1000米", @"2000米", @"5000米"];
    
    self.classifys = @[@"销售", @"维修", @"充电"];
    self.classifysXuanze = [NSMutableArray arrayWithArray:@[@(YES), @(YES), @(YES)]];
}

/* 获取城市列表 */
- (void)getServiceCityList {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    [[G100ShopApi sharedInstance]getServiceCityWithListts:[G100CityDataInfoHelper localCityListts] callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            if (![G100CityDataInfoHelper hasLocalData]) {
                [G100CityDataInfoHelper updateLocalCityDataWithData:response.data];
                self.serviceCityDataDomain = [G100CityDataInfoHelper localCityData];
            }else{
                G100ServiceCityDataDomain *newCityDataDomain = [[G100ServiceCityDataDomain alloc]initWithDictionary:response.data];
                if (newCityDataDomain.versionflag == 0) {
                    self.serviceCityDataDomain = [G100CityDataInfoHelper localCityData];
                }else{
                    self.serviceCityDataDomain = newCityDataDomain;
                    [G100CityDataInfoHelper updateLocalCityDataWithData:response.data];
                }
            }
            
            self.hasGetCityLists = YES;
            [self locationCurrentCity];
        }else{
            if (response) {
                [self showHint:response.errDesc];
            }
        }
    }];
}

/* 判断当前城市是否是在服务城市列表中  是否需要刷新 */
- (BOOL)isInUsedCity:(NSString *)cityCode needRefresh:(BOOL)need {
    
    NSMutableArray *cityCodes = [NSMutableArray array];
    for (NSDictionary * dict in self.serviceCityDataDomain.cities) {
        G100ServiceCityDomain *cityDomain = [[G100ServiceCityDomain alloc] initWithDictionary:dict];
        [cityCodes addObject:cityDomain.adcode];
    }
    if ([cityCodes containsObject:cityCode]) { /* 省直辖县级行政区划 6位 */
        if (need) {
            _currentCityCode = cityCode;
            [self getCityDistrictListWithCityCode:cityCode];
            [self.contentTableView.mj_header beginRefreshing];
        }
        
        return YES;
    }else{
        
        NSArray *centralCity = @[@"11",@"12",@"31",@"50"];/* 北京 天津 上海 重庆 */
        NSString *newCityCode;
        if ([centralCity containsObject:[cityCode substringToIndex:2]]) {/* 直辖市 */
            newCityCode = [[cityCode substringToIndex:2] stringByAppendingString:@"0000"];
        }else{
            newCityCode = [[cityCode substringToIndex:4] stringByAppendingString:@"00"];
        }
        if ([cityCodes containsObject:newCityCode]) {
            if (need) {
                _currentCityCode = newCityCode;
                [self getCityDistrictListWithCityCode:newCityCode];
                [self.contentTableView.mj_header beginRefreshing];
            }
            return YES;
        }
    }
    return NO;
}

/* 获取当前定位城市 */
- (void)locationCurrentCity {
    
    self.selectedModel = [G100LocationResultManager sharedInstance].discoverySelectedCity;
    if (self.selectedModel.city.length>0) {/* 有选择过城市 */
        _currentCityCode = self.selectedModel.adcode;
        [self configView];
    }else{
        NSString *cityCode = [G100LocationResultManager sharedInstance].locationResult.adcode;
        //NSString *city = [G100LocationResultManager sharedInstance].locationInfo.city;
        
        if (cityCode.length>0) { /* 本地有定位信息 */
            _currentCityCode = cityCode;
            [self configView];
        }
    }
    
    //单次定位
    if (!_locationManager) {
        self.locationManager = [[AMapLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
        }
        NSString *currentCity;
        if (location && regeocode) {
            /* 更新定位信息 */
            [[G100LocationResultManager sharedInstance] saveUserLocationWithLocation:location result:regeocode];
            currentCity = regeocode.city.length>0?regeocode.city:regeocode.province;
            
            self.locatedModel = [G100LocationResultManager sharedInstance].discoveryLocatedCity;
            
            if (self.locatedModel.city.length>0 && ![self.locatedModel.city isEqualToString:currentCity] && ![currentCity isEqualToString:self.selectedModel.city] && [self isInUsedCity:regeocode.adcode needRefresh:NO]) {
            //新的定位城市与之前定位城市不同 && 新的定位城市与当前显示城市不同 && 新的城市在服务城市列表中
                NSString *message = [NSString stringWithFormat:@"系统定位您在%@，是否切换城市？",currentCity];
                [MyAlertView MyAlertWithTitle:@"提示" message:message delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                    
                    [self isInUsedCity:regeocode.adcode needRefresh:YES];
                    self.cityNameLabel.text = currentCity;
                    
                } cancelButtonTitle:@"取消" otherButtonTitles:@"切换"];
            }
            
            [[G100LocationResultManager sharedInstance] saveDiscoveryLocatedCityModelWithResult:regeocode];
            
        }
    }];
    
}

/* 获取城市的区域列表 */
- (void)getCityDistrictListWithCityCode:(NSString *)adcode {
    if ([G100CityDataInfoHelper loadLocalCityDistrictsWithAdcode:adcode]) {
        NSArray * tmp = [G100CityDataInfoHelper loadLocalCityDistrictsWithAdcode:adcode];
        
        if(!_cityDistricts) {
            self.cityDistricts = [NSMutableArray array];
        }
        [self.cityDistricts removeAllObjects];
        
        for (NSDictionary * dict in tmp) {
            G100ServiceCityDistrictDomain * domain = [[G100ServiceCityDistrictDomain alloc] initWithDictionary:dict];
            [self.cityDistricts addObject:domain];
        }
        
        [self.cityDistricts insertObject:@"附近" atIndex:0];
    }else{
        self.cityDistricts = @[@"附近"].mutableCopy;
    }
    
    [[G100ShopApi sharedInstance]getCityDistrictWithAdcode:adcode callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            NSArray *districtArray = [response.data objectForKey:@"districts"];
            [G100CityDataInfoHelper updateLocalCityDistrictWithDistricts:districtArray adcode:adcode];
        }
        
        if ([G100CityDataInfoHelper loadLocalCityDistrictsWithAdcode:adcode]) {
            NSArray * tmp = [G100CityDataInfoHelper loadLocalCityDistrictsWithAdcode:adcode];
            
            if(!_cityDistricts) {
                self.cityDistricts = [NSMutableArray array];
            }
            [self.cityDistricts removeAllObjects];
            
            for (NSDictionary * dict in tmp) {
                G100ServiceCityDistrictDomain * domain = [[G100ServiceCityDistrictDomain alloc] initWithDictionary:dict];
                [self.cityDistricts addObject:domain];
            }
            
            [self.cityDistricts insertObject:@"附近" atIndex:0];
        }else{
            self.cityDistricts = @[@"附近"].mutableCopy;
        }
    }];
}

/* 根据条件搜索店铺 */
- (void)getCurrentCityDataWithRefreshType:(BOOL)isDownPull {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        isDownPull?[self.contentTableView.mj_header endRefreshing]:[self.contentTableView.mj_footer endRefreshing];
        return;
    }
    NSArray *locationArray = [G100LocationResultManager sharedInstance].locationResult.coordinate;
    
    [[G100ShopApi sharedInstance] searchPlaceWithSearchtype:_kSearchSearchtype
                                                   searchwd:nil
                                                   location:locationArray
                                                     adcode:self.currentCityCode
                                                       type:_kSearchType
                                                     sortby:_kSearchSortby
                                                   sorttype:_kSearchSorttype
                                                     radius:_kSearchRadius
                                                       page:_kSearchPageNum
                                                       size:_kSearchPageSize
                                                   callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        isDownPull?[self.contentTableView.mj_header endRefreshing]:[self.contentTableView.mj_footer endRefreshing];
        if (requestSuccess) {
            if (!_dataArray) {
                self.dataArray = [NSMutableArray array];
            }
            
            if (isDownPull) {
                [self.dataArray removeAllObjects];
            }
            
            if (0 == response.total) {
                ((MJRefreshAutoStateFooter*)self.contentTableView.mj_footer).stateLabel.hidden = YES;
                [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                
                [self.dataArray removeAllObjects];
                [self.contentTableView reloadData];
            }else {
                ((MJRefreshAutoStateFooter*)self.contentTableView.mj_footer).stateLabel.hidden = NO;
                [self.contentTableView.mj_footer resetNoMoreData];
                
                if (0 != response.subtotal) {
                    if (response.subtotal == _kSearchPageSize) {
                        ((MJRefreshAutoStateFooter*)self.contentTableView.mj_footer).stateLabel.hidden = NO;
                        [self.contentTableView.mj_footer resetNoMoreData];
                    }else{
                        [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                    }
                    NSArray *shopPlacesArray = [response.data objectForKey:@"places"];
                    for (NSDictionary *dict in shopPlacesArray) {
                        G100ShopPlaceDomain *placeDomain = [[G100ShopPlaceDomain alloc]initWithDictionary:dict];
                        [self.dataArray addObject:placeDomain];
                    }
                    [self.contentTableView reloadData];
                }else {
                    ((MJRefreshAutoStateFooter*)self.contentTableView.mj_footer).stateLabel.hidden = YES;
                    [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            
        }else{
            if (response) {
                [self showHint:response.errDesc];
            }
        }
        
    }];
}

/* 页面更新 */
- (void)configView {
    
    if (_selectedModel.city.length>0) {
        
        self.noUsedCityView.hidden = [self isInUsedCity:self.selectedModel.adcode needRefresh:YES];
        self.cityNameLabel.text = self.selectedModel.city;
        
        self.currentCityCode = _selectedModel.adcode;

    }else {
        
        self.noUsedCityView.hidden = [self isInUsedCity:self.currentCityCode needRefresh:YES];
        self.cityNameLabel.text = [G100LocationResultManager sharedInstance].locationInfo.city;
        
        NSString *cityCode = [G100LocationResultManager sharedInstance].locationInfo.adcode;
        
        NSArray *centralCity = @[@"11",@"12",@"31",@"50"];/* 北京 天津 上海 重庆 */
        NSString *newCityCode = @"";
        if ([centralCity containsObject:[cityCode substringToIndex:2]]) {/* 直辖市 */
            newCityCode = [[cityCode substringToIndex:2] stringByAppendingString:@"0000"];
        }else{
            newCityCode = [[cityCode substringToIndex:4] stringByAppendingString:@"00"];
        }
        
        self.currentCityCode = newCityCode;
    }
}

- (void)setHasGetCityLists:(BOOL)hasGetCityLists {
    _hasGetCityLists = hasGetCityLists;
    
    self.cityPickButton.enabled = hasGetCityLists;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)changeCity:(UIButton *)sender {
    //跳转城市选择页面
    G100CityPickViewController *cityPickViewController = [[G100CityPickViewController alloc]initWithNibName:@"G100CityPickViewController" bundle:nil];
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in self.serviceCityDataDomain.cities) {
        G100ServiceCityDomain *city = [[G100ServiceCityDomain alloc] initWithDictionary:dict];
        [data addObject:city];
    }
    
    if (data.count) cityPickViewController.dataArray = data;
    cityPickViewController.pickCityComplete = ^(G100ServiceCityDomain * city, NSIndexPath *indexPath){
        /* 保存选中城市 */
        [[G100LocationResultManager sharedInstance] saveDiscoverySelectedCityModelWithResult:city];
        
        [self initializationData];
        
        [self configView];
        
        [self.menu reloadData];
        
        [self getCityDistrictListWithCityCode:city.adcode];
        
        [self.contentTableView.mj_header beginRefreshing];
        
    };
    
    [self presentViewController:cityPickViewController animated:YES completion:nil];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"暂无店铺数据";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark - G100DropDownMenuDataSource
- (NSInteger)numberOfColumnsInMenu:(G100DropDownMenu *)menu
{
    return self.filterTitles.count;
}

- (NSString *)menu:(G100DropDownMenu *)menu titleForColumn:(NSInteger)column
{
    // 如果需要根据条件更换标题 return nil
    if (column == 1) {
        return self.filterTitles[column];
    }
    return nil;
}

- (NSInteger)menu:(G100DropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    if (column == 0) {
        return self.cityDistricts.count;
    }else if (column == 1) {
        return self.classifys.count;
    }
    return 0;
}

- (NSString *)menu:(G100DropDownMenu *)menu titleForRowAtIndexPath:(G100IndexPath *)indexPath
{
    if (indexPath.column == 0) {
        id tmp = self.cityDistricts[indexPath.row];
        if ([tmp isKindOfClass:[NSString class]]) {
            return tmp;
        }else {
            G100ServiceCityDistrictDomain *domain = (G100ServiceCityDistrictDomain *)tmp;
            return domain.district;
        }
    }else if (indexPath.column == 1) {
        return self.classifys[indexPath.row];
    }
    return nil;
}

- (G100DropDownMenuColomnStyle)menu:(G100DropDownMenu *)menu colomnStyleForColumn:(NSInteger)column
{
    if (column == 0) {
        return G100DropDownMenuColomnStyleDefault;
    }else if (column == 1) {
        return G100DropDownMenuColomnStyleMultiple;
    }
    return G100DropDownMenuColomnStyleDefault;
}

// new datasource

- (NSString *)menu:(G100DropDownMenu *)menu imageNameForRowAtIndexPath:(G100IndexPath *)indexPath
{
    if (indexPath.column == 0 || indexPath.column == 1) {
        
    }
    return nil;
}

- (NSString *)menu:(G100DropDownMenu *)menu imageNameForItemsInRowAtIndexPath:(G100IndexPath *)indexPath
{
    if (indexPath.column == 0 && indexPath.item >= 0) {
        
    }
    return nil;
}

// new datasource

- (NSString *)menu:(G100DropDownMenu *)menu detailTextForRowAtIndexPath:(G100IndexPath *)indexPath
{
    return nil;
}

- (BOOL)menu:(G100DropDownMenu *)menu detailButtonForRowAtIndexPath:(G100IndexPath *)indexPath
{
    if (indexPath.column == 1) {
        BOOL selected = [self.classifysXuanze[indexPath.row] boolValue];
        return selected;
    }
    
    return NO;
}

- (NSString *)menu:(G100DropDownMenu *)menu detailTextForItemsInRowAtIndexPath:(G100IndexPath *)indexPath
{
    return nil;
}

- (NSInteger)menu:(G100DropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column
{
    if (column == 0) {
        if (row == 0) {
            return self.distance.count;
        }
    }
    return 0;
}

- (NSString *)menu:(G100DropDownMenu *)menu titleForItemsInRowAtIndexPath:(G100IndexPath *)indexPath
{
    if (indexPath.column == 0) {
        if (indexPath.row == 0) {
            return self.distance[indexPath.item];
        }
    }
    return nil;
}

#pragma mark - G100DropDownMenuDelegate
- (void)menu:(G100DropDownMenu *)menu didSelectRowAtIndexPath:(G100IndexPath *)indexPath
{
    if (indexPath.item >= 0) {
        NSLog(@"点击了 %@ - %@ - %@ 项目",@(indexPath.column),@(indexPath.row),@(indexPath.item));
    }else {
        NSLog(@"点击了 %@ - %@ 项目",@(indexPath.column),@(indexPath.row));
    }
    
    if (indexPath.column == 0) {
        
        if (indexPath.item >= 0 && indexPath.row == 0) {
            _kSearchSortby = G100ShopSortbyModeDistance;
            if (indexPath.item == 0) {
                // 智能排序
                _kSearchSearchtype = G100ShopSearchModeAutomatic;
                _kSearchRadius = 10000;
            }else {
                _kSearchSearchtype = G100ShopSearchModeDistance;
                NSInteger distance = [self.distance[indexPath.item] integerValue];
                _kSearchRadius = distance;
            }
            self.currentCityCode = self.selectedModel.adcode;
            [self.contentTableView.mj_header beginRefreshing];
        }else if (indexPath.row > 0){
            // 区域筛选
            _kSearchSearchtype = G100ShopSearchModeArea;
            G100ServiceCityDistrictDomain * domain = self.cityDistricts[indexPath.row];
            self.currentCityCode = domain.adcode;
            [self.contentTableView.mj_header beginRefreshing];
        }
        
    }else if (indexPath.column == 1) {
        BOOL selected = [self.classifysXuanze[indexPath.row] boolValue];
        selected = !selected;
        [self.classifysXuanze replaceObjectAtIndex:indexPath.row withObject:@(selected)];
        
        [menu refreshData];
    }
}

- (void)menu:(G100DropDownMenu *)menu resetFilter:(NSArray *)filter {
    self.classifysXuanze = [NSMutableArray arrayWithArray:@[@(YES), @(YES), @(YES)]];
    
    [menu refreshData];
}

- (void)menu:(G100DropDownMenu *)menu confirmFilter:(NSArray *)fileter {
    
    NSMutableArray * tttt = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.classifysXuanze.count; i++) {
        BOOL selected = [self.classifysXuanze[i] boolValue];
        if (selected) {
            [tttt addObject:@(i+1)];
        }
    }
    if (tttt.count > 0) {
        _kSearchType = tttt.copy;
    }else{
        _kSearchType= @[];
    }
    
    [self.contentTableView.mj_header beginRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"G100DiscoveryShopDetailCell";
    G100DiscoveryShopDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"G100DiscoveryShopDetailCell" owner:self options:nil]lastObject];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    G100ShopPlaceDomain *model = self.dataArray[indexPath.row];
    [cell setCellDataWithModel:model];
    
    cell.buttonClick = ^(G100ShopPlaceDomain *domain, ClickType type){
        
        if (type == ClickTypeAddress) {
            G100ShopMapViewController * shopMap = [[G100ShopMapViewController alloc] initWithNibName:@"G100ShopMapViewController" bundle:nil];
            
            shopMap.shopPlaceDomain = self.dataArray[indexPath.row];
            
            [self.navigationController pushViewController:shopMap animated:YES];
        }else if (type == ClickTypePhoneNum) {
            NSString *number = domain.phone_num;
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", number]]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", number]]];
            }else {
                MyAlertTitle(@"电话拨打失败");
            }
        }
    };
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

@end
