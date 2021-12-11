//
//  G100WeatherCardView.m
//  G100
//
//  Created by sunjingjing on 2017/6/2.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100WeatherCardView.h"

@interface G100WeatherCardView ()

@property (weak, nonatomic) IBOutlet UILabel *todayWeatherLabel;
@property (weak, nonatomic) IBOutlet UIButton *todayWindButton;
@property (weak, nonatomic) IBOutlet UILabel *todayTemperLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayDesLabel;

@property (weak, nonatomic) IBOutlet UILabel *tomorrowWeatherLabel;
@property (weak, nonatomic) IBOutlet UIButton *tomorrowWindButton;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowTemperLabel;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLowLabel;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (strong, nonatomic) NSArray *weaModels;
@property (strong, nonatomic) NSArray *windArray;
@property (strong, nonatomic) G100WeatherManager *weaManager;

@end

@implementation G100WeatherCardView

//- (void)drawRect:(CGRect)rect {
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = rect;
//    gradient.colors = [NSArray arrayWithObjects:
//                       (id)[UIColor blackColor].CGColor,
//                       (id)[UIColor colorWithRed:69/255.0 green:69/255.0 blue:69/255.0 alpha:1.0].CGColor,nil];
//    [self.layer insertSublayer:gradient atIndex:0];
//}

+ (instancetype)showView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100WeatherCardView" owner:nil options:nil] firstObject];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.todayWindButton.layer.cornerRadius = 4.0;
    self.tomorrowWindButton.layer.cornerRadius = 4.0;
    self.windArray = @[@"1",@"2",@"3",@"4",@"5"];
    
    // 默认隐藏天气UI
    self.leftView.hidden = YES;
    self.rightView.hidden = YES;
    
    self.errorLowLabel.hidden = YES;
    self.errorDesLabel.text = @"查询中";
    self.errorLowLabel.numberOfLines = 0;
    
    self.backgroundColor = [UIColor clearColor];
}

- (G100WeatherManager *)weaManager {
    if (!_weaManager) {
        _weaManager = [G100WeatherManager sharedInstance];
    }
    return _weaManager;
}

- (void)loadForecastWeatherModeComplete:(G100ForecastWeatherRequestCallback)callback {
    [self.weaManager getForecastWeatherModeComplete:^(NSError *error, NSArray *forecasts) {
        if (error) {
            self.leftView.hidden = YES;
            self.rightView.hidden = YES;
            self.errorDesLabel.hidden = NO;
            if (error.code == AMapLocationErrorLocateFailed) {
                self.errorDesLabel.text = @"定位服务未开启，无法使用查看天气";
                self.errorLowLabel.hidden = NO;
            }else {
                self.errorDesLabel.text = @"天气信息更新失败，稍后再试";
                self.errorLowLabel.hidden = YES;
            }
        }else {
            self.leftView.hidden = NO;
            self.rightView.hidden = NO;
            self.errorLowLabel.hidden = YES;
            self.errorDesLabel.hidden = YES;
            self.weaModels = forecasts.copy;
            [self updateWeatherUI];
        }
        
        if (callback) {
            callback(error, forecasts);
        }
    }];
}

- (void)updateWeatherUI {
    G100WeatherModel *today = [self.weaModels safe_objectAtIndex:0];
    G100WeatherModel *tomorrow = [self.weaModels safe_objectAtIndex:1];
    
    self.todayWeatherLabel.text = today.weather;
    [self.todayWindButton setTitle:today.windPower forState:UIControlStateNormal];
    
    self.todayTemperLabel.text = today.temperature;
    
    if ([self isLowPowerExist:today.windPower]) {
        [self.todayWindButton setBackgroundColor:[UIColor colorWithHexString:@"1FA200"]];
    }else {
        [self.todayWindButton setBackgroundColor:[UIColor colorWithHexString:@"E45000"]];
    }
    
    self.tomorrowWeatherLabel.text = tomorrow.weather;
    [self.tomorrowWindButton setTitle:tomorrow.windPower forState:UIControlStateNormal];
    self.tomorrowTemperLabel.text = tomorrow.temperature;
    
    if ([self isLowPowerExist:tomorrow.windPower]) {
        [self.tomorrowWindButton setBackgroundColor:[UIColor colorWithHexString:@"1FA200"]];
    }else {
        [self.tomorrowWindButton setBackgroundColor:[UIColor colorWithHexString:@"E45000"]];
    }
    
    self.todayDesLabel.text = [self getTravelHint:today today:YES];
    self.tomorrowDesLabel.text = [self getTravelHint:tomorrow today:NO];
}

