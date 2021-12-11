//
//  Target_ScanCode.m
//  G100
//
//  Created by yuhanle on 16/8/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_ScanCode.h"
#import "G100BindDevViewController.h"

@implementation Target_ScanCode

- (UIViewController *)Action_nativeFetchScanCodeViewController:(NSDictionary *)params {
    G100BindDevViewController *viewController = [[G100BindDevViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    viewController.bindMode = [params[@"bindMode"] intValue];
    viewController.operationMethod = [params[@"operationMethod"] intValue];
    viewController.qrcode = params[@"qrcode"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
