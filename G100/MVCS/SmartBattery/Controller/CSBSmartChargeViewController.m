//
//  G100BattAnimateViewController.m
//  Demobase
//
//  Created by sunjingjing on 16/12/13.
//  Copyright © 2016年 sunjingjing. All rights reserved.
//

#import "CSBSmartChargeViewController.h"
#import "G100BatteryAnimateView.h"
#import "NSDate+TimeString.h"
#import "UILabeL+AjustFont.h"
#import "YJFavorEmitter.h"
#import <POP.h>
@interface CSBSmartChargeViewController ()
@property (weak, nonatomic) IBOutlet UIView *animateBattView;
@property (weak, nonatomic) IBOutlet UIImageView *battBgImageView;

@property (weak, nonatomic) IBOutlet UIImageView *battHunImage;
@property (weak, nonatomic) IBOutlet UIImageView *battTenImage;
@property (weak, nonatomic) IBOutlet UIImageView *battPerImage;
@property (weak, nonatomic) IBOutlet UIImageView *battUnitImage;

@property (weak, nonatomic) IBOutlet UIImageView *mileHunImage;
@property (weak, nonatomic) IBOutlet UIImageView *mileTenImage;
@property (weak, nonatomic) IBOutlet UIImageView *mileDotImage;
@property (weak, nonatomic) IBOutlet UIImageView *milePerImage;
@property (weak, nonatomic) IBOutlet UIImageView *mileUnitImage;

@property (weak, nonatomic) IBOutlet UIView *battingView;
@property (weak, nonatomic) IBOutlet UIImageView *battingImage;
@property (weak, nonatomic) IBOutlet UILabel *battingLabel;
@property (weak, nonatomic) IBOutlet UILabel *battCompleteTime;

@property (weak, nonatomic) IBOutlet UILabel *battWeaLabel;
@property (weak, nonatomic) IBOutlet UILabel *battTempLable;
@property (weak, nonatomic) IBOutlet UILabel *battUseTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *lowEleDesView;
@property (weak, nonatomic) IBOutlet UIView *battingDesView;

@property (weak, nonatomic) IBOutlet UIImageView *firstChargeImage;
@property (weak, nonatomic) IBOutlet UIImageView *firstLineImage;
@property (weak, nonatomic) IBOutlet UILabel *firstChargeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *sencondChargeImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondLineImage;
@property (weak, nonatomic) IBOutlet UILabel *secondChargeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thirdChargeImage;
@property (weak, nonatomic) IBOutlet UILabel *thirdChargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeDesLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastChargeDate;
@property (weak, nonatomic) IBOutlet UILabel *lastChargeUseTime;
@property (weak, nonatomic) IBOutlet UILabel *lastChargeEle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chargingImageNoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chargingImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileDotNoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileDotWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battHunNoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battHunWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battTenNoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battTenWidthConstraint;
@property (strong, nonatomic) G100BatteryAnimateView *battAnimateView;
@property (strong, nonatomic) NSTimer *autoPaoTimer;
@property (nonatomic, strong) YJFavorEmitter *emitter;
@property (nonatomic, strong) POPBasicAnimation  *countAnimation;
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, assign) NSInteger varCount;
@property (strong, nonatomic)  UIView *paoView;
@end

@implementation CSBSmartChargeViewController

#pragma mark - Setter
- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain {
    [self setBatteryDomain:batteryDomain animated:NO];
}

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated {
    _batteryDomain = batteryDomain;
    [self updateUIWithAnimated:animated];
}

- (void)becameActived {
    if (!self.batteryDomain) {
        return;
    }
    
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _battAnimateView = [[G100BatteryAnimateView alloc] initWithFrame:CGRectZero];
    _battAnimateView.percent = 0.65;
    [self.animateBattView addSubview:_battAnimateView];
    [_battAnimateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.battUnitImage.image = [[UIImage imageNamed:@"ic_batt_%"] imageWithTintColor:[UIColor whiteColor]];
    self.mileUnitImage.image = [[UIImage imageNamed:@"ic_batt_km"] imageWithTintColor:[UIColor whiteColor]];
    _battUseTimeLabel.font = [_battUseTimeLabel adjustFont:_battUseTimeLabel.font multiple:0.5];
    
    _paoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    _paoView.backgroundColor = [UIColor clearColor];
    [self.battAnimateView addSubview:_paoView];
    [_paoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.battAnimateView.mas_bottom).offset(0);
        make.centerX.mas_equalTo(self.battAnimateView).offset(-16);
    }];
    self.counter = 0;
    _emitter = [YJFavorEmitter emitterWithFrame:CGRectMake(0, 0, 32, 32)
                               favorDisplayView:self.battAnimateView
                                          image:nil
                                 highlightImage:nil];
    _emitter.interactEnabled = NO;
    _emitter.extraShift = 20;
    _emitter.minRisingVelocity = 50;
    _emitter.originRange = 1;
    _emitter.risingDuration = 5.0;
    [_paoView addSubview:_emitter];
}

