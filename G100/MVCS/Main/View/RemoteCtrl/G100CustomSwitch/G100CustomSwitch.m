//
//  G100CustomSwitch.m
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import "G100CustomSwitch.h"

@interface G100CustomSwitch ()

/**
 *  switch background view
 */
@property (nonatomic, strong) UIView *backgroundView;

/**
 *  slider layer
 */
@property (nonatomic, strong) CAShapeLayer *circleSliderLayer;

/**
 *  paddingWidth
 */
@property (nonatomic, assign) CGFloat paddingWidth;

/**
 *  dots layer
 */
@property (nonatomic, strong) CAShapeLayer *dotsLayer;

/**
 *  slider radius
 */
@property (nonatomic, assign) CGFloat circleSliderRadius;

/**
 *  the sliderLayer move distance
 */
@property (nonatomic, assign) CGFloat moveDistance;

/**
 *  whether is animated
 */
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) CGFloat circleSliderWidth;

@end

@implementation G100CustomSwitch

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setupView {
    /**
     *  check the switch width and height
     */
    NSAssert(self.frame.size.width >= self.frame.size.height, @"switch width must be tall！");
    
    _leftColor = [UIColor colorWithRed:33/255.0 green:188/255.0 blue:250/255.0 alpha:1.0];
    _rightColor = [UIColor colorWithRed:62/255.0 green:207/255.0 blue:39/255.0 alpha:1.0];
    _sliderColor = [UIColor whiteColor];
    _paddingWidth = self.frame.size.height * 0.1;
    _circleSliderRadius = (self.frame.size.height - 2 * _paddingWidth) / 2;
    _animationDuration = 1.2f;
    _moveDistance = self.frame.size.width - _paddingWidth * 2 - _circleSliderRadius * 2;
    _mws_status = 0;
    _isAnimating = NO;
    
    self.backgroundView.backgroundColor = [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209/255.0 alpha:1.0];
    self.circleSliderLayer.fillColor = _sliderColor.CGColor;
    self.circleSliderWidth = self.circleSliderLayer.frame.size.width;
    [self.circleSliderLayer setNeedsDisplay];
    
    self.dotsLayer.fillColor = self.leftColor.CGColor;
    [self.dotsLayer setNeedsDisplay];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapSwitch:)]];
    
    self.mws_enable = YES;
}

- (void)handleTapSwitch:(UITapGestureRecognizer *)tapGesture {
    if (!_mws_enable) {
        return;
    }
    
    if (_mws_status == 0) {
        // left -> right
        _mws_status = 1;
    }else {
        // right -> left
        _mws_status = 0;
    }
    
    [UIView animateWithDuration:_animationDuration animations:^{
        [self layoutIfNeeded];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:@selector(valueDidChanged:status:)]) {
            [_delegate valueDidChanged:self status:_mws_status];
        }
    }];
}

- (void)setMws_status:(int)mws_status {
    _mws_status = mws_status;
    
    [self layoutIfNeeded];
    [self layoutSubviews];
}

#pragma mark Init

/**
 *  init backgroundView
 *
 *  @return backgroundView
 */
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.frame = self.bounds;
        _backgroundView.layer.cornerRadius = self.frame.size.height / 2;
        _backgroundView.layer.masksToBounds = YES;
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}


/**
 *  init circleFaceLayer
 *
 *  @return circleFaceLayer
 */
- (CAShapeLayer *)circleSliderLayer {
    if (!_circleSliderLayer) {
        _circleSliderLayer = [CAShapeLayer layer];
        [_circleSliderLayer setFrame:CGRectMake(_paddingWidth, _paddingWidth, _circleSliderRadius * 3.6, _circleSliderRadius * 2)];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:_circleSliderLayer.bounds cornerRadius:8.0];
        _circleSliderLayer.path = circlePath.CGPath;
        [self.backgroundView.layer addSublayer:_circleSliderLayer];
    }
    return _circleSliderLayer;
}

- (CAShapeLayer *)dotsLayer {
    if (!_dotsLayer) {
        _dotsLayer = [CAShapeLayer layer];
        [_dotsLayer setFrame:CGRectMake(_paddingWidth, _paddingWidth, 12, 12)];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:_dotsLayer.bounds];
        _dotsLayer.path = circlePath.CGPath;
        [self.circleSliderLayer addSublayer:_dotsLayer];
    }
    return _dotsLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    _backgroundView.layer.cornerRadius = self.frame.size.height / 2;
    
    _paddingWidth = 1;
    _circleSliderRadius = (self.frame.size.height - 2 * _paddingWidth) / 2;
    
    if (_mws_status == 0) {
        [_circleSliderLayer setFrame:CGRectMake(_paddingWidth, _paddingWidth, _circleSliderRadius * 3.2, _circleSliderRadius * 2)];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:_circleSliderLayer.bounds cornerRadius:8.0];
        _circleSliderLayer.path = circlePath.CGPath;
        
        [_dotsLayer setFrame:CGRectMake(4, (CGRectGetHeight(self.circleSliderLayer.frame)-12)/2.0, CGRectGetHeight(self.circleSliderLayer.frame)/1.6, CGRectGetHeight(self.circleSliderLayer.frame)/1.6)];
        UIBezierPath *circlePath1 = [UIBezierPath bezierPathWithOvalInRect:_dotsLayer.bounds];
        _dotsLayer.fillColor = _leftColor.CGColor;
        _dotsLayer.path = circlePath1.CGPath;
    }else {
        [_circleSliderLayer setFrame:CGRectMake(CGRectGetWidth(self.backgroundView.frame) - _circleSliderRadius * 3.2 - _paddingWidth, _paddingWidth, _circleSliderRadius * 3.2, _circleSliderRadius * 2)];
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:_circleSliderLayer.bounds cornerRadius:8.0];
        _circleSliderLayer.path = circlePath.CGPath;
        
        [_dotsLayer setFrame:CGRectMake(CGRectGetWidth(self.circleSliderLayer.frame)-12-4, (CGRectGetHeight(self.circleSliderLayer.frame)-12)/2.0, CGRectGetHeight(self.circleSliderLayer.frame)/1.6, CGRectGetHeight(self.circleSliderLayer.frame)/1.6)];
        UIBezierPath *circlePath1 = [UIBezierPath bezierPathWithOvalInRect:_dotsLayer.bounds];
        _dotsLayer.fillColor = _rightColor.CGColor;
        _dotsLayer.path = circlePath1.CGPath;
    }
    
    _circleSliderLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    _circleSliderLayer.shadowOffset = CGSizeMake(1, 1);
    _circleSliderLayer.shadowOpacity = 1;
    _circleSliderLayer.shadowRadius = 8.0;
}

@end
