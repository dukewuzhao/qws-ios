//
//  Target_BikeDetail.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_BikeEdit.h"
#import "G100BikeEditFeatureViewController.h"

@implementation Target_BikeEdit

- (UIViewController *)Action_nativeFetchBikeEditViewController:(NSDictionary *)params {
    G100BikeEditFeatureViewController *viewController = [[G100BikeEditFeatureViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.entranceFrom = [params[@"entranceFrom"] integerValue];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}
@end