#pragma mark - Private Method
- (BOOL)isLowPowerExist:(NSString *)power {
    for (NSString *pow in self.windArray) {
        if ([power hasContainString:pow]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getTimeDesc:(NSString *)time {
    NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
    
    NSDate *date = [formatter dateFromString:time];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    
    NSInteger hour = [dateComponent hour];
    
    if (hour >= 7 && hour < 9) {
        return @"早上";
    } else if (hour >= 9 && hour < 11) {
        return @"上午";
    } else if (hour >= 11 && hour < 13) {
        return @"中午";
    } else if (hour >= 13 && hour < 17) {
        return @"下午";
    } else if (hour >= 17 && hour < 19) {
        return @"傍晚";
    }
    
    return @"晚上";
}

- (NSString *)getTravelHint:(G100WeatherModel *)weaModel today:(BOOL)isToday {
    NSString *result = [[weaModel.temperature componentsSeparatedByString:@"/"] safe_objectAtIndex:0];
    NSInteger tTem = result ? result.integerValue : 0;
    
    NSString *travelHint = @"";
    NSString *travelTime = @"";
    
    // 今天实时天气
    if (isToday) {
        //travelTime = [self getTimeDesc:weaModel.reportTime];
        travelTime = @"今天";
    } else {
        travelTime = @"明天";
    }
    
    BOOL needAddTime = YES;
    if ([weaModel.weather isEqualToString:@"晴"]) {
        if (tTem >= 25) {
            travelHint = @"出行注意防晒";
        }else if (tTem > 5 && tTem < 25){
            travelHint = @"出行注意安全";
        }else{
            travelHint = @"出行注意御寒";
        }
    }else if ([weaModel.weather isEqualToString:@"多云"]) {
        if (tTem >= 25) {
            travelHint = @"出行注意防晒";
        }else if (tTem > 5 && tTem < 25){
            travelHint = @"出行注意安全";
        }else{
            travelHint = @"出行注意御寒";
        }
        if ([self isLowPowerExist:weaModel.windPower]) {
            travelHint = @"出行注意安全";
            needAddTime = NO;
        }else{
            travelHint = @"不宜出行";
            needAddTime = NO;
        }
    }else if ([weaModel.weather isEqualToString:@"阴"]) {
        if (tTem >= 25) {
            travelHint = @"出行注意防晒";
            needAddTime = NO;
        }else if (tTem > 5 && tTem < 25){
            travelHint = @"出行注意安全";
            needAddTime = NO;
        }else{
            travelHint = @"出行注意御寒";
            needAddTime = NO;
        }
        if ([self isLowPowerExist:weaModel.windPower]) {
            travelHint = @"出行注意安全";
        }else{
            travelHint = @"不宜出行";
        }
    }else if ([weaModel.weather isEqualToString:@"阵雨"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"雷阵雨"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather hasContainString:@"冰雹"]) {
    }else if ([weaModel.weather isEqualToString:@"雨夹雪"]) {
    }else if ([weaModel.weather isEqualToString:@"小雨"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"中雨"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"大雨"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather hasContainString:@"暴雨"]) {
        travelHint = @"不宜出行";
    }else if ([weaModel.weather isEqualToString:@"小雨-中雨"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"中雨-大雨"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"阵雪"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"小雪"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"中雪"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"大雪"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather hasContainString:@"暴雪"]) {
        travelHint = @"不宜出行";
    }else if ([weaModel.weather hasContainString:@"雾"]) {
        travelHint = @"不宜出行";
    }else if ([weaModel.weather hasContainString:@"霾"]) {
        travelHint = @"不宜出行";
    }else if ([weaModel.weather isEqualToString:@"小雪-中雪"]) {
        travelHint = @"不宜出行";
    }else if ([weaModel.weather isEqualToString:@"中雪-大雪"]) {
        travelHint = @"出行带雨衣";
    }else if ([weaModel.weather isEqualToString:@"扬沙"] || [weaModel.weather isEqualToString:@"浮尘"]) {
        travelHint = @"不宜出行";
    }
    
    if (travelHint.length) {
        if (needAddTime) {
            return [NSString stringWithFormat:@"%@%@", travelTime, travelHint];
        } else {
            return travelHint;
        }
    } else {
        return @"";
    }
}

@end
