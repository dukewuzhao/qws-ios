//
//  UIView+Wen_Additions.m
//  SunDemo
//
//  Created by nil on 14-1-5.
//  Copyright (c) 2014年 温世波. All rights reserved.
//

#import "UIView+Wen_Additions.h"

@implementation UIView (Wen_Additions)

UIInterfaceOrientation WENInterfaceOrientation() {
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    return orient;
}

CGRect WENScreenBounds() {
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape(WENInterfaceOrientation())) {
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = width;
    }
    return bounds;
}

- (CGFloat)v_left {
    return self.frame.origin.x;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)v_top {
    return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)v_right {
    return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)v_bottom {
    return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)v_centerX {
    return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)v_centerY {
    return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)v_width {
    return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)v_height {
    return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.v_left;
    }
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.v_top;
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.v_left;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.v_top;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)screenFrame {
    return CGRectMake(self.screenViewX, self.screenViewY, self.v_width, self.v_height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)v_origin {
    return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)v_size {
    return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setV_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)orientationWidth {
    return UIInterfaceOrientationIsLandscape(WENInterfaceOrientation())
    ? self.v_height : self.v_height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)orientationHeight {
    return UIInterfaceOrientationIsLandscape(WENInterfaceOrientation())
    ? self.v_width : self.v_height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)descendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;
    
    for (UIView* child in self.subviews) {
        UIView* it = [child descendantOrSelfWithClass:cls];
        if (it)
            return it;
    }
    
    return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)ancestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;
        
    } else if (self.superview) {
        return [self.superview ancestorOrSelfWithClass:cls];
        
    } else {
        return nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)offsetFromView:(UIView*)otherView {
    CGFloat x = 0, y = 0;
    for (UIView* view = self; view && view != otherView; view = view.superview) {
        x += view.v_left;
        y += view.v_top;
    }
    return CGPointMake(x, y);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBorderColor:(UIColor *)borderColor width:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius
{
    self.layer.borderColor = borderColor.CGColor;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = borderWidth;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
