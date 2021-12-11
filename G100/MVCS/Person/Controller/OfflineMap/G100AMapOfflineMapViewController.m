//
//  G100AMapOfflineMapViewController.m
//  G100
//
//  Created by 温世波 on 15/11/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100AMapOfflineMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import "MAHeaderView.h"
#import "OfflineMapCityCell.h"
#import "MemoryCapacityView.h"

#import "EBOfflineMapService.h"
#import "MAGeoCodeResult.h"

#define kSectionHeaderMargin    15.f
#define kSectionHeaderHeight    44.f
#define kTableCellHeight        44.f

typedef enum {
    StateUnknown = 0,
    StateOn,
    StateOff
}LocatorState;

@interface G100AMapOfflineMapViewController () <UITableViewDataSource, UITableViewDelegate, MAHeaderViewDelegate, UIScrollViewDelegate, OfflineMapCityCellDelegate, MAMapViewDelegate, AMapSearchDelegate, EBOfflineMapServiceDelegate>
{
    UISegmentedControl *segmentedControl;
    LocatorState locatorState;
}

@property (nonatomic, strong) MAMapView           *mapView;
@property (nonatomic, strong) AMapSearchAPI       *search;

@property (nonatomic, strong) UIScrollView        *scrollView;
@property (nonatomic, strong) UITableView         *xiazaiTableView;
@property (nonatomic, strong) UITableView         *tableView;
@property (nonatomic, strong) MemoryCapacityView  *MCView;

@property (nonatomic, strong) NSArray             *sectionTitles;
@property (nonatomic, assign) BOOL                isAllow3GDownLoad;
@property (nonatomic, assign) BOOL                isClear;

@property (nonatomic, strong) NSMutableArray      *arraylocalDownLoadMapInfo; //本地下载的离线地图
@property (nonatomic, strong) NSArray             *arrayCurrentCityData; //当前城市
@property (nonatomic, strong) NSMutableArray      *arrayExpandedSections; //存储section的开关

@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *municipalities;

@property (nonatomic, strong) NSMutableSet *downloadingItems;
@property (nonatomic, strong) NSMutableDictionary *downloadStages;

@property (nonatomic, assign) BOOL needReloadWhenDisappear;

@property (nonatomic, strong) EBOfflineMapService *ebservice;

@end

@implementation G100AMapOfflineMapViewController

@synthesize mapView   = _mapView;
@synthesize tableView = _tableView;
@synthesize sectionTitles = _sectionTitles;
@synthesize isAllow3GDownLoad = _isAllow3GDownLoad;

@synthesize provinces = _provinces;
@synthesize municipalities = _municipalities;

@synthesize downloadingItems = _downloadingItems;
@synthesize downloadStages = _downloadStages;

@synthesize needReloadWhenDisappear = _needReloadWhenDisappear;

- (void)checkNewestVersionAction
{
    [[MAOfflineMap sharedOfflineMap] checkNewestVersion:^(BOOL hasNewestVersion) {
        
        if (!hasNewestVersion)
        {
            /* Manipulations to your application's user interface must occur on the main thread. */
            dispatch_async(dispatch_get_main_queue(), ^{
                [[EBOfflineMapTool sharedManager] resume];
            });
            
            return;
        }
        
        /* Manipulations to your application's user interface must occur on the main thread. */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self setupCities];
            
            [self.tableView reloadData];
            
            [[EBOfflineMapTool sharedManager] resume];
        });
    }];
}

- (EBOfflineMapService *)ebservice {
    if (!_ebservice) {
        _ebservice = [[EBOfflineMapService alloc] init];
        _ebservice.delegate = self;
    }
    return _ebservice;
}

#pragma mark - Utility

- (UIButton *)downloadButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60.f, 40.f)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (NSIndexPath *)indexPathForSender:(id)sender event:(UIEvent *)event
{
    UIButton *button = (UIButton*)sender;
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![button pointInside:[touch locationInView:button] withEvent:event])
    {
        return nil;
    }
    
    CGPoint touchPosition = [touch locationInView:self.tableView];
    
    return [self.tableView indexPathForRowAtPoint:touchPosition];
}

