//
//  G100DevManagementViewController.m
//  G100
//
//  Created by William on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevManagementViewController.h"
#import "G100BikeEditDevNameViewController.h"
#import "G100BindDevViewController.h"
#import "G100Mediator+BuyService.h"
#import "G100UserAndDevManagementViewController.h"
#import "G100WebViewController.h"
#import "G100DevUpdateViewController.h"
#import "G100UrlManager.h"
#import "CustomQrCodeView.h"

#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "G100DevDataHelper.h"
#import "G100GoodsApi.h"

#import <YYText.h>
#import <SDImageCache.h>
#import "QRCodeGenerator.h"

#import "G100AllGoodsDomain.h"
#import "G100GoodDomain.h"
#import "G100UpdateVersionModel.h"

#define kRebootInterval 30
#define kMaxCheckCount 10

@interface G100DevManagementViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSInteger checkCount;
}

@property (nonatomic, assign) BOOL isMaster;
@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSArray * basicsArray;

@property (nonatomic, strong) NSArray * actionArray;

@property (nonatomic, strong) NSArray * basicsSecArray;

@property (nonatomic, strong) G100DeviceDomain *devDomain;

@property (nonatomic, strong) UIImage *QRImage;

@property (nonatomic, strong) G100AllGoodsDomain *allGoods;

@property (nonatomic, assign) CGFloat lowDiscount;

@property (nonatomic, assign) BOOL hasUpdateFirm;
@end

@implementation G100DevManagementViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperDeviceInfoDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lowDiscount = 1;
    
    [self setupData];
    
    [self loadGoodDisCountShowHUD:NO];
    
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoDeviceDomainDidChange:) name:CDDDataHelperDeviceInfoDidChangeNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self checkUpdateVersion];
    
    [[UserManager shareManager]updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [self setupData];
    }];
}
- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [self.contentView addSubview:_tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.bottom.equalTo(@0);
    }];
}

- (void)setupData {
    self.devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid
                                                                  bikeid:self.bikeid
                                                                   devid:self.devid];
    
    G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    self.isMaster = bikeDomain.isMaster;
    
    if (self.isMaster) {
        if (self.devDomain.isSpecialChinaMobileDevice || self.devDomain.isAfterInstallSingleDevice) {
            self.actionArray = @[@"与该车解绑", @"更换设备", @"重启设备"];
        }else{
            self.actionArray = @[@"与该车解绑", @"重新绑定", @"重启设备"];
        }
    }else {
        //self.actionArray = @[@"与该车解绑"];
    }
    
    if (self.devDomain.isSpecialChinaMobileDevice) {
        _basicsArray = @[@"设备名称", @"设备二维码", @"激活时间", @"保修截止日期", @"版本号"];
        _basicsSecArray = @[@"绑定时间"];
    }else{
        _basicsArray = @[@"设备名称", @"设备二维码",@"激活时间", @"保修截止日期", @"版本号"];
        _basicsSecArray = @[@"绑定时间", @"剩余服务时间", @"续费充值"];
    }
    
    [self setupNavigationBarView];
    [self downloadQRImage];
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:self.devDomain.name.length ? self.devDomain.name : @"GPS"];
    [self.navigationBarView setNavigationTitleLabelWidth:self.view.frame.size.width - 100];
}

- (void)downloadQRImage{
    _QRImage = [[UIImage alloc]init];
    __block typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if ([[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:self.devDomain.add_url]) {
            weakSelf.QRImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:self.devDomain.add_url];
        }else {
            if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:self.devDomain.add_url]) {
                weakSelf.QRImage  = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.devDomain.add_url];
            }else{
                weakSelf.QRImage  = [QRCodeGenerator qrImageForString:self.devDomain.add_url
                                                            imageSize:500];
                [[SDImageCache sharedImageCache] storeImage:weakSelf.QRImage forKey:self.devDomain.add_url toDisk:YES];
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    });
}

