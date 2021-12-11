//
//  G100BindDevViewController.m
//  G100 2.0
//
//  Created by yuhanle on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BindDevViewController.h"
#import "G100AlertConfirmClickView.h"

#import "G100DevManagementViewController.h"
#import "G100QRBindDevViewController.h"
#import "G100ManuallyBindDevViewController.h"
#import "G100WebViewController.h"

#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "G100DevCheckBindResultDomain.h"
#import "BindErrorView.h"
#import "BindWaitingView.h"
#import "MBProgressHUDManager.h"

#import "G100ThemeManager.h"
#import <SDWebImage/SDWebImageManager.h>
//#import <UMAnalytics/MobClick.h>
static NSTimeInterval kBindTimeOut = 180;

NSString *kGNRebindNotification = @"web_rebind_notification";

@interface G100BindDevViewController ()

@property (nonatomic, strong) G100QRBindDevViewController *qrBindVc;
@property (nonatomic, strong) G100ManuallyBindDevViewController *manuallyBindVc;

@property (strong, nonatomic) NSTimer * waitTimer;
@property (strong, nonatomic) BindWaitingView * backView;

@property (strong, nonatomic) NSDate * bangdingBeginDate;
@property (strong, nonatomic) NSDate * bangdingEndDate;

@property (strong, nonatomic) G100OptionsPopingView *optionPopView;

@property (strong, nonatomic) G100TextEnterPopingView *bikeNamePopView;

@property (strong, nonatomic) NSArray *bikes;

@property (strong, nonatomic) NSMutableArray *optionBikesName;
@property (strong, nonatomic) NSMutableArray *optionBikes;

@property (assign, nonatomic) NSInteger errorCount;

@property (copy, nonatomic) NSString *checkBikeid;
@property (assign, nonatomic) BOOL isSelectBike;

@property (strong, nonatomic) G100DevBindResultDomain *bindResultDomain;
@property (strong, nonatomic) BindErrorView * kBindErrorView;
@property (nonatomic, assign) BOOL bindFailed;
@property (strong, nonatomic) G100DevCheckBindResultDomain *checkResultDomian;

@end

@implementation G100BindDevViewController

- (void)dealloc
{
    [self removeNotification];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialData];
    
    [self setupView];
    
    [self registerNotification];
}

- (void)initialData {
    
}

- (void)setupView {
    switch (_bindMode) {
        case 2:
        {
            [self addChildViewController:self.manuallyBindVc];
            [self.view addSubview:self.manuallyBindVc.view];
            self.manuallyBindVc.view.frame = self.view.frame;
            [self.view bringSubviewToFront:self.manuallyBindVc.view];
            
            __weak __typeof__(self) weakSelf = self;
            [self.manuallyBindVc setCompletionWithBlock:^(NSString *resultAsString) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.operationMethod == 0) {
                    [strongSelf bindNewDeviceWithQr_code:resultAsString];
                }else if (strongSelf.operationMethod == 1) {
                    [strongSelf bindChangeLocatorWithDevid:strongSelf.devid qr:resultAsString];
                }else {
                    
                }
            }];
        }
            break;
        case 1:
        case 3:
        default:
        {
            [self addChildViewController:self.qrBindVc];
            [self.view addSubview:self.qrBindVc.view];
            self.qrBindVc.view.frame = self.view.frame;
            if (_bindMode == 3) {
                [self.qrBindVc setSaoYiSaoMode:2];
            }
            
            [self.view bringSubviewToFront:self.qrBindVc.view];
            
            __weak __typeof__(self) weakSelf = self;
            [self.qrBindVc setCompletionWithBlock:^(NSString *resultAsString) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.bindMode == 3) {
                    // 扫一扫模式
                    if (![resultAsString hasPrefix:@"http"] && ![resultAsString hasPrefix:@"qwsapp"]) {
                        if (strongSelf.operationMethod == 0) {
                            [strongSelf bindNewDeviceWithQr_code:resultAsString];
                        }else if (strongSelf.operationMethod == 1) {
                            [strongSelf bindChangeLocatorWithDevid:strongSelf.devid qr:resultAsString];
                        }else {
                            [strongSelf bindNewDeviceWithUserid:strongSelf.userid
                                                         bikeid:strongSelf.bikeid
                                                       bikeName:@""
                                                        qr_code:resultAsString
                                                     needVerify:YES];
                        }
                    }else {
                        if ([G100Router canOpenURL:resultAsString]) {
                            [G100Router openURL:resultAsString completion:^(id result) {
                                if (![result boolValue]) {
                                    if (strongSelf.bindMode != 2) {
                                        strongSelf.qrBindVc.isProcessing = NO;
                                        [strongSelf.qrBindVc startScanning];
                                    }
                                }
                            }];
                        }else {
                            G100WebViewController * msgWeb = [G100WebViewController loadNibWebViewController];
                            msgWeb.msg_title = @"扫描结果";
                            msgWeb.msg_desc = resultAsString;
                            msgWeb.filename = @"msg_template.html";
                            [strongSelf.navigationController pushViewController:msgWeb animated:YES];
                        }
                    }
                }else {
                    if (strongSelf.operationMethod == 0) {
                        [strongSelf bindNewDeviceWithQr_code:resultAsString];
                    }else if (strongSelf.operationMethod == 1) {
                        [strongSelf bindChangeLocatorWithDevid:strongSelf.devid qr:resultAsString];
                    }else {
                        
                    }
                }
            }];
        }
            break;
    }
    

}

