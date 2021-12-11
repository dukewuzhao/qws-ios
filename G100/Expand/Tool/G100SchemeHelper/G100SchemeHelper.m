//
//  G100SchemeHelper.m
//  G100
//
//  Created by yuhanle on 16/3/10.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100SchemeHelper.h"
#import "ExtString.h"
#import "G100UrlManager.h"

#import "G100Mediator+GPS.h"
#import "G100Mediator+ServiceStatus.h"
#import "G100Mediator+SecuritySetting.h"

#import "G100Mediator+BikeDetail.h"
#import "G100Mediator+BikeReport.h"
#import "G100Mediator+PersonProfile.h"

#import "G100Mediator+Insurance.h"
#import "G100Mediator+Order.h"
#import "G100Mediator+Login.h"
#import "G100Mediator+WebBrowser.h"
#import "G100Mediator+ScanCode.h"
#import "G100Mediator+InsuranceOrders.h"
#import "G100Mediator+DeviceDetail.h"
#import "G100Mediator+Management.h"
#import "G100Mediator+MyGarage.h"
#import "G100Mediator+BuyService.h"
#import "G100Mediator+QWSMall.h"
#import "G100Mediator+BikeEdit.h"
#import "G100Mediator+DevUpdate.h"

#import "G100BindDevViewController.h"
#import "G100DevUpdateViewController.h"
#import "G100PayOrderViewController.h"

#import "G100SchemeDefinition.h"

static NSString * const kQWSAppProtocol             = @"qwsapp";

static NSString * const kQWSHostHome                = @"home";
static NSString * const kQWSHostBike                = @"bike";
static NSString * const kQWSHostMy                  = @"profile";

static NSString * const kRouterParametersSourceApp    = @"sourceApp";
static NSString * const kRouterParametersBackScheme   = @"backScheme";
static NSString * const kRouterParametersUserid       = @"userid";
static NSString * const kRouterParametersBikeid       = @"bikeid";
static NSString * const kRouterParametersDevid        = @"devid";
static NSString * const kRouterParametersOrderid      = @"orderid";
static NSString * const kRouterParametersCloseCurrent = @"close";


@interface G100SchemeHelper ()

/** 程序是否完全激活 指的是广告结束 完全进入首页以后*/
@property (nonatomic, assign) BOOL appHasActived;
@property (nonatomic, strong) NSDictionary *routerParameters;
@property (nonatomic, copy) G100RouterHandler handler;

@end

@implementation G100SchemeHelper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNDIDShowMainView object:nil];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceTonken;
    static G100SchemeHelper * instance = nil;
    dispatch_once(&onceTonken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // 监听消息
        self.appHasActived = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tl_mainViewDidShow:)
                                                     name:kGNDIDShowMainView
                                                   object:nil];
    }
    
    return self;
}

- (void)tl_mainViewDidShow:(NSNotification *)notification {
    _appHasActived = YES;
    
    if (_routerParameters && _handler) {
        // 主页面加载以后 延时跳转
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.handler(self.routerParameters);
                self.routerParameters = nil;
                self.handler = nil;
            });
        });
    }
}

