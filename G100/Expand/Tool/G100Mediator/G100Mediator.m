//
//  G100Mediator.m
//  G100
//
//  Created by yuhanle on 16/7/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

NSString * kCTMediatorTargetLogin1 = @"Login";
NSString * kCTMediatorActionNativeIsLogined1 = @"nativeIsLogined";
NSString * kCTMediatorActionNativePresentLoginViewController1 = @"nativePresentLoginViewController";

NSString * kCTMediatorTargetRegister1 = @"Register";
NSString * kCTMediatorActionNativePresentRegisterViewController1 = @"nativePresentRegisterViewController";

@implementation G100Mediator

#pragma mark - public methods
+ (instancetype)sharedInstance {
    static G100Mediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[G100Mediator alloc] init];
    });
    return mediator;
}

/**
 scheme://[target]/[action]?[params]
 
 url sample:
 qwsapp://targetA/actionB?id=1234
 */

- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion {
    if (![url.scheme isEqualToString:@"qwsapp"]) {
        // 这里就是针对远程app调用404的简单处理了，根据不同app的产品经理要求不同，你们可以在这里自己做需要的逻辑
        return @(NO);
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *urlString = [url query];
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    
    // 这里这么写主要是出于安全考虑，防止黑客通过远程方式调用本地模块。这里的做法足以应对绝大多数场景，如果要求更加严苛，也可以做更加复杂的安全逻辑。
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    // 这个demo针对URL的路由处理非常简单，就只是取对应的target名字和method名字，但这已经足以应对绝大部份需求。如果需要拓展，可以在这个方法调用之前加入完整的路由逻辑
    id result = [self performTarget:url.host action:actionName params:params];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params {
    NSString *targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    NSString *actionString = [NSString stringWithFormat:@"Action_%@:", actionName];
    
    Class targetClass = NSClassFromString(targetClassString);
    id target = [[targetClass alloc] init];
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        // 这里是处理无响应请求的地方之一，这个demo做得比较简单，如果没有可以响应的target，就直接return了。实际开发过程中是可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求的
        return nil;
    }
    
    void (^loginHandler)(UIViewController *, BOOL) = params[@"loginHandler"];
    // 调用组件需要登录时进行统一拦截
    if ([target conformsToProtocol:@protocol(G100ShouldLoginProtocol)] &&
        [target shouldLoginBeforeAction:actionName]) {
        
        // 向登录模块请求当前是否已经登录
        BOOL isLogined = [[self performTarget:kCTMediatorTargetLogin1
                                       action:kCTMediatorActionNativeIsLogined1
                                       params:nil] boolValue];
        
        if (!isLogined) {
            void (^loginResult)(NSString *, BOOL) = ^(NSString *userid, BOOL loginSuccess){
                if (loginHandler) {
                    if (loginSuccess) {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:params];
                        if (userid) [dict setObject:userid forKey:@"userid"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        loginHandler([self performTarget:targetName action:actionName params:dict], loginSuccess);
#pragma clang diagnostic pop
                    }else {
                        loginHandler(nil, NO);
                    }
                }
            };
            [self performTarget:kCTMediatorTargetLogin1
                         action:kCTMediatorActionNativePresentLoginViewController1
                         params:@{@"loginResult":loginResult}];
            return nil;
        }
    }
    
    if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (loginHandler) {
            loginHandler([target performSelector:action withObject:params], YES);
            return nil;
        }else {
            return [target performSelector:action withObject:params];
        }
#pragma clang diagnostic pop
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (loginHandler) {
                loginHandler([target performSelector:action withObject:params], YES);
                return nil;
            }else {
                return [target performSelector:action withObject:params];
            }
#pragma clang diagnostic pop
        } else {
            // 这里也是处理无响应请求的地方，在notFound都没有的时候，这个demo是直接return了。实际开发过程中，可以用前面提到的固定的target顶上的。
            return nil;
        }
    }
}

@end