#pragma mark - Lazzy load
- (G100QRBindDevViewController *)qrBindVc {
    if (!_qrBindVc) {
        _qrBindVc = [[G100QRBindDevViewController alloc] init];
        _qrBindVc.userid = self.userid;
        _qrBindVc.bikeid = self.bikeid;
        _qrBindVc.devid = self.devid;
        _qrBindVc.operationMethod = self.operationMethod;
    }
    return _qrBindVc;
}
- (G100ManuallyBindDevViewController *)manuallyBindVc {
    if (!_manuallyBindVc) {
        _manuallyBindVc = [[G100ManuallyBindDevViewController alloc] init];
        _manuallyBindVc.userid = self.userid;
    }
    return _manuallyBindVc;
}

-(G100OptionsPopingView *)optionPopView
{
    if (!_optionPopView) {
        _optionPopView = [G100OptionsPopingView popingViewWithOptionsView];
    }
    return _optionPopView;
}

-(G100TextEnterPopingView *)bikeNamePopView
{
    if (!_bikeNamePopView) {
        _bikeNamePopView = [G100TextEnterPopingView popingViewWithTextEnterView];
    }
    return _bikeNamePopView;
}

-(NSArray *)bikes
{
    if (!_bikes) {
        _bikes = [[NSArray alloc] init];
    }
    return _bikes;
}

- (NSMutableArray *)optionBikesName {
    if (!_optionBikesName) {
        _optionBikesName = [NSMutableArray array];
    }
    return _optionBikesName;
}

-(NSMutableArray *)optionBikes
{
    if (!_optionBikes) {
        _optionBikes = [NSMutableArray array];
    }
    return _optionBikes;
}

//是否有免费领取的保险
- (BOOL)hasFreeInsurance {
    if (self.checkResultDomian.gifttheftinsurance == 1) {
        return YES;
    }
    return NO;
}
#pragma mark - 扫描或输入成功 开始绑定
- (void)bindNewDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName qr_code:(NSString *)qr_code {
    [self bindNewDeviceWithUserid:userid bikeid:bikeid bikeName:bikeName qr_code:qr_code needVerify:NO];
}
/**
 绑定设备接口

 @param userid 用户id
 @param bikeid 车辆id
 @param bikeName 车辆名称
 @param qr_code 设备二维码
 @param needVerify 是否直接绑定 扫一扫功能调用此接口 需要验证是不是设备二维码
 */