- (NSString *)cellLabelTextForItem:(MAOfflineItem *)oneCity
{
    NSString *labelText = nil;
    
    if (![self.downloadingItems containsObject:oneCity]) {
        switch (oneCity.itemStatus) {
            case MAOfflineItemStatusInstalled:
            {
                labelText = @"(已安装)";
            }
                break;
            case MAOfflineItemStatusExpired:
            {
                labelText = @"(有更新)";
            }
                break;
            case MAOfflineItemStatusCached:
            {
                labelText = @"(已暂停)";
            }
                break;
            default:
                break;
        }
    }else {
        // 下载中
        NSMutableDictionary *stage  = [self.downloadStages objectForKey:oneCity.adcode];
        
        MAOfflineMapDownloadStatus status = [[stage objectForKey:EBOfflineMapToolDownloadStageStatusKey] intValue];
        
        switch (status)
        {
            case MAOfflineMapDownloadStatusWaiting:
            {
                labelText = @"(等待下载)";
                
                break;
            }
            case MAOfflineMapDownloadStatusStart:
            {
                labelText = @"(开始下载)";
                
                break;
            }
            case MAOfflineMapDownloadStatusProgress:
            {
                labelText = @"(正在下载)";
                
                break;
            }
            case MAOfflineMapDownloadStatusCompleted:
            {
                labelText = @"(下载完成)";
                
                break;
            }
            case MAOfflineMapDownloadStatusCancelled:
            {
                labelText = @"(下载取消)";
                
                break;
            }
            case MAOfflineMapDownloadStatusUnzip:
            {
                labelText = @"(正在解压)";
                
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                labelText = @"(已安装)";
                
                break;
            }
            default:
            {
                labelText = @"(错误)";
                
                break;
            }
        } // end switch
    }
    
    return labelText;
}

- (CGFloat)cellProgressForItem:(MAOfflineItem *)oneCity {
    
    CGFloat progress = 0.0;
    if (oneCity.size != 0) {
        progress = oneCity.downloadedSize / 1.0 / oneCity.size;
    }else {
        progress = 0;
    }
    
    switch (oneCity.itemStatus) {
        case MAOfflineItemStatusNone:
        {
            progress = 0;
            
            break;
        }
        case MAOfflineItemStatusCached:
        {
            
            break;
        }
        case MAOfflineItemStatusInstalled:
        {
            progress = 0.0;
            
            break;
        }
        case MAOfflineItemStatusExpired:
        {
            progress = 0.0;
            
            break;
        }
            
        default:
            break;
    }
    
    if (![self.downloadingItems containsObject:oneCity]) {
        // 无
        
    } else {
        NSMutableDictionary *stage  = [self.downloadStages objectForKey:oneCity.adcode];
        
        MAOfflineMapDownloadStatus status = [[stage objectForKey:EBOfflineMapToolDownloadStageStatusKey] intValue];
        
        switch (status)
        {
            case MAOfflineMapDownloadStatusWaiting:
            {
                
                break;
            }
            case MAOfflineMapDownloadStatusStart:
            {
                
                break;
            }
            case MAOfflineMapDownloadStatusProgress:
            {
                NSDictionary *progressDict = [stage objectForKey:EBOfflineMapToolDownloadStageInfoKey];
                
                long long recieved = [[progressDict objectForKey:MAOfflineMapDownloadReceivedSizeKey] longLongValue];
                long long expected = [[progressDict objectForKey:MAOfflineMapDownloadExpectedSizeKey] longLongValue];
                
                if (expected != 0) {
                    progress = recieved / 1.0 / (float)expected;
                }else {
                    progress = 0.0;
                }
                
                break;
            }
            case MAOfflineMapDownloadStatusCompleted:
            {
                progress = 1.0;
                
                break;
            }
            case MAOfflineMapDownloadStatusCancelled:
            {

                break;
            }
            case MAOfflineMapDownloadStatusUnzip:
            {
                progress = 1.0;
                
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                progress = 1.0;
                
                break;
            }
            default:
            {
                
                break;
            }
        } // end switch
        
    }
    
    return progress;
}