- (void)startAnimationBefore{
    //_emitter.scale = (2 + (arc4random() % 14))/10;
    [self startAnimation];
}

- (void)setCounter:(NSInteger)counter
{
    if (_counter == counter) {
        return;
    }
    
    _counter = counter;
    [_emitter generateEmitterCellsForCellsCount:1];
}
- (void)startAnimation
{
    [self pop_addAnimation:self.countAnimation forKey:nil];
}

- (void)stopAnimation
{
    [self pop_removeAllAnimations];
}
- (POPBasicAnimation *)countAnimation
{
    if (!_countAnimation) {
        _countAnimation = [POPBasicAnimation animation];
        _countAnimation.fromValue = @(0);
        _countAnimation.toValue   = @(2);
        _countAnimation.duration  = 0.5;
        _countAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        __weak typeof(self) weakSelf = self;
        _countAnimation.property = [POPMutableAnimatableProperty propertyWithName:@"varCount" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                weakSelf.counter = (int)values[0];
            };
        }];
        
        _countAnimation.animationDidReachToValueBlock = ^ (POPAnimation *anim) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf.battAnimateView.isCharging) {
                    [weakSelf startAnimationBefore];
                }else{
                    [weakSelf stopAnimation];
                }
            });
        };

    }
    return _countAnimation;
}

