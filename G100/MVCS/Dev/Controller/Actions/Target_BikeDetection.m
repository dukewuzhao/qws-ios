//
//  Target_BikeDetection.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_BikeDetection.h"
#import "G100ScanViewController.h"

@implementation Target_BikeDetection

- (UIViewController *)Action_nativeFetchBikeDetectionViewController:(NSDictionary *)params {
    G100ScanViewController *viewController = [[G100ScanViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    return viewController;
}
- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}
@end
