//
//  G100PaopaoView.m
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PaopaoView.h"
#import <QuartzCore/QuartzCore.h>

#define Arror_height 6
#define TextFont [UIFont systemFontOfSize:14.0f]

#define paopaoViewMinWidth 280
#define paopaoViewMaxWidth WIDTH - 20
#define paopaoViewHeight 60

#define kPadding 6

@interface G100PaopaoView ()

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * conentLabel;

@end
@implementation G100PaopaoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] init];
    _conentLabel = [[UILabel alloc] init];
    
    _titleLabel.font = TextFont;
    _conentLabel.font = TextFont;
    
    _titleLabel.textColor = [UIColor colorWithHexString:@"2D3033"];
    _conentLabel.textColor = [UIColor colorWithHexString:@"2D3033"];
    
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _conentLabel.textAlignment = NSTextAlignmentLeft;
    
    [self addSubview:_titleLabel];
    [self addSubview:_conentLabel];
}

- (void)showInfoWithTitle:(NSString *)title content:(NSString *)content {
    _titleLabel.text = title;
    _conentLabel.text = content;
    
    CGSize titleSize = [title calculateSize:CGSizeMake(paopaoViewMaxWidth, 18) font:TextFont];
    CGSize contentSize = [content calculateSize:CGSizeMake(paopaoViewMaxWidth, 18) font:TextFont];
    
    CGFloat frameW = MAX(titleSize.width, contentSize.width) + 2*kPadding;
    frameW = frameW > paopaoViewMaxWidth ? paopaoViewMaxWidth : frameW;
    
    CGRect newFrame = self.frame;
    newFrame.size.width = frameW;
    newFrame.size.height = paopaoViewHeight;
    if (!title.length || !content.length) {
        newFrame.size.height = paopaoViewHeight/2.0 + 15;
    }
    
    self.frame = newFrame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat frameW = CGRectGetWidth(self.frame);
    CGFloat frameH = CGRectGetHeight(self.frame);
    _titleLabel.frame = CGRectMake(kPadding, kPadding, frameW - 2*kPadding, 18);
    _conentLabel.frame = CGRectMake(kPadding, frameH - 2*kPadding - 18, frameW - 2*kPadding, 18);
    
    if (!_titleLabel.text.length) {
        // 没有title
        _conentLabel.frame = CGRectMake(kPadding, (frameH-18-Arror_height)/2.0, frameW - 2*kPadding, 18);
    }
    
    if (!_conentLabel.text.length) {
        // 没有content
        _titleLabel.frame = CGRectMake(kPadding, (frameH-18-Arror_height)/2.0, frameW - 2*kPadding, 18);
    }
}

-(void)drawRect:(CGRect)rect{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

-(void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0f].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
    //    CGContextSetLineWidth(context, 2.0);
    //    CGContextSetRGBStrokeColor(context, 0.8, 0.1, 0.8, 1);
    //    [self getDrawPath:context];
    //    CGContextStrokeRect(context, self.bounds);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    // midy = CGRectGetMidY(rrect),
    maxy = CGRectGetMaxY(rrect)-Arror_height;
    CGContextMoveToPoint(context, midx+Arror_height, maxy);
    CGContextAddLineToPoint(context,midx, maxy+Arror_height);
    CGContextAddLineToPoint(context,midx-Arror_height, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