- (void)addQwsScheme {
    // 未知页面
    [G100Router registerURLPattern:kGSDAPPScheme toHandler:^(NSDictionary *routerParameters) {
        DLog(@"没有人处理该 URL，就只能 fallback 到这里了");
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        NSString *result = [G100SchemeDefinition exchangeToUrlPrefix:routerParameters];
        if (result && [G100Router canOpenURL:result]) {
            [G100Router openURL:result];
        }else {
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                          bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                         httpUrl:result
                                                                                                                          params:routerParameters];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        }
    }];
    
    // 拨打电话
    [G100Router registerURLPattern:@"qwsapp://tel" toHandler:^(NSDictionary *routerParameters) {
        NSString *pn = routerParameters[@"pn"];
        
        if (pn.length) {
            NSURL *opUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", pn]];
            if ([[UIApplication sharedApplication] canOpenURL:opUrl]) {
                [[UIApplication sharedApplication] openURL:opUrl];
            };
        } else {
            DLog(@"无法获取电话号码");
        }
    }];
    
    //TODO: 跳转类路由
    // Web 页面跳转
    [G100Router registerURLPattern:@"http://" toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                      bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                     httpUrl:routerParameters[G100RouterParameterURL]
                                                                                                                      params:routerParameters];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    // Web 安全页面跳转
    [G100Router registerURLPattern:@"https://" toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                      bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                     httpUrl:routerParameters[G100RouterParameterURL]
                                                                                                                      params:routerParameters];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 主页
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"home"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
    }];
    
    // 实时追踪
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"bike/trace"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForGPS:routerParameters[kRouterParametersUserid]
                                                                                                     bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                      devid:routerParameters[kRouterParametersDevid]];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
  
    // 车辆设置
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"bike/setting"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForSecuritySetting:routerParameters[kRouterParametersUserid]
                                                                                                                 bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                  devid:routerParameters[kRouterParametersDevid]];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 服务状态
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"bike/state"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForServiceStatus:routerParameters[kRouterParametersUserid]
                                                                                                               bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                devid:routerParameters[kRouterParametersDevid]];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];

    // 用车报告
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"bike/report"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeReport:routerParameters[kRouterParametersUserid]
                                                                                                            bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                             devid:routerParameters[kRouterParametersDevid]];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 我的
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForPersonProfile:routerParameters[kRouterParametersUserid] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (loginSuccess && viewController) {
                [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
            }
        }];
    }];
    
    // 我的车库
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/bikes"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForMyGarageWithUserid:routerParameters[kRouterParametersUserid] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (loginSuccess && viewController) {
                [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
            }
        }];
    }];
    
    // 车辆详情
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/bikes/detail"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        if ([routerParameters[G100RouterParameterURL] hasContainString:@"devid"]) {
            // 为了兼容1.0 版本重启设备的需求
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForDeviceDetail:routerParameters[kRouterParametersUserid]
                                                                                                                  bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                   devid:routerParameters[kRouterParametersDevid]];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        } else {
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeDetail:routerParameters[kRouterParametersUserid]
                                                                                                                bikeid:routerParameters[kRouterParametersBikeid]];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        }
    }];
    
    // 我的保险
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/insurance"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForInsurance:routerParameters[kRouterParametersUserid] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (loginSuccess && viewController) {
                [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
            }
        }];
    }];
    
    // 保单详情
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/insurance/detail"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        // 1.0 废弃 目前打开web 页面实现保单详情
        // [[G100SchemeHelper shareInstance] handleOpenResultWithRouterParameters:routerParameters];
        
        // 2.0 需要根据其中的参数 拼接出保单详情的url
        NSString *result = [[G100UrlManager sharedInstance] getInsuranceOrderDetailWithUserid:routerParameters[kRouterParametersUserid]
                                                                                       bikeid:routerParameters[kRouterParametersBikeid]
                                                                                      orderid:routerParameters[kRouterParametersOrderid]];
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                      bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                     httpUrl:result
                                                                                                                      params:routerParameters];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 我的订单
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/orders"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForOrder:routerParameters[kRouterParametersUserid] loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (loginSuccess && viewController) {
                [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
            }
        }];
    }];
    
    // 我的保单列表
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/insuranceorders"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForInsuranceOrdersWithUserid:routerParameters[kRouterParametersUserid]
                                                                                        params:routerParameters
                                                                                  loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (loginSuccess && viewController) {
                [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
            }
        }];
    }];
    
    // 用户与设备管理页面
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/bikes/userdevs"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForManagement:routerParameters[kRouterParametersUserid]
                                                                                                            bikeid:routerParameters[kRouterParametersBikeid]];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 设备详情页面
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/bikes/device/detail"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForDeviceDetail:routerParameters[kRouterParametersUserid]
                                                                                                              bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                               devid:routerParameters[kRouterParametersDevid]];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 购买服务
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"service/buy"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForBuyServiceUserid:routerParameters[kRouterParametersUserid] params:routerParameters loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (loginSuccess && viewController) {
                [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
            }
        }];
    }];
    
    // 支付
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"pay"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        G100PayOrderViewController *viewController = [G100PayOrderViewController loadXibViewController];
        viewController.userid = routerParameters[kRouterParametersUserid];
        viewController.bikeid = routerParameters[kRouterParametersBikeid];
        viewController.devid = routerParameters[kRouterParametersDevid];
        viewController.orderid = routerParameters[kRouterParametersOrderid];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 骑卫士商城跳转
    [G100Router registerURLPattern:@"qwsapp://mall/" toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters needLogin:NO]) {
            return;
        }
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForQWSMallWithParams:routerParameters];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    // 跳转至车辆编辑页面
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/bikes/detail/edit"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeEdit:routerParameters[kRouterParametersUserid]
                                                                       bikeid:routerParameters[kRouterParametersBikeid]
                                                                 entranceFrom:0
                                                                 loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                                                                     if (loginSuccess && viewController) {
                                                                         [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
                                                                     }
        }];
    }];
    // 跳转至OTA升级
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDPushScheme,@"profile/bikes/device/update"] toHandler:^(NSDictionary *routerParameters) {
        DLog(@"%@", [NSString stringWithFormat:@"routerParameters:%@", routerParameters]);
        if (![[G100SchemeHelper shareInstance] canHandleResultWithRouterParameters:routerParameters]) {
            return;
        }
        if (![[CURRENTVIEWCONTROLLER class] isSubclassOfClass:[G100DevUpdateViewController class]]) {
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForDevUpdate:routerParameters[kRouterParametersUserid]
                                                                                                               bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                devid:routerParameters[kRouterParametersDevid]];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        }
    }];
    
    //TODO: 操作类路由
    // 统一错误处理
    [G100Router registerURLPattern:kGSDHostScheme toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                      bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                     httpUrl:routerParameters[G100RouterParameterURL]
                                                                                                                      params:routerParameters];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    [G100Router registerURLPattern:[kGSDHostScheme stringByAppendingString:@"action"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                      bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                     httpUrl:routerParameters[G100RouterParameterURL]
                                                                                                                      params:routerParameters];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDActionHost,@"bind"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                      bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                     httpUrl:routerParameters[G100RouterParameterURL]
                                                                                                                      params:routerParameters];
        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
    }];
    [G100Router registerURLPattern:[kGSDAPPScheme stringByAppendingString:@"action"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        NSString *result = [G100SchemeDefinition exchangeToUrlPrefix:routerParameters];
        if (result && [G100Router canOpenURL:result]) {
            [G100Router openURL:result];
        }else {
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                          bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                         httpUrl:result
                                                                                                                          params:routerParameters];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        }
    }];
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDActionScheme,@"bind"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        NSString *result = [G100SchemeDefinition exchangeToUrlPrefix:routerParameters];
        if (result && [G100Router canOpenURL:result]) {
            [G100Router openURL:result];
        }else {
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                          bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                         httpUrl:result
                                                                                                                          params:routerParameters];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        }
    }];
    // 绑定车辆
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDActionHost,@"bind/bike"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        NSString *result = [G100SchemeDefinition exchangeToScheme:routerParameters];
        if (result && [G100Router canOpenURL:result]) {
            [G100Router openURL:result];
        }else {
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                          bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                         httpUrl:routerParameters[G100RouterParameterURL]
                                                                                                                          params:routerParameters];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        }
    }];
    
    // 绑定设备
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDActionHost,@"bind/device"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        NSString * result = [G100SchemeDefinition exchangeToScheme:routerParameters];
        if (result && [G100Router canOpenURL:result]) {
            [G100Router openURL:result];
        }else {
            UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForWebBrowserWithUserid:routerParameters[kRouterParametersUserid]
                                                                                                                          bikeid:routerParameters[kRouterParametersBikeid]
                                                                                                                         httpUrl:routerParameters[G100RouterParameterURL]
                                                                                                                          params:routerParameters];
            [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
        }
    }];
    
    // 绑定车辆
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDActionScheme,@"bind/bike"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        NSString * parameterURL   = routerParameters[G100RouterParameterURL];
        
        NSDictionary * dict       = [parameterURL paramsFromURL];
        NSArray * uriArray        = dict[URI];
        
        if ([uriArray lastObject]) {
            // 这里是我们需要的参数
            if ([CURRENTVIEWCONTROLLER isKindOfClass:[NSClassFromString(@"G100BindDevViewController") class]]) {
                [((G100BindDevViewController *)CURRENTVIEWCONTROLLER) bindNewBikeWithQr_code:[uriArray lastObject]];
            }else {
                [[G100Mediator sharedInstance] G100Mediator_viewControllerForScanCode:[G100InfoHelper shareInstance].buserid bikeid:[uriArray lastObject] bindMode:3 loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                    if (loginSuccess && viewController) {
                        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
                    }
                }];
            }
        }else {
            
        }
        
    }];
    
    // 绑定设备
    [G100Router registerURLPattern:[NSString stringWithFormat:KSDActionScheme,@"bind/device"] toHandler:^(NSDictionary *routerParameters) {
        if (![[G100SchemeHelper shareInstance] canHandleActionResultWithRouterParameters:routerParameters]) {
            return;
        }
        
        NSString * parameterURL   = routerParameters[G100RouterParameterURL];
        
        NSDictionary * dict       = [parameterURL paramsFromURL];
        NSArray * uriArray        = dict[URI];
        
        if ([uriArray lastObject]) {
            // 这里是我们需要的参数
            if ([CURRENTVIEWCONTROLLER isKindOfClass:[NSClassFromString(@"G100BindDevViewController") class]]) {
                [((G100BindDevViewController *)CURRENTVIEWCONTROLLER) bindNewDeviceWithDevid:[uriArray lastObject]];
            }else {
                [[G100Mediator sharedInstance] G100Mediator_viewControllerForScanCode:[G100InfoHelper shareInstance].buserid devid:[uriArray lastObject] bindMode:3 loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                    if (loginSuccess && viewController) {
                        [APPDELEGATE.mainNavc pushViewController:viewController animated:YES];
                    }
                }];
            }
        }else {
            
        }
    }];
}

