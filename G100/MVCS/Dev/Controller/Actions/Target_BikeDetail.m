//
//  Target_BikeDetail.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_BikeDetail.h"
#import "G100BikeInfoDetailViewController.h"

@implementation Target_BikeDetail

- (UIViewController *)Action_nativeFetchBikeDetailViewController:(NSDictionary *)params {
    G100BikeInfoDetailViewController *viewController = [[G100BikeInfoDetailViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}
@end
