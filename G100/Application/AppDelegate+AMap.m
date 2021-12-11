//
//  AppDelegate+AMap.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+AMap.h"
#import "EBOfflineMapTool.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

@implementation AppDelegate (AMap)

- (void)xks_amapConfigConfiguration {
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [[AMapServices sharedServices] setApiKey:MAMapViewKey];
    [[MAOfflineMap sharedOfflineMap] checkNewestVersion:^(BOOL hasNewestVersion) {
        [[EBOfflineMapTool sharedManager] resume];
    }];
}

@end
