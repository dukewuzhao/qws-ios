//
//  Target_InsuranceOrders.m
//  G100
//
//  Created by yuhanle on 2017/1/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_InsuranceOrders.h"
#import "G100InsuranceContainerViewController.h"

@implementation Target_InsuranceOrders

- (UIViewController *)Action_nativeFetchInsuranceOrdersViewController:(NSDictionary *)params {
    NSString *userid = params[@"userid"];
    NSInteger listtype = [params[@"listtype"] integerValue];
    
    switch (listtype) {
        case 1:
        {
            G100InsuranceContainerViewController *viewController = [[G100InsuranceContainerViewController alloc] init];
            viewController.userid = userid;
            viewController.insuranceOrderType = InsuranceOrderWaitPay;
            return viewController;
        }
            break;
        case 2:
        {
            G100InsuranceContainerViewController *viewController = [[G100InsuranceContainerViewController alloc] init];
            viewController.userid = userid;
            viewController.insuranceOrderType = InsuranceOrderGuarantee;
            return viewController;
        }
            break;
        case 3:
        {
            G100InsuranceContainerViewController *viewController = [[G100InsuranceContainerViewController alloc] init];
            viewController.userid = userid;
            viewController.insuranceOrderType = InsuranceOrderExpired;
            return viewController;
        }
            break;
        default:
        {
            G100InsuranceContainerViewController *viewController = [[G100InsuranceContainerViewController alloc] init];
            viewController.userid = userid;
            return viewController;
        }
            break;
    }
    
    return [[G100NotFoundViewController alloc] init];
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
