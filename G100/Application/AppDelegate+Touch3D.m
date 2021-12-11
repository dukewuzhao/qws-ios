//
//  AppDelegate+Touch3D.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+Touch3D.h"

@implementation AppDelegate (Touch3D)

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler {
    if([shortcutItem.type isEqualToString:@"-11.UITouchText.share"]) {
        NSArray *arr = @[@"hello 3D Touch"];
        UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:arr applicationActivities:nil];
        [self.window.rootViewController presentViewController:vc animated:YES completion:^{

        }];
    }
}

@end