- (void)handleOpenResultWithRouterParameters:(NSDictionary *)routerParameters {
    NSString * sourceApp  = routerParameters[kRouterParametersSourceApp];
    NSString * backScheme = routerParameters[kRouterParametersBackScheme];
    NSString * userid     = routerParameters[kRouterParametersUserid];
    //TODO: 切换正确的设备id
    NSString * devid      = routerParameters[kRouterParametersBikeid];
    BOOL closeCurrent     = [routerParameters[kRouterParametersCloseCurrent] boolValue];
    
    NSString * parameterURL   = routerParameters[G100RouterParameterURL];
    
    NSDictionary * dict       = [parameterURL paramsFromURL];
    NSString * protocolString = dict[PROTOCOL];
    NSString * hostString     = dict[HOST];
    NSArray * uriArray        = dict[URI];
    
    NSString * uriString = nil;
    if ([uriArray count] == 1) {
        // 若为 “/” 就是host主页
        uriString = uriArray[0];
    }else if ([uriArray count] >= 2) {
        // 一级 path
        uriString = uriArray[1];
    }
    
    BOOL hasBackScheme = NO;
    
    UIViewController * rootVc = CURRENTVIEWCONTROLLER;
    
    if (![protocolString isEqualToString:kQWSAppProtocol]) {
        DLog(@"未知协议");
#if DEBUG
        [rootVc showHint:@"未知协议"];
#endif
        return;
    }
    
    if (!sourceApp) {
        DLog(@"sourceApp 为必填项，请确认");
#if DEBUG
        [rootVc showHint:@"sourceApp 为必填项，请确认"];
#endif
        return;
    }
    
    if (!backScheme) {
        DLog(@"backScheme 未填写，请确认");
        hasBackScheme = NO;
    }else {
        hasBackScheme = YES;
    }
    
    if (!userid) {
        DLog(@"userid 为必填项，请确认");
#if DEBUG
        [rootVc showHint:@"userid 为必填项，请确认"];
#endif
        return;
    }
    
    if (!IsLogin()) {
        [rootVc showHint:@"未登录"];
        return;
    }
    
    if (![userid isEqualToString:[[G100InfoHelper shareInstance] buserid]]) {
        DLog(@"userid 匹配错误 请退出到登陆界面");
        [MyAlertView MyAlertWithTitle:@"提示" message:@"需要切换当前帐号到您的帐号才能使用相关功能，请先登录您的帐号" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UserManager shareManager] logoff];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                }];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"立即登录"];
        
        return;
    }
    
    G100BikeDomain * bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:userid bikeid:devid];
    if ([hostString isEqualToString:kQWSHostHome]) {
        // 主页host
        if ([uriString isEqualToString:@"/"]) {
            // 根 没有uri  切换当前车辆
            DLog(@"跳转到主页");
            [APPDELEGATE.mainNavc popToRootViewControllerAnimated:YES];
        }else {
            
        }
    }else if ([hostString isEqualToString:kQWSHostBike]) {
        // 车辆host
        if (!devid) {
            DLog(@"车辆id为必填项");
            [rootVc showHint:@"车辆id为必填项，请确认"];
            return;
        }
        
        if (!IsBind()) {
            DLog(@"用户没有绑定任何车辆，请先绑定车辆");
            [rootVc showHint:@"用户没有绑定任何车辆，请先绑定车辆"];
            return;
        }
        
        BOOL isExsit = (bikeDomain == nil ? NO : YES);
        if (!isExsit) {
            [rootVc showHint:@"车辆未绑定"];
            return;
        }
        
        if ([uriString isEqualToString:@"/"]) {
            DLog(@"其实也是主页");
            
        }else {
            NSString * pageClass = nil;
            NSString * tmp = uriString;
            
            if ([tmp isEqualToString:@"trace"]) {
                DLog(@"实时追踪");
                pageClass = @"G100DevGPSViewController";
            }else if ([tmp isEqualToString:@"setting"]) {
                DLog(@"车辆设置");
                pageClass = @"G100FunctionViewController";
            }else if ([tmp isEqualToString:@"state"]) {
                DLog(@"服务状态");
                pageClass = @"G100ServiceViewController";
            }else if ([tmp isEqualToString:@"report"]) {
                DLog(@"用车报告");
                pageClass = @"G100DevLogsViewController";
            }else {
                DLog(@"无法解析");
            }
            
            if (!pageClass) {
                return;
            }else {
                G100BaseVC * aPage = [[NSClassFromString(pageClass) alloc] init];
                if ([aPage respondsToSelector:@selector(setDevid:)]) {
                    [aPage setValue:devid forKey:@"devid"];
                }
                
                if ([aPage respondsToSelector:@selector(setUserid:)]) {
                    [aPage setValue:userid forKey:@"userid"];
                }
                
                if (hasBackScheme) {
                    __weak UIViewController * weakPage = aPage;
                    aPage.schemeOverBlock = ^(){
                        __strong UIViewController * strongPage = weakPage;
                        [APPDELEGATE.mainNavc setViewControllers:@[APPDELEGATE.mainViewController, strongPage] animated:NO];
                    };
                }else {
                    // 正常跳转
                    NSMutableArray *navs = [[APPDELEGATE.mainNavc viewControllers] mutableCopy];
                    BOOL hasOldVC = NO;
                    UIViewController *oldVC = nil;
                    for (UIViewController *vc in navs) {
                        if ([vc isKindOfClass:[aPage class]]) {
                            hasOldVC = YES;
                            oldVC    = vc;
                            break;
                        }
                    }
                    
                    if (hasOldVC) {
                        [APPDELEGATE.mainNavc popToViewController:oldVC animated:YES];
                    }else {
                        if (closeCurrent) {
                            [navs removeLastObject];
                        }
                        
                        [navs addObject:aPage];
                        [APPDELEGATE.mainNavc setViewControllers:navs.copy animated:YES];
                    }
                }
            }
        }
    }else if ([hostString isEqualToString:kQWSHostMy]) {
        // 我的host
        if ([uriString isEqualToString:@"/"]) {
            DLog(@"我的主页");
            [APPDELEGATE.mainNavc popToRootViewControllerAnimated:YES];
        }else {
            NSString * pageClass = nil;
            NSString * tmp = uriString;
            NSString * orderid = nil;
            
            if ([tmp isEqualToString:@"bikes"]) {
                DLog(@"我的车辆");
                pageClass = @"G100CarManageViewController";
                if ([uriArray count] == 3) {
                    if ([[uriArray lastObject] isEqualToString:@"detail"]) {
                        pageClass = @"G100DevDetailsViewController";
                    }
                }
            }else if ([tmp isEqualToString:@"insurance"]) {
                DLog(@"我的保险");
                pageClass = @"G100MyInsurancesViewController";
                if ([uriArray count] == 3) {
                    if ([[uriArray lastObject] isEqualToString:@"detail"]) {
                        orderid = routerParameters[kRouterParametersOrderid];
                        // pageClass = @"MyInsuranceDetailViewController";
                    }
                }
            }else if ([tmp isEqualToString:@"orders"]) {
                DLog(@"我的订单");
                pageClass = @"G100MyOrderViewController";
            }else {
                DLog(@"无法解析");
            }
            
            if (!pageClass) {
                return;
            }else {
                G100BaseVC * aPage = [[NSClassFromString(pageClass) alloc] init];
                if ([aPage respondsToSelector:@selector(setDevid:)]) {
                    [aPage setValue:devid forKey:@"devid"];
                }
                if ([aPage respondsToSelector:@selector(setUserid:)]) {
                    [aPage setValue:userid forKey:@"userid"];
                }
                if (orderid && orderid.length) {
                    [aPage setValue:orderid forKey:@"orderid"];
                }
                
                if (hasBackScheme) {
                    __weak UIViewController * weakPage = aPage;
                    aPage.schemeOverBlock = ^(){
                        __strong UIViewController * strongPage = weakPage;
                        [APPDELEGATE.mainNavc setViewControllers:@[APPDELEGATE.mainViewController, strongPage] animated:NO];
                    };
                }else {
                    // 正常跳转
                    NSMutableArray *navs = [[APPDELEGATE.mainNavc viewControllers] mutableCopy];
                    BOOL hasOldVC = NO;
                    UIViewController *oldVC = nil;
                    for (UIViewController *vc in navs) {
                        if ([vc isKindOfClass:[aPage class]]) {
                            hasOldVC = YES;
                            oldVC    = vc;
                            break;
                        }
                    }
                    
                    if (hasOldVC) {
                        [APPDELEGATE.mainNavc popToViewController:oldVC animated:YES];
                    }else {
                        if (closeCurrent) {
                            [navs removeLastObject];
                        }
                        
                        [navs addObject:aPage];
                        [APPDELEGATE.mainNavc setViewControllers:navs.copy animated:YES];
                    }
                }
            }
        }
    }
}