- (void)updateUIForItem:(MAOfflineItem *)item atIndexPath:(NSIndexPath *)indexPath
{
    OfflineMapCityCell * cell = (OfflineMapCityCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    if (cell != nil) {
        [self updateCell:cell forItem:item];
    }
}

- (void)updateAccessoryViewForCell:(OfflineMapCityCell *)cell item:(MAOfflineItem *)oneCity
{
    UIButton *btn = cell.statusButton;
    
    if (![self.downloadingItems containsObject:oneCity]) {
        if (oneCity.itemStatus == MAOfflineItemStatusInstalled) {
            btn.hidden = YES;
        }else {
            btn.hidden = NO;
        }
        
        switch (oneCity.itemStatus) {
            case MAOfflineItemStatusNone:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download"] forState:UIControlStateNormal];
                
                break;
            }
            case MAOfflineItemStatusCached:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download_start"] forState:UIControlStateNormal];
                
                break;
            }
            case MAOfflineItemStatusInstalled:
            {
                btn.hidden = YES;
                
                break;
            }
            case MAOfflineItemStatusExpired:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download"] forState:UIControlStateNormal];
                
                break;
            }
                
            default:
                break;
        }
    }else {
        // 下载中
        NSMutableDictionary *stage  = [self.downloadStages objectForKey:oneCity.adcode];
        
        MAOfflineMapDownloadStatus status = [[stage objectForKey:EBOfflineMapToolDownloadStageStatusKey] intValue];
        
        btn.hidden = NO;
        
        switch (status)
        {
            case MAOfflineMapDownloadStatusWaiting:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download"] forState:UIControlStateNormal];
                
                break;
            }
            case MAOfflineMapDownloadStatusStart:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download_stop"] forState:UIControlStateNormal];
                
                break;
            }
            case MAOfflineMapDownloadStatusProgress:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download_stop"] forState:UIControlStateNormal];
                
                break;
            }
            case MAOfflineMapDownloadStatusCompleted:
            {
                btn.hidden = YES;
                
                break;
            }
            case MAOfflineMapDownloadStatusCancelled:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download"] forState:UIControlStateNormal];
                
                break;
            }
            case MAOfflineMapDownloadStatusUnzip:
            {
                btn.hidden = YES;
                
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                btn.hidden = YES;
                
                break;
            }
            default:
            {
                [btn setImage:[UIImage imageNamed:@"ic_map_download"] forState:UIControlStateNormal];
                
                break;
            }
        } // end switch
    }
}

- (void)updateCell:(OfflineMapCityCell *)cell forItem:(MAOfflineItem *)oneCity
{
    if (oneCity) {
        
        cell.sizeLabel.hidden = NO;
        cell.statusButton.hidden = NO;
        cell.statusLabel.hidden = NO;
        
        cell.cityLabel.text = oneCity.name;
        
        cell.sizeLabel.text = [NSString stringWithFormat:@"(%@)", [self getDataSizeString:oneCity.size]];
        
        [self updateAccessoryViewForCell:cell item:oneCity];    // 更新button状态
        
        cell.statusLabel.text = [self cellLabelTextForItem:oneCity];
        
        cell.xiazaiProgress.progress = [self cellProgressForItem:oneCity];
    }else{
        switch (locatorState) {
            case 0:
                cell.cityLabel.text = @"";
                cell.sizeLabel.hidden = YES;
                cell.statusButton.hidden = YES;
                cell.statusLabel.hidden = YES ;
                break;
            case 1:
                cell.cityLabel.text = @"定位中...";
                cell.sizeLabel.hidden = YES;
                cell.statusButton.hidden = YES;
                cell.statusLabel.hidden = YES;
                break;
            case 2:
                cell.cityLabel.text = @"定位失败";
                cell.sizeLabel.hidden = YES;
                cell.statusButton.hidden = YES;
                cell.statusLabel.hidden = YES;
                break;
            default:
                break;
        }
    }
}

#pragma mark -- EBOfflineMapServiceDelegate

- (void)mapTool:(EBOfflineMapTool *)tool didFinishedItem:(MAOfflineItem *)downloadItem {
    self.needReloadWhenDisappear = YES;
    
    [self.MCView updateMCViewWithFrame:self.contentView.bounds];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        [self setupYixiazaiData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.xiazaiTableView reloadData];
        });
    });
}