#pragma mark - 获取套餐折扣数据
- (void)loadGoodDisCountShowHUD:(BOOL)showHUD
{
    if (kNetworkNotReachability) {
        return;
    }
    __weak G100DevManagementViewController *weakself = self;
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess)
    {
        if (showHUD) {
            [weakself hideHud];
        }
        if (response.success) {
            weakself.allGoods = [[G100AllGoodsDomain alloc]initWithDictionary:response.data];
            CGFloat tempLowDiscount = 1;
            for (G100GoodDomain *goodDomain in weakself.allGoods.prods) {
                if (goodDomain.discount <  tempLowDiscount) {
                    tempLowDiscount = goodDomain.discount;
                }
            }
            self.lowDiscount = tempLowDiscount;
            [weakself.tableView reloadData];
        }
        
    };
    if (showHUD) {
        [self showHudInView:self.contentView hint:@"正在更新"];
    }
    
    [[G100GoodsApi sharedInstance]loadProductListWithType:@"1" devid:self.devDomain.device_id callback:callback];
}
#pragma mark - 检查是否有更新
- (void)checkUpdateVersion {
    __weak typeof(self) wself = self;
    [[G100BikeApi sharedInstance] checkDeviceFirmWithBikeid:self.bikeid deviceid:self.devid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            G100UpdateVersionModel *updateVersionModel = [[G100UpdateVersionModel alloc] initWithDictionary:response.data];
            if(updateVersionModel.firm.state == 1){
                wself.hasUpdateFirm = YES;
            }else{
                wself.hasUpdateFirm = NO;
            }
            [wself.tableView reloadData];
        }
    }];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.basicsArray.count;
    }else if (section == 1){
        return self.basicsSecArray.count;
    }
    return self.actionArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 4 && self.isMaster) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = self.basicsArray[indexPath.row];
        
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = self.devDomain.name;
        }else if (indexPath.row == 1) {
            UIImageView *imageview = [[UIImageView alloc]initWithImage:self.QRImage];
            imageview.frame = CGRectMake(WIDTH - 50, 7, 30, 30);
            [cell.contentView addSubview:imageview];
        }else if (indexPath.row == 2) {
            cell.detailTextLabel.text = self.devDomain.service.activated_date;
        }else if (indexPath.row == 3) {
            cell.detailTextLabel.text = self.devDomain.warranty;
        }else if (indexPath.row == 4) {
            if (self.hasUpdateFirm) {
                cell.detailTextLabel.textColor = [UIColor redColor];
                cell.detailTextLabel.text = @"有新版本点击升级";
            }else{
                cell.detailTextLabel.text = self.devDomain.firm;
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0.55 green:0.54 blue:0.56 alpha:1.00];
            }
        }
    }else if(indexPath.section == 1){
        cell.textLabel.text = self.basicsSecArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = self.devDomain.service.binded_date;
        }else if (indexPath.row == 1){
            if (![self.devDomain isOverdue]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@天", @(self.devDomain.leftdays)];
                
                if (self.devDomain.leftdays <= 0) {
                    cell.detailTextLabel.textColor = [UIColor redColor];
                }else if (self.devDomain.leftdays <= 30) {
                    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#ff6c00"];
                }
            }else {
                cell.detailTextLabel.text =  @"已过期";
                if (![self.devDomain canRecharge]) {
                    cell.detailTextLabel.text =  @"请致电客服重新开通服务";
                }
                
                cell.detailTextLabel.textColor = [UIColor redColor];
            }
            
        }else if (indexPath.row == 2){
            if ([self.devDomain canRecharge]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.userInteractionEnabled = YES;
                if (self.lowDiscount != 1) {
                    if ((int)(self.lowDiscount * 10) == self.lowDiscount * 10) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"立享%.0f折", self.lowDiscount * 10];
                    }else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"立享%.1f折", self.lowDiscount * 10];
                    }
                }
                
            }else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.userInteractionEnabled = NO;
            }
            
        }
    }
    else if (indexPath.section == 2) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.actionArray[indexPath.row];
        if (indexPath.row == 2) {
            cell.detailTextLabel.text = @"若发现丢失数据，可尝试";
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) { // 信息类
        if (indexPath.row == 0) {
            /** 暂时不支持修改设备名称
            G100BikeEditDevNameViewController *viewController = [[G100BikeEditDevNameViewController alloc] initWithUserid:self.userid
                                                                                                                   bikeid:self.bikeid
                                                                                                                    devid:self.devid
                                                                                                                  oldName:self.devDomain.name];
            viewController.sureBlock = ^(NSString *result){
                self.devDomain.name = result;
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:viewController animated:YES];
             */
        }else if (indexPath.row == 1) {
            // 设备二维码
            CustomQrCodeView * customQrcodeView = [[[NSBundle mainBundle]loadNibNamed:@"CustomQrCodeView" owner:self options:nil]firstObject];
            
            [customQrcodeView showOpenQRCodeWithVc:self
                                              view:self.view
                                             image:nil
                                           devName:self.devDomain.name
                                            qrCode:self.devDomain.qr
                                          qrNumber:self.devDomain.qr other:nil];
        }else if (indexPath.row == 3){
//            G100WebViewController * helper = [G100WebViewController loadNibWebViewController];
//            helper.webTitle = @"帮助中心";
//            helper.httpUrl = [[G100UrlManager sharedInstance]getHelpWithAnchor:@"10" mid:self.devDomain.model_id mtid:self.devDomain.model_type_id];
//            [self.navigationController pushViewController:helper animated:YES];
        }else if(indexPath.row == 4){
            if (!self.isMaster) {
                return;
            }
            G100DevUpdateViewController *updateVC = [[G100DevUpdateViewController alloc] init];
            updateVC.devid = self.devid;
            updateVC.bikeid = self.bikeid;
            updateVC.userid = self.userid;
            [self.navigationController pushViewController:updateVC animated:YES];
        }
        
    }else if(indexPath.section == 1){
        if (indexPath.row == 2) {
            // 续费充值
            if (![UserAccount sharedInfo].appfunction.servicestatus_buy.enable && IsLogin()) {
                return;
            };
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBuyService:self.userid
                                                                                                                bikeid:self.bikeid
                                                                                                                 devid:self.devid];
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
    }
    else if (indexPath.section == 2) { // 操作类
        if (indexPath.row == 0) { // 与该车解绑
            if (![UserAccount sharedInfo].appfunction.mybikes_bikedetail_unbind.enable && IsLogin()) {
                return;
            };
            [self unbindDevice];
        }else if (indexPath.row == 1) { // 重新绑定 或 更换设备
            if (![UserAccount sharedInfo].appfunction.mybikes_bikedetail_rebind.enable && IsLogin()) {
                return;
            };
            [self tl_devRebind:nil];
        }else if (indexPath.row == 2) { // 重启设备
            [self tl_devReboot:nil];
        }
    }else {
        
    }
}
- (void)unbindDevice{
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    __weak G100DevManagementViewController * wself = self;
    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
    box.contentAlignment = PopContentAlignmentLeft;
    [box showPopingViewWithTitle:@"解绑协议" content:@"解绑后，您将无法收到报警提醒及位置数据。您设备内剩余的服务期不会暂停，将继续处于服务状态。" noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
        if (index == 2) {
            [wself removeDev:wself.devDomain vc:@"1234"];
        }
        [box dismissWithVc:wself animation:YES];
    } onViewController:self onBaseView:self.view];
}

