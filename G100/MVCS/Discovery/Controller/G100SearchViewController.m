//
//  G100SearchViewController.m
//  G100
//
//  Created by 天奕 on 15/12/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100SearchViewController.h"
#import "G100SearchView.h"
#import "G100SearchHelper.h"
#import "G100LocationResultManager.h"

#import "G100ShopApi.h"
#import "G100ShopDomain.h"
#import "G100DiscoveryShopDetailCell.h"

#import "G100ShopMapViewController.h"

static NSInteger const SearchHistoryTableTag   = 100;
static NSInteger const SearchShopPlaceTableTag = 200;

@interface G100SearchViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource> {
    NSArray * _kSearchType; //!< 店铺类型
    NSInteger _kSearchRadius;
    NSInteger _kSearchPageSize;
    NSInteger _kSearchPageNum;
    NSString * _commitStr;
}

@property (assign, nonatomic) BOOL hasClickSearch;
@property (weak, nonatomic) IBOutlet UIView *searchContentView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
/*
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHighContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewLowConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
- (IBAction)cancelSearch:(UIButton *)sender;
*/
@property (strong, nonatomic) G100SearchView *searchView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) MJRefreshAutoNormalFooter *footer;

- (IBAction)back:(id)sender;


@end

@implementation G100SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarView.hidden = YES;
    
    self.hasClickSearch = NO;
    
    [self initializationData];
    
    self.searchView = [[G100SearchView alloc]initWithEnableClick:YES];
    [self.searchContentView addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(@0);
        make.trailing.and.leading.equalTo(@0);
    }];
    __weak G100SearchViewController *wself = self;
    self.searchView.commitSearchContent = ^(NSString *commitStr){
        _commitStr = commitStr;
        //处理搜索结果
        wself.hasClickSearch = YES;
        
        [wself.dataArray removeAllObjects];
        [wself getCurrentCityDataWithTextFieldResult:commitStr];
        
        [[G100SearchHelper shareInstance]updateSearchResultWithKey:@"discovery" andResult:commitStr];
        [wself.contentTableView reloadData];
    };
    self.searchView.clearEditing = ^(){
        [wself setHasClickSearch:NO];
    };
    _footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _kSearchPageNum++;
        [self getCurrentCityDataWithTextFieldResult:_commitStr];
    }];
    self.searchResultTableView.mj_footer = self.footer;
    
    self.searchResultTableView.emptyDataSetDelegate = self;
    self.searchResultTableView.emptyDataSetSource = self;
    self.searchResultTableView.tableFooterView = [UIView new];
    
    self.contentTableView.emptyDataSetDelegate = self;
    self.contentTableView.emptyDataSetSource = self;
    self.contentTableView.tableFooterView = [UIView new];
}

- (void)initializationData {
    _kSearchType = @[@(1), @(2), @(3)];;
    _kSearchRadius = 200000;
    _kSearchPageSize = 10;
    _kSearchPageNum = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasAppear) {
        [self.searchView.searchTextFiled becomeFirstResponder];
        
        self.hasAppear = YES;
    }else {
        self.hasAppear = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getCurrentCityDataWithTextFieldResult:(NSString *)result {
    NSArray *locationArray = [G100LocationResultManager sharedInstance].locationResult.coordinate;
    NSString *cityCode = [G100LocationResultManager sharedInstance].locationInfo.adcode;
    
    NSArray *centralCity = @[@"11",@"12",@"31",@"50"];/* 北京 天津 上海 重庆 */
    NSString *newCityCode = @"";
    if ([centralCity containsObject:[cityCode substringToIndex:2]]) {/* 直辖市 */
        newCityCode = [[cityCode substringToIndex:2] stringByAppendingString:@"0000"];
    }else{
        newCityCode = [[cityCode substringToIndex:4] stringByAppendingString:@"00"];
    }
    
    [[G100ShopApi sharedInstance] searchPlaceWithSearchtype:G100ShopSearchModeKeyword
                                                   searchwd:result
                                                   location:locationArray
                                                     adcode:newCityCode
                                                       type:_kSearchType
                                                     sortby:G100ShopSortbyModeDistance
                                                   sorttype:G100ShopSorttypeDirectionAscend
                                                     radius:_kSearchRadius
                                                       page:_kSearchPageNum
                                                       size:_kSearchPageSize
                                                   callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
           if (requestSuccess) {
               if (!_dataArray) {
                   self.dataArray = [NSMutableArray array];
               }
               
               if (0 == response.total) {
                   ((MJRefreshAutoStateFooter*)self.searchResultTableView.mj_footer).stateLabel.hidden = YES;
                   [self.searchResultTableView.mj_footer endRefreshingWithNoMoreData];
                   
                   [self.dataArray removeAllObjects];
                   [self.contentTableView reloadData];
               }else {
                   ((MJRefreshAutoStateFooter*)self.searchResultTableView.mj_footer).stateLabel.hidden = NO;
                   [self.searchResultTableView.mj_footer resetNoMoreData];
                   
                   if (0 != response.subtotal) {
                       if (response.subtotal == _kSearchPageSize) {
                           ((MJRefreshAutoStateFooter*)self.searchResultTableView.mj_footer).stateLabel.hidden = NO;
                           [self.searchResultTableView.mj_footer resetNoMoreData];
                       }else{
                           [self.searchResultTableView.mj_footer endRefreshingWithNoMoreData];
                       }
                       NSArray *shopPlacesArray = [response.data objectForKey:@"places"];
                       for (NSDictionary *dict in shopPlacesArray) {
                           G100ShopPlaceDomain *placeDomain = [[G100ShopPlaceDomain alloc]initWithDictionary:dict];
                           [self.dataArray addObject:placeDomain];
                       }
                       [self.searchResultTableView reloadData];
                   }else {
                       ((MJRefreshAutoStateFooter*)self.searchResultTableView.mj_footer).stateLabel.hidden = YES;
                       [self.searchResultTableView.mj_footer endRefreshingWithNoMoreData];
                   }
               }
               
           }else{
               if (response) {
                   [self showHint:response.errDesc];
               }
           }
           
       }];
}

