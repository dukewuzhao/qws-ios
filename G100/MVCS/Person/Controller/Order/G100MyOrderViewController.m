//
//  G100MyOrderViewController.m
//  G100
//
//  Created by Tilink on 15/3/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100MyOrderViewController.h"
#import "G100GoodDomain.h"
#import "G100AllOrderDomain.h"
#import "G100OrderDomain.h"
#import "PayServiceCell.h"
#import "G100OrderApi.h"

#import "InsuranceWebModel.h"
#import "G100InsuranceWebViewController.h"
#import "G100PayOrderViewController.h"
#import "G100MallViewController.h"

#import <UITableView+FDTemplateLayoutCell.h>

@interface G100MyOrderViewController () <OrderCellDelegate> {
    BOOL hasAppear;
}

@property (strong, nonatomic) G100AllOrderDomain *allOrderDomain;
@property (strong, nonatomic) NSMutableArray *uncompletedArray;

@end

@implementation G100MyOrderViewController

-(void)dealloc {
    DLog(@"我的订单页面已释放");
}

#pragma mark - Private Method
- (void)rightNaivigationBtnClicked {
    G100MallViewController *mallVC = [G100MallViewController loadXibViewControllerWithType:QWSMallTypeOrder];
    [self.navigationController pushViewController:mallVC animated:YES];
}

