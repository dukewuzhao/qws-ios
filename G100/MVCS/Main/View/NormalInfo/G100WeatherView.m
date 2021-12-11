//
//  G100WeatherView.m
//  G100
//
//  Created by sunjingjing on 16/6/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100WeatherView.h"
#import "NSDate+TimeString.h"
#import "G100WeatherManager.h"
#import "G100NoCarView.h"
#import "G100WeatherInitErrorView.h"
@interface G100WeatherView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tenWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *perWidConstraint;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger num;

@property (assign, nonatomic) NSInteger temp;

@end

@implementation G100WeatherView

+ (instancetype)showView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100WeatherView" owner:nil options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.lastTemp = 24;
    [self setTempImageWithTemp:self.lastTemp];
    [self setBackgroundWithTemperature:self.lastTemp];
    if (ISIPHONE_4 || ISIPHONE_5) {
        self.locationLabel.font = [UIFont systemFontOfSize:10];
        self.weathLabel.font = [UIFont systemFontOfSize:15];
        self.timeRefLabel.font = [UIFont systemFontOfSize:10];
    }
    _noWeather = [G100NoWeatherView showView];
    [self insertSubview:self.noWeather belowSubview:self.clickedAniView];
    [self.noWeather mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

-(void)setWeatherModel:(G100WeatherModel *)weatherModel
{
    _weatherModel = weatherModel;
}

- (void)updateDataWithWeatherModel:(G100WeatherModel *)weaModel
{
    if (_ErrorView) {
        [self.ErrorView removeFromSuperview];
        self.ErrorView = nil;
    }
    if (self.noWeather) {
        [self.noWeather removeFromSuperview];
        self.noWeather = nil;
    }
    self.lastTemp = [weaModel.temperature integerValue];
    [UIView animateWithDuration:0.5 animations:^{
        [self setImageViewByWeather:weaModel.weather];
        self.weathLabel.text = weaModel.weather;
        self.timeRefLabel.text = [NSString stringWithFormat:@"%@发布", [NSDate getWeatherReportTimeWithDate:weaModel.reportTime]];
        self.locationLabel.text = weaModel.locAddress;
        [self setTempImageWithTemp:self.lastTemp];

    } completion:^(BOOL finished) {
        
        [self setBackgroundWithTemperature:[self.weatherModel.temperature integerValue]];
        
    }];
}

- (void)setImageViewByWeather:(NSString *)weatherStatus
{
    if ([weatherStatus isEqualToString:@"晴"]) {
        weatherStatus = @"icon_wea_fine";
    }else if ([weatherStatus isEqualToString:@"多云"]) {
        weatherStatus = @"icon_wea_cloud";
    }else if ([weatherStatus isEqualToString:@"阴"]) {
        weatherStatus = @"icon_wea_yin";
    }else if ([weatherStatus isEqualToString:@"阵雨"]) {
        weatherStatus = @"icon_wea_zhenRain";
    }else if ([weatherStatus isEqualToString:@"雷阵雨"]) {
        weatherStatus = @"icon_wea_leiRain";
    }else if ([weatherStatus hasContainString:@"冰雹"]) {
        weatherStatus = @"icon_wea_ice";
    }else if ([weatherStatus isEqualToString:@"雨夹雪"]) {
        weatherStatus = @"icon_wea_rain&Snow";
    }else if ([weatherStatus isEqualToString:@"小雨"]) {
        weatherStatus = @"icon_wea_smaRain";
    }else if ([weatherStatus isEqualToString:@"中雨"]) {
        weatherStatus = @"icon_wea_midRain";
    }else if ([weatherStatus isEqualToString:@"大雨"]) {
        weatherStatus = @"icon_wea_bigRain";
    }else if ([weatherStatus hasContainString:@"暴雨"]) {
        weatherStatus = @"icon_wea_baoRain";
    }else if ([weatherStatus isEqualToString:@"小雨-中雨"]) {
        weatherStatus = @"icon_wea_midRain";
    }else if ([weatherStatus isEqualToString:@"中雨-大雨"]) {
        weatherStatus = @"icon_wea_bigRain";
    }else if ([weatherStatus isEqualToString:@"阵雪"]) {
        weatherStatus = @"icon_wea_smaSnow";
    }else if ([weatherStatus isEqualToString:@"小雪"]) {
        weatherStatus = @"icon_wea_smaSnow";
    }else if ([weatherStatus isEqualToString:@"中雪"]) {
        weatherStatus = @"icon_wea_midSnow@";
    }else if ([weatherStatus isEqualToString:@"大雪"]) {
        weatherStatus = @"icon_wea_bigSnow";
    }else if ([weatherStatus hasContainString:@"暴雪"]) {
        weatherStatus = @"icon_wea_baoC&Snow";
    }else if ([weatherStatus hasContainString:@"雾"]) {
        weatherStatus = @"icon_wea_wu";
    }else if ([weatherStatus hasContainString:@"霾"]) {
        weatherStatus = @"icon_wea_mai";
    }else if ([weatherStatus isEqualToString:@"小雪-中雪"]) {
        weatherStatus = @"icon_wea_midSnow雪";
    }else if ([weatherStatus isEqualToString:@"中雪-大雪"]) {
        weatherStatus = @"icon_wea_bigSnow";
    }else if ([weatherStatus isEqualToString:@"扬沙"] ||
              [weatherStatus isEqualToString:@"浮尘"]) {
        weatherStatus = @"icon_wea_dust";
    }
    
    self.weathImageView.image = [UIImage imageNamed:weatherStatus];

}
-(void)setTempImageWithTemp:(NSInteger)temp
{
    
   NSInteger tenNum = labs(temp)/10;
   NSInteger perNum =labs(temp)%10;
    
    NSString *imageNameTen = [NSString stringWithFormat:@"ic_big%ld",(long)tenNum];
    NSString *imageNamePer = [NSString stringWithFormat:@"ic_big%ld",(long)perNum];
    if (temp <0) {
        
        self.minWidthConstraint.constant = 20;
        self.minImageView.image = [UIImage imageNamed:@"icon_wea_-0"];
        
    }else
    {
        self.minWidthConstraint.constant = 0;
    }
    
    if (tenNum==0) {
        self.tenWidConstraint.constant = 0;
    }else
    {
        if (tenNum == 1) {
            self.tenWidConstraint.constant = 12;
        }else
        {
            self.tenWidConstraint.constant = 20;
        }
        self.tenImageView.image = [UIImage imageNamed:imageNameTen];
    }
    
    if (perNum == 1) {
        
        self.perWidConstraint.constant = 12;
    }else
    {
        self.perWidConstraint.constant = 20;

    }
    
    self.perImageView.image = [UIImage imageNamed:imageNamePer];
    //[self setBackgroundWithTemperature:temp];
}

-(void)setBackgroundWithTemperature:(NSInteger)temperature
{
    [self.bgImageView.layer removeAnimationForKey:@"bgTrans"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.bgImageView.layer addAnimation:transition forKey:@"bgTrans"];
    if (temperature < 0) {
        
        [self.bgImageView setImage:[UIImage imageNamed:@"bg_wea_cold"]];
    }else if (temperature >= 0 && temperature <= 15)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"bg_wea_cool"]];
        
    }else if (temperature > 15 && temperature <= 25)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"bg_wea_soft"]];
    }else if (temperature > 25 && temperature <= 35)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"bg_wea_warm"]];

    }else if (temperature >35)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"bg_wea_hot"]];

    }
    
}

