//
//  UpdateNotificationHelper.h
//  G100
//
//  Created by 曹晓雨 on 2017/10/24.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateNotificationHelper : NSObject

+ (instancetype)shareInstance;

- (void)application:(UIApplication *)application didReceiveJPushRemoteNotification:(NSDictionary *)userInfo;

@end