- (void)bindNewDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName qr_code:(NSString *)qr_code needVerify:(BOOL)needVerify {
    __weak G100BindDevViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 如果是不需要验证的情况下 二维码有效 则绑定正式开始计时
            if (needVerify) {
                // 绑定
                [wself showBinding];
                // 记录绑定起始时间
                wself.bangdingBeginDate = [NSDate date];
            }
            
            [wself handleResposeSuccessWithRespose:response];
        }else {
            // 需要验证的绑定设备
            if (response.errCode == SERV_RESP_BIND_INVALID_QRCODE && needVerify) {
                if ([G100Router canOpenURL:qr_code]) {
                    [G100Router openURL:qr_code completion:^(id result) {
                        if (wself.bindMode != 2) {
                            wself.qrBindVc.isProcessing = NO;
                            [wself.qrBindVc startScanning];
                        }
                    }];
                }else {
                    G100WebViewController * msgWeb = [G100WebViewController loadNibWebViewController];
                    msgWeb.msg_title = @"扫描结果";
                    msgWeb.msg_desc = qr_code;
                    msgWeb.filename = @"msg_template.html";
                    [wself.navigationController pushViewController:msgWeb animated:YES];
                }
                
                return;
            }else {
                // 如果是不需要验证的情况下 二维码有效 则绑定正式开始计时
                if (needVerify) {
                    // 绑定
                    [wself showBinding];
                    // 记录绑定起始时间
                    wself.bangdingBeginDate = [NSDate date];
                }
            }
            
            if (response) {
                [wself hideBinding];
                if (response.errCode == SERV_RESP_BIND_REQUEST_SUBMMITED) {
                    // 请求已提交
                    G100StatusPopingView * popview = [G100StatusPopingView popingViewWithStatusView];
                    NSString * message = [NSString stringWithFormat:@"添加成功，等待主用户%@审核", [NSString shieldImportantInfo:[response.data objectForKey:@"ownerphone"]]];
                    popview.statueLevel = G100StatusPopingViewLevelOk;
                    [popview showPopingViewWithMessage:message confirmTitle:@"我知道了" clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself.navigationController popViewControllerAnimated:YES];
                        }
                    } onViewController:wself onBaseView:wself.view];
                }else if (response.errCode == SERV_RESP_BIND_NEED_ALARM_INFO) {
                    // 返回代码 当为71时，需要将请求参数alertor设为非0值再次调用此接口
                    
                }else if(response.errCode == SERV_RESP_BIND_NEED_BIND_BIKE) {
                    [wself handleResponseNeedSelectedBikeWithQr_code:qr_code bikeType:[[response.data objectForKey:@"locmodeltype"] integerValue] == 12 ? 1 : 0];
                }else {
                    
                    if (response.errCode == SERV_RESP_BIND_ERROR_FAILED) {
                        //[MobClick event:@"bind_failed"];
                    }
                    
                    // 绑定错误提示
                    if (response.errCode == SERV_RESP_BIND_INVALID_QRCODE ||
                        response.errCode == SERV_RESP_BIND_BINDED_CAR ||
                        response.errCode == SERV_RESP_BIND_DEV_ACTIVEING ||
                        response.errCode == SERV_RESP_BIND_ERROR_DEV_BIND||
                        response.errCode == SERV_RESP_BIND_CAR_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_USER_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_NO_BIND ||
                        response.errCode == SERV_RESP_BIND_CAR_BIND_VERIFYING ||
                        response.errCode == SERV_RESP_BIND_ERROR_FAILED)
                    {
                        [wself bindErrorWithResponse:response];
                    }else {
                        [wself showHint:response.errDesc];
                        
                        if (wself.bindMode != 2) {
                            // 绑定失败 重启扫描相机
                            [wself.qrBindVc startScanning];
                        }
                    }
                    
                }
                
            }else {
                [wself hideBinding];
                if (wself.bindMode != 2) {
                    // 绑定失败 重启扫描相机
                    [wself.qrBindVc startScanning];
                }
            }
        }
    };
    
    if (!needVerify) {
        // 绑定
        [self showBinding];
        // 记录绑定起始时间
        self.bangdingBeginDate = [NSDate date];
    }
    
    [[G100BikeApi sharedInstance] addBikeDeviceWithUserid:userid bikeid:bikeid bikeName:bikeName new_flag:0 qr:qr_code callback:callback];
}
- (void)bindNewDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName devid:(NSString *)devid {
    __weak G100BindDevViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [wself handleResposeSuccessWithRespose:response];
        }else {
            
            if (response) {
                [wself hideBinding];
                if (response.errCode == SERV_RESP_BIND_REQUEST_SUBMMITED) {
                    // 请求已提交
                    G100StatusPopingView * popview = [G100StatusPopingView popingViewWithStatusView];
                    NSString * message = [NSString stringWithFormat:@"添加成功，等待主用户%@审核", [NSString shieldImportantInfo:[response.data objectForKey:@"ownerphone"]]];
                    popview.statueLevel = G100StatusPopingViewLevelOk;
                    [popview showPopingViewWithMessage:message confirmTitle:@"我知道了" clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself.navigationController popViewControllerAnimated:YES];
                        }
                    } onViewController:wself onBaseView:wself.view];
                }else if (response.errCode == SERV_RESP_BIND_NEED_ALARM_INFO) {
                    // 返回代码 当为71时，需要将请求参数alertor设为非0值再次调用此接口
                    
                }else if(response.errCode == SERV_RESP_BIND_NEED_BIND_BIKE) {
                    
                }else {
                    
                    if (response.errCode == SERV_RESP_BIND_ERROR_FAILED) {
                       // [MobClick event:@"bind_failed"];
                    }
                    
                    // 绑定错误提示
                    if (response.errCode == SERV_RESP_BIND_INVALID_QRCODE ||
                        response.errCode == SERV_RESP_BIND_BINDED_CAR ||
                        response.errCode == SERV_RESP_BIND_DEV_ACTIVEING ||
                        response.errCode == SERV_RESP_BIND_ERROR_DEV_BIND||
                        response.errCode == SERV_RESP_BIND_CAR_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_USER_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_NO_BIND ||
                        response.errCode == SERV_RESP_BIND_CAR_BIND_VERIFYING ||
                        response.errCode == SERV_RESP_BIND_ERROR_FAILED)
                    {
                        [wself bindErrorWithResponse:response];
                    }else {
                        [wself showHint:response.errDesc];
                        
                        if (wself.bindMode != 2) {
                            // 绑定失败 重启扫描相机
                            [wself.qrBindVc startScanning];
                        }
                    }
                    
                }
                
            }else {
                [wself hideBinding];
                if (wself.bindMode != 2) {
                    // 绑定失败 重启扫描相机
                    [wself.qrBindVc startScanning];
                }
            }
        }
    };
    // 绑定
    [self showBinding];
    [[G100BikeApi sharedInstance] addBikeDeviceWithUserid:userid bikeid:bikeid bikeName:bikeName new_flag:0 devid:devid callback:callback];
    
    // 记录绑定起始时间
    self.bangdingBeginDate = [NSDate date];
}
- (void)bindNewDeviceWithQr_code:(NSString *)qr_code {
    if ([qr_code trim].length == 0) {
        [self showHint:@"请输入设备号"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        
        if (_bindMode != 2) {
            self.qrBindVc.isProcessing = NO;
            [self.qrBindVc startScanning];
        }
        
        return;
    }
    
    if (_bindMode != 2) {
        // 扫描输入需要处理
        self.qrBindVc.isProcessing = YES;
        [self.qrBindVc stopScanning];
    }
    self.isSelectBike = NO;
    [self bindNewDeviceWithUserid:self.userid bikeid:self.bikeid bikeName:nil qr_code:qr_code];
}
- (void)bindNewDeviceWithDevid:(NSString *)devid {
    if ([devid trim].length == 0) {
        [self showHint:@"请输入设备号"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        
        if (_bindMode != 2) {
            self.qrBindVc.isProcessing = NO;
            [self.qrBindVc startScanning];
        }
        
        return;
    }
    
    if (_bindMode != 2) {
        // 扫描输入需要处理
        self.qrBindVc.isProcessing = YES;
        [self.qrBindVc stopScanning];
    }
    self.isSelectBike = NO;
    [self bindNewDeviceWithUserid:self.userid bikeid:self.bikeid bikeName:nil devid:devid];
}

- (void)bindNewBikeWithQr_code:(NSString *)qr_code {
    // 先判断车辆id 是否有效
    NSInteger bikeid = [qr_code integerValue];
    if (bikeid == 0) {
        [self showHint:@"无效车辆编号"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        
        if (_bindMode != 2) {
            self.qrBindVc.isProcessing = NO;
            [self.qrBindVc startScanning];
        }
        
        return;
    }
    
    // 绑定车辆 qr_code 表示车辆 bikeid
    __weak G100BindDevViewController * wself = self;
    [[G100BikeApi sharedInstance] addBikeWithUserid:self.userid bikeInfo:@{@"bike_id" : [NSNumber numberWithInteger:bikeid]} callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [wself hideBinding];
            [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else {
            if (response) {
                [wself hideBinding];
                if (response.errCode == SERV_RESP_BIND_REQUEST_SUBMMITED) {
                    // 请求已提交
                    G100StatusPopingView * popview = [G100StatusPopingView popingViewWithStatusView];
                    NSString * message = [NSString stringWithFormat:@"添加成功，等待主用户%@审核", [NSString shieldImportantInfo:[response.data objectForKey:@"ownerphone"]]];
                    popview.statueLevel = G100StatusPopingViewLevelOk;
                    [popview showPopingViewWithMessage:message confirmTitle:@"我知道了" clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself.navigationController popViewControllerAnimated:YES];
                        }
                    } onViewController:wself onBaseView:wself.view];
                }else if (response.errCode == SERV_RESP_BIND_NEED_ALARM_INFO) {
                    // 返回代码 当为71时，需要将请求参数alertor设为非0值再次调用此接口
                    
                }else if(response.errCode == SERV_RESP_BIND_NEED_BIND_BIKE) {
                    [wself handleResponseNeedSelectedBikeWithQr_code:qr_code bikeType:[response.data integerForKey:@"locmodeltype"] == 12 ? 1 : 0];
                }else {
                    
                    if (response.errCode == SERV_RESP_BIND_ERROR_FAILED) {
                        //[MobClick event:@"bind_failed"];
                    }
                    
                    // 绑定错误提示
                    if (response.errCode == SERV_RESP_BIND_INVALID_QRCODE ||
                        response.errCode == SERV_RESP_BIND_BINDED_CAR ||
                        response.errCode == SERV_RESP_BIND_DEV_ACTIVEING ||
                        response.errCode == SERV_RESP_BIND_ERROR_DEV_BIND||
                        response.errCode == SERV_RESP_BIND_CAR_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_USER_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_NO_BIND ||
                        response.errCode == SERV_RESP_BIND_CAR_BIND_VERIFYING ||
                        response.errCode == SERV_RESP_BIND_ERROR_FAILED)
                    {
                        [wself bindErrorWithResponse:response];
                    }else {
                        [wself showHint:response.errDesc];
                        
                        if (wself.bindMode != 2) {
                            // 绑定失败 重启扫描相机
                            [wself.qrBindVc startScanning];
                        }
                    }
                    
                }
                
            }else {
                [wself hideBinding];
                if (wself.bindMode != 2) {
                    // 绑定失败 重启扫描相机
                    [wself.qrBindVc startScanning];
                }
            }
        }
    }];
    
    // 绑定
    [self showBinding];
    // 记录绑定起始时间
    self.bangdingBeginDate = [NSDate date];
}