-(void)removeDev:(G100DeviceDomain *)devModel vc:(NSString *)vc {
    __weak G100DevManagementViewController * wself = self;
    G100UserAndDevManagementViewController * carManger = nil;
    for (UIViewController * obj in self.navigationController.viewControllers) {
        if ([obj isKindOfClass:[G100UserAndDevManagementViewController class]]) {
            carManger = (G100UserAndDevManagementViewController *)obj;
        }
    }
    
    [[G100DevApi sharedInstance] deleteDevWithBikeid:self.bikeid deviceid:self.devid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            // bug fixed: QWSIOS-422
            [[G100DevDataHelper shareInstance] updateAllBikeRuntimeData];
            
            [[UserManager shareManager] updateBikeInfoWithUserid:wself.userid bikeid:wself.bikeid updateType:BikeInfoDeleteType complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    //[wself showHint:@"解绑成功"];
                    if (carManger) {
                        [wself.navigationController popToViewController:carManger animated:YES];
                    }else {
                        [wself.navigationController popToRootViewControllerAnimated:YES];
                    }
                }else {
                    [wself showHint:response.errDesc];
                }
                
                [[G100InfoHelper shareInstance] clearRelevantDataWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
            }];
        }else {
            
            [wself showHint:response.errDesc];
        }
    }];
    
}

#pragma mark - unbid && rebind
-(void)tl_devRebind:(UIButton *)button {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    if (self.devDomain.isSpecialChinaMobileDevice || self.devDomain.isAfterInstallSingleDevice) {
        // 更换设备
        G100BindDevViewController *changeBindVC = [[G100BindDevViewController alloc] init];
        
        changeBindVC.userid = self.userid;
        changeBindVC.bikeid = self.bikeid;
        changeBindVC.devid = self.devid;
        
        changeBindVC.operationMethod = 1;
        changeBindVC.bindMode = 1;
        
        [self.navigationController pushViewController:changeBindVC animated:YES];
    }else {
        [self reBindDevice];
    }
}
-(void)reBindDevice {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak G100DevManagementViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateDevInfoWithUserid:self.userid bikeid:self.bikeid devid:self.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [wself showHint:@"绑定成功"];
                }
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    // 绑定
    [self showHudInView:self.contentView hint:@"正在绑定"];
    [[G100BikeApi sharedInstance] rebindBikeDeviceWithbikeid:self.bikeid devid:self.devid callback:callback];
}

#pragma mark - reboot
-(void)tl_devReboot:(UIButton *)button {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    NSString * content = @"重启设备前请先打开车辆电门，重启期间将无法接收报警提示，是否继续？";
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:content];
    text.yy_font = [UIFont systemFontOfSize:17];
    NSRange hiRange = [content rangeOfString:@"打开车辆电门"];
    
    [text yy_setColor:MyHomeColor range:hiRange];
    [text yy_setFont:[UIFont boldSystemFontOfSize:17] range:hiRange];
    
    G100PromptBox * promptBox = [G100PromptBox promptBoxSureOrCancelAlertView];
    [promptBox showBoxWith:@"提示" attriPrompt:text sureTitle:@"重启设备" cancelTitle:@"放弃" sure:^{
        [self rebootDevice];
    } cancel:nil];
}

