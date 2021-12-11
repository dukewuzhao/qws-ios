//
//  DevPositionPaoPaoView.m
//  G100
//
//  Created by Tilink on 15/6/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100ShopInfoPaoPaoView.h"
#import <QuartzCore/QuartzCore.h>
#import "G100ShopDomain.h"

#define Arror_height 6
#define TextFont [UIFont systemFontOfSize:14.0f]
#define paopaoViewMinWidth 176
#define paopaoViewShopHeight 64
#define paopaoViewMaxWidth WIDTH - 20

#define kPadding 6
#define kNavigationButtonW 64

#define GET_MAX_WIDTH(a,b) (a>b?(a>paopaoViewMinWidth?a:paopaoViewMinWidth):(b>paopaoViewMinWidth?b:paopaoViewMinWidth))

@interface G100ShopInfoPaoPaoView ()

@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

@property (strong, nonatomic) UIButton *navigationButton;

@end

@implementation G100ShopInfoPaoPaoView

-(void)showShopInfoViewWithDomain:(G100ShopPlaceDomain *)domain {
    
    self.userInteractionEnabled = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, 176, 84);

    self.topLabel = [[UILabel alloc]init];
    self.bottomLabel = [[UILabel alloc]init];
    self.navigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navigationButton addTarget:self action:@selector(clickNavigationButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationButton setBackgroundImage:[UIImage imageNamed:@"map_navigation_up"] forState:UIControlStateNormal];
    [self.navigationButton setBackgroundImage:[UIImage imageNamed:@"map_navigation_down"] forState:UIControlStateHighlighted];
    
    self.topLabel.font = self.bottomLabel.font = TextFont;
    self.topLabel.textColor = self.bottomLabel.textColor = [UIColor colorWithRed:45/255.0 green:48/255.0 blue:51/255.0 alpha:1.0f];
    
    self.topLabel.numberOfLines = 0;
    self.bottomLabel.numberOfLines = 0;
    
    [self.topLabel setFrame:CGRectMake(12, 6, WIDTH - 20, 18)];
    [self.bottomLabel setFrame:CGRectMake(12, 30, WIDTH - 20, 18)];
    [self.navigationButton setFrame:CGRectMake(self.bottomLabel.v_right + kPadding, 28, kNavigationButtonW, 22)];
    
    [self addSubview:self.topLabel];
    [self addSubview:self.bottomLabel];
    [self addSubview:self.navigationButton];

    NSString * name = [NSString stringWithFormat:@"名称：%@", domain.name];
    NSString * address = [NSString stringWithFormat:@"地址：%@", domain.address];
    
    self.topLabel.text = name;
    self.bottomLabel.text = address;
    
    CGSize titleSize = [name calculateSize:CGSizeMake(WIDTH, 18) font:TextFont];
    CGFloat titleWidth = titleSize.width + 24 + 80;
    CGSize bottomSize = [address calculateSize:CGSizeMake(WIDTH, 18) font:TextFont];
    CGFloat bottomWidth = bottomSize.width + 24 + 80;

    CGFloat maxWidth = GET_MAX_WIDTH(titleWidth, bottomWidth);
    
    if (maxWidth > paopaoViewMaxWidth) {
        maxWidth = paopaoViewMaxWidth;
        self.topLabel.v_width = maxWidth - (3*kPadding+kNavigationButtonW);
        self.bottomLabel.v_width = maxWidth - (3*kPadding+kNavigationButtonW);
    }
    
    self.navigationButton.v_right = maxWidth - 12;
    
    [self setFrame:CGRectMake(0, 0, maxWidth, paopaoViewShopHeight)];
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

- (void)clickNavigationButtonEvent {
    if (self.navigationButtonBlock) {
        self.navigationButtonBlock();
    }
}

@end
