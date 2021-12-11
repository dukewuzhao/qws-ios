//
//  CEClickEffectView.m
//  ClickEffect
//
//  Created by Reese on 13-6-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "G100ClickEffectView.h"
#import <QuartzCore/QuartzCore.h>

@interface G100ClickEffectView ()

@property (strong, nonatomic) CAShapeLayer *circleLayer;

@property (strong, nonatomic) UIBezierPath *circleSmall;

@property (strong, nonatomic) UIBezierPath *circleBig;

@property (assign, nonatomic) CGPoint touchPoint;

@property (assign, nonatomic) CGPoint touchSuperPoint;

@end
@implementation G100ClickEffectView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.effect_enabled = YES;
}

- (instancetype)init {
    if (self = [super init]) {
        self.effect_enabled = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.effect_enabled = YES;
    }
    return self;
}

#pragma mark - Touches Method
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_effect_enabled && !_effect_isAnimating) {
        self.touchPoint = [[touches anyObject] locationInView:self];
        self.touchSuperPoint = [[touches anyObject] locationInView:self.superview];
        [self setTouchedBeganAnimate];
    }
    
    id next = self.nextResponder;
    while (![next isKindOfClass:[UICollectionViewCell class]]) {
        next = [next nextResponder];
    }
    
    [next touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // if (_effect_enabled && !_effect_isAnimating) {
    //     [self setTouchedCancelAnimate];
    // }
    
    id next = self.nextResponder;
    while (![next isKindOfClass:[UICollectionViewCell class]]) {
        next = [next nextResponder];
    }
    
    [next touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_effect_enabled && !_effect_isAnimating) {
        [self setTouchedCancelAnimate];
    }
    
    id next = self.nextResponder;
    while (![next isKindOfClass:[UICollectionViewCell class]]) {
        next = [next nextResponder];
    }
    
    [next touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_effect_enabled && !_effect_isAnimating) {
        UITouch *anyTouch = [touches anyObject];
        CGPoint clickPoint = [anyTouch locationInView:self];
        
        if (CGRectContainsPoint(self.bounds, clickPoint)) {
            
            [self setTouchedEndAnimate];
            if ([self.delegate respondsToSelector:@selector(viewTouchedEndWithView:touchPoint:)]) {
                [self.delegate viewTouchedEndWithView:self.superview touchPoint:self.touchSuperPoint];
            }
        }else {
            [self setTouchedCancelAnimate];
        }
    }
    
    id next = self.nextResponder;
    while (![next isKindOfClass:[UICollectionViewCell class]]) {
        next = [next nextResponder];
    }
    
    [next touchesEnded:touches withEvent:event];
}

#pragma mark - Public Method
- (void)startAnimate
{
    // self.effect_isAnimating = YES;
    // [self setTouchedEndAnimate];
}

#pragma mark - Private Method
- (void)setTouchedEndAnimate
{
    self.effect_isAnimating = YES;
    [_circleLayer removeAnimationForKey:@"bas"];
    
    if (_circleLayer) {
        [_circleLayer removeFromSuperlayer];
        _circleLayer = nil;
    }
    CGPoint touchPoint= self.touchPoint;
    float width;
    float height;
    if (self.touchPoint.x < self.bounds.size.width/2) {
        width = self.bounds.size.width- self.touchPoint.x;
    }else
    {
        width = self.touchPoint.x;
    }
    if (self.touchPoint.y < self.bounds.size.height/2) {
        height = self.bounds.size.height- self.touchPoint.y;
    }else
    {
        height = self.touchPoint.y;
    }
    CGFloat radius = sqrt(width * width + height * height)*2 - sqrt(128) + 8;
    if (!_circleLayer) {
        _circleLayer =[CAShapeLayer layer];
        _circleLayer.frame = CGRectMake(touchPoint.x-42,touchPoint.y-42, 84, 84);
        
        _circleSmall = [UIBezierPath bezierPathWithArcCenter:CGPointMake(42, 42) radius:28 startAngle:0 endAngle:2*M_PI clockwise:YES];
        _circleLayer.backgroundColor= [UIColor clearColor].CGColor;
        _circleLayer.fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0].CGColor;
        _circleLayer.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6].CGColor;
        _circleLayer.lineWidth = 28;
        _circleLayer.path = self.circleSmall.CGPath;
        _circleLayer.transform = CATransform3DMakeScale(1,1,1);
        self.layer.masksToBounds = YES;
        [self.layer insertSublayer:_circleLayer atIndex:0];
    }
    CABasicAnimation * opcAniUp = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opcAniUp.fromValue = [NSNumber numberWithFloat:0.7];
    opcAniUp.toValue =  [NSNumber numberWithFloat:0.1];
    // _circleLayer.strokeColor = [UIColor colorWithRed:0.1763 green:0.1763 blue:0.1763 alpha:0.1].CGColor;
    opcAniUp.removedOnCompletion = NO;
    opcAniUp.duration = radius/300;
    [_circleLayer addAnimation:opcAniUp forKey:@"opcAniUp"];
    
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // bas.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    bas.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1,1,1)];
    bas.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(radius/28, radius/28, radius/28)];
    _circleLayer.transform = CATransform3DMakeScale(radius/28,radius/28,radius/28);
    
    // CAAnimationGroup * groupAni = [CAAnimationGroup animation];
    // groupAni.animations = @[opcAni,bas];
    bas.removedOnCompletion = NO;
    // bas.fillMode = kCAFillModeForwards;
    bas.duration = radius/300;
    [_circleLayer addAnimation:bas forKey:@"bas"];
    
    // [CATransaction commit];
    float pushDelay = radius/900;
    if (pushDelay >0.2) {
        pushDelay = 0.2;
    }
    [self performSelector:@selector(resposeTonotify) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(respondsToPushVC) withObject:nil afterDelay:pushDelay];
    [self performSelector:@selector(removeCirclePath) withObject:nil afterDelay:radius/300];
}

