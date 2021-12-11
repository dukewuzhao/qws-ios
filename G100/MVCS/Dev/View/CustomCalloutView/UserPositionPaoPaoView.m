//
//  DevPositionPaoPaoView.m
//  G100
//
//  Created by Tilink on 15/6/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "UserPositionPaoPaoView.h"
#import <QuartzCore/QuartzCore.h>
#import "PositionDomain.h"

#define Arror_height 6
#define TextFont [UIFont systemFontOfSize:14.0f]

#define paopaoViewMinWidth 280
#define paopaoViewMaxWidth WIDTH - 20
#define paopaoViewDevHeight 84
#define paopaoViewUserHeight 60

#define kPadding 6
#define kNavigationButtonW 64

@interface UserPositionPaoPaoView ()

@property (strong, nonatomic) UILabel *colonLabel;
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

@property (strong, nonatomic) UILabel *signalLabel;
@property (strong, nonatomic) UIImageView *devGPSImageView;
@property (strong, nonatomic) UIImageView *devGSMImageView;
@property (strong, nonatomic) UIButton *navigationButton;

@end

@implementation UserPositionPaoPaoView

-(void)showBusInfoViewWithDomain:(PositionDomain *)domain {
    NSString *colonText = @"位置：";
    NSString *topTitle = domain.topTitle;
    NSArray *topTextArray  = [domain.topTitle componentsSeparatedByString:@"："];
    if ([topTextArray count] == 2) {
        colonText = [NSString stringWithFormat:@"%@：", [topTextArray firstObject]];
        topTitle = [topTextArray lastObject];
    }else {
        
    }
    
    self.userInteractionEnabled = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, 176, 84);

    if (!self.colonLabel) {
        self.colonLabel = [[UILabel alloc] init];
        self.topLabel = [[UILabel alloc] init];
        self.bottomLabel = [[UILabel alloc] init];
        self.signalLabel = [[UILabel alloc] init];
        self.devGPSImageView = [[UIImageView alloc] init];
        self.devGSMImageView = [[UIImageView alloc] init];
        self.navigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.navigationButton addTarget:self action:@selector(clickNavigationButtonEvent) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.colonLabel];
        [self addSubview:self.topLabel];
        [self addSubview:self.bottomLabel];
        [self addSubview:self.signalLabel];
        [self addSubview:self.devGPSImageView];
        [self addSubview:self.devGSMImageView];
        [self addSubview:self.navigationButton];
    }
    
    [self.navigationButton setBackgroundImage:[UIImage imageNamed:@"map_navigation_up"] forState:UIControlStateNormal];
    [self.navigationButton setBackgroundImage:[UIImage imageNamed:@"map_navigation_down"] forState:UIControlStateHighlighted];
    
    self.colonLabel.font = TextFont;
    self.colonLabel.textColor = [UIColor colorWithRed:45/255.0 green:48/255.0 blue:51/255.0 alpha:1.0f];
    self.topLabel.font = self.bottomLabel.font = self.signalLabel.font = TextFont;
    self.topLabel.textColor = self.bottomLabel.textColor = self.signalLabel.textColor = [UIColor colorWithRed:45/255.0 green:48/255.0 blue:51/255.0 alpha:1.0f];
    
    self.colonLabel.numberOfLines = 0;
    self.topLabel.numberOfLines = 0;
    self.bottomLabel.numberOfLines = 0;
    
    [self.colonLabel setFrame:CGRectMake(12, 6, 30, 18)];
    [self.topLabel setFrame:CGRectMake(12, 6, paopaoViewMaxWidth, 18)];
    [self.bottomLabel setFrame:CGRectMake(12, 30, paopaoViewMaxWidth, 18)];
    [self.signalLabel setFrame:CGRectMake(12, 54, 72, 18)];
    [self.devGPSImageView setFrame:CGRectMake(self.signalLabel.v_right, 54, 54, 18)];
    [self.devGSMImageView setFrame:CGRectMake(self.devGPSImageView.v_right + kPadding, 54, 54, 18)];
    [self.navigationButton setFrame:CGRectMake(self.devGSMImageView.v_right + kPadding, 52, kNavigationButtonW, 22)];
    
    self.colonLabel.text = colonText;
    self.topLabel.text = topTitle;
    self.bottomLabel.text = domain.bottomContent;
    self.signalLabel.text = @"信号强度：";
    
    NSString *devGPSImageStr = [NSString stringWithFormat:@"GPS_%@",@(domain.gpssvs)];
    NSString *devGSMImageStr = [NSString stringWithFormat:@"GSM_%@",@(domain.bssignal)];

    [self.devGPSImageView setImage:[UIImage imageNamed:devGPSImageStr]];
    [self.devGSMImageView setImage:[UIImage imageNamed:devGSMImageStr]];
    
    CGSize colonSize = [colonText calculateSize:CGSizeMake(paopaoViewMaxWidth, 18) font:TextFont];
    CGSize titleSize = [topTitle calculateSize:CGSizeMake(paopaoViewMaxWidth, 18) font:TextFont];
    CGFloat titleWidth = titleSize.width + 24;
    CGSize titleSize1 = [topTitle calculateSize:CGSizeMake(paopaoViewMaxWidth - 24 - colonSize.width, 999) font:TextFont];
    CGFloat titleHeight = titleSize1.height;
    CGSize bottomSize = [domain.bottomContent calculateSize:CGSizeMake(paopaoViewMaxWidth, 999) font:TextFont];
    CGFloat bottomWidth = bottomSize.width + 24;
    
    self.colonLabel.v_width = colonSize.width;
    self.topLabel.v_height = titleSize1.height;
    [self.topLabel setFrame:CGRectMake(12+colonSize.width, 6, MIN(titleWidth-24, paopaoViewMaxWidth - 24 - colonSize.width), titleHeight)];
    [self.bottomLabel setFrame:CGRectMake(12, self.topLabel.v_bottom+6, paopaoViewMaxWidth, bottomSize.height)];
    [self.signalLabel setFrame:CGRectMake(12, self.bottomLabel.v_bottom+6, 72, 18)];
    [self.devGPSImageView setFrame:CGRectMake(self.signalLabel.v_right, self.bottomLabel.v_bottom+6, 54, 18)];
    [self.devGSMImageView setFrame:CGRectMake(self.devGPSImageView.v_right + kPadding, self.bottomLabel.v_bottom+6, 54, 18)];
    [self.navigationButton setFrame:CGRectMake(self.devGSMImageView.v_right + kPadding, self.bottomLabel.v_bottom+6-2, kNavigationButtonW, 22)];
    
    if (domain.devid.length>0) {
        CGFloat maxWidth = MAX(titleWidth+colonSize.width, bottomWidth);
        maxWidth = (maxWidth > paopaoViewMinWidth ? maxWidth : paopaoViewMinWidth);
        
        if (maxWidth > paopaoViewMaxWidth) {
            maxWidth = paopaoViewMaxWidth;
            
            self.topLabel.v_width = maxWidth - (3*kPadding) - colonSize.width;
            self.bottomLabel.v_width = maxWidth - (3*kPadding);
        }
       
        self.navigationButton.v_right = maxWidth - 12;
        [self setFrame:CGRectMake(0, 0, maxWidth, paopaoViewDevHeight+titleHeight-18+bottomSize.height-18)];
    }else{
        self.signalLabel.hidden = YES;
        self.devGPSImageView.hidden = YES;
        self.devGSMImageView.hidden = YES;
        self.navigationButton.hidden = YES;
        
        CGFloat maxWidth = MAX(titleWidth+colonSize.width, bottomWidth);
        
        if (maxWidth > paopaoViewMaxWidth) {
            maxWidth = paopaoViewMaxWidth;
            self.topLabel.v_width = maxWidth - (3*kPadding) - colonSize.width;
            self.bottomLabel.v_width = maxWidth - (3*kPadding);
        }
        
        [self setFrame:CGRectMake(0, 0, maxWidth, paopaoViewUserHeight+titleHeight-18+bottomSize.height-18)];
        if (0 == topTitle.length) {
            [self setFrame:CGRectZero];
        }
    }
    
}

- (void)drawRect:(CGRect)rect {
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context {
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context {
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
