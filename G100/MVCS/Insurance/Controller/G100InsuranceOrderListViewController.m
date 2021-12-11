//
//  G100InsuranceOrderListViewController.m
//  G100
//
//  Created by yuhanle on 2017/8/7.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100InsuranceOrderListViewController.h"

#import "G100InsuranceApi.h"
#import "G100InsuranceOrder.h"

#import "G100InsuranceOrderCell.h"

@interface G100InsuranceOrderListViewController () <UITableViewDelegate, UITableViewDataSource, G100InsuranceOrderCellDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (strong, nonatomic) UITableView *orderTable;

@property (strong, nonatomic) NSMutableArray *orderArray;

@property (strong, nonatomic) G100InsuranceStatusPacks *insuranceStatusPacks;

@end

@implementation G100InsuranceOrderListViewController

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"717071"]};
    return [[NSAttributedString alloc] initWithString:@"暂无保单" attributes:attributes];
}
#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderArray.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *stateCellID = @"G100InsuranceOrderCell";
    G100InsuranceOrder *order = [self.orderArray safe_objectAtIndex:indexPath.row];
    
    G100InsuranceOrderCell *stateCell = (G100InsuranceOrderCell *)[tableView dequeueReusableCellWithIdentifier:stateCellID];
    if (!stateCell) {
        stateCell = [[[NSBundle mainBundle] loadNibNamed:@"G100InsuranceOrderCell" owner:self options:nil] lastObject];
    }
    
    stateCell.delegate = self;
    stateCell.insuranceOrder = order;
    
    return stateCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    G100InsuranceOrder *order = [self.orderArray safe_objectAtIndex:indexPath.row];
    
    NSString *openUrl = [NSString stringWithFormat:@"%@&qws_order_id=%@", order.detail_url, @(order.order_id)];
    if ([G100Router canOpenURL:openUrl]) {
        [G100Router openURL:openUrl];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - G100InsuranceOrderCellDelegate
- (void)insuranceOrderCell:(G100InsuranceOrderCell *)orderCell insuranceOrder:(G100InsuranceOrder *)order {
    NSString *openUrl = [NSString stringWithFormat:@"%@&qws_order_id=%@", order.action_url, @(order.order_id)];
    if ([G100Router canOpenURL:openUrl]) {
        [G100Router openURL:openUrl];
    }
}

#pragma mark - 获取数据
- (void)quereyOrderDataWithUserid:(NSString *)userid status:(NSArray *)status showHUD:(BOOL)showHUD {
    if (kNetworkNotReachability) {
        [self.orderTable.mj_header endRefreshing];
        [self showHint:kError_Network_NotReachable];
        [self.orderTable.mj_header endRefreshing];
        return;
    }
    
    __weak typeof(self) wself = self;
    [[G100InsuranceApi sharedInstance] queryInsuranceOrderWithUserid:userid status:status callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself.orderTable.mj_header endRefreshing];
        [wself hideHud];
        
        if (requestSuccess) {
            [wself.orderArray removeAllObjects];
            
            wself.insuranceStatusPacks = [[G100InsuranceStatusPacks alloc] initWithDictionary:response.data];
            
            for (G100InsuranceStatusPack *pack in wself.insuranceStatusPacks.list) {
                [wself.orderArray addObjectsFromArray:pack.orderlist];
            }
            
            wself.orderArray = [wself.orderArray sortedArrayUsingComparator:^NSComparisonResult(G100InsuranceOrder * pre, G100InsuranceOrder * next) {
                return [[NSNumber numberWithInteger:next.order_created] compare:[NSNumber numberWithInteger:pre.order_created]];
            }].mutableCopy;
            
            [wself.orderTable reloadData];
            
        }else {
            [wself showHint:response.errDesc];
        }
    }];
    
    if (showHUD) {
        [self showHudInView:self.view hint:@""];
    }
}

#pragma mark - setupView
- (void)setupView {
    [self.view addSubview:self.orderTable];
    [self.orderTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark - Lazy load
- (UITableView *)orderTable {
    if (!_orderTable) {
        _orderTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _orderTable.delegate = self;
        _orderTable.dataSource = self;
        _orderTable.emptyDataSetDelegate = self;
        _orderTable.emptyDataSetSource = self;
        _orderTable.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _orderTable;
}

- (NSMutableArray *)orderArray {
    if (!_orderArray) {
        _orderArray = [[NSMutableArray alloc] init];
    }
    return _orderArray;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) wself = self;
    self.orderTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (wself.insuranceOrderType == InsuranceOrderWaitPay) {
            [wself quereyOrderDataWithUserid:wself.userid status:@[ [NSNumber numberWithInteger:9], [NSNumber numberWithInteger:10] ] showHUD:NO];
        }
        else {
            [wself quereyOrderDataWithUserid:wself.userid status:@[ [NSNumber numberWithInteger:wself.insuranceOrderType] ] showHUD:NO];
        }
    }];
    
    NSString *lastUpdatedTimeKey = [NSString stringWithFormat:@"%@-%@", NSStringFromClass([self class]), @(self.insuranceOrderType)];
    self.orderTable.mj_header.lastUpdatedTimeKey = lastUpdatedTimeKey;
    
    [self setupView];
    
    // iOS 11 UI 显示bug 修复
    if ([self.orderTable respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.orderTable setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [self showHudInView:self.view hint:@"正在加载"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_insuranceOrderType == InsuranceOrderWaitPay) {
        [self quereyOrderDataWithUserid:self.userid status:@[ [NSNumber numberWithInteger:9], [NSNumber numberWithInteger:10] ] showHUD:NO];
    }
    else {
        [self quereyOrderDataWithUserid:self.userid status:@[ [NSNumber numberWithInteger:_insuranceOrderType] ] showHUD:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