#pragma mark - 绑定成功处理 检查绑定
- (void)handleResposeSuccessWithRespose:(ApiResponse *)response
{
    self.bindResultDomain = [[G100DevBindResultDomain alloc] initWithDictionary:response.data];
    G100DevBindResultDomain * bindResult = [[G100DevBindResultDomain alloc] initWithDictionary:response.data];
    if (bindResult.bike_id && ![bindResult.bike_id isEqualToString:@"0"]) {
        self.checkBikeid = bindResult.bike_id;
    }
    if (!self.checkBikeid && self.bikeid) {
        self.checkBikeid = self.bikeid;
    }
    // 下载主题包中的图片
    [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:bindResult.channeltheme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
        G100ThemeInfoBikeModel * themeBikeModel = [theme findThemeInfoBikeModelWithModelid:bindResult.modelid];
        
        NSArray * pic_urlsArr = @[
                                  theme.theme_channel_info.logo_big ? : @"",
                                  theme.theme_channel_info.logo_mid ? : @"",
                                  theme.theme_channel_info.logo_small ? : @"",
                                  themeBikeModel.pic_big ? : @"",
                                  themeBikeModel.pic_small ? : @""
                                  ];
        
        for (NSString * pic_urlstr in pic_urlsArr) {
            if (!pic_urlstr || !pic_urlstr.length) {
                continue;
            }
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:pic_urlstr] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
            }];
        }
    }];
    
    NSArray * pic_urls = @[ bindResult.logo_small ? : @"", bindResult.pic_big ? : @"", bindResult.pic_small ? : @"" ];
    for (NSString * pic_urlstr in pic_urls) {
        if (!pic_urlstr || !pic_urlstr.length) {
            continue;
        }
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:pic_urlstr] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
        }];
    }
    
    if (_backView) {
        [_backView setBindResult:bindResult];
    }
    
    self.waitTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                      target:self
                                                    selector:@selector(checkBindAlways:)
                                                    userInfo:@[bindResult.bike_id, bindResult.device_id]
                                                     repeats:YES];
}