- (void)mapTool:(EBOfflineMapTool *)tool downloadingItem:(MAOfflineItem *)downloadItem downloadItems:(NSMutableSet *)downloadItems option:(NSMutableDictionary *)downloadStages info:(id)info {
    _downloadingItems = downloadItems;
    _downloadStages = downloadStages;

    //更新触发下载操作的item涉及到的UI 刷新所有可见的
    NSArray * cellArray = [self.tableView visibleCells];
    for (OfflineMapCityCell * tmp in cellArray) {
        if ([tmp.sItem.adcode isEqualToString:downloadItem.adcode]) {
            [self updateUIForItem:tmp.sItem atIndexPath:tmp.indexPath];
        }
    }
}

- (void)download:(MAOfflineItem *)oneCity atIndexPath:(NSIndexPath *)indexPath
{
    [[EBOfflineMapTool sharedManager] downloadOfflineMapWithAdcode:oneCity.adcode downloadType:EBOfflineItemDownloadTypeDefault];
}

- (void)pause:(MAOfflineItem *)oneCity atIndexPath:(NSIndexPath *)indexPath
{
    [[EBOfflineMapTool sharedManager] pauseWithAdcode:oneCity.adcode];
    self.needReloadWhenDisappear = YES;
}

- (void)deleteItem:(MAOfflineItem *)oneCity {
    [[EBOfflineMapTool sharedManager] deleteWithAdcode:oneCity.adcode];
    self.needReloadWhenDisappear = YES;
}

- (void)handleItemAtIndexPath:(NSIndexPath *)indexPath
{
    MAOfflineItem *oneCity = [self itemForIndexPath:indexPath];
    
    if (oneCity == nil)
    {
        return;
    }
    
    if ([[MAOfflineMap sharedOfflineMap] isDownloadingForItem:oneCity])
    {
        [self pause:oneCity atIndexPath:indexPath];
    }
    else
    {
        if (!kNetworkNotReachability) {
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
                if (self.isAllow3GDownLoad) {
                    [self download:oneCity atIndexPath:indexPath];
                }else {
                    G100MAlertTitleWithBlock(@"建议在WIFI环境下载离线地图包", ^{
                        self.isAllow3GDownLoad = YES;
                        [self download:oneCity atIndexPath:indexPath];
                    });
                }
            }else {
                [self download:oneCity atIndexPath:indexPath];
            }
        }else {
            [self showHint:kError_Network_NotReachable];
        }
    }
}

