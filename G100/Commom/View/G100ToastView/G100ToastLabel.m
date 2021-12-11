//
//  G100ToastLabel.m
//  G100
//
//  Created by William on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ToastLabel.h"

@implementation G100ToastLabel

- (instancetype)init {
    if (self = [super init]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
}

@end