#pragma mark - 需要选择车辆处理
- (void)handleResponseNeedSelectedBikeWithQr_code:(NSString *)qr_code bikeType:(NSInteger)type {
    __weak G100BindDevViewController * wself = self;
    
    NSString *title;
    [wself.optionBikes removeAllObjects];
    [wself.optionBikesName removeAllObjects];
    _bikes = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:self.userid];
    if (wself.bikes.count == 0) {
        [self.optionBikesName addObject:@"新建车辆"];
        title = @"您目前无可选车辆，请先新建车辆";
        
    }else
    {
        for (G100BikeDomain *bikeDomin in wself.bikes) {
            if (type == 1) {
                if (![bikeDomin.devices count]) {
                    /** 不区分主副用户*/
                    [wself.optionBikesName addObject:bikeDomin.name];
                    [wself.optionBikes addObject:bikeDomin];
                }
            }else{
                if (bikeDomin.bike_type != 1 && [bikeDomin.devices count] < 5) {
                    /** 不区分主副用户*/
                    [wself.optionBikesName addObject:bikeDomin.name];
                    [wself.optionBikes addObject:bikeDomin];
                }
            }
        }
        [wself.optionBikesName addObject:@"新建车辆"];
        title = @"您有多部车辆，请选择设备所需安装的车辆";
    }
    [wself.optionPopView showPopingViewWithTitle:title options:wself.optionBikesName noticeType:ClickEventBlockCancel optionsMode:OptionsModeSingle otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
        if (index == 1) {
            //取消
            if ([wself.optionPopView superview]) {
                [wself.optionPopView dismissWithVc:wself animation:YES];
                wself.optionPopView = nil;
            }
            [wself.qrBindVc startScanning];
            
        }else if (index == 2)
        {
            //确定
            if (wself.optionPopView.selectedIndex == 0) {
                [wself showHint:@"请选择一辆车"];
                return;
            }
            if (wself.optionBikes.count == 0 || wself.optionPopView.selectedIndex > wself.optionBikes.count) {
                [wself handleResponseNeedCreateNewBikeWithQr_code:qr_code bikeType:type];
                if ([wself.optionPopView superview]) {
                    [wself.optionPopView dismissWithVc:wself animation:YES];
                    wself.optionPopView = nil;
                }
            }else
            {
                self.isSelectBike = YES;
                G100BikeDomain *bikeDomin = [wself.optionBikes safe_objectAtIndex:wself.optionPopView.selectedIndex-1];
                self.checkBikeid = [NSString stringWithFormat:@"%@", @(bikeDomin.bike_id)];
                if (type == 1 && bikeDomin.bike_type != 1) {
                    G100PromptBox * promptBox = [G100PromptBox promptBoxSureOrCancelAlertView];
                    NSString *text = [NSString stringWithFormat:@"\"%@\"不是摩托车，是否更改为摩托车",bikeDomin.name];
                    [promptBox showBoxWith:@"车型与设备不符" prompt:text sureTitle:@"更改" cancelTitle:@"不更改" sure:^{
                        [wself bindNewDeviceWithUserid:wself.userid bikeid:wself.checkBikeid bikeName:bikeDomin.name qr_code:qr_code];
                        if ([wself.optionPopView superview]) {
                            [wself.optionPopView dismissWithVc:wself animation:YES];
                            wself.optionPopView = nil;
                        }
                    } cancel:nil];
                }else{
                    [wself bindNewDeviceWithUserid:wself.userid bikeid:wself.checkBikeid bikeName:bikeDomin.name qr_code:qr_code];
                    if ([wself.optionPopView superview]) {
                        [wself.optionPopView dismissWithVc:wself animation:YES];
                        wself.optionPopView = nil;
                    }
                }
                
            }
        }
    } onViewController:wself onBaseView:wself.view];
}

#pragma mark - 新建车辆绑定设备
- (void)handleResponseNeedCreateNewBikeWithQr_code:(NSString *)qr_code bikeType:(NSInteger)type
{
    __weak G100BindDevViewController * wself = self;
    self.bikeNamePopView.enterTextfield.placeholder = @"最多10个字";
    [IQKeyHelper setKeyboardDistanceFromTextField:50];
    self.bikeNamePopView.baseScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.bikeNamePopView.baseScrollView.bounds.size.height);
    [wself.bikeNamePopView showPopingViewWithclickEvent:^(NSInteger index) {
        
        if (index == 1) {
            //取消
            [wself.bikeNamePopView.enterTextfield resignFirstResponder];
            if ([wself.bikeNamePopView superview]) {
                [wself.bikeNamePopView dismissWithVc:wself animation:YES];
                wself.bikeNamePopView = nil;
            }
            [wself.qrBindVc startScanning];
        }else if(index == 2)
        {
            [wself.bikeNamePopView.enterTextfield resignFirstResponder];
            if ([NSString checkBikeName:wself.bikeNamePopView.enterTextfield.text]) {
                [wself showHint:[NSString checkBikeName:wself.bikeNamePopView.enterTextfield.text]];
                return;
            }
            NSString *bikeName = wself.bikeNamePopView.enterTextfield.text;
            NSMutableDictionary *bikeInfo = [[NSMutableDictionary alloc] init];
            [bikeInfo setObject:EMPTY_IF_NIL(bikeName) forKey:@"name"];
            [bikeInfo setObject:EMPTY_IF_NIL(wself.userid) forKey:@"user_id"];
            [bikeInfo setObject:[NSNumber numberWithInteger:type] forKey:@"bike_type"];
            [wself showHudInView:wself.view hint:@"正在添加"];
            [[G100BikeApi sharedInstance] addBikeWithUserid:wself.userid bikeInfo:bikeInfo callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                [self hideHud];
                if (requestSuccess) {
                    self.checkBikeid = response.data[@"bike_info"][@"bike_id"];
                    [wself bindNewDeviceWithUserid:wself.userid bikeid:wself.checkBikeid bikeName:bikeName qr_code:qr_code];
                    [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:nil];
                }else {
                    [wself showHint:response.errDesc];
                }
                
            }];
            if ([wself.bikeNamePopView superview]) {
                [wself.bikeNamePopView dismissWithVc:wself animation:YES];
                wself.bikeNamePopView = nil;
            }
            
        }
        
        [IQKeyHelper setKeyboardDistanceFromTextField:12];
        
    } onViewController:wself onBaseView:wself.view];
}

