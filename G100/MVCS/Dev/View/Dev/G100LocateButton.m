//
//  G100LocaButton.m
//  G100
//
//  Created by Tilink on 15/5/13.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100LocateButton.h"

@implementation G100LocateButton
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shortline = [[ShortArcLine alloc]init];
        
        _shortline.userInteractionEnabled = NO;
        _shortline.layer.masksToBounds = YES;
        _shortline.layer.cornerRadius = CGRectGetHeight(_shortline.frame) / 2.0;
        _shortline.backgroundColor = [UIColor clearColor];
        
        _shortline.hidden = YES;
        [self addSubview:_shortline];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    [self.shortline setFrame:rect];
}

-(void)startAnimation {
    [self setNeedsDisplay];
    
    _animating = YES;
    _shortline.hidden = NO;
    CABasicAnimation * rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [_shortline.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopAnimation {
    [self setNeedsDisplay];
    
    _animating = NO;
    _shortline.hidden = YES;
    [_shortline.layer removeAllAnimations];
}

@end
