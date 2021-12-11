//
//  G100CardSlantView.m
//  G100
//
//  Created by sunjingjing on 16/10/21.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardSlantView.h"

@interface G100CardSlantView ()

@property (strong, nonatomic) UIColor *leftColor;

@property (strong, nonatomic) UIColor *rightColor;

@end

@implementation G100CardSlantView

- (instancetype)initWithFrame:(CGRect)frame leftViewColor:(UIColor *)leftColor rightViewColor:(UIColor *)rightColor{
    
    if (self = [super initWithFrame:frame]) {
        self.leftColor = leftColor;
        self.rightColor = rightColor;
        self.backgroundColor = rightColor;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [self drawLeftViewWithColor:self.leftColor rect:rect];
}

- (void)drawLeftViewWithColor:(UIColor *)leftColor rect:(CGRect)rect{
    CGSize finalSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGFloat layerHeight = finalSize.height;
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    [bezier moveToPoint:CGPointMake(0, finalSize.height - layerHeight)];
    [bezier addLineToPoint:CGPointMake(0, finalSize.height)];
    [bezier addLineToPoint:CGPointMake(finalSize.width *2/3, finalSize.height)];
    [bezier addLineToPoint:CGPointMake(finalSize.width *7/10, finalSize.height - layerHeight)];
    [bezier addLineToPoint:CGPointMake(0,0)];
    layer.path = bezier.CGPath;
    layer.fillColor = leftColor.CGColor;
    [self.layer addSublayer:layer];
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(6, 0);
    layer.shadowRadius = 0;
    layer.shadowOpacity = 0.2;
}
@end
