//
//  G100MyInsurancesViewController.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MyInsurancesViewController.h"
#import "G100MyInsuraceCell.h"
#import "G100InsurancesIntroduceCell.h"
#import "G100ScrollView.h"

#import "PingAnInsuranceModel.h"
#import "G100ActivityDomain.h"
#import "G100InsuranceOrder.h"
#import "G100GoodsApi.h"
#import "G100InsuranceApi.h"
#import "G100UrlManager.h"
#import "InsuranceCheckService.h"

#import "G100InsuranceContainerViewController.h"

@interface G100MyInsurancesViewController () <G100ScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) G100ScrollView *headerView;

@property (nonatomic, strong) NSMutableArray *activityArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) UIButton *rightPayButton;

@property (strong, nonatomic) G100InsuranceStatusPacks *insuranceStatusPacks;

@end

@implementation G100MyInsurancesViewController

- (void)dealloc
{
    _headerView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:@"我的保险"];
    [self configRightButton];
    [self initView];
    
    __weak G100MyInsurancesViewController * weakSelf = self;
    MJRefreshHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getPackageInfoWithShowHUD:NO];
        [weakSelf getActivityInfoWithShowHUD:NO];
        [[InsuranceCheckService sharedService] checkInsurancePacksWithUserid:weakSelf.userid complete:nil];
    }];
    
    header.lastUpdatedTimeKey = NSStringFromClass([self class]);
    self.tableView.mj_header = header;
    
    [self.KVOController observe:[InsuranceCheckService sharedService] keyPath:@"totalCount" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [weakSelf.tableView reloadData];
    }];
}

- (void)initView
{
    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    // iOS 11 UI 显示bug 修复
    if ([self.tableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.tableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [G100MyInsuraceCell registerToTabelView:self.tableView];
    [G100InsurancesIntroduceCell registerToTabelView:self.tableView];
}

-(void)configRightButton {
    _rightPayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightPayButton.frame = CGRectMake(0, 0, 80, 30);
    _rightPayButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_rightPayButton setTitle:@"理赔流程" forState:UIControlStateNormal];
    [_rightPayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightPayButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self setRightNavgationButton:_rightPayButton];
    _rightPayButton.enabled = YES;;
}

- (void)rightButtonClick
{
    if (kNetworkNotReachability) {
        [self showWarningHint:kError_Network_NotReachable];
        return;
    }
    
    NSString *claimUrl = [[G100UrlManager sharedInstance] getClaimProcessUrlWithUserid:self.userid];
    if (claimUrl && [G100Router canOpenURL:claimUrl]) {
        [G100Router openURL:claimUrl];
    }
}

- (void)getActivityInfoWithShowHUD:(BOOL)showHUd
{
    __block ApiRequest *request;
    __weak G100MyInsurancesViewController *wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself api_removeApiRequest:request];
        if (requestSuccess) {
            [wself.activityArr removeAllObjects];
            NSDictionary * result = [response.data objectForKey:@"list"];
            for (NSMutableDictionary *dict in result) {
                G100ActivityDomain *domain = [[G100ActivityDomain alloc] initWithDictionary:dict];
                [wself.activityArr addObject:domain];
            }
            
            if ([wself.activityArr count]) {
                NSMutableArray *result = [NSMutableArray arrayWithCapacity:wself.activityArr.count];
                
                for (G100ActivityDomain *domain in wself.activityArr) {
                    if (domain.picture.length) {
                        [result addObject:domain.picture];
                    }else {
                        [result addObject:@"insurance_ advertisement"];
                    }
                }
                
                wself.headerView.imageUrlArr = result.copy;
                wself.tableView.tableHeaderView = wself.headerView;
            }else {
                wself.headerView.imageUrlArr = nil;
                wself.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, wself.tableView.bounds.size.width, 3.0f)];
            }
        }
    };
    request = [[G100InsuranceApi sharedInstance] queryMyInsuranceActivity:callback];
    [self api_addApiRequest:request];
}

