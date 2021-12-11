//
//  G100StrokeLabel.m
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100StrokeLabel.h"

@implementation G100StrokeLabel

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.outlineColor = [UIColor blackColor];
        self.outlineWidth = 1;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, self.outlineWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = self.outlineColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
}

@end