- (MAOfflineItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    MAOfflineItem *oneCity = nil;
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (self.arrayCurrentCityData.count) {
                oneCity = self.arrayCurrentCityData[0];
            }
            
            break;
        }
        case 1:
        {
            oneCity = [[MAOfflineMap sharedOfflineMap] nationWide];
            break;
        }
        case 2:
        {
            oneCity = self.municipalities[indexPath.row];
            break;
        }
        default:
        {
            MAOfflineProvince *pro = self.provinces[indexPath.section - self.sectionTitles.count];
            
            oneCity = pro.cities[indexPath.row];
        }
            break;
    }
    
    return oneCity;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _xiazaiTableView) {
        return 0.01;
    }
    
    return kSectionHeaderHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 54;
    
    /*
    MAOfflineItem *oneCity = [self itemForIndexPath:indexPath];
    
    if (![[EBOfflineMapTool sharedManager].downloadingItems containsObject:oneCity]) {
        switch (oneCity.itemStatus) {
            case MAOfflineItemStatusInstalled:
            {
                return kTableCellHeight;
            }
                break;
            case MAOfflineItemStatusExpired:
            {
                return kTableCellHeight;
            }
                break;
            case MAOfflineItemStatusCached:
            {
                return 54;
            }
                break;
            default:
                break;
        }
    }else {
        // 下载中
        NSMutableDictionary *stage  = [[EBOfflineMapTool sharedManager].downloadStages objectForKey:oneCity.adcode];
        
        MAOfflineMapDownloadStatus status = [[stage objectForKey:EBOfflineMapToolDownloadStageStatusKey] intValue];
        
        switch (status)
        {
            case MAOfflineMapDownloadStatusWaiting:
            {
                return 54;
                
                break;
            }
            case MAOfflineMapDownloadStatusStart:
            {
                return 54;
                
                break;
            }
            case MAOfflineMapDownloadStatusProgress:
            {
                return 54;
                
                break;
            }
            case MAOfflineMapDownloadStatusCompleted:
            {
                return kTableCellHeight;
                
                break;
            }
            case MAOfflineMapDownloadStatusCancelled:
            {
                return kTableCellHeight;
                
                break;
            }
            case MAOfflineMapDownloadStatusUnzip:
            {
                return kTableCellHeight;
                
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                return kTableCellHeight;
                
                break;
            }
            default:
            {
                return kTableCellHeight;
                
                break;
            }
        } // end switch
    }
    
    return kTableCellHeight;
     */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _xiazaiTableView) {
        return 1;
    }
    
    return self.sectionTitles.count + self.provinces.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _xiazaiTableView) {
        return _arraylocalDownLoadMapInfo.count;
    }
    
    NSInteger number = 0;
    
    switch (section)
    {
        case 0:
        {
            if ([_arrayExpandedSections[section] boolValue])
            {
                number = 1;
            }
            break;
        }
        case 1:
        {
            if ([_arrayExpandedSections[section] boolValue])
            {
                number = 1;
            }
            break;
        }
        case 2:
        {
            if ([_arrayExpandedSections[section] boolValue])
            {
                number = self.municipalities.count;
            }
            break;
        }
        default:
        {
            if ([_arrayExpandedSections[section] boolValue])
            {
                MAOfflineProvince *pro = self.provinces[section - self.sectionTitles.count];
                // 不包含全省地图
                number = pro.cities.count - 1;
            }
            break;
        }
    }
    
    return number;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _xiazaiTableView) {
        return nil;
    }
    
    NSString *theTitle = nil;
    
    if (section < self.sectionTitles.count)
    {
        theTitle = self.sectionTitles[section];
        
        MAHeaderView *headerView = [[MAHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), kTableCellHeight) expanded:[_arrayExpandedSections[section] boolValue] section:section];
        
        headerView.section = section;
        headerView.text = theTitle;
        headerView.delegate = self;
        return headerView;
    }
    else
    {
        MAOfflineItem *pro = self.provinces[section - self.sectionTitles.count];
        theTitle = pro.name;
        
        MAHeaderView *headerView = [[MAHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), kTableCellHeight) expanded:[_arrayExpandedSections[section] boolValue] section:section];
        
        headerView.section = section;
        headerView.text = theTitle;
        headerView.delegate = self;
        
        return headerView;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _xiazaiTableView) {
        static NSString *yixiazaicell = @"yixiazaicell";
        OfflineMapCityCell * yixiazaiCell = [tableView dequeueReusableCellWithIdentifier:yixiazaicell];
        if (yixiazaiCell == nil) {
            yixiazaiCell = [[[NSBundle mainBundle]loadNibNamed:@"OfflineMapCityCell" owner:self options:nil]firstObject];
        }
        
        yixiazaiCell.delegate = self;
        yixiazaiCell.indexPath = indexPath;
        MAOfflineItem *oneCity = [_arraylocalDownLoadMapInfo safe_objectAtIndex:indexPath.row];
        [yixiazaiCell showYixiazaiCityWithItem:oneCity];
        
        return yixiazaiCell;
    }else {
        static NSString *cityCellIdentifier = @"offlineMapCityCell";
        OfflineMapCityCell *cell = [tableView dequeueReusableCellWithIdentifier:cityCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"OfflineMapCityCell" owner:self options:nil]lastObject];
        }
        
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        [cell.statusButton addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        
        MAOfflineItem *oneCity = [self itemForIndexPath:indexPath];
        
        cell.sItem = oneCity;
        [self updateCell:cell forItem:oneCity];
        
        return cell;
    }
}

