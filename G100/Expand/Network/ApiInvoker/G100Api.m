//
//  G100Api.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100Api.h"
#import "G100Mediator+Login.h"
#import "G100ReactivePopingView+GrabLoginView.h"

#define kMaxErrorCount  3

@interface G100Api () {
    NSInteger _errCount;
}

@end

@implementation G100Api

- (id)init {
    //重写init方法 设置不同的请求
    self = [super init];
    if (self) {
        //ENT API Base
        [self setupApiBaseUrl:nil apiHttpsBaseUrl:MainNetV2];
        
        self.token = [[G100InfoHelper shareInstance] token];
        if(!self.token) self.token = @"";
        _errCount = 0;
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static G100Api * instance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest callback:(API_CALLBACK)callback{
    return [self postApi:api andRequest:apiRequest token:YES https:YES callback:callback];
}

- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest token:(BOOL)hasToken callback:(API_CALLBACK)callback {
    return [self postApi:api andRequest:apiRequest token:hasToken https:YES callback:callback];
}

- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest token:(BOOL)hasToken https:(BOOL)isHttps callback:(API_CALLBACK)callback {
    return [self postApi:api andRequest:apiRequest token:hasToken https:isHttps timeoutInSeconds:apiRequest.timeoutInSeconds callback:callback];
}

- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest token:(BOOL)hasToken https:(BOOL)isHttps timeoutInSeconds:(NSInteger)timeoutInSeconds callback:(API_CALLBACK)callback {
    apiRequest.api = api;
    apiRequest.isHttps = isHttps;
    apiRequest.hasToken = hasToken;
    apiRequest.timeoutInSeconds = timeoutInSeconds;
    apiRequest.callback = callback;
    
    if (!_allowNetRequest) {
        [self addRequest:apiRequest];
    }else {
        [self requestApi:api withMethod:@"POST" andRequest:apiRequest callback:callback];
    }
    
    return apiRequest;
}

- (ApiRequest *)postImageApi:(NSString *)api andRequest:(ApiRequest *)apiRequest imageArray:(NSArray*)imageArray nameArray:(NSArray*)nameArray progress:(Progress_Callback)progressCallback callback:(API_CALLBACK)callback {
    apiRequest.api = api;
    apiRequest.callback = callback;
    apiRequest.hasToken = YES;
    apiRequest.isHttps = YES;
    if (!_allowNetRequest) {
        [self addRequest:apiRequest];
    }else{
        [self requestApi:api andRequest:apiRequest imageArray:imageArray nameArray:nameArray progress:progressCallback callback:callback];
    }
    
    return apiRequest;
}

// 公共的处理错误信息
- (void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse error:(NSError *)error {
    BOOL isShowHint = YES;
    if ([apiRequest.api hasContainString:@"postpush"]) {
        isShowHint = NO;
    }
    
    if (error != nil) {
        if (isShowHint) {
            NSString *errorHint = nil;
            if (error.code == -1) {
                IDLog(IDLogTypeWarning, @"请求Unknown");
                errorHint = nil;
                _errCount++;
            }else if (error.code == -999) {
                IDLog(IDLogTypeWarning, @"请求Cancel");
                errorHint = nil;
            }else if (error.code == -1000) {
                errorHint = [NSString stringWithFormat:@"Error %@:(%@)", @(statusCode), @(error.code)];
                _errCount++;
            }else if (error.code == -1001) {
                errorHint = @"网络连接超时，请稍后重试";
                _errCount++;
            }else if (error.code == -1002) {
                errorHint = [NSString stringWithFormat:@"Error %@:(%@)", @(statusCode), @(error.code)];
                _errCount++;
            }else if (error.code == -1003) {
                errorHint = [NSString stringWithFormat:@"Error %@:(%@)", @(statusCode), @(error.code)];
                _errCount++;
            }else if (error.code == -1004) {
                errorHint = @"未能连接到服务器";
                _errCount++;
            }else if (error.code == -1005) {
                errorHint = @"网络连接已中断";
                _errCount++;
            }else if (error.code == -1006) {
                errorHint = [NSString stringWithFormat:@"Error %@:(%@)", @(statusCode), @(error.code)];
                _errCount++;
            }else if (error.code == -1017) {
                errorHint = [NSString stringWithFormat:@"Error %@:(%@)", @(statusCode), @(error.code)];
                _errCount++;
            }else if (statusCode == 404) {
                errorHint = [NSString stringWithFormat:@"Error %@:(%@)", @(statusCode), @(error.code)];
                _errCount++;
            }else if (statusCode == 408) {
                errorHint = @"网络连接超时，请稍后重试";
                _errCount++;
            }else if (statusCode == 502) {
                errorHint = [NSString stringWithFormat:@"Error %@:(%@)", @(statusCode), @(error.code)];
                _errCount++;
            }else if (statusCode == 503) {
                errorHint = nil;
                _errCount++;
            }else if (statusCode >= 500) {
                errorHint = @"数据加载失败，请稍后重试";
                _errCount++;
            }else {
                _errCount++;
            }
            
            if (errorHint && APPDELEGATE.showNetChangedHUD) {
                [KEY_WINDOW.rootViewController showHint:errorHint];
            }else {
                
            }
        }
    }
    
    [self handleError:statusCode apiRequest:apiRequest response:apiResponse];
}
-(void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse {
    BOOL isShowHint = YES;
    if ([apiRequest.api hasContainString:@"postpush"]) {
        isShowHint = NO;
    }
    
    if (isShowHint) {
        if (statusCode == 0) {
            
        }else if (statusCode == 200) {
            // 请求成功
        }
    }
    
    if (statusCode == 0) {
        
    }else if (statusCode == 200) {
        // 请求成功
        _errCount = 0;
    }
    
    if (_errCount > kMaxErrorCount) {
        _errCount = 0;
        [self cancelAllRequest];
    }
    
    if (apiResponse != nil) {
        if (apiResponse.errCode == 64) {
            [self cancelAllRequest];
        }
        
        if (apiResponse.errCode == 64 && ![UserManager shareManager].remoteLogin) {
            /** 
             *  登陆过程中遇到被抢占的情况 统一处理
             *  弹窗提示用户被抢占的情况
             *  用户点击重新登陆 退到登陆页面
             */
            [[NSNotificationCenter defaultCenter]postNotificationName:kGNRemoteLoginMsg object:nil userInfo:nil];
            [UserManager shareManager].remoteLogin = YES;
            [[UserManager shareManager] logoff];
            
            NSString * message = [apiResponse custDesc];
            NSArray * msgArray = [message componentsSeparatedByString:@"|"];
            NSString * title   = [msgArray safe_objectAtIndex:0];
            NSString * content = [msgArray safe_objectAtIndex:1];
            
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
        }else if (apiResponse.errCode == 6) {
            /** 
             *  若程序是在后台  则不处理  因为程序退到后台的时候，会发请求，例如更新启动页图片
             *  这个时候 如果另一台设备强占登陆的时候 这边就会重新登录
             *  从而导致互刷token 的问题
             */
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                __weak G100Api * wself = self;
                [[UserManager shareManager] autoLoginWithComplete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                    __typeof__(self) strongSelf = wself;
                    if (requestSuccess) {
                        IDLog(IDLogTypeInfo, @"自动登录成功---由于%@ 请求无效", apiRequest.api);
                        [strongSelf reRequestAllRequest];
                    }else {
                        [strongSelf cancelAllRequest];
                        IDLog(IDLogTypeError, @"自动登录失败----%@----由于%@ 请求无效", response.errDesc, apiRequest.api);
                        
                        /**
                         *  判断当前是否在登陆界面
                         *  是 不作操作
                         *  不是 则清空信息跳转到登录界面
                         */
                        if ([CURRENTVIEWCONTROLLER isKindOfClass:[NSClassFromString(@"G100UserLoginViewController") class]] ||
                            [UserManager shareManager].remoteLogin) {
                            
                        }else {
                            [UserManager shareManager].remoteLogin = NO;
                            [[UserManager shareManager] logoff];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                            [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                                [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                            }];
                            [APPDELEGATE.mainNavc showHint:@"您的密码已过期，请重新登录"];
                        }
                    }
                }];
            }else {
                if (apiRequest.callback) {
                    apiRequest.callback(0, nil, NO);
                }
            }
        }else if (apiResponse.errCode == 4 ||
                  (apiResponse.errCode == 57 && [apiRequest.api hasContainString:kApiLoginUrl])) {
            [self cancelAllRequest];
            
            /**
             *  判断当前是否在登陆界面
             *  是 不作操作
             *  不是 则清空信息跳转到登录界面
             */
            if ([CURRENTVIEWCONTROLLER isKindOfClass:[NSClassFromString(@"G100UserLoginViewController") class]] ||
                [UserManager shareManager].remoteLogin) {
                
            }else {
                [UserManager shareManager].remoteLogin = NO;
                [[UserManager shareManager] logoff];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                }];
                [APPDELEGATE.mainNavc showHint:@"您的密码已过期，请重新登录"];
            }
        }
    }
}

@end
