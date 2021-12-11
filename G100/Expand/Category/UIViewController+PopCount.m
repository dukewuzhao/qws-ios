//
//  UIViewController+PopCount.m
//  G100
//
//  Created by yuhanle on 16/3/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "UIViewController+PopCount.h"
#import <objc/runtime.h>

static const void *PopViewCountKey = &PopViewCountKey;
@implementation UIViewController (PopCount)

- (NSInteger)popViewCount {
    return [objc_getAssociatedObject(self, PopViewCountKey) integerValue];
}

- (void)setPopViewCount:(NSInteger)popViewCount {
    objc_setAssociatedObject(self, PopViewCountKey, @(popViewCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)addPopViewCount {
    self.popViewCount++;
}
-(void)reducePopViewCount {
    if (self.popViewCount > 0) {
        self.popViewCount--;
    }
}

@end