#pragma mark - 更换设备
- (void)bindChangeLocatorWithDevid:(NSString *)devid qr:(NSString *)qr {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        
        if (self.bindMode != 2) {
            // 绑定失败 重启扫描相机
            [self.qrBindVc startScanning];
        }
        
        return;
    }
    __weak G100BindDevViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        wself.bindResultDomain = [[G100DevBindResultDomain alloc] initWithDictionary:response.data];
        if (requestSuccess) {
            G100DevBindResultDomain * bindResult = [[G100DevBindResultDomain alloc] initWithDictionary:response.data];
            
            // 下载主题包中的图片
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:bindResult.channeltheme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                
                G100ThemeInfoBikeModel * themeBikeModel = [theme findThemeInfoBikeModelWithModelid:bindResult.modelid];
                
                NSArray * pic_urlsArr = @[
                                          theme.theme_channel_info.logo_big ? : @"",
                                          theme.theme_channel_info.logo_mid ? : @"",
                                          theme.theme_channel_info.logo_small ? : @"",
                                          themeBikeModel.pic_big ? : @"",
                                          themeBikeModel.pic_small ? : @""
                                          ];
                
                for (NSString * pic_urlstr in pic_urlsArr) {
                    if (!pic_urlstr || !pic_urlstr.length) {
                        continue;
                    }
                    
                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:pic_urlstr] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        
                    }];
                }
            }];
            
            NSArray * pic_urls = @[ bindResult.logo_small ? : @"", bindResult.pic_big ? : @"", bindResult.pic_small ? : @"" ];
            for (NSString * pic_urlstr in pic_urls) {
                if (!pic_urlstr || !pic_urlstr.length) {
                    continue;
                }
                
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:pic_urlstr] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    
                }];
            }
            
            if (_backView) {
                [_backView setBindResult:bindResult];
            }
            
            [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    MBProgressHUDManager *hud = [[MBProgressHUDManager alloc] initWithView:wself.view];
                    void (^overBack)() = ^(){
                        [wself hideBinding];
                        // 模拟更换设备成功
                        if (wself.operationMethod == 1) {
                            NSArray * viewControllers = [wself.navigationController viewControllers];
                            BOOL isExist = NO;
                            for (UIViewController * object in viewControllers) {
                                if ([object isKindOfClass:NSClassFromString(@"G100DevManagementViewController")]) {
                                    isExist = YES;
                                    [wself.navigationController popToViewController:object animated:YES];
                                }
                            }
                            
                            if (!isExist) {
                                [wself.navigationController popViewControllerAnimated:YES];
                            }else {
                                ;
                            }
                        }else {
                            // 模拟更换设备成功
                            [wself.navigationController popToRootViewControllerAnimated:YES];
                        }
                    };
                    
                    [wself.backView stopAnimation];
                    [hud showSuccessWithMessage:@"绑定成功" duration:3.0 complection:overBack];
                }else {
                    [wself hideBinding];
                }
            }];
        }else {
            [wself hideBinding];
            if (response) {
                if (response.errCode == SERV_RESP_BIND_REQUEST_SUBMMITED) {
                    // 请求已提交
                    G100StatusPopingView * popview = [G100StatusPopingView popingViewWithStatusView];
                    NSString * message = [NSString stringWithFormat:@"添加成功，等待主用户%@审核", [NSString shieldImportantInfo:[response.data objectForKey:@"ownerphone"]]];
                    popview.statueLevel = G100StatusPopingViewLevelOk;
                    [popview showPopingViewWithMessage:message confirmTitle:@"我知道了" clickEvent:^(NSInteger index) {
                        if (index == 2) {
                            [wself.navigationController popViewControllerAnimated:YES];
                        }
                    } onViewController:wself onBaseView:wself.view];
                }else if (response.errCode == SERV_RESP_BIND_NEED_ALARM_INFO) {
                    // 返回代码 当为71时，需要将请求参数alertor设为非0值再次调用此接口
                    DLog(@"返回代码 当为71时，需要将请求参数alertor设为非0值再次调用此接口");
                }else {
                    
                    if (response.errCode == SERV_RESP_BIND_ERROR_FAILED) {
                       // [MobClick event:@"bind_failed"];
                    }
                    
                    // 绑定错误提示
                    if (response.errCode == SERV_RESP_BIND_INVALID_QRCODE ||
                        response.errCode == SERV_RESP_BIND_BINDED_CAR ||
                        response.errCode == SERV_RESP_BIND_DEV_ACTIVEING ||
                        response.errCode == SERV_RESP_BIND_ERROR_DEV_BIND ||
                        response.errCode == SERV_RESP_BIND_CAR_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_USER_MAX_BIND ||
                        response.errCode == SERV_RESP_BIND_NO_BIND ||
                        response.errCode == SERV_RESP_BIND_CAR_BIND_VERIFYING)
                    {
                        [wself bindErrorWithResponse:response];
                    }else {
                        [wself showHint:response.errDesc];
                        
                        if (wself.bindMode != 2) {
                            // 绑定失败 重启扫描相机
                            [wself.qrBindVc startScanning];
                        }
                    }
                    
                }
                
            }else {
                if (wself.bindMode != 2) {
                    // 绑定失败 重启扫描相机
                    [wself.qrBindVc startScanning];
                }
            }
        }
    };
    
    [self showBinding];
    [[G100DevApi sharedInstance] changeLocatorWithBikeid:self.bikeid devid:devid qr:qr callback:callback];
    
    // 记录绑定起始时间
    self.bangdingBeginDate = [NSDate date];
}

