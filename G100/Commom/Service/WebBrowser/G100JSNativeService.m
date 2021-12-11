//
//  G100JSNativeService.m
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100JSNativeService.h"

#import "InsuranceWebModel.h"
#import "G100WeatherManager.h"

#import "G100InsuranceWebViewController.h"
#import "G100WebViewController.h"

#import "G100ReactivePopingView+GrabLoginView.h"
#import "G100Mediator+Login.h"

@implementation QWSJsObjCModel

- (NSString *)getToken:(NSString *)qwsKey {
    if (_webVc) {
        if ([_webVc.qwsKey isEqualToString:qwsKey]) {
            NSString * token = [[G100InfoHelper shareInstance] token];
            return token ? token : @"";
        }
    }
    
    return @"";
}

- (void)getNewToken:(NSString *)key callback:(NSString *)callback property:(NSString *)property {
    if (_webVc) {
        if ([_webVc.qwsKey isEqualToString:key]) {
            
            __block NSString * newToken = @"";
            __block NSInteger result = 0;
            NSThread * webThread = [NSThread currentThread];
            
            [[UserManager shareManager] autoLoginWithComplete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    newToken = [[G100InfoHelper shareInstance] token];
                }else{
                    newToken = @"error";
                }
                
                result = requestSuccess ? response.errCode : statusCode;
                [self performSelector:@selector(callQWSJSWithArgument:) onThread:webThread withObject:@[callback, @(result), newToken, property] waitUntilDone:NO];
            }];
        }
    }
}

- (void)occupyToken {
    dispatch_async(dispatch_get_main_queue(), ^{
        //弹框提示用户退出登录
        /**
         *  登陆过程中遇到被抢占的情况 统一处理
         *  弹窗提示用户被抢占的情况
         *  用户点击重新登陆 退到登陆页面
         */
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNRemoteLoginMsg object:nil userInfo:nil];
        [UserManager shareManager].remoteLogin = YES;
        [[UserManager shareManager] logoff];
        
        NSString * title   = @"登录提示";
        NSString * content = @"当前帐号在其他设备上登录。若非本人操作，您的登录密码可能已经泄露，请及时修改密码。";
        
        G100ReactivePopingView *box = [G100ReactivePopingView grabLoginView];
        box.backgorundTouchEnable = NO;
        
        __weak UIViewController *topVC = CURRENTVIEWCONTROLLER;
        [box dismissWithVc:box.popVc animation:YES];
        [box showPopingViewWithTitle:title content:content noticeType:ClickEventBlockCancel otherTitle:nil confirmTitle:@"重新登录" clickEvent:^(NSInteger index) {
            if (index == 2) {
                [UserManager shareManager].remoteLogin = NO;
                [[UserManager shareManager] logoff];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                }];
            }
            [box dismissWithVc:topVC animation:YES];
        } onViewController:topVC onBaseView:topVC.view];
    });
}

- (void)callQWSJSWithArgument:(NSArray *)argument {
    NSString * callback = argument[0];
    JSValue * function = self.jsContext[callback];
    
    NSMutableArray * params = [NSMutableArray arrayWithArray:argument];
    // 移除第一个 方法名
    [params removeObjectAtIndex:0];
    [function callWithArguments:params];
}

#pragma mark - 保险功能
- (void)payPingAnInsurance:(NSString *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        //TODO: 跳转到平安商城
        InsuranceWebModel *model = [InsuranceWebModel mj_objectWithKeyValues:[data mj_JSONObject]];
        
        if (model) {
            G100InsuranceWebViewController *insuranceWeb = [G100InsuranceWebViewController loadNibWebViewController];
            insuranceWeb.model = model;
            
            NSMutableArray *vcs = self.webVc.navigationController.viewControllers.mutableCopy;
            [vcs removeObject:self.webVc];
            [vcs addObject:insuranceWeb];
            
            // 关闭当前浏览器 打开新的浏览器
            [self.webVc.navigationController setViewControllers:vcs.copy animated:YES];
        }
    });
}

#pragma mark - Toast/HUD功能
- (void)qwsShowHudHint:(NSString *)hint canOperate:(BOOL)canOperate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webVc setNavigationViewClickEnabled:canOperate];
        if (canOperate) {
            self.webVc.navigationController.interactivePopGestureRecognizer.enabled = self.webVc.previousInteractivePopGestureEnabled;
            [self.webVc showHudInView:self.webVc.webView hint:hint completionBlock:^{
                [self.webVc setNavigationViewClickEnabled:YES];
            }];
        }else {
            self.webVc.navigationController.interactivePopGestureRecognizer.enabled = NO;
            [self.webVc showHudInView:self.webVc.view hint:hint completionBlock:^{
                [self.webVc setNavigationViewClickEnabled:YES];
            }];
        }
    });
}
- (void)qwsHideHud {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webVc hideHud];
    });
}
- (void)qwsShowHint:(NSString *)hint {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webVc showHint:hint];
    });
}
- (void)qwsHideHint {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webVc hideHud];
    });
}

#pragma mark - 配置功能
- (void)getExitMsgCallback:(NSString *)callback {
    if (callback.length) {
        self.webVc.exitJSCallback = callback;
    }else {
        self.webVc.exitJSCallback = nil;
    }
}
- (void)qwsWebViewCanClose:(BOOL)canClose {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webVc setNavigationViewClickEnabled:canClose];
        if (canClose) {
            self.webVc.navigationController.interactivePopGestureRecognizer.enabled = self.webVc.previousInteractivePopGestureEnabled;
        }else {
            self.webVc.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    });
}
- (void)qwsWebViewCanOperate:(BOOL)canOperate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webVc setNavigationViewClickEnabled:canOperate];
        if (canOperate) {
            self.webVc.navigationController.interactivePopGestureRecognizer.enabled = self.webVc.previousInteractivePopGestureEnabled;
        }else {
            self.webVc.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    });
}

- (void)setNavigationBarTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webVc.webTitleLabel.text = title;
    });
}

- (void)setNavigationBarColor:(NSString *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.webVc.navigationView.backgroundColor = [UIColor colorWithHexString:color];
        }];
    });
}

- (void)getCLIWithCallback:(NSString *)callback{
    if (_webVc) {
        NSThread * webThread = [NSThread currentThread];
        [[G100WeatherManager sharedInstance] getCurrentLoactionInfoWithCallback:^(NSError *error, NSDictionary *locationDic) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:locationDic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [self performSelector:@selector(callQWSJSWithArgument:) onThread:webThread withObject:@[callback,jsonString] waitUntilDone:NO];
        }];
    }
}

@end

@implementation G100JSNativeService

@end