- (void)beginAnimateWithIsInit:(BOOL)isInit
{
    if (self.isAnimating) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateDataWithWeatherModel:self.weatherModel];
        });
        return;
    }
    if (isInit) {
        [self viewInitAnimate];
    }else
    {
        [self ViewTapAnimate];
    }
    self.isAnimating = YES;
}

- (void)viewInitAnimate
{
    if (_noWeather) {
        [_noWeather removeFromSuperview];
        _noWeather = nil;
    }
    _noWeather = [G100NoWeatherView showView];
    [self insertSubview:self.noWeather belowSubview:self.clickedAniView];
    [self.noWeather mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    // 初始化图片数组
    NSMutableArray *imagesArray = [NSMutableArray array];
    for (int count = 0; count <= 21; count++) {
        NSString *imageName = [NSString stringWithFormat:@"ic_animaion%d", count];
        UIImage  *image     = [UIImage imageNamed:imageName];
        [imagesArray addObject:image];
    }
    // 设置动画
    self.noWeather.aniImageView.animationImages      = imagesArray;
    self.noWeather.aniImageView.animationDuration    = 0.44;
    self.noWeather.aniImageView.animationRepeatCount = 1;
    
    // 开始动画
    [self.noWeather.aniImageView startAnimating];
    
    [self performSelector:@selector(updataWeather) withObject:nil afterDelay:0.44];
}

- (void)updataWeather
{
    
    if (self.noWeather.aniImageView.isAnimating) {
        [self.noWeather.aniImageView stopAnimating];
    }
    self.num = 0;
    self.bgImageView.alpha = 0.0;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(tempChanged:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    [self setBackgroundWithTemperature:[self.weatherModel.temperature integerValue]];
    [UIView animateWithDuration:0.6 animations:^{
        self.noWeather.aniImageView.alpha = 0;
        self.noWeather.topLabel.alpha = 0;
        self.noWeather.bottomLabel.alpha = 0;
        self.noWeather.alpha = 0;
        
        self.weathLabel.alpha = 0;
        self.weathImageView.alpha = 0;
        self.timeRefLabel.alpha = 0;
        self.locationLabel.alpha = 0;
        self.UnitImageView.alpha = 0;
        self.bgImageView.alpha = 0.6;
        
        //[self setBackgroundWithTemperature:32];
        
    } completion:^(BOOL finished) {
        
        [self.noWeather removeFromSuperview];
        [UIView animateWithDuration:0.4 animations:^{
            self.weathLabel.alpha = 1;
            self.weathImageView.alpha = 1;
            self.timeRefLabel.alpha = 1;
            self.locationLabel.alpha = 1;
            self.UnitImageView.alpha = 1;
            self.bgImageView.alpha = 1;
            if (self.weatherModel) {
                [self setImageViewByWeather:self.weatherModel.weather];
                self.weathLabel.text = self.weatherModel.weather;
                self.timeRefLabel.text = [NSString stringWithFormat:@"%@发布", [NSDate getWeatherReportTimeWithDate:_weatherModel.reportTime]];
                self.locationLabel.text = self.weatherModel.locAddress;
            }
            
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
        }
     ];
    }];
}

- (void)tempChanged:(NSTimer *)timer
{
    if (self.num > 25) {
        //NSInteger rand = arc4random()%30;
        if (self.weatherModel == nil) {
            [self addErrorViewWithErrorInfo:self.errorInfo];
        }else
        {
            [self setTempImageWithTemp:[self.weatherModel.temperature integerValue]];
        }
        self.isAnimating = NO;
        self.errorInfo = nil;
        [self.timer invalidate];
        self.timer =nil;
        self.num = 0;
        return;
    }
    NSInteger rand = arc4random()%60;
    [self setTempImageWithTemp:rand];
    self.num++;
}

-(void)ViewTapAnimate
{
    if (_ErrorView) {
        [self.ErrorView removeFromSuperview];
        self.ErrorView = nil;
    }
    if (_noWeather) {
        [_noWeather removeFromSuperview];
        _noWeather = nil;
    }
    self.num = 0;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(tempChanged:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    
    [UIView animateWithDuration:0.4 animations:^{
       
        self.weathLabel.alpha = 0;
        self.weathImageView.alpha = 0;
        self.timeRefLabel.alpha = 0;
        self.locationLabel.alpha = 0;
        
        self.minImageView.alpha = 0.2;
        self.tenImageView.alpha = 0.2;
        self.perImageView.alpha = 0.2;
        self.UnitImageView.alpha = 0;

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.6 animations:^{
            self.weathLabel.alpha = 1;
            self.weathImageView.alpha = 1;
            self.timeRefLabel.alpha = 1;
            self.locationLabel.alpha = 1;
            
            self.minImageView.alpha = 1;
            self.tenImageView.alpha = 1;
            self.perImageView.alpha = 1;
            self.UnitImageView.alpha = 1;
            //[self updateData];
            if (_weatherModel) {
                [self setImageViewByWeather:self.weatherModel.weather];
                self.weathLabel.text = self.weatherModel.weather;
                self.timeRefLabel.text = [NSString stringWithFormat:@"%@发布", [NSDate getWeatherReportTimeWithDate:_weatherModel.reportTime]];
                self.locationLabel.text = self.weatherModel.locAddress;
            }
           
        } completion:^(BOOL finished) {
        
            if (self.weatherModel) {
                [self setBackgroundWithTemperature:[self.weatherModel.temperature integerValue]];
            }

        }];
    }];

}

- (void)addErrorViewWithErrorInfo:(NSString *)errorInfo
{
    if (_ErrorView) {
        [self.ErrorView removeFromSuperview];
        self.ErrorView = nil;

    }
    _ErrorView = [G100WeatherInitErrorView showView];
    [self insertSubview:self.ErrorView belowSubview:self.clickedAniView];
    [self.ErrorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    if (errorInfo) {
        _ErrorView.noWeatherInfo.text = errorInfo;
    }else
    {
        _ErrorView.noWeatherInfo.text = @"无法获取位置";
    }
}
@end
