//
//  AppDelegate.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQUIWindow+Hierarchy.h"
#import "TLNavigationController.h"

@class G100MainViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) TLNavigationController *mainNavc;
@property (nonatomic, strong) G100MainViewController *mainViewController;

@property (assign, nonatomic) BOOL firstOpenApp;
@property (assign, nonatomic) BOOL showNetChangedHUD;

- (void)noti_showGuideView;
- (void)noti_enterMainView;

@end
