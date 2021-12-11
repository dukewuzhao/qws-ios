//
//  CustomMAPointAnnotation.m
//  G100
//
//  Created by Tilink on 15/10/10.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "CustomMAPointAnnotation.h"

@implementation CustomMAPointAnnotation

- (instancetype)init {
    if (self = [super init]) {
        self.isVisible = YES;
        self.isCenter = NO;
        self.selected = NO;
    }
    return self;
}

@end