- (void)updateUIWithAnimated:(BOOL)animated{
    if ([self.battAnimateView superview]) {
        //self.batteryDomain.current_elec = 18;
        switch (self.batteryDomain.status) {
            case 0:
                self.chargingImageWidthConstraint.priority = 700;
                self.chargingImageNoWidthConstraint.priority= 999;
                self.battingLabel.text = @"未使用";
                self.battAnimateView.isCharging = NO;
                break;
            case -1:
                self.chargingImageWidthConstraint.priority = 700;
                self.chargingImageNoWidthConstraint.priority= 999;
                self.battingLabel.text = @"充电结束";
                self.battAnimateView.isCharging = NO;
                break;
            case 1:
                self.chargingImageNoWidthConstraint.priority = 700;
                self.chargingImageWidthConstraint.priority= 999;
                self.battingLabel.text = @"充电中";
                self.battAnimateView.isCharging = YES;
                [self startAnimationBefore];
                break;
            default:
                break;
        }
        if (animated) {
            [self.battAnimateView setPercent:self.batteryDomain.current_elec/100];
            if (self.batteryDomain.current_elec < 20) {
                [self.battAnimateView setFrontWaterColor:[UIColor colorWithHexString:@"AF0000"]];
                [self.battAnimateView setBackWaterColor:[UIColor colorWithHexString:@"EE1515"]];
                self.battBgImageView.image = [UIImage imageNamed:@"ic_batt_lowEle"];
               
            }else{
                [self.battAnimateView setFrontWaterColor:[UIColor colorWithRed:0.0/255.0 green:204.0/255 blue:193.0/255 alpha:1.0]];
                self.battBgImageView.image = [UIImage imageNamed:@"ic_batt_eleBg"];
               
            }
            if (self.battAnimateView.percent < 0.2) {
                _emitter.cellImages = @[[UIImage imageNamed:@"ic_batt_lowpao"], [UIImage imageNamed:@"ic_batt_slowpao"], [UIImage imageNamed:@"ic_batt_mlowpao"]];
                _emitter.risingY = 10;
            }else{
                _emitter.cellImages = @[[UIImage imageNamed:@"ic_Batt_pao"], [UIImage imageNamed:@"ic_batt_spao"], [UIImage imageNamed:@"ic_batt_mpao"]];
                _emitter.risingY = 100;
            }
        }
        if (self.battAnimateView.isCharging == NO) {
            self.lastChargeDate.text = [NSString stringWithFormat:@"上一次充电时间：%@",self.batteryDomain.last_use.last_charging];
            NSInteger lastUsetime = self.batteryDomain.last_use.charging_duration;
            
            NSInteger useH = lastUsetime/60;
            NSInteger useM = lastUsetime%60;
            
            NSMutableString *reslut = [NSMutableString stringWithString:@"上一次充电用时："];
            
            if (useH) {
                [reslut appendString:[NSString stringWithFormat:@"%@小时", @(useH)]];
            }
            
            if (useM) {
                [reslut appendString:[NSString stringWithFormat:@"%@分钟", @(useM)]];
            }
            
            self.lastChargeUseTime.text = reslut;
            self.lastChargeEle.text = [NSString stringWithFormat:@"上一次充电电量：%ld%%",self.batteryDomain.last_use.charging_elec];
            self.lowEleDesView.hidden = NO;
            self.battingDesView.hidden = YES;
        }else{
            self.lowEleDesView.hidden = YES;
            self.battingDesView.hidden = NO;
        }
    }
     self.battUseTimeLabel.text = [NSString stringWithFormat:@"您的电池已经使用了%@",[NSDate getDateIntervalWithDays:self.batteryDomain.use_duration]];
    self.battTempLable.text = [NSString stringWithFormat:@"%d°",(int)self.batteryDomain.temperature];
    self.battTempLable.textColor = self.batteryDomain.temperature > 60 ? [UIColor redColor] : [UIColor colorWithHexString:@"00B5B3"];
    if (self.batteryDomain.temperature < 0 || self.batteryDomain.temperature > 60) {
        self.battTempLable.textColor = [UIColor redColor];
    }
    self.battCompleteTime.text = self.batteryDomain.use_advice;
    self.firstChargeImage.image = self.batteryDomain.charging_status == 1 ? [UIImage imageNamed:@"ic_batt_end"] : [UIImage imageNamed:@"ic_batt_no_end"];
    self.firstLineImage.image = self.batteryDomain.charging_status == 1 ? [UIImage imageNamed:@"ic_batt_lineT"] : [UIImage imageNamed:@"ic_batt_lineV"];
    self.firstChargeLabel.textColor = self.batteryDomain.charging_status == 1 ? [UIColor colorWithHexString:@"00B5B3"] :[UIColor colorWithHexString:@"959595"];
    self.sencondChargeImage.image = self.batteryDomain.charging_status == 2 ? [UIImage imageNamed:@"ic_batt_end"] : [UIImage imageNamed:@"ic_batt_no_end"];
    self.secondLineImage.image = self.batteryDomain.charging_status == 2 ? [UIImage imageNamed:@"ic_batt_lineT"] : [UIImage imageNamed:@"ic_batt_lineV"];
    self.secondChargeLabel.textColor = self.batteryDomain.charging_status == 2 ? [UIColor colorWithHexString:@"00B5B3"] :[UIColor colorWithHexString:@"959595"];
    self.thirdChargeImage.image = self.batteryDomain.charging_status == 3 ? [UIImage imageNamed:@"ic_batt_end"] : [UIImage imageNamed:@"ic_batt_no_end"];
    self.thirdChargeLabel.textColor = self.batteryDomain.charging_status == 3 ? [UIColor colorWithHexString:@"00B5B3"] :[UIColor colorWithHexString:@"959595"];
    self.chargeDesLabel.text = self.batteryDomain.charging_status == 1 ? @"当前电池电量低于20%，为了避免低电量下充电损耗电池，启用智能涓流充电" : (self.batteryDomain.charging_status == 2 ? @"以最大电流快速的将电池冲到80%，但仍需要进行智能恒压充电才能完全充满电" : @"进行小电流充电，均衡每个电池组的电量，延长电池使用寿命");
    [self updateGradeUI];
    [self updateMileUI];
}