#pragma mark - 绑定过程中
-(void)showBinding {
    // 先隐藏  防止出错
    [self hideBinding];
    
    BindWaitingView * waitView = [BindWaitingView bindWaitingView];
    [waitView showInVc:self view:self.view animation:YES];
    
    _backView = waitView;
}

-(void)quxiaoWait {
    if (_waitTimer) {
        [self.waitTimer setFireDate:[NSDate distantFuture]];
        [self.waitTimer invalidate];
        self.waitTimer = nil;
    }
    
    [self hideBinding];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)stopWait {
    if ([_backView superview]) {
        [_backView stopAnimation];
    }
    
    [self hideBinding];
}

-(void)hideBinding {
    if (_backView) {
        [_backView dismissWithVc:self animation:YES];
        [_backView removeFromSuperview];
        _backView = nil;
    }
}

-(void)checkBindAlways:(NSTimer *)timer {
    NSString * bikeid = [[timer userInfo] firstObject];
    NSString * devid = [[timer userInfo] lastObject];
    
    if ([self.checkBikeid integerValue] == 0 || [devid integerValue] == 0) {
        [self.waitTimer setFireDate:[NSDate distantFuture]];
        [self.waitTimer invalidate];
        self.waitTimer = nil;
        
        [self hideBinding];
        
        if (self.bindMode != 2) {
            // 绑定失败 重启扫描相机
            [self.qrBindVc startScanning];
        }
    }
    else {
        [self checkBindWithBikeid:bikeid devid:devid];
    }
    
}

-(void)checkBindWithBikeid:(NSString *)bikeid devid:(NSString *)devid {
    // 绑定超时 可能是某些原因，绑定失败    提示用户等待推送绑定结果
    self.bangdingEndDate = [NSDate date];
    NSTimeInterval dis = [_bangdingEndDate timeIntervalSinceDate:_bangdingBeginDate];
    
    if (dis >= kBindTimeOut) {   // 三分钟超时
        [self.waitTimer setFireDate:[NSDate distantFuture]];
        [self.waitTimer invalidate];
        self.waitTimer = nil;
        
        [self hideBinding];
        
        //[self showWarningHint:@"绑定超时, 请稍后再试"];
        
        [self bindErrorWithResponse:nil];
        
        if (self.bindMode != 2) {
            // 绑定失败 重启扫描相机
            [self.qrBindVc startScanning];
        }
    }else {
        __weak G100BindDevViewController * wself = self;
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            if (requestSuccess) {
                [wself.waitTimer setFireDate:[NSDate distantFuture]];
                [wself.waitTimer invalidate];
                wself.waitTimer = nil;
               // _checkResultDomian = [[G100DevCheckBindResultDomain alloc]initWithDictionary:response.data];
                __strong G100BindDevViewController * strongSelf = wself;
                if (wself.isSelectBike) {
                  //首页当前页显示选中绑定的车辆
                  [[UserManager shareManager] updateBikeInfoWithUserid:strongSelf.userid bikeid:strongSelf.checkBikeid updateType:BikeInfoAddType complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                      if (requestSuccess) {
                          MBProgressHUDManager *hud = [[MBProgressHUDManager alloc] initWithView:strongSelf.view];
                          void (^overBack)() = ^(){
                              [strongSelf hideBinding];
                              // 模拟绑定成功
                              if (strongSelf.operationMethod == 1) {
                                  NSArray * viewControllers = [strongSelf.navigationController viewControllers];
                                  BOOL isExist = NO;
                                  for (UIViewController * object in viewControllers) {
                                      if ([object isKindOfClass:[G100DevManagementViewController class]]) {
                                          isExist = YES;
                                          [strongSelf.navigationController popToViewController:object animated:YES];
                                      }
                                  }
                                  
                                  if (!isExist) {
                                      [strongSelf.navigationController popViewControllerAnimated:YES];
                                  }else {
                                      ;
                                  }
                              }else {
                                      // 模拟绑定成功
                                      [strongSelf.navigationController popToRootViewControllerAnimated:YES];
                              }
                          };
                          [strongSelf.backView stopAnimation];
                          [hud showSuccessWithMessage:@"绑定成功" duration:3.0 complection:overBack];
                      }else {
                          [strongSelf hideBinding];
                      }
                  }];
                }else{
                    [[UserManager shareManager] updateBikeListWithUserid:strongSelf.userid updateType:BikeListAddType complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        if (requestSuccess) {
                            MBProgressHUDManager *hud = [[MBProgressHUDManager alloc] initWithView:strongSelf.view];
                            void (^overBack)() = ^(){
                                [strongSelf hideBinding];
                                // 模拟绑定成功
                                if (strongSelf.operationMethod == 1) {
                                    NSArray * viewControllers = [strongSelf.navigationController viewControllers];
                                    BOOL isExist = NO;
                                    for (UIViewController * object in viewControllers) {
                                        if ([object isKindOfClass:[G100DevManagementViewController class]]) {
                                            isExist = YES;
                                            [strongSelf.navigationController popToViewController:object animated:YES];
                                        }
                                    }
                                    
                                    if (!isExist) {
                                        [strongSelf.navigationController popViewControllerAnimated:YES];
                                    }else {
                                        ;
                                    }
                                }else {
                                    // 模拟绑定成功
                                     [strongSelf.navigationController popToRootViewControllerAnimated:YES];
                                }
                            };
                            
                            [strongSelf.backView stopAnimation];
                            [hud showSuccessWithMessage:@"绑定成功" duration:3.0 complection:overBack];
                        }else {
                            [strongSelf hideBinding];
                        }
                    }];
                }
                
                if (wself.operationMethod == 0 || wself.operationMethod == 2) {
                    // 绑定成功后 存储一个key值 在用户回到主页的时候 给一个弹窗告诉用户去绑定微信 开通微信报警提醒
                    [[G100InfoHelper shareInstance] updateNewDevBindSuccessWithUserid:wself.userid
                                                                               bikeid:bikeid
                                                                                devid:devid
                                                                               params:@{}];
                }else if (wself.operationMethod == 1) {
                    
                }else {
                    
                }
                
                if (self.bindMode != 2) {
                    // 绑定失败 重启扫描相机
                    [self.qrBindVc startScanning];
                }
            }else {
                if (response) {
                    if (response.errCode != SERV_RESP_BIND_CAR_ACTIVEING) {
                        [wself hideBinding];
                    }
                    
                    if (response.errCode == SERV_RESP_BIND_REQUEST_SUBMMITED) {
                        // 请求已提交
                        G100StatusPopingView * popview = [G100StatusPopingView popingViewWithStatusView];
                        NSString * message = [NSString stringWithFormat:@"添加成功，等待主用户%@审核", [NSString shieldImportantInfo:[response.data objectForKey:@"ownerphone"]]];
                        popview.statueLevel = G100StatusPopingViewLevelOk;
                        [popview showPopingViewWithMessage:message confirmTitle:@"我知道了" clickEvent:^(NSInteger index) {
                            if (index == 2) {
                                [wself.navigationController popViewControllerAnimated:YES];
                            }
                        } onViewController:wself onBaseView:wself.view];
                    }else {
                        
                        if (response.errCode == SERV_RESP_BIND_ERROR_FAILED) {
                            [self.waitTimer setFireDate:[NSDate distantFuture]];
                            [self.waitTimer invalidate];
                            self.waitTimer = nil;
                            
                            //[MobClick event:@"bind_failed"];
                        }
                        
                        // 绑定错误提示
                        if (response.errCode == SERV_RESP_BIND_ERROR_FAILED || response.errCode == SERV_RESP_BIND_CAR_BIND_VERIFYING)
                        {
                            [wself bindErrorWithResponse:response];
                        }
                        
                    }
                    
                }else {
                    [wself hideBinding];
                    
                    if (wself.bindMode != 2) {
                        // 绑定失败 重启扫描相机
                        [wself.qrBindVc startScanning];
                    }
                }
            }
        };
        
        [[G100DevApi sharedInstance] checkBindWithBikeid:bikeid Devid:devid callback:callback];
    }
}

