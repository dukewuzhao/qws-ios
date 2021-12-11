//
//  G100BattGPSView.m
//  G100
//
//  Created by sunjingjing on 16/12/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BattGPSView.h"
#import "YLProgressBar.h"
@interface G100BattGPSView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *poolImaeView;

@property (weak, nonatomic) IBOutlet UIImageView *battingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *battPerImage;
@property (weak, nonatomic) IBOutlet UIImageView *battTenImage;
@property (weak, nonatomic) IBOutlet UIImageView *battHunImage;
@property (weak, nonatomic) IBOutlet UIImageView *battDotImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battTenBigWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battTenSmallWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battPerBigWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *battPerSmallWidConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *mileHunImage;
@property (weak, nonatomic) IBOutlet UIImageView *mileTenImage;
@property (weak, nonatomic) IBOutlet UIImageView *milePerImage;
@property (weak, nonatomic) IBOutlet UIImageView *mileUnitImage;
@property (weak, nonatomic) IBOutlet UIImageView *mileDotImage;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileDotNoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileDotWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *mileLabel;
@property (weak, nonatomic) IBOutlet UIImageView *battRightImageView;

@property (weak, nonatomic) IBOutlet UIImageView *weaHunImage;
@property (weak, nonatomic) IBOutlet UIImageView *weaTenImage;
@property (weak, nonatomic) IBOutlet UIImageView *weaPerImage;
@property (weak, nonatomic) IBOutlet UIImageView *weaUnitImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weaHunWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weaTenWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weaPerWidConstraint;
@property (weak, nonatomic) IBOutlet UILabel *eleTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileHunBigWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileHunSmallWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileTenSmallWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mileTenBigWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *milePerBigWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *milePerSmallWidConstraint;

@property (weak, nonatomic) IBOutlet UILabel *eleDoorState;
@property (weak, nonatomic) IBOutlet UIImageView *eleDoorImage;
@property (weak, nonatomic) IBOutlet UIView *chargingTimeView;
@property (weak, nonatomic) IBOutlet UIImageView *fourImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;

@end
@implementation G100BattGPSView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BattGPSView" owner:nil options:nil] firstObject];
}

+ (CGFloat)heightWithWidth:(CGFloat)width{
    return 55*width/207;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.battDotImage.image = [[UIImage imageNamed:@"ic_batt_%"] imageWithTintColor:[UIColor blackColor]];
    self.battTenImage.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    self.battHunImage.image = [[UIImage imageNamed:@"ic_num_1"] imageWithTintColor:[UIColor blackColor]];
    self.battPerImage.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    
    self.mileTenImage.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    self.milePerImage.image = [[UIImage imageNamed:@"ic_num_5"] imageWithTintColor:[UIColor blackColor]];
    self.mileDotImage.image = [[UIImage imageNamed:@"ic_batt_dot"] imageWithTintColor:[UIColor blackColor]];
    self.eleDoorImage.image = [[UIImage imageNamed:@"ic_batt_off"] imageWithTintColor:[UIColor whiteColor]];
    self.chargingTimeView.hidden = YES;
    [self initProgressBar];
}


-(void)setBatteryDomain:(G100BatteryDomain *)batteryDomain{
    _batteryDomain = batteryDomain;
    [self updateBattDataUI];
}

- (void)initProgressBar
{
    NSArray *tintColors = @[[UIColor colorWithHexString:@"23BED5"],
                            [UIColor colorWithHexString:@"2Df2BF"]];
    
    _progressBarView.progressTintColors       = tintColors;
    _progressBarView.stripesOrientation       = YLProgressBarStripesOrientationLeft;
    _progressBarView.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    _progressBarView.progressStretch          = YES;
}
- (void)updateBattDataUI{
    self.detailLabel.text = self.batteryDomain.use_advice;
    [self.progressBarView setProgress:self.batteryDomain.current_elec/100];
    if (self.batteryDomain.current_elec < 20) {
        NSArray *tintColors = @[[UIColor colorWithHexString:@"FC9C2B"],
                                [UIColor colorWithHexString:@"FC2E33"]];
        _progressBarView.progressTintColors = tintColors;
    }else{
        NSArray *tintColors = @[[UIColor colorWithHexString:@"23BED5"],
                                [UIColor colorWithHexString:@"2Df2BF"]];
        _progressBarView.progressTintColors = tintColors;
    }
    if (self.batteryDomain.status == 1) {
        self.battingImageView.hidden = NO;
        if (self.batteryDomain.current_elec < 15) {
            [self.progressBarView setProgress:0.15];
        }
        [self updateTimeUI];
    }else{
        self.battingImageView.hidden = YES;
        self.chargingTimeView.hidden = YES;
        self.eleDoorImage.hidden = NO;
        self.eleDoorState.hidden = NO;
        self.eleTitle.text = @"电门状态";
    }
    if (self.batteryDomain.current_elec >= 50) {
        self.battRightImageView.image = [UIImage imageNamed:@"icon_batt_normal"];
    }else if (self.batteryDomain.current_elec >30 && self.batteryDomain.current_elec < 50){
        self.battRightImageView.image = [UIImage imageNamed:@"icon_batt_middle"];
    }else{
        self.battRightImageView.image = [UIImage imageNamed:@"icon_batt_important"];
    }
    [self updateGradeUI];
    [self updateMileUI];
    [self setTempImageWithTemp:(NSInteger)self.batteryDomain.temperature];
}