- (void)updateGradeUI{
    int percent = self.batteryDomain.current_elec;
    if (percent <= 0)
    {
        self.battHunImage.hidden = YES;
        self.battTenImage.hidden = YES;
        self.battPerImage.hidden = NO;
        self.battHunWidthConstraint.priority = 700;
        self.battHunNoWidthConstraint.priority = 999;
        self.battTenWidthConstraint.priority = 700;
        self.battTenNoWidthConstraint.priority = 999;
        self.battPerImage.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor whiteColor]];
    }else if (percent<10 && percent >0) {
        self.battHunImage.hidden = YES;
        self.battTenImage.hidden = YES;
        self.battPerImage.hidden = NO;
        self.battHunWidthConstraint.priority = 700;
        self.battHunNoWidthConstraint.priority = 999;
        self.battTenWidthConstraint.priority = 700;
        self.battTenNoWidthConstraint.priority = 999;
        NSString *imageName = [NSString stringWithFormat:@"icon_elec%d",percent];
        self.battPerImage.image = [[UIImage imageNamed:imageName] imageWithTintColor:[UIColor whiteColor]];
    }else if(percent >99)
    {
        self.battHunImage.hidden = NO;
        self.battTenImage.hidden = NO;
        self.battPerImage.hidden = NO;
        self.battHunNoWidthConstraint.priority = 700;
        self.battHunWidthConstraint.priority = 999;
        self.battTenNoWidthConstraint.priority = 700;
        self.battTenWidthConstraint.priority = 999;
        self.battHunImage.image = [[UIImage imageNamed:@"icon_elec1"] imageWithTintColor:[UIColor whiteColor]];
        self.battTenImage.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor whiteColor]];
        self.battPerImage.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor whiteColor]];
    }else
    {
        self.battHunImage.hidden = YES;
        self.battTenImage.hidden = NO;
        self.battPerImage.hidden = NO;
        self.battHunWidthConstraint.priority = 700;
        self.battHunNoWidthConstraint.priority = 999;
        self.battTenNoWidthConstraint.priority = 700;
        self.battTenWidthConstraint.priority = 999;
        NSInteger ten = percent/10;
        NSInteger per = percent%10;
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",per];
        self.battTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.battPerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
    }
}

- (void)updateMileUI{
    NSInteger mile = self.batteryDomain.expe_distance;
    NSInteger mileN = (NSInteger)mile;
    CGFloat mileD = mile-mileN;
    NSInteger mileDN = mileD *10;
    if (mileN<10 && mileN >0) {
        
        self.mileHunImage.hidden = YES;
        self.mileTenImage.hidden = NO;
        self.milePerImage.hidden = NO;
        self.mileDotImage.hidden = NO;
        self.mileDotNoWidthConstraint.priority = 700;
        self.mileDotWidthConstraint.priority = 999;
        NSInteger dotNum;
        if (mileDN >=0 && mileDN < 5) {
            dotNum = 0;
        }else
        {
            dotNum = 5;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)mileN];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)dotNum];
        self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        
    }else if (mileN == 0)
    {
        if (mileDN ==0 ) {
            self.mileHunImage.hidden = YES;
            self.mileTenImage.hidden = YES;
            self.milePerImage.hidden = NO;
            self.mileDotImage.hidden = YES;
            self.mileDotWidthConstraint.priority = 700;
            self.mileDotNoWidthConstraint.priority = 999;
            NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec0"];
            self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        }else
        {
            self.mileHunImage.hidden = YES;
            self.mileTenImage.hidden = NO;
            self.milePerImage.hidden = NO;
            self.mileDotImage.hidden = NO;
            self.mileDotNoWidthConstraint.priority = 700;
            self.mileDotWidthConstraint.priority = 999;
            NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec0"];
            NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec5"];
            self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
            self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        }
        
    }else if(mileN >99)
        
    {
        NSInteger hun = (mileN/100) > 9 ? 9 : (mileN/100);
        NSInteger tenNum = mileN%100;
        NSInteger ten = (mileN/100) > 9 ? 9 : tenNum/10;
        NSInteger per = (mileN/100) > 9 ? 9 : tenNum%10;
        self.mileHunImage.hidden = NO;
        self.mileTenImage.hidden = NO;
        self.milePerImage.hidden = NO;
        self.mileDotImage.hidden = YES;
        self.mileDotWidthConstraint.priority = 700;
        self.mileDotNoWidthConstraint.priority = 999;
        NSString *imageNameHun = [NSString stringWithFormat:@"icon_elec%ld",hun];
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.mileHunImage.image = [[UIImage imageNamed:imageNameHun] imageWithTintColor:[UIColor whiteColor]];
        self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
    }else
    {
        NSInteger ten = mileN/10;
        NSInteger per = mileN%10;
        self.mileHunImage.hidden = YES;
        self.mileTenImage.hidden = NO;
        self.milePerImage.hidden = NO;
        self.mileDotImage.hidden = YES;
        self.mileDotWidthConstraint.priority = 700;
        self.mileDotNoWidthConstraint.priority = 999;
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",(long)per];
        self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
