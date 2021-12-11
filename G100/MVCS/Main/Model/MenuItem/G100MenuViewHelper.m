//
//  G100MenuViewHelper.m
//  G100
//
//  Created by 曹晓雨 on 2018/1/23.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "G100MenuViewHelper.h"
#import "G100Mediator+MsgCenter.h"
#import "G100Mediator+MyGarage.h"
#import "G100Mediator+Insurance.h"
#import "G100Mediator+Order.h"
#import "G100Mediator+MapService.h"
#import "G100UrlManager.h"
#import "DatabaseOperation.h"
#import "InsuranceCheckService.h"
#import "MsgCenterHelper.h"

@interface G100MenuViewHelper ()

@property (nonatomic, strong) MenuItem *msgCenterItem;
@property (nonatomic, strong) MenuItem *myCarportItem;
@property (nonatomic, strong) MenuItem *myInsuranceItem;
@property (nonatomic, strong) MenuItem *myOrderItem;
@property (nonatomic, strong) MenuItem *storeServiceItem;
@property (nonatomic, strong) MenuItem *offlineMapItem;
@property (nonatomic, strong) MenuItem *userHelpItem;
@property (nonatomic, strong) MenuItem *aboutHelpItem;

@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSArray <MenuItem *>*menuItemArr;

@end

static NSString * const kMenuItemMsgCenter     = @"我的消息";
static NSString * const kMenuItemMyCarport     = @"我的车库";
static NSString * const kMenuItemMyInsurance   = @"我的保险";
static NSString * const kMenuItemMyOrder       = @"我的订单";
static NSString * const kMenuItemStoreService  = @"门店服务";
static NSString * const kMenuItemUserHelp      = @"用户反馈";
static NSString * const kMenuItemOfflineMap    = @"离线地图";
static NSString * const kMenuItemAbout         = @"关于";

@implementation G100MenuViewHelper

- (instancetype)init {
    if (self = [super init]) {
        //观察消息中心未读消息
        [self.KVOController observe:[MsgCenterHelper sharedInstace] keyPath:@"unReadMsgCount" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            NSInteger messageNum = [MsgCenterHelper sharedInstace].unReadMsgCount;
            NSString *desc = messageNum > 0 ? [NSString stringWithFormat:@"%@", @(messageNum)] : @"";
            BOOL needNoticeDot = messageNum > 0 ? YES : NO;
            self.msgCenterItem.itemDesc = desc;
            self.msgCenterItem.needNoticeDot = needNoticeDot;
            
            self.menuView.menuItemArr = self.menuItemArr;
        }];
        
        //观察待领取的消息
        [self.KVOController observe:[InsuranceCheckService sharedService] keyPath:@"lingquCount" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            NSString *desc = @"";
            if ([InsuranceCheckService sharedService].lingquCount && IsLogin()) {
                desc = @"免费领取";
            }
            BOOL needNoticeDot = IsLogin() ? [InsuranceCheckService sharedService].totalCount : NO;
            self.myInsuranceItem.needNoticeDot = needNoticeDot;
            self.myInsuranceItem.itemDesc = desc;
            
            self.menuView.menuItemArr = self.menuItemArr;
        }];
    }
    return self;
}

#pragma mark - Public Method
- (void)setMenuItemArr:(NSArray *)menuItemArr {
    _menuItemArr = menuItemArr;
    
    if (self.menuView) {
        self.menuView.userid = self.userid;
        self.menuView.menuItemArr = _menuItemArr;
    }
}

- (void)reloadMenuItemsWithUserid:(NSString *)userid {
    self.userid = userid;
    
    BOOL showMyInsurance = YES;
    BOOL hasChinaMobile = NO;
    BOOL hasNormalDev = NO;
    
    NSArray *bikesArray = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:self.userid];
    for (G100BikeDomain *bike in bikesArray) {
        NSArray *allDevsArr = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:[NSString stringWithFormat:@"%@", @(bike.bike_id)]];
        for (G100DeviceDomain *deviceDomain in allDevsArr) {
            if ([deviceDomain isChinaMobileCustomMode]) {
                hasChinaMobile  = YES;
            }else {
                hasNormalDev = YES;
            }
        }
    }
    
    if (hasChinaMobile && !hasNormalDev) {
        showMyInsurance = NO;
    }
    
    NSMutableArray *menuItemArr = [NSMutableArray array];
    if (showMyInsurance) {
        [menuItemArr addObjectsFromArray:@[ self.msgCenterItem,
                                            self.myCarportItem,
                                            self.myInsuranceItem,
                                            self.myOrderItem,
                                            self.storeServiceItem,
                                            self.userHelpItem ]];
    }else {
        [menuItemArr addObjectsFromArray:@[ self.msgCenterItem,
                                            self.myCarportItem,
                                            self.myOrderItem,
                                            self.storeServiceItem,
                                            self.userHelpItem ]];
    }
    
    self.menuItemArr = menuItemArr;
    [self refreshMessageNum];
}

