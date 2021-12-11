//
//  G100PayOrderViewController.m
//  ebike
//
//  Created by yuhanle on 2017/11/21.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "G100PayOrderViewController.h"
#import "PayChannelCell.h"

#import "G100PayServiceHandler.h"
#import "G100OrderApi.h"
#import "G100WebViewController.h"
#import "G100UrlManager.h"

@interface G100PayOrderViewController () <UITableViewDelegate, UITableViewDataSource, G100PayServiceDelegate>

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *orderLabel;
@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) NSArray <PayChannel *>*channelsData;
@property (nonatomic, strong) G100PayServiceHandler *payService;
@end

@implementation G100PayOrderViewController

- (void)dealloc
{
    [self removeNotificaiton];
    DLog(@"支付页面销毁");
}

#pragma mark - G100PayServiceDelegate
- (void)paymentByPingpp:(ApiResponse *)response requestSucces:(BOOL)requestSucces
{
    [self hideHud];
    if (!requestSucces) {
        [self showHint:response.errDesc];
    }
}
- (void)payStatus:(PayResultStatus)payStatus msg:(NSString *)message
{
    switch (payStatus) {
        case showHint:
            [self showHint:message];
            break;
        case showWarningHint:
            [self showWarningHint:message];
            break;
        case showHudInView:
            [self showHudInView:self.substanceView hint:message];
            break;
        default:
            break;
    }
}
- (void)payFinished:(ApiResponse *)response requestSucces:(BOOL)requestSucces faildType:(PayFaildType)faildType
{
    if (requestSucces) {
        [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if (requestSucces) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CDDDataHelperDeviceInfoDidChangeNotification object:nil];
            }
        }];
        
        [self.listView reloadData];
    }else {
        [self showHint:response.errDesc];
    }
    
    NSString *result = requestSucces ? @"success" : @"fail";
    G100WebViewController *webVC = [G100WebViewController loadNibWebViewController];
    webVC.userid = self.userid;
    webVC.httpUrl = [[G100UrlManager sharedInstance] getPayResultWithUserid:self.userid
                                                                    orderid:self.orderid
                                                                     result:result
                                                                       code:faildType];
    
    NSMutableArray *array = self.navigationController.viewControllers.mutableCopy;
    [array removeLastObject];
    [array addObject:webVC];
    
    [self.navigationController setViewControllers:array animated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PayChannelCell *channelCell = [tableView dequeueReusableCellWithIdentifier:@"PayChannelCell"];
    channelCell.channel = self.channelsData[indexPath.row];
    return channelCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelsData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (NSInteger i = 0; i < self.channelsData.count; i++) {
        PayChannel *channel = self.channelsData[i];
        if (i == indexPath.row) {
            channel.selected = YES;
        }else {
            channel.selected = NO;
        }
    }
    
    [self.listView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    UILabel * left = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, backView.v_width - 20, 30)];
    left.textColor = [UIColor colorWithHexString:@"959595"];
    left.font = [UIFont systemFontOfSize:14];
    left.textAlignment = NSTextAlignmentLeft;
    left.text = @"请选择支付方式";
    left.backgroundColor = [UIColor clearColor];
    [backView addSubview:left];
    return backView;
}

#pragma mark - Actions
- (void)action_surePay {
    // 获取当前支付方式
    PayChannel *payChannel = nil;
    for (PayChannel *channel in self.channelsData) {
        if (channel.selected) {
            payChannel = channel;
            break;
        }
    }
    // 申请支付
   // self.orderModel.price = 0.1;
    [self.payService createWithOrderNum:self.orderid amount:self.orderModel.price cChannel:payChannel.channelID];
}

- (void)didBecomeActive {
    //TODO: 程序激活查询订单支付状态
    
}
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}
- (void)removeNotificaiton {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

#pragma mark - Lazy load
- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStyleGrouped];
        _listView.delegate = self;
        _listView.dataSource = self;
    }
    return _listView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sureButton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.72 blue:0 alpha:1]];
        _sureButton.layer.masksToBounds = YES;
        _sureButton.layer.cornerRadius = 20.0f;
        _sureButton.titleLabel.textColor = [UIColor whiteColor];
        _sureButton.tintColor = [UIColor whiteColor];
        _sureButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_sureButton addTarget:self action:@selector(action_surePay) forControlEvents:UIControlEventTouchUpInside];
        [_sureButton setTitle:@"确认" forState:UIControlStateNormal];
    }
    return _sureButton;
}

- (G100PayServiceHandler *)payService {
    if (!_payService) {
        _payService = [[G100PayServiceHandler alloc] init];
        _payService.delegate = self;
    }
    return _payService;
}

#pragma mark - Private Method
- (void)loadOrderDetail {
    [self showHudInView:self.substanceView hint:@"加载中"];
    __weak typeof(self) wself = self;
    [[G100OrderApi sharedInstance] getOrderDetailWithOrder_id:self.orderid.integerValue callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        if (requestSuccess) {
            wself.orderModel = [[G100OrderDomain alloc] initWithDictionary:[response.data[@"orders"] firstObject]];
            wself.orderLabel.text = [NSString stringWithFormat:@"需支付：%.2f元", wself.orderModel.price];
        }else {
            [wself showHint:response.errDesc];
        }
    }];
}

#pragma mark - setupView
- (void)setupView {
    [self setNavigationTitle:@"请选择支付方式"];
    
    // 添加listView
    [self.substanceView addSubview:self.listView];
    [self.substanceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.substanceView);
    }];
    
    // 添加确认按钮
    [self.substanceView addSubview:self.sureButton];
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.bottom.equalTo(@-20);
        make.centerX.equalTo(self.substanceView);
        make.width.equalTo(self.substanceView.mas_width).multipliedBy(260.0/414.0);
    }];
    
    self.listView.tableHeaderView = self.headerView;
    
    NSMutableArray *currentVCArr =  self.navigationController.viewControllers.mutableCopy;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[G100WebViewController class]]) {
            [currentVCArr removeObject:vc];
        }
    }
    [self.navigationController setViewControllers:currentVCArr animated:NO];
}

- (void)setupData {
    PayChannel *channel1 = [[PayChannel alloc] init];
    channel1.channel = PayChannelAlipay;
    channel1.selected = YES;
    
    PayChannel *channel2 = [[PayChannel alloc] init];
    channel2.channel = PayChannelWX;
    
    PayChannel *channel3 = [[PayChannel alloc] init];
    channel3.channel = PayChannelApple;
    
    PayChannel *channel4 = [[PayChannel alloc] init];
    channel4.channel = PayChannelUnionYun;
    
    PayChannel *channel5 = [[PayChannel alloc] init];
    channel5.channel = PayChannelUnion;
    if ([DeviceManager isIphone4] || [DeviceManager isIphone5] || [UIDevice currentDevice].systemVersion.floatValue < 9.2) {
        self.channelsData = @[ channel1, channel2, channel4 /*,channel5 */];
    }else{
        self.channelsData = @[ channel1, channel2, channel3 ,channel4 /*,channel5 */];
    }
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.orderid.length == 0) {
        DLog(@"缺少支付订单号");
    }
    
    [self setupData];
    [self setupView];
    
    [self registerNotification];
    [self.listView registerNib:[UINib nibWithNibName:@"PayChannelCell" bundle:nil] forCellReuseIdentifier:@"PayChannelCell"];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadOrderDetail];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
