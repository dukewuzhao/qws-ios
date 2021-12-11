//
//  Target_WebBrowser.m
//  G100
//
//  Created by yuhanle on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_WebBrowser.h"
#import "G100WebViewController.h"

@implementation Target_WebBrowser

- (UIViewController *)Action_nativeFetchWebBrowserViewController:(NSDictionary *)params {
    G100WebViewController *viewController = [G100WebViewController loadNibWebViewController];
    viewController.userid = params[@"userid"];
    viewController.devid = params[@"bikeid"];
    viewController.httpUrl = params[@"httpUrl"];
    viewController.isAllowInpourJS = YES;
    return viewController;
}

@end
