//
//  CSBCircleView.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "CSBCircleView.h"
#import "G100BatteryDomain.h"
#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式

static CGFloat lineWidth = 20.0f;
@interface CSBCircleView() {
    BOOL _hasLoadAnimation;
}

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UILabel *batteryStateLabel;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIImageView *hunImageView;

@property (nonatomic, strong) UIImageView *tenImageView;

@property (nonatomic, strong) UIImageView *perImageView;

@property (nonatomic, strong) UIImageView *symbolImageView;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) CAShapeLayer *trackLayer;

@property (nonatomic, strong) CALayer *gradientLayer;

@property (nonatomic, assign) CGPoint circleCenter;

@property (nonatomic, assign) CGFloat circleRadius;

@property (nonatomic, strong) UIColor *startColor;

@property (nonatomic, strong) UIColor *endColor;

@property (nonatomic, strong) MASConstraint *symbolImageViewRightConstraint;

@property (nonatomic, assign) CGFloat currentProgress;

@property (nonatomic, assign) CGFloat rateNum;

@property (nonatomic, assign) CGFloat cycleCount;

@end

static int count = 100;

@implementation CSBCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUpView];
    }
    return self;
}
- (void)setUpView
{
    self.currentProgress = 1.0;
    self.startColor = [UIColor colorWithRed:0.00 green:0.75 blue:0.82 alpha:1.00];
    self.endColor =  [UIColor colorWithHexString:@"off32b"];
    
    _label = [[UILabel alloc]init];
    _label.text = @"电池有效率";
    _label.textColor = [UIColor colorWithHexString:@"7D7D7D"];
    _label.font = [UIFont systemFontOfSize:16.0];
    [self addSubview:_label];
    
    _batteryStateLabel = [[UILabel alloc]init];
    _batteryStateLabel.textColor = [UIColor colorWithHexString:@"00B5B3"];
    _batteryStateLabel.text = @"状态良好";
    
    
    [self addSubview:_batteryStateLabel];
    _hunImageView = [[UIImageView alloc]init];
    [self addSubview:_hunImageView];
    
    _tenImageView = [[UIImageView alloc]init];
    [self addSubview:_tenImageView];
    
    _perImageView = [[UIImageView alloc]init];
    [self addSubview:_perImageView];
    
    _symbolImageView = [[UIImageView alloc]init];
    _symbolImageView.image = [UIImage imageNamed:@"icon_elec%.png"];
    [self addSubview:_symbolImageView];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.equalTo(self.mas_top).offset(66);
    }];
    
    [_symbolImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(-60);
        make.centerY.mas_equalTo(self);
        make.width.equalTo(self.mas_width).multipliedBy(0.15);
        make.height.equalTo(self.mas_height).multipliedBy(0.28);
    }];
    
    [_perImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.symbolImageView.mas_left).offset(-10);
        make.width.height.centerY.mas_equalTo(self.symbolImageView);
    }];
    [_tenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.perImageView.mas_left).offset(-10);
        make.width.height.centerY.mas_equalTo(self.symbolImageView);
    }];
    [_hunImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.tenImageView.mas_left).offset(-10);
        make.width.height.centerY.mas_equalTo(self.symbolImageView);
    }];
    
    [_batteryStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.equalTo(self.symbolImageView.mas_bottom).offset(20);
    }];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
}
- (void)startAnimation
{
    [self setUpTimer];
}
- (void)stopAnimation
{
    [_timer invalidate];
    _timer = nil;
    count = 100;
    _progressLayer.strokeEnd = 1;
    self.currentProgress = 1;
    [self setUpImageWithPercentage:count];
}
- (void)setUpTimer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.00/_cycleCount
                                                  target:self
                                                selector:@selector(percentageChanged)
                                                userInfo:nil
                                                 repeats:YES];
    }
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
#pragma mark - 定时器方法
- (void)percentageChanged
{
    if (count  < self.progress * 100) {
        [_timer invalidate];
        _timer = nil;
        count = self.progress * 100;
    }
    [self setUpImageWithPercentage:count];
    count--;
}
- (void)setUpImageWithPercentage:(NSInteger)percentage
{
    //圆形进度条
    _currentProgress = percentage / 100.00;
    NSInteger hunNum = labs(percentage)/100;
    NSInteger tenNum = labs(percentage)%100/10;
    NSInteger perNum = labs(percentage)%100%10;
    _perImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_elec%ld.png", perNum]];
    //一位数
    if (hunNum == 0 && tenNum == 0) {
        _hunImageView.hidden = YES;
        _tenImageView.hidden = YES;
        [self.symbolImageViewRightConstraint uninstall];
        [_symbolImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(- (self.frame.size.width - (lineWidth * 2)) * 0.7 * 0.5);
        }];
    }else{
        //两位数
        _hunImageView.hidden = YES;
        _tenImageView.hidden = NO;
        _tenImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_elec%ld.png",tenNum]];
        
        [self.symbolImageViewRightConstraint uninstall];
        [_symbolImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(- (self.frame.size.width - (lineWidth * 2)) * 0.55 * 0.5);
        }];
        if (hunNum != 0) {
            //三位数
            _hunImageView.hidden = NO;
            _hunImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_elec%ld.png",(long)hunNum]];
            [self.symbolImageViewRightConstraint uninstall];
            [_symbolImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(-  (self.frame.size.width - (lineWidth * 2)) * 0.4 * 0.5);
            }];
            
        }
    }
    
    [self layoutIfNeeded];
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    self.circleCenter = CGPointMake(self.center.x, self.center.y - self.frame.origin.y); //圆点
    self.circleRadius = self.bounds.size.width * 0.5 - lineWidth /2; //半径
    if (!_trackLayer) {
        // 进度条背景图层
        _trackLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_trackLayer];
        _trackLayer.frame = self.bounds;
        _trackLayer.fillColor = [[UIColor clearColor] CGColor];
        _trackLayer.strokeColor = [[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] CGColor];
        _trackLayer.opacity = 1;
        _trackLayer.lineCap = kCALineCapRound;
        _trackLayer.lineWidth = lineWidth;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.circleCenter
                                                            radius:self.circleRadius
                                                        startAngle:degreesToRadians(270)
                                                          endAngle:degreesToRadians(-90)
                                                         clockwise:NO];//构建圆形
        _trackLayer.path =[path CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    }
    
    if (!_progressLayer) {
        // 进度条
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [[UIColor clearColor]CGColor]; //填充色
        _progressLayer.strokeColor = [[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] CGColor]; //指定path的渲染颜色(不透明)
        _progressLayer.opacity = 1;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = lineWidth;
        _progressLayer.strokeEnd = 1;
        
    }
    
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:self.circleCenter
                                                         radius:self.circleRadius
                                                     startAngle:M_PI + M_PI_2
                                                       endAngle:M_PI + M_PI_2 +(-M_PI * 2 *self.currentProgress)
                                                      clockwise:NO];//构建圆形
    _progressLayer.path = [path1 CGPath];
    
    [self setUpColor];
    
}
//渐变色图层
- (void)setUpColor
{
    if (!_gradientLayer) {
        _gradientLayer = [CALayer layer];
        //左侧的渐变色
        CAGradientLayer *leftLayer = [CAGradientLayer layer];
        leftLayer.frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        leftLayer.locations = @[@0.3, @0.9, @1];
        leftLayer.colors = @[(id)_startColor.CGColor, (id)_endColor.CGColor];
        leftLayer.startPoint = CGPointMake(0, 0.5);
        leftLayer.endPoint = CGPointMake(0, 0);
        [_gradientLayer addSublayer:leftLayer];
        
        //右侧渐变色
        CAGradientLayer *rightLayer = [CAGradientLayer layer];
        rightLayer.frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, self.bounds.size.height);
        rightLayer.locations = @[@0.3, @0.9, @1];
        rightLayer.startPoint = CGPointMake(0, 1);
        rightLayer.endPoint = CGPointMake(0, 0.5);
        rightLayer.colors = @[(id)_startColor.CGColor, (id)_endColor.CGColor];
        [_gradientLayer addSublayer:rightLayer];
        
        [_gradientLayer setMask:_progressLayer]; //用trackLayer来截取渐变层
        [self.layer addSublayer:_gradientLayer];
    }
    
}