- (void)refreshMessageNum {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[MsgCenterHelper sharedInstace] loadUnReadMsgStatusWithUserid:self.userid success:nil];
    });
}

#pragma mark - Lazy load
- (MenuItem *)msgCenterItem {
    if (!_msgCenterItem) {
        _msgCenterItem = [MenuItem itemWithName:kMenuItemMsgCenter desc:nil iconName:@"menu_message" needNoticeDot:NO selectedCallback:^{
            [[G100Mediator sharedInstance] G100Mediator_viewControllerForMsgCenter:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                if (loginSuccess && viewController) {
                    [CURRENTVIEWCONTROLLER.navigationController pushViewController:viewController animated:YES];
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }
            }];
        }];
        
    }
    return _msgCenterItem;
}
- (MenuItem *)myCarportItem {
    if (!_myCarportItem) {
        _myCarportItem = [MenuItem itemWithName:kMenuItemMyCarport iconName:@"menu_garage" selectedCallback:^{
            if (![UserAccount sharedInfo].appfunction.insurance.enable && IsLogin()) {
                return;
            };
            
            [[G100Mediator sharedInstance] G100Mediator_viewControllerForMyGarageWithUserid:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                if (loginSuccess && viewController) {
                    [CURRENTVIEWCONTROLLER.navigationController pushViewController:viewController animated:YES];
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }
            }];
        }];
    }
    return _myCarportItem;
}
- (MenuItem *)myInsuranceItem {
    if (!_myInsuranceItem) {
        _myInsuranceItem = [MenuItem itemWithName:kMenuItemMyInsurance desc:nil iconName:@"menu_insurance" needNoticeDot:NO selectedCallback:^{
            if (![UserAccount sharedInfo].appfunction.insurance.enable && IsLogin()) {
                return;
            };
            [[G100Mediator sharedInstance] G100Mediator_viewControllerForInsurance:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                if (loginSuccess && viewController) {
                    [CURRENTVIEWCONTROLLER.navigationController pushViewController:viewController animated:YES];
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }
            }];
        }];
    }
    return _myInsuranceItem;
}
- (MenuItem *)myOrderItem {
    if (!_myOrderItem) {
        _myOrderItem = [MenuItem itemWithName:kMenuItemMyOrder iconName:@"menu_order" selectedCallback:^{
            if (![UserAccount sharedInfo].appfunction.myorders.enable && IsLogin()) {
                return;
            };
            [[G100Mediator sharedInstance] G100Mediator_viewControllerForOrder:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                if (loginSuccess && viewController) {
                    [CURRENTVIEWCONTROLLER.navigationController pushViewController:viewController animated:YES];
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }
            }];
        }];
    }
    return _myOrderItem;
}
- (MenuItem *)storeServiceItem {
    if (!_storeServiceItem) {
        _storeServiceItem = [MenuItem itemWithName:kMenuItemStoreService iconName:@"menu_map" selectedCallback:^{
            NSString *httpUrl = [[G100UrlManager sharedInstance] getMapServiceDetailWithUserid:self.userid type:@"0"];
            [[G100Mediator sharedInstance] G100Mediator_viewControllerForMapService:self.userid webTitle:@"门店服务" httpUrl:httpUrl loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
                if (viewController && loginSuccess) {
                    [CURRENTVIEWCONTROLLER.navigationController pushViewController:viewController animated:YES];
                }
            }];
            
        }];
    }
    return _storeServiceItem;
}
- (MenuItem *)userHelpItem {
    if (!_userHelpItem) {
        _userHelpItem = [MenuItem itemWithName:kMenuItemUserHelp iconName:@"menu_feedback" selectedCallback:^{
            if (![UserAccount sharedInfo].appfunction.userfeedback.enable && IsLogin()) {
                return;
            };
            
            // 弹框引导用户去微信返回
            G100ReactivePopingView *iKnowBox = [G100ReactivePopingView popingViewWithReactiveView];
            [iKnowBox showPopingViewWithTitle:@"提醒"
                                      content:@"请搜索添加公众号 骑卫士 或者客服微信（微信号：qwsqiqi）进行反馈。"
                                   noticeType:ClickEventBlockCancel
                                   otherTitle:nil
                                 confirmTitle:@"我知道了"
                                   clickEvent:^(NSInteger index) {
                                       [iKnowBox dismissWithVc:CURRENTVIEWCONTROLLER animation:YES];
                                       if (![UIApplication sharedApplication].statusBarHidden) {
                                           [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                                       }
                                   }
                             onViewController:CURRENTVIEWCONTROLLER
                                   onBaseView:CURRENTVIEWCONTROLLER.view];
        }];
    }
    return _userHelpItem;
}

@end