//表的行选择操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(tableView == _xiazaiTableView)
    {
        
    }
    else
    {
        if (0 == indexPath.section && 0 == indexPath.row && locatorState == 2) {
            if (ISIOS8ADD) {
                [MyAlertView MyAlertWithTitle:@"打开定位开关"
                                      message:@"定位服务未开启，请进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许骑卫士使用定位服务"
                                     delegate:self
                             withMyAlertBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }
                            cancelButtonTitle:@"取消"
                            otherButtonTitles:@"立即开启"];
            } else {
                [MyAlertView MyAlertWithTitle:@"打开定位开关"
                                      message:@"定位服务未开启，请进入系统【设置】>【隐私】>【定位服务】中打开开关，并允许骑卫士使用定位服务"
                                     delegate:self
                             withMyAlertBlock:nil
                            cancelButtonTitle:nil
                            otherButtonTitles:@"我知道了"];
            }
            
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(OfflineMapCityCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _xiazaiTableView) {
        return;
    }
    
    if (indexPath.section < self.sectionTitles.count)
    {
        cell.backgroundColor = MyBackColor;
    }
    else
    {
        cell.backgroundColor = MyBackColor;
    }
}

#pragma mark - 定位当前城市
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    self.mapView.showsUserLocation = NO;
    
    if (kCLErrorDenied == error.code) {
        //未打开定位功能
        locatorState = StateOff;
    }else if (kCLErrorLocationUnknown == error.code) {
        //信号差
        [MyAlertView MyAlertWithTitle:@"GPS信号弱或无GPS信号"
                              message:@"请移步空旷的地方重新尝试"
                             delegate:self
                     withMyAlertBlock:nil
                    cancelButtonTitle:nil
                    otherButtonTitles:@"我知道了"];
    }
    
    [self.tableView reloadData];
}
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    self.mapView.showsUserLocation = NO;
    locatorState = StateOn;
    
    // 查询当前位置信息
    if (updatingLocation) {
        [self onClickReverseAMMapGeocode:userLocation.location.coordinate];
    }
}
#pragma mark - 高德逆地址编码
-(void)onClickReverseAMMapGeocode:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    request.requireExtension = YES;
    
    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc]init];
    }
    
    self.search.delegate = self;
    [self.search AMapReGoecodeSearch:request];
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    MAGeoCodeResult *geo = [MAGeoCodeResult instance];
    
    if (response) {
        geo.result = response;
        
        NSString * adcode = response.regeocode.addressComponent.adcode;
        
        // 确保添加到数组中的数据不是nil
        if ([[EBOfflineMapTool sharedManager] searchCityWithAdcode:adcode]) {
            MAOfflineItem *item = [[EBOfflineMapTool sharedManager] searchCityWithAdcode:adcode];
            if (item != nil) {
                self.arrayCurrentCityData = @[ item ];
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark 包大小转换工具类（将包大小转换成合适单位）
-(NSString *)getDataSizeString:(long long) nSize
{
    NSString *string = nil;
    if (nSize<1024)
    {
        string = [NSString stringWithFormat:@"%lldB", nSize];
    }
    else if (nSize<1048576)
    {
        string = [NSString stringWithFormat:@"%lldK", (nSize/1024)];
    }
    else if (nSize<1073741824)
    {
        if ((nSize%1048576)== 0 )
        {
            string = [NSString stringWithFormat:@"%lldM", nSize/1048576];
        }
        else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%lldMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%lld.%@M", nSize/1048576, decimalStr];
            }
        }
    }
    else	// >1G
    {
        string = [NSString stringWithFormat:@"%lldG", nSize/1073741824];
    }
    
    return string;
}

#pragma mark - 地图更新和删除的代理方法
- (void)buttonClickEventForAMapDelegate:(MAOfflineItem *)oneCity indexPath:(NSIndexPath *)indexPath buttonStyle:(ButtonStyle)buttonStyle {
    if (buttonStyle == DeleteCityMap) {
        //删除指定城市id的离线地图
        [self deleteItem:oneCity];
        
        // clear
        [self.downloadingItems removeObject:oneCity];
        [self.downloadStages removeObjectForKey:oneCity.adcode];
        
        //将此城市的离线地图信息从数组中删除
        [(NSMutableArray*)_arraylocalDownLoadMapInfo removeObjectAtIndex:indexPath.row];
        [_xiazaiTableView reloadData];
        
        [self.MCView updateMCViewWithFrame:self.view.bounds];
    }else if (buttonStyle == UpdateCityMap) {
        if (!kNetworkNotReachability) {
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
                if (self.isAllow3GDownLoad) {
                    [self download:oneCity atIndexPath:indexPath];
                }else {
                    G100MAlertTitleWithBlock(@"建议在WIFI环境下载离线地图包", ^{
                        self.isAllow3GDownLoad = YES;
                        [self download:oneCity atIndexPath:nil];
                    });
                }
            }else {
                [self download:oneCity atIndexPath:indexPath];
            }
        }else {
            [self showHint:kError_Network_NotReachable];
        }
    }
    
    [self.MCView updateMCViewWithFrame:self.view.bounds];
}

