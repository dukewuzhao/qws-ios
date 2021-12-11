//
//  Target_MapService.m
//  G100
//
//  Created by sunjingjing on 17/3/15.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_MapService.h"
#import "G100WebViewController.h"
@implementation Target_MapService

- (UIViewController *)Action_nativeFetchMapServiceViewController:(NSDictionary *)params {
    G100WebViewController *viewController = [[G100WebViewController alloc]init];
    viewController.httpUrl = params[@"httpUrl"];
    viewController.webTitle = params[@"webTitle"];
    return viewController;
}
- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}
@end