- (void)updateTimeUI{
    if (self.batteryDomain.remain_charging_time >0) {
        self.chargingTimeView.hidden = NO;
        self.eleDoorImage.hidden = YES;
        self.eleDoorState.hidden = YES;
        self.eleTitle.text = @"剩余充电时间";
        [self updataTimeWithTime:self.batteryDomain.remain_charging_time];
    }
}

- (void)updataTimeWithTime:(NSInteger)time{
    NSInteger hour = time/60;
    NSInteger TenHour = hour/10;
    NSInteger perHour = hour%10;
    NSInteger minutes = time%60;
    NSInteger tenMinute = minutes/10;
    NSInteger perMinute = minutes%10;
    self.firstImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_num_%ld",(long)TenHour]];
    self.secondImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_num_%ld",(long)perHour]];
    self.thirdImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_num_%ld",(long)tenMinute]];
    self.fourImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_num_%ld",(long)perMinute]];
}
- (void)updateEleDoorState:(NSInteger)state{
    if (self.batteryDomain.status == 1) {
        [self updateTimeUI];
    }else{
        self.chargingTimeView.hidden = YES;
        self.eleDoorImage.hidden = NO;
        self.eleDoorState.hidden = NO;
        self.eleTitle.text = @"电门状态";
    }
    if (state) {
        self.eleDoorImage.image = [[UIImage imageNamed:@"ic_batt_on"] imageWithTintColor:[UIColor whiteColor]];
        self.eleDoorState.text = @"已打开";
    }else
    {
        self.eleDoorImage.image = [[UIImage imageNamed:@"ic_batt_off"] imageWithTintColor:[UIColor whiteColor]];
        self.eleDoorState.text = @"已关闭";
    }
}
- (void)updateGradeUI{
    int percent = self.batteryDomain.current_elec;
    if (percent <= 0)
    {
        self.battHunImage.hidden = YES;
        self.battTenImage.hidden = YES;
        self.battPerImage.hidden = NO;
        self.battPerSmallWidConstraint.priority = 700;
        self.battPerBigWidConstraint.priority = 999;
        self.battPerImage.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    }else if (percent<10 && percent >0) {
        self.battHunImage.hidden = YES;
        self.battTenImage.hidden = YES;
        self.battPerImage.hidden = NO;
        if (percent == 1) {
            self.battPerBigWidConstraint.priority = 700;
            self.battPerSmallWidConstraint.priority = 999;
        }else
        {
            self.battPerSmallWidConstraint.priority = 700;
            self.battPerBigWidConstraint.priority = 999;
        }
        NSString *imageName = [NSString stringWithFormat:@"ic_num_%d",percent];
        self.battPerImage.image = [[UIImage imageNamed:imageName] imageWithTintColor:[UIColor blackColor]];
    }else if(percent >99)
    {
        self.battHunImage.hidden = NO;
        self.battTenImage.hidden = NO;
        self.battPerImage.hidden = NO;
        self.battPerSmallWidConstraint.priority = 700;
        self.battPerBigWidConstraint.priority = 999;
        self.battTenSmallWidConstraint.priority = 700;
        self.battTenBigWidConstraint.priority = 999;
        self.battHunImage.image = [[UIImage imageNamed:@"ic_num_1"] imageWithTintColor:[UIColor blackColor]];
        self.battTenImage.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
        self.battPerImage.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    }else
    {
        self.battHunImage.hidden = YES;
        self.battTenImage.hidden = NO;
        self.battPerImage.hidden = NO;
        NSInteger ten = percent/10;
        NSInteger per = percent%10;
        if (ten == 1) {
            self.battTenBigWidConstraint.priority = 700;
            self.battTenSmallWidConstraint.priority = 999;
        }else
        {
            self.battTenSmallWidConstraint.priority = 700;
            self.battTenBigWidConstraint.priority = 999;
        }
        if (per == 1) {
            self.battPerBigWidConstraint.priority = 700;
            self.battPerSmallWidConstraint.priority = 999;
        }else
        {
            self.battPerSmallWidConstraint.priority = 700;
            self.battPerBigWidConstraint.priority = 999;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_%ld",ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",per];
        self.battTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.battPerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
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
        self.milePerSmallWidConstraint.priority = 700;
        self.milePerBigWidConstraint.priority = 999;
        NSInteger dotNum;
        if (mileDN >=0 && mileDN < 5) {
            dotNum = 0;
        }else
        {
            dotNum = 5;
        }
        if (mileN == 1) {
            self.mileTenBigWidConstraint.priority = 700;
            self.mileTenSmallWidConstraint.priority = 999;
        }else
        {
            self.mileTenSmallWidConstraint.priority = 700;
            self.mileTenBigWidConstraint.priority = 999;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_%ld",(long)mileN];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",(long)dotNum];
        self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
        
    }else if (mileN == 0)
    {
        self.milePerSmallWidConstraint.priority = 700;
        self.milePerBigWidConstraint.priority = 999;
        self.mileTenSmallWidConstraint.priority = 700;
        self.mileTenBigWidConstraint.priority = 999;
        if (mileDN ==0 ) {
            self.mileHunImage.hidden = YES;
            self.mileTenImage.hidden = YES;
            self.milePerImage.hidden = NO;
            self.mileDotImage.hidden = YES;
            self.mileDotWidthConstraint.priority = 700;
            self.mileDotNoWidthConstraint.priority = 999;
            NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_0"];
            self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
        }else
        {
            self.mileHunImage.hidden = YES;
            self.mileTenImage.hidden = NO;
            self.milePerImage.hidden = NO;
            self.mileDotImage.hidden = NO;
            self.mileDotNoWidthConstraint.priority = 700;
            self.mileDotWidthConstraint.priority = 999;
            NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_0"];
            NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_5"];
            self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
            self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
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
        if (hun == 1) {
            self.mileHunBigWidConstraint.priority = 700;
            self.mileHunSmallWidConstraint.priority = 999;
        }else
        {
            self.mileHunSmallWidConstraint.priority = 700;
            self.mileHunBigWidConstraint.priority = 999;
        }
        if (ten == 1) {
            self.mileTenBigWidConstraint.priority = 700;
            self.mileTenSmallWidConstraint.priority = 999;
        }else
        {
            self.mileTenSmallWidConstraint.priority = 700;
            self.mileTenBigWidConstraint.priority = 999;
        }
        if (per == 1) {
            self.milePerBigWidConstraint.priority = 700;
            self.milePerSmallWidConstraint.priority = 999;
        }else
        {
            self.milePerSmallWidConstraint.priority = 700;
            self.milePerBigWidConstraint.priority = 999;
        }
        NSString *imageNameHun = [NSString stringWithFormat:@"ic_num_%ld",hun];
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",(long)per];
        self.mileHunImage.image = [[UIImage imageNamed:imageNameHun] imageWithTintColor:[UIColor blackColor]];
        self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
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
        if (ten == 1) {
            self.mileTenBigWidConstraint.priority = 700;
            self.mileTenSmallWidConstraint.priority = 999;
        }else
        {
            self.mileTenSmallWidConstraint.priority = 700;
            self.mileTenBigWidConstraint.priority = 999;
        }
        if (per == 1) {
            self.milePerBigWidConstraint.priority = 700;
            self.milePerSmallWidConstraint.priority = 999;
        }else
        {
            self.milePerSmallWidConstraint.priority = 700;
            self.milePerBigWidConstraint.priority = 999;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",(long)per];
        self.mileTenImage.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.milePerImage.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
    }
}

-(void)setTempImageWithTemp:(NSInteger)temp
{
    
    NSInteger tenNum = labs(temp)/10;
    NSInteger perNum =labs(temp)%10;
    
    NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_%ld",(long)tenNum];
    NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",(long)perNum];
    if (temp <0) {
        
        self.weaHunWidConstraint.constant = 10;
        self.weaHunImage.image = [UIImage imageNamed:@"ic_bike_-"];
        
    }else
    {
        self.weaHunWidConstraint.constant = 0;
    }
    
    if (tenNum==0) {
        self.weaTenWidConstraint.constant = 0;
    }else
    {
        if (tenNum == 1) {
            self.weaTenWidConstraint.constant = 6.25;
        }else
        {
            self.weaTenWidConstraint.constant = 12.5;
        }
        self.weaTenImage.image = [UIImage imageNamed:imageNameTen];
    }
    
    if (perNum == 1) {
        
        self.weaPerWidConstraint.constant = 6.25;
    }else
    {
        self.weaPerWidConstraint.constant = 12.5;
        
    }
    self.weaPerImage.image = [UIImage imageNamed:imageNamePer];
    self.weaUnitImage.image = [UIImage imageNamed:@"ic_bike_du"];
}
- (IBAction)viewTaped:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushBattGPSDetailWithView:)]) {
        [self.delegate viewTapToPushBattGPSDetailWithView:self];
    }
}
@end