#pragma mark - MAHeaderViewDelegate

- (void)headerView:(MAHeaderView *)headerView section:(NSInteger)section expanded:(BOOL)expanded
{
    _arrayExpandedSections[section] = @(expanded);
    
    _arrayExpandedSections[0] = @YES;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    CGRect rect = [_tableView rectForFooterInSection:section];
    rect.origin.y -= kSectionHeaderHeight;
    
    CGFloat conffsetY = _tableView.contentOffset.y;
    if (rect.origin.y < conffsetY) {
        // 关闭某一组后   置顶
        _tableView.contentOffset = rect.origin;
    }
}

#pragma mark - Handle Action
- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSIndexPath *indexPath = [self indexPathForSender:sender event:event];
    
    [self handleItemAtIndexPath:indexPath];
}

- (void)noti_offlineMapViewAppDidBecameActive:(NSNotification *)noti {
    self.mapView.showsUserLocation = YES;
}

#pragma mark - Initialization
-(void)segSelected:(UISegmentedControl *)seg {
    if (seg.selectedSegmentIndex == 0) {
        _scrollView.contentOffset = CGPointMake(0, 0);
        [_tableView reloadData];
    }else {
        _scrollView.contentOffset = CGPointMake(_scrollView.v_width, 0);
        [self setupYixiazaiData];
        [_xiazaiTableView reloadData];
    }
}

#pragma mark - scrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        if (_scrollView.contentOffset.x >= _scrollView.v_width / 2.0f) {
            segmentedControl.selectedSegmentIndex = 1;
            
            [_tableView reloadData];
        }else {
            segmentedControl.selectedSegmentIndex = 0;
            
            [self setupYixiazaiData];
            [_xiazaiTableView reloadData];
        }
    }
}
- (void)initTableView
{
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // 两个tableview
    segmentedControl = [[UISegmentedControl alloc]initWithItems:@[ @"城市列表", @"已下载" ]];
    segmentedControl.frame = CGRectMake(20, 10, self.view.v_width - 40, 30);
    segmentedControl.selectedSegmentIndex = 0;
    // segmentedControl.segmentedControlStyle= UISegmentedControlStyleBar;//设置
    segmentedControl.tintColor= [UIColor colorWithRed:250.0f / 255.0f green:181.0f / 255.0f blue:74.0f / 255.0f alpha:1.0f];
    
    [segmentedControl setTitleTextAttributes:@{
                                               NSForegroundColorAttributeName:[UIColor whiteColor],
                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16.0f]
                                               } forState:UIControlStateSelected];
    
    [segmentedControl setTitleTextAttributes:@{
                                               NSForegroundColorAttributeName:[UIColor colorWithRed:250.0f / 255.0f green:181.0f / 255.0f blue:74.0f / 255.0f alpha:1.0f],
                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16.0f]
                                               } forState:UIControlStateNormal];
    
    [segmentedControl addTarget:self action:@selector(segSelected:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:segmentedControl];
    
    self.MCView = [[MemoryCapacityView alloc] initWithFrame:self.contentView.bounds];
    self.MCView.v_top -= kBottomPadding;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, segmentedControl.v_bottom + 10, WIDTH, self.contentView.v_height - segmentedControl.v_bottom - 10 - self.MCView.v_height - kBottomPadding)];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.scrollEnabled = NO;
    _scrollView.contentSize = CGSizeMake(WIDTH * 2, self.scrollView.v_height);
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.contentView addSubview:_scrollView];
    [self.contentView addSubview:_MCView];
    
    self.isAllow3GDownLoad = NO;        // default不允许使用流量下载
    
    self.xiazaiTableView = [[UITableView alloc] initWithFrame:CGRectMake(_scrollView.v_width, 0, _scrollView.v_width, _scrollView.v_height) style:UITableViewStylePlain];
    self.xiazaiTableView.delegate   = self;
    self.xiazaiTableView.dataSource = self;
    self.xiazaiTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.xiazaiTableView.backgroundColor = MyBackColor;
    
    [self.scrollView addSubview:self.xiazaiTableView];
    
    // 城市列表back
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.v_width, _scrollView.v_height)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, backView.v_width, 30)];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = MyBackColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"下载离线地图在使用地图相关功能时候可节省90%流量";
    label.adjustsFontSizeToFitWidth = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, backView.v_width, backView.v_height) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = label;
    
    [backView addSubview:self.tableView];
    [self.scrollView addSubview:backView];
}

