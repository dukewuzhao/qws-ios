//
//  Target_DevUpdate.m
//  G100
//
//  Created by 曹晓雨 on 2017/10/26.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_DevUpdate.h"
#import "G100DevUpdateViewController.h"

@implementation Target_DevUpdate

- (UIViewController *)Action_nativeFetchDevUpdateViewController:(NSDictionary *)params {
    G100DevUpdateViewController *viewController = [[G100DevUpdateViewController alloc]init];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    return viewController;
}
@end