-(void)rebootDevice {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    __weak G100DevManagementViewController * wself = self;
    API_CALLBACK callback =  ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [wself performSelector:@selector(checkRebootDev:) withObject:wself.devid afterDelay:kRebootInterval];
        }else{
            [wself hideHud];
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    [self showHudInView:self.contentView hint:@"正在重启" detailHint:@"重启需要几分钟，请耐心等待"];
    [[G100DevApi sharedInstance] rebootLocatorWithBikeid:self.bikeid devid:self.devid callback:callback];
}

-(void)checkRebootDev:(NSString*)devid {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    __weak G100DevManagementViewController * wself = self;
    [[G100DevApi sharedInstance] checkLocatorRebootWithBikeid:self.bikeid devid:devid minute:1 callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (response.errCode == 00) { /* 有重启 */
            [wself hideHud];
            //[wself showHint:@"重启成功"];
            G100PromptBox * promptBox = [G100PromptBox promptBoxIKnowAlertView];
            [promptBox showBoxWith:@"提示" prompt:@"重启成功" sureTitle:nil sure:nil];
        }else if(response.errCode == 75) { /* 无重启 */
            checkCount++;
            [self performSelector:@selector(checkRebootDev:) withObject:devid afterDelay:kRebootInterval-checkCount>5?5:checkCount*5];
            
            if (checkCount == kMaxCheckCount) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                
                [wself hideHud];
                G100PromptBox * promptBox = [G100PromptBox promptImageBoxSureOrCancelAlertView];
                if ([wself.devDomain isG500Device]) {
                    promptBox.imageAspectConstraint.priority = 700;
                    promptBox.G500ImageAspectConstraint.priority = 999;
                    [promptBox showBoxWith:@"提示" prompt:@"抱歉，重启失败！请重试或者尝试手动重启！" imageName:@"ic_reboot_introduction_G500" sureTitle:@"重试" sure:^{
                        checkCount = 0;
                        [self rebootDevice];
                    }];
                }else if([wself.devDomain isG800Device]) {
                    G100PromptBox * promptBoxG800 = [G100PromptBox promptBoxSureOrCancelAlertView];
                    [promptBoxG800 showBoxWith:@"提示" prompt:@"抱歉，重启失败！请重试!" sureTitle:@"重试" sure:^{
                        checkCount = 0;
                        [self rebootDevice];
                    }];
                }else{
                    promptBox.G500ImageAspectConstraint.priority = 700;
                    promptBox.imageAspectConstraint.priority = 999;
                    [promptBox showBoxWith:@"提示" prompt:@"抱歉，重启失败！请重试或者尝试手动重启！" imageName:@"ic_reboot_introduction" sureTitle:@"重试" sure:^{
                        checkCount = 0;
                        [self rebootDevice];
                    }];
                }
            }
        }else{
            [wself hideHud];
            G100PromptBox * promptBox = [G100PromptBox promptImageBoxSureOrCancelAlertView];
            if ([wself.devDomain isG500Device]) {
                promptBox.imageAspectConstraint.priority = 700;
                promptBox.G500ImageAspectConstraint.priority = 999;
                [promptBox showBoxWith:@"提示" prompt:@"抱歉，重启失败！请重试或者尝试手动重启！" imageName:@"ic_reboot_introduction_G500" sureTitle:@"重试" sure:^{
                    checkCount = 0;
                    [self rebootDevice];
                }];
            }else if([wself.devDomain isG800Device]) {
                G100PromptBox * promptBoxG800 = [G100PromptBox promptBoxSureOrCancelAlertView];
                [promptBoxG800 showBoxWith:@"提示" prompt:@"抱歉，重启失败！请重试!" sureTitle:@"重试" sure:^{
                    checkCount = 0;
                    [self rebootDevice];
                }];
            }else{
                promptBox.G500ImageAspectConstraint.priority = 700;
                promptBox.imageAspectConstraint.priority = 999;
                [promptBox showBoxWith:@"提示" prompt:@"抱歉，重启失败！请重试或者尝试手动重启！" imageName:@"ic_reboot_introduction" sureTitle:@"重试" sure:^{
                    checkCount = 0;
                    [self rebootDevice];
                }];
            }
        }
    }];
    
}

#pragma mark - NotificationCenter Action
- (void)infoDeviceDomainDidChange:(NSNotification *)noti {
    if ([noti.userInfo[@"user_id"] integerValue] != [self.userid integerValue]) {
        return;
    }
    
    [self setupData];
    [self.tableView reloadData];
}

@end