- (void)setupCities
{
    self.mapView = [[MAMapView alloc] init];
    
    self.search  = [[AMapSearchAPI alloc] init];
    
    self.sectionTitles = @[ @"当前城市", @"全国", @"热门城市" ];
    
    self.provinces = [[MAOfflineMap sharedOfflineMap] provinces];
    self.municipalities = [[MAOfflineMap sharedOfflineMap] municipalities];
    
    self.downloadingItems = [NSMutableSet set];
    self.downloadStages = [NSMutableDictionary dictionary];
    
    if (!_arrayExpandedSections) {
        self.arrayExpandedSections = [[NSMutableArray alloc] init];
        for (int i = 0; i < (self.sectionTitles.count + self.provinces.count); i++) {
            if (i == 0) {
                [_arrayExpandedSections addObject:@YES];
            }else {
                [_arrayExpandedSections addObject:@NO];
            }
        }
    }
}

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self)
    {
        self.isClear = NO;
        
        [self setupCities];
        
        [self setupYixiazaiData];
        
        locatorState = StateOn;
    }
    
    return self;
}

-(void)setupYixiazaiData {
    // 获取所有城市 判断下载状态
    NSArray * allCities = [[MAOfflineMap sharedOfflineMap] cities];

    NSMutableArray * yixiazaiArray = [[NSMutableArray alloc] init];
    
    // 全国地图
    MAOfflineItem * nationwide = [[MAOfflineMap sharedOfflineMap] nationWide];
    if (nationwide.itemStatus == MAOfflineItemStatusInstalled) {
        [yixiazaiArray addObject:nationwide];
    }
    
    [allCities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MAOfflineItem * item = (MAOfflineItem *)obj;
        //
        if (item.itemStatus == MAOfflineItemStatusInstalled) {
            [yixiazaiArray addObject:item];
        }
    }];
    
    self.arraylocalDownLoadMapInfo = [NSMutableArray arrayWithArray:yixiazaiArray];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavigationTitle:@"离线地图"];
    
    [self initTableView];

    [self ebservice];
    
    // 检查新版本
    [self checkNewestVersionAction];
    
    // 监听程序激活的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_offlineMapViewAppDidBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.mapView.delegate = self;
    self.search.delegate = self;

    self.mapView.distanceFilter = 50;
    self.mapView.showsUserLocation = YES;

    APPDELEGATE.showNetChangedHUD = NO;
    [EBOfflineMapTool sharedManager].showHUD = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.mapView.showsUserLocation = NO;
    
    APPDELEGATE.showNetChangedHUD = YES;
    [EBOfflineMapTool sharedManager].showHUD = NO;
    
    // 不刷新也没问题 刷新高概率崩溃
    if (self.needReloadWhenDisappear)
    {
        self.needReloadWhenDisappear = NO;
    }
    
    self.mapView.delegate = nil;
    self.search.delegate = nil;
}

- (void)dealloc {
    _ebservice.delegate = nil;
    DLog(@"离线地图页面已释放");
}

@end

