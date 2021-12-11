//
//  EBCheckVersion.m
//  G100
//
//  Created by yuhanle on 2017/2/6.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "EBCheckVersion.h"
#import "G100AppApi.h"

#define EB_APP_ID   @"980188777"
#define EB_APP_URL  @"https://itunes.apple.com/lookup"

static NSString *_appId;

@interface EBCheckVersion () <UIAlertViewDelegate>

+(instancetype)shareInstance;

@end

@implementation EBCheckVersion

+ (void)setAppId:(NSString *)appId {
    _appId = appId;
}

+ (void)appLaunched:(BOOL)canPromptForRating {
    [[EBCheckVersion shareInstance] doCheckVersion];
}

+ (void)appBecomeActived {
    [[EBCheckVersion shareInstance] doCheckVersion];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceTonken;
    static EBCheckVersion * shareInstance = nil;
    dispatch_once(&onceTonken, ^{
        shareInstance = [[EBCheckVersion alloc] init];
    });
    
    return shareInstance;
}

#pragma mark - 应用商店检查更新
- (void)doCheckVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *svn_resversion = [infoDic objectForKey:@"SVN-Reversion"];
    NSString *app_version = [NSString stringWithFormat:@"%@.%@", [infoDic objectForKey:@"CFBundleShortVersionString"], svn_resversion];
    NSString *currentVersion = [NSString stringWithFormat:@"%@_%@", app_version, [infoDic objectForKey:@"CFBundleVersion"]];
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            NSString *lastVersion = response.data[@"latestversion"];
            NSString *msg = response.data[@"description"];
            
            // 比较最新版本和当前版本号
            if ([self isVersion:lastVersion biggerThanVersion:currentVersion]) {
                
                // 判断用户是否允许检查更新
                BOOL isAllow = [self isTipstoCheckUpdate];
                
                if (!isAllow) {
                    NSLog(@"新版本(%@)用户不允许弹框!!!", lastVersion);
                    return;
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发现一个新版本"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"不再提醒", @"去下载", nil];
                alert.delegate = self;
                alert.tag = 10000;
                [alert show];
                
                NSLog(@"新版本(%@)弹出提示框!!!", lastVersion);
            }else if ([lastVersion compare:currentVersion] == NSOrderedSame) {
                NSLog(@"最新版本(%@)!!!", lastVersion);
                [self setTipstoCheckUpdate:YES];
            }else {
                NSLog(@"最新版本(%@)!!!", lastVersion);
                [self setTipstoCheckUpdate:YES];
            }
        }
    };
    
    ApiRequest * request = [ApiRequest requestWithBizData:@{ @"platform" : @"I",
                                                             @"channel" : @"0",
                                                             @"version" : EMPTY_IF_NIL(currentVersion),
                                                             @"pkgname" : @"com.tilink.360qws" }];
    
    [[G100Api sharedInstance] requestApi:@"app/checkupdate" withMethod:@"POST" andRequest:request callback:callback];
}

#pragma mark - 系统弹框提醒更新
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
#if DEBUG
        NSString *appStoreLink = @"http://i.ti-link.com.cn/release/builds/?platform=ios&buildkey=IOS-DB-JOB1";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
#else
        NSString *appStoreLink = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/360qi-wei-shi/id%@?l=zh&ls=1&mt=8", APP_ID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
#endif
        }else if (buttonIndex == 0) {
            [self setTipstoCheckUpdate:NO];
        }
    }
}

#pragma mark - Unitils
- (BOOL)isVersion:(NSString*)versionA biggerThanVersion:(NSString*)versionB {
    NSArray *arrayNow = [versionB componentsSeparatedByString:@"."];
    NSArray *arrayNew = [versionA componentsSeparatedByString:@"."];
    BOOL isBigger = NO;
    NSInteger i = arrayNew.count > arrayNow.count? arrayNow.count : arrayNew.count;
    NSInteger j = 0;
    BOOL hasResult = NO;
    for (j = 0; j < i; j ++) {
        NSString* strNew = [arrayNew objectAtIndex:j];
        NSString* strNow = [arrayNow objectAtIndex:j];
        if ([strNew integerValue] > [strNow integerValue]) {
            hasResult = YES;
            isBigger = YES;
            break;
        }
        if ([strNew integerValue] < [strNow integerValue]) {
            hasResult = YES;
            isBigger = NO;
            break;
        }
    }
    if (!hasResult) {
        if (arrayNew.count > arrayNow.count) {
            NSInteger nTmp = 0;
            NSInteger k = 0;
            for (k = arrayNow.count; k < arrayNew.count; k++) {
                nTmp += [[arrayNew objectAtIndex:k]integerValue];
            }
            if (nTmp > 0) {
                isBigger = YES;
            }
        }
    }
    return isBigger;
}

- (BOOL)isTipstoCheckUpdate {
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    NSNumber * tips = [info valueForKey:@"istiptocheckupdate"];
    
    if (tips == nil) {
        tips = [NSNumber numberWithBool:YES];
    }
    
    BOOL isAllow = [tips boolValue];
    
    return isAllow;
}

- (void)setTipstoCheckUpdate:(BOOL)allowTips {
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    [info setObject:[NSNumber numberWithBool:allowTips] forKey:@"istiptocheckupdate"];
    [info synchronize];
}

@end
