//
//  Target_BuyService.m
//  G100
//
//  Created by yuhanle on 16/8/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_BuyService.h"
#import "G100BuyServiceViewController.h"
#import "G100WebViewController.h"
#import "G100UrlManager.h"

@implementation Target_BuyService

- (UIViewController *)Action_nativeFetchBuyServiceViewController:(NSDictionary *)params {
    G100WebViewController *viewController = [G100WebViewController loadNibWebViewController];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    viewController.httpUrl = [[G100UrlManager sharedInstance] getServicePayWithUserid:params[@"userid"]
                                                                               bikeid:params[@"bikeid"]
                                                                                devid:params[@"devid"]
                                                                                 type:[params[@"type"] intValue]
                                                                            productid:params[@"productid"]];
//    G100BuyServiceViewController *viewController = [[G100BuyServiceViewController alloc] init];
//    viewController.userid = params[@"userid"];
//    viewController.bikeid = params[@"bikeid"];
//    viewController.devid = params[@"devid"];
//    viewController.fromVc = params[@"fromvc"];
//    viewController.productid = params[@"productid"];
    return viewController;
}

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName {
    return YES;
}

@end