- (void)setTouchedCancelAnimate
{
    self.effect_isAnimating = YES;
    CABasicAnimation * opcAniDown = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opcAniDown.fromValue = [NSNumber numberWithFloat:0.7];
    opcAniDown.toValue =  [NSNumber numberWithFloat:0.0];
    opcAniDown.removedOnCompletion = NO;
    opcAniDown.fillMode = kCAFillModeForwards;
    opcAniDown.duration = 0.3;
    [_circleLayer addAnimation:opcAniDown forKey:@"opcAniDown"];
    [self performSelector:@selector(removeTapCancelCirclePath) withObject:nil afterDelay:0.3];
}

- (void)setTouchedBeganAnimate
{
    // [CATransaction begin];
    [_circleLayer removeAnimationForKey:@"bas"];
    [_circleLayer removeAnimationForKey:@"opcAniUp"];

    if (_circleLayer) {
        [_circleLayer removeFromSuperlayer];
        _circleLayer = nil;
    }
    CGPoint touchPoint= self.touchPoint;
    CGFloat radius = 28;
    _circleLayer =[CAShapeLayer layer];
    _circleLayer.frame = CGRectMake(touchPoint.x-42,touchPoint.y-42, 84, 84);
    
    _circleSmall = [UIBezierPath bezierPathWithArcCenter:CGPointMake(42, 42) radius:5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    _circleBig = [UIBezierPath bezierPathWithArcCenter:CGPointMake(42, 42) radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    _circleLayer.backgroundColor= [UIColor clearColor].CGColor;
    _circleLayer.fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0].CGColor;
    _circleLayer.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
    _circleLayer.lineWidth = 5;
    _circleLayer.path = self.circleSmall.CGPath;
    _circleLayer.transform = CATransform3DMakeScale(1,1,1);
    self.layer.masksToBounds = YES;
    [self.layer insertSublayer:_circleLayer atIndex:0];
    
    CABasicAnimation * opcAniUp = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opcAniUp.fromValue = [NSNumber numberWithFloat:0.1];
    opcAniUp.toValue =  [NSNumber numberWithFloat:0.7];
    _circleLayer.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
    opcAniUp.removedOnCompletion = NO;
    opcAniUp.duration = 0.1;
    [_circleLayer addAnimation:opcAniUp forKey:@"opcAniUp"];

    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // bas.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    bas.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1,1,1)];
    bas.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(5.6, 5.6, 5.6)];
    _circleLayer.transform = CATransform3DMakeScale(5.6,5.6,5.6);
    bas.removedOnCompletion = NO;
    // bas.fillMode = kCAFillModeForwards;
    bas.duration = 0.1;
    [_circleLayer addAnimation:bas forKey:@"bas"];
}

- (void)removeCirclePath {
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    self.effect_isAnimating = NO;
    if ([self.delegate respondsToSelector:@selector(viewTouchedAnimateEndWithView:)]) {
        [self.delegate viewTouchedAnimateEndWithView:self.superview];
    }
}

- (void)removeTapCancelCirclePath {
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    self.effect_isAnimating = NO;
}

- (void)resposeTonotify
{
    if ([self.delegate respondsToSelector:@selector(viewTouchedToBeginAnimate:touchPoint:)]) {
        [self.delegate viewTouchedToBeginAnimate:self.superview touchPoint:self.touchSuperPoint];
    }
}

- (void)respondsToPushVC
{
    if ([self.delegate respondsToSelector:@selector(viewTouchedToPushWithView:touchPoint:)]) {
        [self.delegate viewTouchedToPushWithView:self.superview touchPoint:self.touchSuperPoint];
    }
}
@end
