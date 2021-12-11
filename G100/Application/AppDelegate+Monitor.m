//
//  AppDelegate+Monitor.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+Monitor.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AFNetworkReachabilityManager.h"

@implementation AppDelegate (Monitor)

- (void)xks_monitorConfigConfiguration {
    self.firstOpenApp = YES;
    self.showNetChangedHUD = YES;
    [self mcg_addMonitorObserver];
    
    // 开始监听网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)mcg_addMonitorObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kMonitorEarphoneChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kMonitorNetworkChanged:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_showGuideView)
                                                 name:kGNShowGuidePage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_enterMainView)
                                                 name:kGNShowMainView
                                               object:nil];
}

- (void)kMonitorNetworkChanged:(NSNotification *)notification {
    switch ([[[notification userInfo]objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue]) {
        case AFNetworkReachabilityStatusNotReachable:
        {
            if (self.showNetChangedHUD) {
                [CURRENTVIEWCONTROLLER showHint:@"网络无连接" inView:[[UIApplication sharedApplication].delegate window]];
            }
            
            [[UserManager shareManager] stopPostPush];
            [[UserManager shareManager] stopUpdateInfo];
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
        {
            if (!self.firstOpenApp && self.showNetChangedHUD) {
                [CURRENTVIEWCONTROLLER showHint:@"Wifi已连接" inView:[[UIApplication sharedApplication].delegate window]];
            }
            
            [[UserManager shareManager] startPostPush];
            [[UserManager shareManager] startUpdateInfo];
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            if (!self.firstOpenApp && self.showNetChangedHUD) {
                [CURRENTVIEWCONTROLLER showHint:@"3G/4G已连接" inView:[[UIApplication sharedApplication].delegate window]];
            }
            
            [[UserManager shareManager] startPostPush];
            [[UserManager shareManager] startUpdateInfo];
        }
            break;
        default:
            break;
    }
    
    self.firstOpenApp = NO;
}

- (void)kMonitorEarphoneChanged:(NSNotification *)noti {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

@end