#pragma mark - set
- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain
{
    _batteryDomain = batteryDomain;
    
    if ([self.timer isValid]) {
        return;
    }
    
    _batteryStateLabel.text = _batteryDomain.performance.status_des;
    
    CGFloat status = _batteryDomain.performance.valid_c * 1.00 / _batteryDomain.performance.rated_c;
    if (status >= 0.5) {
        self.startColor = [UIColor colorWithRed:0.00 green:0.75 blue:0.82 alpha:1.00];
        self.endColor =  [UIColor colorWithHexString:@"off32b"];
    }else{
        self.startColor = [UIColor colorWithHexString:@"ff9c00"];
        self.endColor = [UIColor colorWithHexString:@"ee1515"];
    }
    
    self.rateNum = batteryDomain.performance.valid_c / 1000;
    self.cycleCount = (batteryDomain.performance.valid_c * 1.00 / 1000) - (batteryDomain.performance.rated_c * 1.00 / 1000);
    
    self.progress = status;
    self.currentProgress = status;
    
    if (!_hasLoadAnimation) {
        [self setUpImageWithPercentage:100];
    }else {
        [self setUpImageWithPercentage:batteryDomain.performance.valid_c * 1.00 / _batteryDomain.performance.rated_c * 100];
    }
}

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated {
    [self setBatteryDomain:batteryDomain];
    // 是否需要动画显示
    if (animated) {
        [self stopAnimation];
        [self startAnimation];
        _hasLoadAnimation = YES;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [_timer invalidate];
        _timer = nil;
    }
}

// CAGradientLayer 讲解 http://www.cnblogs.com/YouXianMing/p/3793913.html
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
