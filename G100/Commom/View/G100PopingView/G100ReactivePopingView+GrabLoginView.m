//
//  G100GrabLoginView.m
//  G100
//
//  Created by yuhanle on 2016/12/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ReactivePopingView+GrabLoginView.h"

@implementation G100ReactivePopingView (GrabLoginView)

+ (instancetype)grabLoginView {
    static G100ReactivePopingView *box;
    static dispatch_once_t onceTonken;
    dispatch_once(&onceTonken, ^{
        box = [self popingViewWithReactiveView];
        box.backgorundTouchEnable = NO;
    });
    return box;
}

@end