-(void)getPackageInfoWithShowHUD:(BOOL)showHUd {
    if (kNetworkNotReachability) {
        [self.tableView.mj_header endRefreshing];
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __block ApiRequest *request;
    __weak G100MyInsurancesViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself api_removeApiRequest:request];
        [wself.tableView.mj_header endRefreshing];
        if (showHUd) {
            [wself hideHud];
        }
        if (requestSuccess) {
            [wself.dataArray removeAllObjects];
            
            NSDictionary * result = [response.data objectForKey:@"prods"];
            if (!result.count || !result) {
                //[wself showHint:@"暂无保险"];
                return;
            }
            for (NSDictionary * dict in result) {
                PingAnInsuranceModel * model = [[PingAnInsuranceModel alloc] initWithDictionary:dict];
                [wself.dataArray addObject:model];
            }
            // 刷新label
            [wself.tableView reloadData];
        }
    };
    
    if (showHUd) {
        [self showHudInView:self.contentView hint:@"正在查询"];
    }
    
    request = [[G100GoodsApi sharedInstance] loadProductListWithType:@"2"  callback:callback];
    [self api_addApiRequest:request];
}

#pragma mark - tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, WIDTH, 29)];
        [titleLabel setText:@"我的保单"];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        [view addSubview:titleLabel];
        return view;
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else
    {
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        G100MyInsuraceCell *myInsuranceCell = [tableView dequeueReusableCellWithIdentifier:[G100MyInsuraceCell cellID]];
        __weak G100MyInsurancesViewController * weakself = self;
        
        myInsuranceCell.insuranceStatebtnClickBlock = ^(NSInteger tag){
            switch (tag) {
                case 1001:
                {
                    G100InsuranceContainerViewController *stateVC = [[G100InsuranceContainerViewController alloc] init];
                    stateVC.userid = weakself.userid;
                    stateVC.insuranceOrderType = InsuranceOrderWaitPay;
                    [weakself.navigationController pushViewController:stateVC animated:YES];
                }
                    break;
                case 1002:
                {
                    G100InsuranceContainerViewController *ensureVC = [[G100InsuranceContainerViewController alloc] init];
                    ensureVC.userid = weakself.userid;
                    ensureVC.insuranceOrderType = InsuranceOrderGuarantee;
                    [weakself.navigationController pushViewController:ensureVC animated:YES];
                }
                    break;
                case 1003:
                {
                    G100InsuranceContainerViewController *hisVC = [[G100InsuranceContainerViewController alloc] init];
                    hisVC.userid = weakself.userid;
                    hisVC.insuranceOrderType = InsuranceOrderExpired;
                    [weakself.navigationController pushViewController:hisVC animated:YES];
                }
                    break;
                default:
                    break;
            }
        };
        
        [myInsuranceCell updateStatusUI];
        myInsuranceCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return myInsuranceCell;
    } else {
        G100InsurancesIntroduceCell *insuraceIntroCell = [tableView dequeueReusableCellWithIdentifier:[G100InsurancesIntroduceCell cellID]];
        insuraceIntroCell.model = [self.dataArray safe_objectAtIndex:indexPath.row];
        insuraceIntroCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        insuraceIntroCell.freeBtnClickBlock = ^(PingAnInsuranceModel *model){
            if (model.action_url && [G100Router canOpenURL:model.action_url]) {
                [G100Router openURL:model.action_url];
            }
        };
        return insuraceIntroCell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PingAnInsuranceModel *model = [self.dataArray safe_objectAtIndex:indexPath.row];
    
    if (model.detail_url && [G100Router canOpenURL:model.detail_url]) {
        [G100Router openURL:model.detail_url];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 100;
    }
    return 170;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }
    return 8;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8;
}

#pragma mark - headerView deleagate
- (void)selectedScrollViewAtIndex:(NSInteger)index OnScrollView:(G100ScrollView *)scrollView
{
    G100ActivityDomain *activity = [self.activityArr safe_objectAtIndex:index];
    
    if (activity.url && [G100Router canOpenURL:activity.url]) {
        [G100Router openURL:activity.url];
    }
}

#pragma mark - Lazy load
- (NSMutableArray *)activityArr {
    if (!_activityArr) {
        _activityArr = [NSMutableArray array];
    }
    return _activityArr;
}

- (G100ScrollView *)headerView {
    if (!_headerView) {
        _headerView = [G100ScrollView createScrollViewWithFrame:CGRectMake(0, 0, WIDTH, 48.0/108.0*WIDTH) imagesArr:nil];
        _headerView.delegate = self;
    }
    return _headerView;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset =UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}

#pragma mark - Life cycle
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (self.hasAppear) {
        [self getPackageInfoWithShowHUD:NO];
    }
    else {
        [self getPackageInfoWithShowHUD:YES];
    }
    
    self.hasAppear = YES;
    [self getActivityInfoWithShowHUD:NO];
    [[InsuranceCheckService sharedService] checkInsurancePacksWithUserid:self.userid complete:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
