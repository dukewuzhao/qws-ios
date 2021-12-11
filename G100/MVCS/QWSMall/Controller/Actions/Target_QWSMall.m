//
//  Target_QWSMall.m
//  G100
//
//  Created by yuhanle on 2017/7/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_QWSMall.h"
#import "G100MallViewController.h"

@implementation Target_QWSMall

- (UIViewController *)Action_nativeFetchQWSMallViewController:(NSDictionary *)params {
    G100MallViewController *viewController = [G100MallViewController loadXibViewControllerWithType:[params[@"mallType"] integerValue]];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.status = [params[@"status"] integerValue];
    viewController.pageUrl = params[@"pageUrl"];
    return viewController;
}

@end
