//
//  NetHead.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#ifndef G100_NetHeader_h
#define G100_NetHeader_h

#define kNetworkNotReachability  ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == 0)  //无网
#define kNetworkReachableViaUnknown ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == -1)
#define kNetworkReachableViaWWAN ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == 1)
#define kNetworkReachableViaWiFi ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == 2)

// 检查更新
#define APP_ID                  @"980188777"
#define APP_URL                 @"http://itunes.apple.com/lookup"

#if DEBUG
#define ISProduct               0
#define ISOutSide               0
#else
#define ISProduct               1
#define ISOutSide               1
#endif

#define ISInHouse               0

// Umeng
#define UmengKey                @"553f953667e58ead610000c0"
// PingPPPay
#define kPingPPPayAppKey        @"app_14unL0Py9eP4bXPm"
#define kPingPPPayUrlScheme     @"wxfca35ef3c2669919"

// 高德地图key
#if G100FIRM
    #define MAMapViewKey        @"1fce6e28b63556460062eebcced3a65f"
#else
    #define MAMapViewKey        @"7272c66d24e3d287c74045229c8d5c9d"
#endif

// 极光推送
#define ISJPush                 1
#define JPushKey                @"2cfc7dead0fbc7403ef4e8e3"

#define MainNetV2               ISOutSide ? @"https://apiv2.360qws.cn:443/" : @"https://api.d.360qws.cn/"

#endif
