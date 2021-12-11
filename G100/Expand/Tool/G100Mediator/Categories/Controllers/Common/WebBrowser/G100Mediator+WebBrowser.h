//
//  G100Mediator+WebBrowser.h
//  G100
//
//  Created by yuhanle on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (WebBrowser)

- (UIViewController *)G100Mediator_viewControllerForWebBrowser:(NSString *)httpUrl;

- (UIViewController *)G100Mediator_viewControllerForWebBrowser:(NSString *)userid bikeid:(NSString *)bikeid httpUrl:(NSString *)httpUrl;

- (UIViewController *)G100Mediator_viewControllerForWebBrowserWithUserid:(NSString *)userid bikeid:(NSString *)bikeid httpUrl:(NSString *)httpUrl params:(NSDictionary *)otherParams;

@end