- (void)setHasClickSearch:(BOOL)hasClickSearch {
    _hasClickSearch = hasClickSearch;
    self.contentTableView.hidden = hasClickSearch;
}

- (void)clearSearchResult {
    [MyAlertView MyAlertWithTitle:@"清空记录" message:@"确定要清空搜索记录吗" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[G100SearchHelper shareInstance]removeSearchResultWithKey:@"discovery"];
            [self.contentTableView reloadData];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"清空"];
}

- (BOOL)hasSearchResult {
    if ([[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"].count > 0) {
        return YES;
    }
    return NO;
}
#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text;
    if (scrollView == self.contentTableView) {
        text = @"无历史搜索记录";
    }else if (scrollView == self.searchResultTableView) {
        text = @"没有找到相关店铺";
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView.tag == SearchHistoryTableTag) {
        return [[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"].count;
    }else if (tableView.tag == SearchShopPlaceTableTag) {
        return self.dataArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == SearchShopPlaceTableTag) {
        return 100;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == SearchHistoryTableTag) {
        static NSString *cellIdentifier = @"historycell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSInteger dataArrayCount = [[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"].count;
        cell.textLabel.text = [[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"][dataArrayCount - indexPath.row - 1];
        
        return cell;
    }else if (tableView.tag == SearchShopPlaceTableTag) {
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
    
    static NSString *cellIdentifier = @"historycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger dataArrayCount = [[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"].count;
    cell.textLabel.text = [[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"][dataArrayCount - indexPath.row - 1];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self hasSearchResult] && tableView.tag == SearchHistoryTableTag) {
        return 20.0;
    }
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self hasSearchResult] && tableView.tag == SearchHistoryTableTag) {
        return 36.0;
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self hasSearchResult] && tableView.tag == SearchHistoryTableTag) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 20)];
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(WidthInSmallest(12.0), 0, WIDTH, 20)];
        headerLabel.font = [UIFont systemFontOfSize:12.0f];
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.text = @"搜索历史";
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self hasSearchResult] && tableView.tag == SearchHistoryTableTag) {
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 36)];
        footerView.backgroundColor = [UIColor whiteColor];
        UIButton *clearBtn = [[UIButton alloc]init];
        [footerView addSubview:clearBtn];
        [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(@0);
            make.trailing.and.leading.equalTo(@0);
        }];
        [clearBtn setTitle:@"清除搜索记录" forState:UIControlStateNormal];
        [clearBtn setTitleColor:MyGreenColor forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearSearchResult) forControlEvents:UIControlEventTouchUpInside];
        return footerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == SearchHistoryTableTag) {
        // 搜索历史
        NSInteger dataArrayCount = [[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"].count;
        NSString *result = [[G100SearchHelper shareInstance] searchResultArrayWithKey:@"discovery"][dataArrayCount - indexPath.row - 1];
        
        _commitStr = result;
        self.hasClickSearch = YES;
        
        self.searchView.searchTextFiled.text = result;
        
        [self.dataArray removeAllObjects];
        
        [self getCurrentCityDataWithTextFieldResult:result];
        
    }else if (tableView.tag == SearchShopPlaceTableTag) {
        
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
