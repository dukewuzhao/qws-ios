//
//  ShortArcLine.m
//  G100
//
//  Created by Tilink on 15/6/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ShortArcLine.h"

#define PI M_PI

@implementation ShortArcLine

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, MyNavColor.CGColor);//画笔线的颜色
    CGContextSetLineWidth(context, 2.0);//线的宽度
    
    CGContextAddArc(context, w / 2.0, h / 2.0, w / 2.0 - 4, 0.0, M_PI / 2.0, NO);
    CGContextStrokePath(context);
}

@end