- (BOOL)canHandleActionResultWithRouterParameters:(NSDictionary *)routerParameters {
    if (!self.appHasActived) {
        self.routerParameters = routerParameters;
        self.handler = routerParameters[G100RouterParameterRegisterCompletion];
        return NO;
    }
    
    void (^routerParameterCompletion)(id result) = routerParameters[G100RouterParameterCompletion];
    if (routerParameterCompletion) {
        routerParameterCompletion(@(YES));
    }
    
    return YES;
}

- (BOOL)canHandleResultWithRouterParameters:(NSDictionary *)routerParameters {
    return [self canHandleResultWithRouterParameters:routerParameters needLogin:YES];
}

- (BOOL)canHandleResultWithRouterParameters:(NSDictionary *)routerParameters needLogin:(BOOL)needLogin {
    if (!self.appHasActived) {
        self.routerParameters = routerParameters;
        self.handler = routerParameters[G100RouterParameterRegisterCompletion];
        return NO;
    }
    
    void (^routerParameterCompletion)(id result) = routerParameters[G100RouterParameterCompletion];
    
    NSString * sourceApp  = routerParameters[kRouterParametersSourceApp];
    NSString * backScheme = routerParameters[kRouterParametersBackScheme];
    NSString * userid     = routerParameters[kRouterParametersUserid];
    
    NSString * parameterURL   = routerParameters[G100RouterParameterURL];
    
    NSDictionary * dict       = [parameterURL paramsFromURL];
    NSString * protocolString = dict[PROTOCOL];
    
    BOOL hasBackScheme = NO;
    
    UIViewController * rootVc  = CURRENTVIEWCONTROLLER;
    
    if (![protocolString isEqualToString:kQWSAppProtocol]) {
        DLog(@"未知协议");
#if DEBUG
        [rootVc showHint:@"未知协议"];
#endif
        if (routerParameterCompletion) {
            routerParameterCompletion(@(NO));
        }
        return NO;
    }
    
    if (!sourceApp) {
        DLog(@"sourceApp 为必填项，请确认");
#if DEBUG
        [rootVc showHint:@"sourceApp 为必填项，请确认"];
#endif
        if (routerParameterCompletion) {
            routerParameterCompletion(@(NO));
        }
        return NO;
    }
    
    if (!backScheme) {
        DLog(@"backScheme 未填写，请确认");
        hasBackScheme = NO;
    }else {
        hasBackScheme = YES;
    }
    
    // 判断跳转是否需要登录
    if (!needLogin) {
        if (routerParameterCompletion) {
            routerParameterCompletion(@(YES));
        }
        return YES;
    }
    
    if (!userid) {
        DLog(@"userid 为必填项，请确认");
#if DEBUG
        [rootVc showHint:@"userid 为必填项，请确认"];
#endif
        if (routerParameterCompletion) {
            routerParameterCompletion(@(NO));
        }
        return NO;
    }
    
    if (!IsLogin()) {
        [rootVc showHint:@"未登录"];
        if (routerParameterCompletion) {
            routerParameterCompletion(@(NO));
        }
        return NO;
    }
    
    if (![userid isEqualToString:[G100InfoHelper shareInstance].buserid]) {
        DLog(@"userid 匹配错误 请退出到登陆界面");
        [MyAlertView MyAlertWithTitle:@"提示" message:@"需要切换当前帐号到您的帐号才能使用相关功能，请先登录您的帐号" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UserManager shareManager] logoff];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                }];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"立即登录"];
        
        if (routerParameterCompletion) {
            routerParameterCompletion(@(NO));
        }
        return NO;
    }
    
    if (routerParameterCompletion) {
        routerParameterCompletion(@(YES));
    }
    return YES;
}

@end
