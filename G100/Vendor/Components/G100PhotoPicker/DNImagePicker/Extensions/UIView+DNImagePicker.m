//
//  UIView+DNImagePicker.m
//  JKImagePicker
//
//  Created by DingXiao on 15/2/11.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import "UIView+DNImagePicker.h"

@implementation UIView (DNImagePicker)

- (CGFloat)dn_left {
    return self.frame.origin.x;
}

-(void)setDn_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)dn_top {
    return self.frame.origin.y;
}

-(void)setDn_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)dn_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setDn_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)dn_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

-(void)setDn_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)dn_centerX {
    return self.center.x;
}

- (void)setDn_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)dn_centerY {
    return self.center.y;
}

- (void)setDn_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)dn_width {
    return self.frame.size.width;
}

- (void)setDn_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)dn_height {
    return self.frame.size.height;
}

- (void)setDn_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)dn_origin {
    return self.frame.origin;
}

- (void)setDn_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)dn_size {
    return self.frame.size;
}

- (void)setDn_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end
