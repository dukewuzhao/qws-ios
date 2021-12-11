//
//  G100CardBaseViewController.m
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseViewController.h"

@interface G100CardBaseViewController ()

@end

@implementation G100CardBaseViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGNAppLoginOrLogoutNotification
                                                  object:nil];
}

#pragma mark - Notification Handler
- (void)loginOrLogoutNotification:(NSNotification *)notification {
    BOOL result = [notification.object boolValue];
    
    if (!result) {
        [self freeIt];
    }
    else {
        self.hasAppear = NO;
    }
}

#pragma mark - 出现/消失
- (void)mdv_viewWillAppear:(BOOL)animated {
    
}
- (void)mdv_viewDidAppear:(BOOL)animated {
    
}
- (void)mdv_viewWillDisappear:(BOOL)animated {
    
}
- (void)mdv_viewDidDisappear:(BOOL)animated {
    
}

- (void)freeIt {
    self.userid = nil;
    self.bikeid = nil;
    self.devid = nil;
    self.bikeDomain = nil;
    self.cardModel = nil;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hasAppear = NO;
    self.view.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginOrLogoutNotification:)
                                                 name:kGNAppLoginOrLogoutNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // DLog(@"CardView 即将出现");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // DLog(@"CardView 已经出现");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // DLog(@"CardView 即将消失");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // DLog(@"CardView 已经消失");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