-(void)loadMyOrder:(BOOL)showHUD {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    __weak G100MyOrderViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        [wself.tableView.mj_header endRefreshing];
        [wself hideHud];
        if (response.success) {
            NSDictionary *bizDict = response.data;
            wself.allOrderDomain = [[G100AllOrderDomain alloc]initWithDictionary:bizDict];
            [wself handleUncompleteOrder];
            [wself buildUI];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    if (showHUD) {
        [self showHudInView:self.contentView hint:@"正在加载"];
    }
    
    [[G100OrderApi sharedInstance] loadMyorderWithCallback:callback];
}

-(void)handleUncompleteOrder {
    self.uncompletedArray = [NSMutableArray array];
    self.uncompletedArray = [NSMutableArray arrayWithArray:self.allOrderDomain.orders];
    NSInteger temp = 0;
    for (G100OrderDomain *model in self.allOrderDomain.orders) {
        temp++;
        if (model.order_id == self.recentOrderId) {
            [self.uncompletedArray insertObject:model atIndex:0];
            [self.uncompletedArray removeObjectAtIndex:temp];
        }
    }
}

-(void)buildUI {
    if (!self.allOrderDomain.orders.count) {
        UILabel * nullFooterView = [[UILabel alloc]initWithFrame:self.tableView.bounds];
        
        nullFooterView.text = @"暂无任何订单";
        nullFooterView.textAlignment = NSTextAlignmentCenter;
        nullFooterView.textColor = [UIColor lightGrayColor];
        nullFooterView.font = [UIFont systemFontOfSize:21];
        _tableView.tableFooterView = nullFooterView;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.allOrderDomain.orders count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100OrderDomain *domain = [self.uncompletedArray safe_objectAtIndex:indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:@"PayServiceCell" configuration:^(PayServiceCell *cell) {
        [cell showOrderUIWithModel:domain];
    }];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PayServiceCell *paycell = [tableView dequeueReusableCellWithIdentifier:@"PayServiceCell"];
    paycell.indexPath = indexPath;
    paycell.delegate = self;
    G100OrderDomain *model = [self.uncompletedArray safe_objectAtIndex:indexPath.section];
    [paycell showOrderUIWithModel:model];
    [paycell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return paycell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    G100OrderDomain * model = [self.uncompletedArray safe_objectAtIndex:section];
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    UILabel * left = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, backView.v_width - 20, 30)];
    left.textColor = [UIColor lightGrayColor];
    left.font = [UIFont systemFontOfSize:14];
    left.textAlignment = NSTextAlignmentLeft;
    left.text = [NSString stringWithFormat:@"订单号：%ld", (long)model.order_id];
    left.backgroundColor = [UIColor clearColor];
    [backView addSubview:left];
    
    UILabel * rightTime = [[UILabel alloc]initWithFrame:left.bounds];
    rightTime.backgroundColor = [UIColor clearColor];
    rightTime.textColor = [UIColor lightGrayColor];
    rightTime.font = [UIFont systemFontOfSize:14];
    
    NSString * subString = [model.created_time substringToIndex:10];
    rightTime.text = [NSString stringWithFormat:@"时间：%@", subString];
    rightTime.textAlignment = NSTextAlignmentRight;
    [left addSubview:rightTime];
    
    return backView;
}

#pragma mark OrderCellDelegate 取消订单 & 付款
-(void)handleCancelOrderWithIndexPath:(NSIndexPath *)indexPath {
    G100OrderDomain * model = [self.uncompletedArray safe_objectAtIndex:indexPath.section];
    [MyAlertView MyAlertWithTitle:@"提示" message:@"您确定要取消订单吗?" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (kNetworkNotReachability) {
                [self showHint:kError_Network_NotReachable];
                return;
            }
            
            __weak G100MyOrderViewController * wself = self;
            API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
                [wself hideHud];
                if (response.success) {
                    [self loadMyOrder:NO];
                    [self showHint:[NSString stringWithFormat:@"%@订单被取消", model.product_name]];
                }else{
                    if (response) {
                        [wself showHint:response.errDesc];
                    }
                }
            };
            [self showHudInView:self.contentView hint:@"正在取消"];
            [[G100OrderApi sharedInstance] cancelOrderWithOrderid:model.order_id callback:callback];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
}

-(void)handlePayOrderWithIndexPath:(NSIndexPath *)indexPath {
    G100OrderDomain * model = [self.uncompletedArray safe_objectAtIndex:indexPath.section];
    if (model.order_type == 1) {
        [self moveToServicePayViewWithModel:model];
    }else if (model.order_type == 2) {
        [self moveToInsurancePayViewWithModel:model];
    }
}

//跳转服务支付页面
-(void)moveToServicePayViewWithModel:(G100OrderDomain *)model {
    G100PayOrderViewController *payOrderVC = [G100PayOrderViewController loadXibViewController];
    payOrderVC.userid = self.userid;
    payOrderVC.bikeid = model.bike_id;
    payOrderVC.devid = model.device_id;
    payOrderVC.orderid = [NSString stringWithFormat:@"%ld", model.order_id];
    [self.navigationController pushViewController:payOrderVC animated:YES];
}

//跳转保险支付页面
-(void)moveToInsurancePayViewWithModel:(G100OrderDomain *)model {
    BOOL insurance_apply = [UserAccount sharedInfo].appfunction.insurance_apply.enable && IsLogin();
    if (insurance_apply && model.pay_url.length) {
        if ([model.pay_url hasContainString:@"dmzstg1.pa18.com"]) {
            // 平安的保险 非赠送的盗抢险
            InsuranceWebModel * webModel = [[InsuranceWebModel alloc] initWithDictionary:[model mj_keyValues]];
            G100InsuranceWebViewController * store = [[G100InsuranceWebViewController alloc] initWithNibName:@"G100InsuranceWebViewController" bundle:nil];
            store.model = webModel;
            [self.navigationController pushViewController:store animated:YES];
        }else if ([G100Router canOpenURL:model.pay_url]) {
            [G100Router openURL:model.pay_url];
        }
    }
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:@"我的订单"];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 80, 40);
    [rightBtn setTitle:@"淘宝订单" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightNaivigationBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self setRightNavgationButton:rightBtn];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PayServiceCell" bundle:nil] forCellReuseIdentifier:@"PayServiceCell"];
    
    __weak G100MyOrderViewController * wself = self;
    MJRefreshHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself loadMyOrder:NO];
    }];
    header.lastUpdatedTimeKey = NSStringFromClass([self class]);
    self.tableView.mj_header = header;
    hasAppear = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (hasAppear) {
        [self loadMyOrder:NO];
    }else {
        [self loadMyOrder:YES];
        hasAppear = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