#pragma mark - 绑定错误提示
- (void)bindErrorWithResponse:(ApiResponse *)response {
    BindErrorView * kBindErrorView = [BindErrorView bindErrorViewWithErrorCode:response.errCode response:response];
    kBindErrorView.bindResultDomain = self.bindResultDomain;
    
    __weak G100BindDevViewController * wself = self;
    kBindErrorView.bindErrorViewExit = ^(){
        NSArray * vcs = wself.navigationController.viewControllers;
        
        NSInteger index = vcs.count - 1;
        if (wself.bindMode != 2) {
            index -= 1;
        }else {
            index -= 2;
        }
        if (index < 0) {
            index = 0;
        }
        [wself.navigationController popToViewController:vcs[index] animated:YES];
    };
    
    kBindErrorView.bindErrorViewRebind = ^(){
        if (wself.bindMode != 2) {
            // 绑定失败 重启扫描相机
            [wself.qrBindVc startScanning];
        }
    };
    
    [kBindErrorView showInVc:self view:self.view animation:YES];
    self.kBindErrorView = kBindErrorView;
}

- (void)webRebindNotificationDidRecieved {
    if ([self.kBindErrorView superview]) {
        [self.kBindErrorView dismissWithVc:self animation:YES];
    }
    if (self.bindMode != 2) {
        // 绑定失败 重启扫描相机
        [self.qrBindVc startScanning];
    }
}
- (void)bindfailedNotificationDidReceived
{
    _bindFailed = YES;

}
- (void)applicationWillResignActive:(NSNotification *)notification
{
    _bindFailed = NO;
    [self.waitTimer setFireDate:[NSDate distantFuture]];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (_bindFailed) {
        [self.waitTimer setFireDate:[NSDate distantFuture]];
        [self.waitTimer invalidate];
        self.waitTimer = nil;
        [self hideBinding];
        [self bindErrorWithResponse:nil];
        _bindFailed = NO;
    }else{
        [self.waitTimer setFireDate:[NSDate distantPast]];
    }
}
- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webRebindNotificationDidRecieved)
                                                 name:kGNRebindNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindfailedNotificationDidReceived)
                                                 name:kGNDevBindFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     kGNRebindNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     kGNDevBindFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:
     UIApplicationDidBecomeActiveNotification object:nil];
}
#pragma mark - Life Cycle
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasAppear) {
        if (_qrcode) {
            // 带着qrcode 首次进入页面 表示外部跳转过来扫描
            if (_bikeid && !_devid) {
                // 绑定车辆
                [self bindNewBikeWithQr_code:_qrcode];
            }else if (!_bikeid && _devid) {
                // 绑定设备
                [self bindNewDeviceWithDevid:_devid];
            }else {
                // 其他
            }
        }
    }
    self.hasAppear = YES;
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
