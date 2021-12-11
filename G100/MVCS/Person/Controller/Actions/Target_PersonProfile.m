//
//  Target_PersonProfile.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_PersonProfile.h"
#import "G100PersonProfileViewController.h"

@implementation Target_PersonProfile

- (UIViewController *)Action_nativeFetchPersonProfileViewController:(NSDictionary *)params {
    G100PersonProfileViewController *viewController = [[G100PersonProfileViewController alloc] init];
    viewController.userid = params[@"userid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
