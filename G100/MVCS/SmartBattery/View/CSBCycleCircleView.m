//
//  CSBCycleCircleView.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "CSBCycleCircleView.h"
#import "G100BatteryDomain.h"
#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式

static CGFloat lineWidth = 20.0f;
static int count = 600;
@interface CSBCycleCircleView () {
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

@end

@implementation CSBCycleCircleView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [ self setUpView];
        [self initData];
    }
    return self;
}
- (void)initData
{
    self.startColor = [UIColor colorWithRed:0.00 green:0.75 blue:0.82 alpha:1.00];
    self.endColor =  [UIColor colorWithHexString:@"off32b"];
}
- (void)setUpView
{
    _label = [[UILabel alloc]init];
    _label.text = @"还可循环使用";
    _label.font = [UIFont systemFontOfSize:16.0];
    _label.textColor = [UIColor colorWithHexString:@"7D7D7D"];
    [self addSubview:_label];
    
    _batteryStateLabel = [[UILabel alloc]init];
    _batteryStateLabel.text = @"状态良好";
    _batteryStateLabel.textColor = [UIColor colorWithHexString:@"00B5B3"];
    [self addSubview:_batteryStateLabel];
    
    _hunImageView = [[UIImageView alloc]init];
    [self addSubview:_hunImageView];
    
    _tenImageView = [[UIImageView alloc]init];
    [self addSubview:_tenImageView];
    
    _perImageView = [[UIImageView alloc]init];
    [self addSubview:_perImageView];
    
    _symbolImageView = [[UIImageView alloc]init];
    [self addSubview:_symbolImageView];
    
    UILabel *ciLable = [[UILabel alloc]init];
    ciLable.text = @"次";
    ciLable.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [_symbolImageView addSubview:ciLable];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.equalTo(self.mas_top).offset(66);
    }];
    
    [_symbolImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(-60);
        make.centerY.mas_equalTo(self);
        make.width.equalTo(self.mas_width).multipliedBy(0.08);
        make.height.equalTo(self.mas_height).multipliedBy(0.28);
    }];
    
    [_perImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width).multipliedBy(0.15);
        make.right.equalTo(self.symbolImageView.mas_left).offset(-10);
        make.height.centerY.mas_equalTo(self.symbolImageView);
    }];
    [_tenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.perImageView.mas_left).offset(-10);
        make.width.height.centerY.mas_equalTo(self.perImageView);
    }];
    [_hunImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.tenImageView.mas_left).offset(-10);
        make.width.height.centerY.mas_equalTo(self.perImageView);
    }];
    
    [_batteryStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.equalTo(self.symbolImageView.mas_bottom).offset(20);
    }];
    
    [ciLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(_symbolImageView);
    }];
}
- (void)startAnimation
{
    [self setUpTimer];
}
- (void)stopAnimation
{
    [_timer invalidate];
    _timer = nil;
    if (self.rateNum != 0) {
         count = self.rateNum;
    }
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
    if (count < self.cycleCount) {
        [self.timer invalidate];
        self.timer = nil;
        count = self.cycleCount;
    }
    [self setUpImageWithPercentage:count];
   
    count = count - 5;
}
- (void)setUpImageWithPercentage:(NSInteger)percentage
{
    //圆形进度条
    if (self.rateNum == 0) {
        self.rateNum = 600;
    }
    self.currentProgress = [[NSString stringWithFormat:@"%.2f", percentage / (self.rateNum * 1.00)] floatValue];

    NSInteger hunNum = labs(percentage)/100;
    NSInteger tenNum = labs(percentage)%100/10;
    NSInteger perNum =labs(percentage)%100%10;
    
     _perImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_elec%ld.png", perNum]];
    //一位数
    if (hunNum == 0 && tenNum == 0) {
        _hunImageView.hidden = YES;
        _tenImageView.hidden = YES;
        [self.symbolImageViewRightConstraint uninstall];
        [_symbolImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(- (self.frame.size.width - (lineWidth * 2) - 10)* 0.77 * 0.5);
        }];
    }else{
        //两位数
        _hunImageView.hidden = YES;
        _tenImageView.hidden = NO;
        _tenImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_elec%ld.png",tenNum]];
        
        [self.symbolImageViewRightConstraint uninstall];
        [_symbolImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(- (self.frame.size.width - (lineWidth * 2) - 20)* 0.62 * 0.5);
        }];
        if (hunNum != 0) {
            //三位数
            _hunImageView.hidden = NO;
            _hunImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_elec%ld.png",(long)hunNum]];
            [self.symbolImageViewRightConstraint uninstall];
            [_symbolImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                self.symbolImageViewRightConstraint = make.right.equalTo(self.mas_right).offset(-(  self.frame.size.width - (lineWidth * 2) - 30)* 0.47 *0.5);
            }];
            
        }
    }
    [UIView animateWithDuration:3.00/_cycleCount animations:^{
        [self layoutIfNeeded];
        [self setNeedsDisplay];
    }];
}
#pragma mark - draw rect
- (void)drawRect:(CGRect)rect
{
    self.circleCenter = CGPointMake(self.center.x, self.center.y - self.frame.origin.y); //圆点
    self.circleRadius = self.bounds.size.width * 0.5 - ((30 /2) *( WIDTH / 414.00)); //半径
    // 进度条背景图层
    if (!_trackLayer) {
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = self.bounds;
        [self.layer addSublayer:_trackLayer];
        _trackLayer.fillColor = [[UIColor clearColor] CGColor];
        _trackLayer.strokeColor = [[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] CGColor];
        _trackLayer.opacity = 0.5;
        _trackLayer.lineCap = kCALineCapRound;
        _trackLayer.lineWidth = lineWidth;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.circleCenter
                                                            radius:self.circleRadius
                                                        startAngle:degreesToRadians(270)
                                                          endAngle:degreesToRadians(-90)
                                                         clockwise:NO];//构建圆形
        _trackLayer.path =[path CGPath]; //把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    }
   
    // 进度条
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [[UIColor clearColor]CGColor]; //填充色
        _progressLayer.strokeColor = [[UIColor grayColor]CGColor]; //指定path的渲染颜色(不透明)
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
        
        [_gradientLayer setMask:_progressLayer]; //用progressLayer来截取渐变层
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
    _rateNum = batteryDomain.use_cycle.rated_num;
    _cycleCount =  batteryDomain.use_cycle.rated_num - batteryDomain.use_cycle.use_num;
    _batteryStateLabel.text = batteryDomain.use_cycle.status_des;
    
    self.currentProgress = [[NSString stringWithFormat:@"%.2f", _cycleCount / (_rateNum * 1.00)] floatValue];
    
    if (!_hasLoadAnimation) {
        [self setUpImageWithPercentage:_rateNum];
    }else {
        [self setUpImageWithPercentage:_cycleCount];
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

- (void)willRemoveSubview:(UIView *)subview
{
    [_timer invalidate];
    _timer = nil;
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [_timer invalidate];
        _timer = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
