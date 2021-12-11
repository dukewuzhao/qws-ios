//
//  EleShowView.m
//  G100
//
//  Created by sunjingjing on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "EleShowView.h"
#define annimateTime 5.0

@interface EleShowView ()
@property (strong, nonatomic) CAShapeLayer *arcLayer;
@property (strong, nonatomic)  UIBezierPath *path;


@end
@implementation EleShowView

+(instancetype)sharedViewWithFrame:(CGRect)frame option:(NSInteger)option
{
    return [[self alloc]initWithFrame:frame option:option];
}

- (id)initWithFrame:(CGRect)frame option:(NSInteger)option
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        if (option<0) {
            self.lastPercnet = 0;
        }else
        {
           self.lastPercnet = option;
        }
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    if (self.arcLayer) {
        return;
    }
    CAShapeLayer *arcLayerBase = [CAShapeLayer layer];
    UIBezierPath *pathBase=[UIBezierPath bezierPath];
    [pathBase addArcWithCenter:CGPointMake(rect.size.width/2,rect.size.height/2) radius:rect.size.height*25/52 startAngle:3*M_PI_4 endAngle:M_PI_4 clockwise:YES];
    arcLayerBase.path=pathBase.CGPath;
    arcLayerBase.fillColor=[UIColor clearColor].CGColor;
    arcLayerBase.strokeColor=[UIColor colorWithRed:0.4568 green:0.4546 blue:0.459 alpha:0.2].CGColor;
    arcLayerBase.lineWidth= rect.size.height/26;
    arcLayerBase.lineCap = kCALineCapRound;
    arcLayerBase.frame=rect;
    [self.layer addSublayer:arcLayerBase];
    
    
    float angle = ((self.lastPercnet/100)*3/2 *M_PI + 3*M_PI_4);
    if (angle>2*M_PI) {
        angle = angle -2*M_PI;
    }
    _arcLayer=[CAShapeLayer layer];
    _path=[UIBezierPath bezierPath];
    [_path addArcWithCenter:CGPointMake(rect.size.width/2,rect.size.height/2) radius:rect.size.height*25/52 startAngle:3*M_PI_4 endAngle:angle clockwise:YES];
    _arcLayer.path=_path.CGPath;
    _arcLayer.fillColor=[UIColor clearColor].CGColor;
    _arcLayer.strokeColor=[UIColor whiteColor].CGColor;
    _arcLayer.lineWidth = rect.size.height/26;
    _arcLayer.frame=rect;
    _arcLayer.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:_arcLayer];
   
}

-(void)setViewWithPercent:(float)percent isAnimate:(BOOL)isAnimate
{
    
    if (!isAnimate) {
        [self.arcLayer removeFromSuperlayer];
        self.arcLayer =nil;
        self.path = nil;
        float angle = (percent/100)*3/2 *M_PI + 3*M_PI_4;
        if (angle> 2*M_PI) {
            angle -= 2*M_PI;
        }
        
        _arcLayer=[CAShapeLayer layer];
        _path=[UIBezierPath bezierPath];
        _arcLayer.fillColor=[UIColor clearColor].CGColor;
        _arcLayer.strokeColor=[UIColor whiteColor].CGColor;
        _arcLayer.lineWidth = self.bounds.size.height/26;
        _arcLayer.frame=self.bounds;
        _arcLayer.lineCap = kCALineCapRound;
        [_path addArcWithCenter:CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2) radius:self.bounds.size.height*25/52 startAngle:3*M_PI_4 endAngle:angle clockwise:YES];
        _arcLayer.path=_path.CGPath;
        [self.layer addSublayer:_arcLayer];
        self.lastPercnet = percent;
        return;
    }
    percent = percent<0 ? 0 :percent;
    [self.arcLayer removeAnimationForKey:@"keyStroke"];
   // CGRect rect = self.bounds;
    float angleLast = (self.lastPercnet/100)*3/2 *M_PI + 3*M_PI_4;
    if (angleLast>2*M_PI) {
        angleLast = angleLast-2*M_PI;
    }
    float angle = (percent/100)*3/2 *M_PI + 3*M_PI_4;
    if (angle> 2*M_PI) {
        angle -= 2*M_PI;
    }
//    if (percent > self.lastPercnet) {
//
   // UIBezierPath *decresePath = [UIBezierPath bezierPath];
     //[decresePath addArcWithCenter:CGPointMake(rect.size.width/2,rect.size.height/2) radius:rect.size.height*25/52 startAngle:3*M_PI_4 endAngle:3*M_PI_4 clockwise:YES];
    if (self.lastPercnet == 0) {
        
        [self performSelector:@selector(upPercent) withObject:nil afterDelay:0.25];
        self.lastPercnet = percent;
        return;
    }
    UIBezierPath *decresePath = [_path bezierPathByReversingPath];
    _arcLayer.path= decresePath.CGPath;
     //[self.layer addSublayer:_arcLayer];
        CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeStart"];
        bas.duration = self.lastPercnet/100;
        bas.removedOnCompletion = NO;
        bas.fromValue=[NSNumber numberWithFloat:0];
        bas.toValue=[NSNumber numberWithFloat:1];
        bas.fillMode = kCAFillModeForwards;
        [_arcLayer addAnimation:bas forKey:@"keyStroke"];
        [self performSelector:@selector(upPercent) withObject:nil afterDelay:(self.lastPercnet/100+0.25)];
         self.lastPercnet = percent;

}

- (void)upPercent
{
    [self.arcLayer removeAnimationForKey:@"keyRotation"];
    [self.arcLayer removeFromSuperlayer];
    self.arcLayer =nil;
    self.path = nil;
    float angle = (self.lastPercnet/100)*3/2 *M_PI + 3*M_PI_4;
    if (angle> 2*M_PI) {
        angle -= 2*M_PI;
    }
    
    _arcLayer=[CAShapeLayer layer];
    _path=[UIBezierPath bezierPath];
    _arcLayer.fillColor=[UIColor clearColor].CGColor;
    _arcLayer.strokeColor=[UIColor whiteColor].CGColor;
    _arcLayer.lineWidth = self.bounds.size.height/26;
    _arcLayer.frame=self.bounds;
    _arcLayer.lineCap = kCALineCapRound;
    [_path addArcWithCenter:CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2) radius:self.bounds.size.height*25/52 startAngle:3*M_PI_4 endAngle:angle clockwise:YES];
    _arcLayer.path=_path.CGPath;
    [self.layer addSublayer:_arcLayer];

    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration = self.lastPercnet/100;
    bas.removedOnCompletion = NO;
    bas.fromValue=[NSNumber numberWithFloat:0];
    bas.toValue=[NSNumber numberWithFloat:1];
    [_arcLayer addAnimation:bas forKey:@"keyRotation"];
}

@end
