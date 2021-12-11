//
//  UIViewController+UMeng.m
//  G100
//
//  Created by yuhanle on 16/8/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "UIViewController+UMeng.h"
#import <objc/runtime.h>

@implementation UIViewController (UMeng)

+ (void)load {
    Method originalWillAppearMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzledWillAppearMethod = class_getInstanceMethod(self, @selector(um_viewWillAppear:));
    method_exchangeImplementations(originalWillAppearMethod, swizzledWillAppearMethod);
    
    Method originalDidDisappearMethod = class_getInstanceMethod(self, @selector(viewDidDisappear:));
    Method swizzledDidDisappearMethod = class_getInstanceMethod(self, @selector(um_viewDidDisappear:));
    method_exchangeImplementations(originalDidDisappearMethod, swizzledDidDisappearMethod);
}

- (void)um_viewWillAppear:(BOOL)animated {
    [self um_viewWillAppear:animated];
    [self um_pageCount:YES];
}

- (void)um_viewDidDisappear:(BOOL)animated {
    [self um_viewDidDisappear:animated];
    [self um_pageCount:NO];
}

- (void)um_pageCount:(BOOL)isWillAppear {
    NSString *controllerName = NSStringFromClass([self class]);
    // 哪些页面不用统计
    if ([controllerName isEqualToString:@""]) {
        return;
    }
    
    if (isWillAppear) {
        //[MobClick beginLogPageView:controllerName];
    }else {
        //[MobClick endLogPageView:controllerName];
    }
}

@end
