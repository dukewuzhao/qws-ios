//
//  G100BikeInfoDeviceViewController.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoDeviceViewController.h"
#import "G100BikeInfoDeviceCell.h"
#import "G100BikeDomain.h"

#import "G100Mediator+BuyService.h"

#import "G100DevManagementViewController.h"

#import "UILabeL+AjustFont.h"

@interface G100BikeInfoDeviceViewController () <UITableViewDelegate, UITableViewDataSource,BikeInfoDeviceCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *devInfoArr;

@end

@implementation G100BikeInfoDeviceViewController

#pragma mark - Lazy Load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma mark - Override
- (void)setBikeInfoModel:(G100BikeInfoCardModel *)bikeInfoModel{
    _bikeInfoModel = bikeInfoModel;
    self.devInfoArr = [_bikeInfoModel.bike.devices mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - BikeInfoDeviceCellDelegate
- (void)showDevDetailInfoPageActionWithDeviceDomain:(G100DeviceDomain *)deviceDomain{
    G100DevManagementViewController * viewController = [[G100DevManagementViewController alloc]init];
    viewController.userid = self.userid;
    viewController.bikeid = self.bikeid;
    viewController.devid = [NSString stringWithFormat:@"%@", @(deviceDomain.device_id)];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private Method
- (void)rechargeBtnClickedWithDeviceDomain:(G100DeviceDomain *)deviceDomain{
    // 续费充值
    if (![UserAccount sharedInfo].appfunction.servicestatus_buy.enable && IsLogin()) {
        return;
    };
    NSString *devid =  [NSString stringWithFormat:@"%@",@(deviceDomain.device_id)];
    if (deviceDomain.isSpecialChinaMobileDevice) {
        G100ReactivePopingView *iKnowBox = [G100ReactivePopingView popingViewWithReactiveView];
        [iKnowBox showPopingViewWithTitle:nil
                                  content:@"使用期间请确保SIM卡不要欠费，SIM卡资费使用情况咨询当地运营商"
                               noticeType:ClickEventBlockCancel
                               otherTitle:nil
                             confirmTitle:@"我知道了"
                               clickEvent:^(NSInteger index) {
                                   [iKnowBox dismissWithVc:self animation:YES];
                               }
                         onViewController:self.topParentViewController
                               onBaseView:self.topParentViewController.view];
        return;
        
    }
    
    UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBuyService:self.userid
                                                                                                        bikeid:self.bikeid
                                                                                                         devid:devid];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.devInfoArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UITableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    G100BikeInfoDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:[G100BikeInfoDeviceCell cellID]];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.delegate = self;
    
    G100DeviceDomain *deviceDomain = [self.devInfoArr safe_objectAtIndex:indexPath.section];
    cell.deviceDomain = deviceDomain;
    cell.indexPath = indexPath;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (WIDTH /414.00) *113;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}

#pragma mark - Public Method
+ (CGFloat)heightForItem:(id)item width:(CGFloat)width {
    G100BikeDomain *bikeDomain = nil;
    if ([item isKindOfClass:[G100BikeDomain class]]) {
        bikeDomain = item;
    }
    if (bikeDomain.devices.count == 0) {
        return 0;
    }else{
        return (WIDTH /414.00) * 113 * bikeDomain.devices.count + (10 * (bikeDomain.devices.count - 1));
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(0);
    }];
    
    [G100BikeInfoDeviceCell registerToTabelView:self.tableView];
    
    [UILabel adjustAllLabel:self.view multiple:0.5];
}
- (void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
