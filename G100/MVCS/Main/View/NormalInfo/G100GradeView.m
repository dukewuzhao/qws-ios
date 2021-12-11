//
//  SYCompassView.m
//  SYCompassDemo
//
//  Created by 陈蜜 on 16/6/27.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import "G100GradeView.h"
#define calibrationColor            [UIColor colorWithRed:0.2283 green:0.2239 blue:0.2328 alpha:0.4]
#define calibrationTinkColor        [UIColor whiteColor]

@interface G100GradeView ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGPoint point;

@property (strong, nonatomic) UIImageView *hunImageView;
@property (strong, nonatomic) UIImageView *tenImageView;
@property (strong, nonatomic) UIImageView *perImageView;
@property (nonatomic, strong) UIImageView *fenImageView;

@property (strong, nonatomic) NSMutableArray *layers;

@property (strong, nonatomic) NSTimer *aniTimer;

@property (assign, nonatomic) NSInteger num;

@property (assign, nonatomic) BOOL isAnimate;

@property (assign, nonatomic) NSInteger newGrade;

@property (assign, nonatomic) BOOL isFirst;
@property (assign, nonatomic) BOOL isCreat;

@end

@implementation G100GradeView

+ (instancetype)sharedWithFrame:(CGRect)rect option:(id)option
{
    return [[self alloc]initWithFrame:rect option:option];
}

- (instancetype)initWithFrame:(CGRect)frame option:(id)option
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        _option = option;
        _grade = -1;
        [self customUI];
}
    return self;
}

-(void)drawRect:(CGRect)rect
{
    if (!self.isCreat) {
        if (self.isAnimate) {
            [self createBadGradeWithRect:rect];
        }else
        {
            [self createCalibration:rect withIsTest:NO];
        }
    }
}

-(NSMutableArray *)layers
{
    if (!_layers) {
        _layers = [NSMutableArray array];
    }
    return _layers;
}

-(UIView *)bgView
{
    
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        _bgView.backgroundColor = [UIColor clearColor];
    }
    return _bgView;
}
- (void)customUI
{
    
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(@0);
    }];
    
    _percentView = [PercentShowView showView];

    [self.bgView addSubview:self.percentView];
    
    [self.percentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(@0);
    }];
    
    [_percentView setPercentAnimateWithPercent:self.grade];
}


- (void)beginDraw:(NSTimer *)timer
{
    if (self.num >=100) {
        [self.aniTimer invalidate];
        self.aniTimer =nil;
        self.num = 0;
        if (self.grade == 0) {
            [self.percentView setPercentAnimateWithPercent:self.grade];
        }
        return;
    }
    CGFloat perAngle = M_PI/100;
    CGFloat startAngle = (-M_PI_2+perAngle*(2*self.num+1));
    CGFloat endAngle = startAngle+perAngle;
    
    UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width*15/32 startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    if (self.num < (100-self.grade)) {
        shapeLayer.strokeColor = calibrationColor.CGColor;
        NSInteger rand = arc4random()%100;
        [self.percentView setPercentAnimateWithPercent:rand];
    }else
    {
        [self.percentView setPercentAnimateWithPercent:self.grade];
        shapeLayer.strokeColor = calibrationTinkColor.CGColor;
      
    }
   
    shapeLayer.lineWidth = self.bounds.size.width/16;
    shapeLayer.path = bezPath.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer replaceSublayer:self.layer.sublayers[self.num+1] with:shapeLayer];
    self.num++;
}
/**
 *  创建刻度
 */
- (void)createCalibration:(CGRect)rect withIsTest:(BOOL)istest
{
    //self.grade = self.grade == -1 ? 0 : self.grade;
    if (self.grade == -1) {
        self.grade = 0;
    }
    self.num = 0;
    if (self.isAnimate) {
        [self createBestGradeWithRect:rect];
        if (!self.aniTimer) {
            self.aniTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(beginDraw:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.aniTimer forMode:NSRunLoopCommonModes];
        }
    }else
    {
        if (istest) {
            for (int i = 0; i< 100; i++) {
                CGFloat perAngle = M_PI/100;
                CGFloat startAngle = (-M_PI_2+perAngle*(2*i+1));
                CGFloat endAngle = startAngle+perAngle;
                
                UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width*15/32 startAngle:startAngle endAngle:endAngle clockwise:YES];
                
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                if (i < (100-self.grade)) {
                    shapeLayer.strokeColor = calibrationColor.CGColor;
                }else
                {
                    shapeLayer.strokeColor = calibrationTinkColor.CGColor;
                }
                shapeLayer.lineWidth = self.bounds.size.width/16;
                shapeLayer.path = bezPath.CGPath;
                shapeLayer.fillColor = [UIColor clearColor].CGColor;
                if (self.layer.sublayers.count == 101) {
                    [self.layer replaceSublayer:self.layer.sublayers[i+1] with:shapeLayer];
                }else
                {
                    [self.layer addSublayer:shapeLayer];
                }
            }
            [self.percentView setPercentAnimateWithPercent:self.grade];
        }else
        {
            [self createBadGradeWithRect:rect];
            [self.percentView setPercentAnimateWithPercent:-1];
            self.isCreat = YES;
        }
    }
}

- (void)createBestGradeWithRect:(CGRect)rect
{
    for (int i =0; i< 100; i++) {
        CGFloat perAngle = M_PI/100;
        CGFloat startAngle = (-M_PI_2+perAngle*(2*i+1));
        CGFloat endAngle = startAngle+perAngle;
        
        UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width*15/32 startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.strokeColor = calibrationTinkColor.CGColor;
        shapeLayer.lineWidth = rect.size.width/16;
        shapeLayer.path = bezPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        if (self.layer.sublayers.count == 101) {
            [self.layer replaceSublayer:self.layer.sublayers[i+1] with:shapeLayer];
        }else
        {
            [self.layer addSublayer:shapeLayer];
        }
    }

}

- (void)createBadGradeWithRect:(CGRect)rect
{
    for (int i =0; i< 100; i++) {
        CGFloat perAngle = M_PI/100;
        CGFloat startAngle = (-M_PI_2+perAngle*(2*i+1));
        CGFloat endAngle = startAngle+perAngle;
        
        UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width*15/32 startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.strokeColor = calibrationColor.CGColor;
        //}
        shapeLayer.lineWidth = rect.size.width/16;
        shapeLayer.path = bezPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        if (self.layer.sublayers.count == 101) {
            [self.layer replaceSublayer:self.layer.sublayers[i+1] with:shapeLayer];
        }else
        {
            [self.layer addSublayer:shapeLayer];
        }
    }
    self.isCreat = YES;
}

-(void)setGradeViewWithGrade:(float)grade isAnimation:(BOOL)animate
{
    self.isAnimate = animate;
    if (grade != -1) {
        self.grade = grade;
        [self createCalibration:self.bounds withIsTest:YES];
    }else
    {
        self.grade = 0;
        [self createCalibration:self.bounds withIsTest:NO];
    }
    
}

@end
