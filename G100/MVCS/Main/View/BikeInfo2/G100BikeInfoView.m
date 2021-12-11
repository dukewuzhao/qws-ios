//
//  G100BikeInfoView.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeInfoView.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Tint.h"
#import "NSDate+TimeString.h"

#define IMAGE_MAX_SIZE_WIDTH 160
#define IMAGE_MAX_SIZE_GEIGHT 40

@interface G100BikeInfoView ()

@property (weak, nonatomic) IBOutlet UIImageView *bikelogo;
@property (weak, nonatomic) IBOutlet UIImageView *bikeImageView;
@property (weak, nonatomic) IBOutlet UIView *weaTapView;

@property (weak, nonatomic) IBOutlet UILabel *weaLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weaHunImageView;
@property (weak, nonatomic) IBOutlet UIImageView *weaTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *weaPerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *weaDuImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weaTenWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weaHunWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weaPerWidConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *safeImageView;
@property (weak, nonatomic) IBOutlet UILabel *safeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *safeWidthConstraint;

/**电量显示*/
@property (weak, nonatomic) IBOutlet UIImageView *battImageView;
/**未检测到电量*/
@property (weak, nonatomic) IBOutlet UIButton *noBattButton;

@property (weak, nonatomic) IBOutlet UIImageView *mileUnitImage;
@property (weak, nonatomic) IBOutlet UIImageView *milePerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mileDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mileTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mileHunImageView;
@property (weak, nonatomic) IBOutlet UILabel *eleDoorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eleDoorImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveDotSmallConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveDotBigConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noMilePerImageeView;
@property (weak, nonatomic) IBOutlet UIImageView *noMileTenImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hunTrailConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSmallWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBigWidConstraint;
@property (weak, nonatomic) IBOutlet UIView *battBgView;
@property (weak, nonatomic) IBOutlet UILabel *bottomTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *volUnitLabel;

@end

@implementation G100BikeInfoView

+ (instancetype)loadBikeInfoView{
    //bugfix: http://mobile.umeng.com/apps/0c000016dae85e766359f355/error_types/show?error_type_id=553f953667e58ead610000c0_748787296476671050_2.2.18
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BikeInfoView" owner:nil options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.safeLabel.hidden = YES;
    self.safeImageView.hidden = YES;
    CGFloat imgWidth = self.noBattButton.imageView.bounds.size.width;
    CGFloat labWidth = self.noBattButton.titleLabel.bounds.size.width;
    [self.noBattButton setImageEdgeInsets:UIEdgeInsetsMake(0, labWidth, 0, -labWidth)];
    [self.noBattButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgWidth, 0, imgWidth)];
    [self setupDefaultUI];
    self.noMileTenImageView.hidden = YES;
    self.noMilePerImageeView.hidden = YES;
}

+ (float)heightWithWidth:(float)width{
    return 80*width/207;
}

- (void)setupDefaultUI{
    self.mileUnitImage.image = [[UIImage imageNamed:@"ic_batt_km"] imageWithTintColor:[UIColor whiteColor]];
    self.mileHunImageView.image = [[UIImage imageNamed:@"icon_elec9"] imageWithTintColor:[UIColor whiteColor]];
    self.mileTenImageView.image = [[UIImage imageNamed:@"icon_elec9"] imageWithTintColor:[UIColor whiteColor]];
    self.milePerImageView.image = [[UIImage imageNamed:@"icon_elec9"] imageWithTintColor:[UIColor whiteColor]];
}
-(void)setBikeModel:(G100BikeModel *)bikeModel{
    if (![[bikeModel.car_logo substringToIndex:4] isEqualToString:@"http"]) {
        bikeModel.car_logo = [NSString stringWithFormat:@"https://%@",bikeModel.car_logo];
    }
    _bikeModel = bikeModel;
    [self updateBikeUI];
}

- (void)setWeatherModel:(G100WeatherModel *)weatherModel{
    _weatherModel = weatherModel;
    [self updateWeatherUI];
}

- (void)updateBikeUI
{
    if (!_bikeModel) {
        return;
    }
    if (_bikeModel.car_logo) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_bikeModel.car_logo] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.logoWidthConstraint.constant = [self fitsize:image.size].width;
                    self.bikelogo.image = image;
                }else {
                    self.bikelogo.image = [UIImage imageNamed:@"g100_main_left_logo"];
                }
            });
        }];
    }else
    {
        self.bikelogo.image = [UIImage imageNamed:@"g100_main_left_logo"];
    }
    if (_bikeModel.pic_small) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_bikeModel.pic_small] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.bikeImageView.image = image;
                }else {
                    if (_bikeModel.bike_type == 1) {
                        self.bikeImageView.image = [UIImage imageNamed:@"icon_motor"];
                    }else{
                        if (_bikeModel.isSmartDevice) {
                            self.bikeImageView.image = [UIImage imageNamed:@"ic_batt_smart"];
                        }else{
                            self.bikeImageView.image = [UIImage imageNamed:@"ic_bike_defaultnew"];
                        }
                    }
                }
            });
        }];
        
    }else
    {
        if (_bikeModel.bike_type == 1) {
            self.bikeImageView.image = [UIImage imageNamed:@"icon_motor"];
        }else{
            if (_bikeModel.isSmartDevice) {
                self.bikeImageView.image = [UIImage imageNamed:@"ic_batt_smart"];
            }else{
                self.bikeImageView.image = [UIImage imageNamed:@"ic_bike_defaultnew"];
            }
        }
    }
    [self updateBattDataDefaultUI];
}

- (void)updateBattDataDefaultUI {
    if (IsLogin() && !self.bikeModel.hasDevice) {
        self.rightBattView.hidden = YES;
        self.eleDoorLabel.hidden = YES;
        self.eleDoorImageView.hidden = YES;
        self.rightBigWidConstraint.priority = 700;
        self.rightSmallWidConstraint.priority = 999;
    }else if (!IsLogin()){
        self.rightBattView.hidden = NO;
        self.eleDoorLabel.hidden = NO;
        self.eleDoorImageView.hidden = NO;
        self.rightSmallWidConstraint.priority = 700;
        self.rightBigWidConstraint.priority = 999;
    }else{
        self.rightBattView.hidden = NO;
        self.eleDoorLabel.hidden = NO;
        self.eleDoorImageView.hidden = NO;
        self.rightSmallWidConstraint.priority = 700;
        self.rightBigWidConstraint.priority = 999;
    }
    if (_bikeModel.bike_type == 1 || _bikeModel.isChinaMobileCustom) {
        self.rightBattView.hidden = YES;
        self.safeLabel.hidden = YES;
        self.safeImageView.hidden = YES;
        self.rightBigWidConstraint.priority = 700;
        self.rightSmallWidConstraint.priority = 999;
    }
}
- (void)updateSafeState {
    if (self.setSafeMode == 2 || self.setSafeMode == 3) {
        self.safeLabel.text = @"设防";
        self.safeImageView.image = [UIImage imageNamed:@"ic_bike_sfang"];
        self.safeImageView.hidden = NO;
        self.safeLabel.hidden = NO;
    }else if (self.setSafeMode == 4 || self.setSafeMode == 1){
        self.safeLabel.text = @"撤防";
        self.safeImageView.image = [UIImage imageNamed:@"ic_bike_cfang"];
        self.safeImageView.hidden = NO;
        self.safeLabel.hidden = NO;
    }else if (self.setSafeMode == -1){
        self.safeLabel.hidden = YES;
        self.safeImageView.hidden = YES;
    }else if (self.setSafeMode == -2){
        self.safeLabel.text = @"设/撤防未知";
        self.safeImageView.image = [UIImage imageNamed:@"ic_batt_help"];
        self.safeLabel.hidden = NO;
        self.safeImageView.hidden = NO;
    }
    [self updateBattDataUI];
}

- (void)updateBattDataUI {
    [self updateEleDoorStateWithisOpen:self.eleDoorState];
    if (self.isCompute) {
        self.battBgView.hidden = NO;
        self.bottomTitleLabel.text = @"续航预估";
        self.volUnitLabel.hidden = YES;
        self.mileUnitImage.hidden = NO;
        NSString *eleImageName = [NSString stringWithFormat:@"ic_batt_%@", @((NSInteger)self.soc/10)];
        self.battImageView.image = [UIImage imageNamed:eleImageName];
        self.battImageView.hidden = NO;
        if(self.soc == -100){
            self.battImageView.hidden = YES;
            self.noBattButton.hidden = NO;
            [self.noBattButton setTitle:@"未检测到电池" forState:UIControlStateNormal];
            [self.noBattButton setImage:nil forState:UIControlStateNormal];
            self.noBattButton.userInteractionEnabled = NO;
            [self.noBattButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }else if(self.soc == -200){
            self.battImageView.hidden = YES;
            self.noBattButton.hidden = NO;
            [self.noBattButton setTitle:@"电量无法计算" forState:UIControlStateNormal];
            [self.noBattButton setImage:[UIImage imageNamed:@"ic_batt_help"] forState:UIControlStateNormal];
            self.noBattButton.userInteractionEnabled = YES;
            CGFloat imgWidth = self.noBattButton.imageView.bounds.size.width;
            CGFloat labWidth = self.noBattButton.titleLabel.bounds.size.width;
            [self.noBattButton setImageEdgeInsets:UIEdgeInsetsMake(0, labWidth, 0, -labWidth)];
            [self.noBattButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgWidth, 0, imgWidth)];
        }else if(self.soc >= 0)
        {
            NSString *eleImageName = [NSString stringWithFormat:@"ic_batt_%@", @((NSInteger)self.soc/10)];
            self.battImageView.image = [UIImage imageNamed:eleImageName];
            self.battImageView.hidden = NO;
            self.noBattButton.hidden = YES;
        }
        [self setMilesUIWithMile:self.expecteddistance];
    }else{
        self.battBgView.hidden = YES;
        self.bottomTitleLabel.text = @"电压";
        self.volUnitLabel.hidden = NO;
        self.mileUnitImage.hidden = YES;
        [self setVolUIWithVol:self.vol];
    }
   
}

- (void)setMilesUIWithMile:(CGFloat)mile
{
    if (mile < 0 || self.soc < 0) {
        self.mileHunImageView.hidden = YES;
        self.mileTenImageView.hidden = YES;
        self.milePerImageView.hidden = YES;
        self.mileDotImageView.hidden = YES;
        self.mileUnitImage.hidden = NO;
        self.driveDotBigConstraint.priority = 700;
        self.driveDotSmallConstraint.priority = 999;
        self.noMilePerImageeView.hidden = NO;
        self.noMileTenImageView.hidden = NO;
        return;
    }
    self.noMilePerImageeView.hidden = YES;
    self.noMileTenImageView.hidden = YES;
    self.hunTrailConstraint.constant = 0;
    NSInteger mileN = (NSInteger)mile;
    CGFloat mileD = mile-mileN;
    NSInteger mileDN = mileD *10;
    if (mileN<10 && mileN >0) {
        
        self.mileHunImageView.hidden = YES;
        self.mileTenImageView.hidden = NO;
        self.milePerImageView.hidden = NO;
        self.mileDotImageView.hidden = NO;
        self.driveDotSmallConstraint.priority = 700;
        self.driveDotBigConstraint.priority = 999;
        NSInteger dotNum;
        if (mileDN >=0 && mileDN < 5) {
            dotNum = 0;
        }else
        {
            dotNum = 5;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)mileN];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)dotNum];
        self.mileTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        self.mileDotImageView.image = [UIImage imageNamed:@"ic_batt_dot"];
        
    }else if (mileN == 0)
    {
        if (mileDN ==0 ) {
            self.mileHunImageView.hidden = YES;
            self.mileTenImageView.hidden = YES;
            self.milePerImageView.hidden = NO;
            self.mileDotImageView.hidden = YES;
            NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec0"];
            self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        }else
        {
            self.mileHunImageView.hidden = YES;
            self.mileTenImageView.hidden = NO;
            self.milePerImageView.hidden = NO;
            self.mileDotImageView.hidden = NO;
            self.driveDotSmallConstraint.priority = 700;
            self.driveDotBigConstraint.priority = 999;
            NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec0"];
            NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec5"];
            self.mileTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
            self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        }
        
    }else if(mileN >99)
        
    {
        NSInteger hunNum = mileN/100 > 9 ? 9 : mileN/100;
        NSInteger tenNum = mileN%100;
        NSInteger ten = tenNum/10;
        NSInteger per = tenNum%10;
        self.mileHunImageView.hidden = NO;
        self.mileTenImageView.hidden = NO;
        self.milePerImageView.hidden = NO;
        self.mileDotImageView.hidden = YES;
        self.driveDotBigConstraint.priority = 700;
        self.driveDotSmallConstraint.priority = 999;
        NSString *imageNameHun = [NSString stringWithFormat:@"icon_elec%ld",(long)hunNum];
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.mileHunImageView.image = [[UIImage imageNamed:imageNameHun] imageWithTintColor:[UIColor whiteColor]];
        self.mileTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        if (hunNum == 1) {
            self.hunTrailConstraint.constant = -2;
        }else{
            self.hunTrailConstraint.constant = 0;
        }
    }else
    {
        NSInteger ten = mileN/10;
        NSInteger per = mileN%10;
        self.mileHunImageView.hidden = YES;
        self.mileTenImageView.hidden = NO;
        self.milePerImageView.hidden = NO;
        self.mileDotImageView.hidden = YES;
        self.mileUnitImage.hidden = NO;
        self.driveDotBigConstraint.priority = 700;
        self.driveDotSmallConstraint.priority = 999;
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.mileTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
    }
}

- (void)setVolUIWithVol:(NSInteger)vol
{
    self.noMilePerImageeView.hidden = YES;
    self.noMileTenImageView.hidden = YES;
    self.hunTrailConstraint.constant = 0;
    self.mileDotImageView.hidden = YES;
    self.driveDotBigConstraint.priority = 700;
    self.driveDotSmallConstraint.priority = 999;
    if (self.soc == -100 ) {
        self.mileHunImageView.hidden = YES;
        self.mileTenImageView.hidden = YES;
        self.milePerImageView.hidden = YES;
        self.noMilePerImageeView.hidden = NO;
        self.noMileTenImageView.hidden = NO;
        return;
    }
    if (vol<10 && vol >= 0) {
        self.mileHunImageView.hidden = YES;
        self.mileTenImageView.hidden = YES;
        self.milePerImageView.hidden = NO;
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)vol];
        self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        
    }else if(vol >99)
        
    {
        NSInteger hunNum = vol/100 > 9 ? 9 : vol/100;
        NSInteger tenNum = vol%100;
        NSInteger ten = tenNum/10;
        NSInteger per = tenNum%10;
        self.mileHunImageView.hidden = NO;
        self.mileTenImageView.hidden = NO;
        self.milePerImageView.hidden = NO;
        NSString *imageNameHun = [NSString stringWithFormat:@"icon_elec%ld",(long)hunNum];
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.mileHunImageView.image = [[UIImage imageNamed:imageNameHun] imageWithTintColor:[UIColor whiteColor]];
        self.mileTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        if (hunNum == 1) {
            self.hunTrailConstraint.constant = -2;
        }else{
            self.hunTrailConstraint.constant = 0;
        }
    }else
    {
        NSInteger ten = vol/10;
        NSInteger per = vol%10;
        self.mileHunImageView.hidden = YES;
        self.mileTenImageView.hidden = NO;
        self.milePerImageView.hidden = NO;
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.mileTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.milePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
    }
}
-(void)updateEleDoorStateWithisOpen:(BOOL)isOpen
{
    if (isOpen) {
        self.eleDoorImageView.image = [UIImage imageNamed:@"ic_eleDoor_open"];
        self.eleDoorLabel.text = @"电门已打开";
    }else
    {
        self.eleDoorImageView.image = [UIImage imageNamed:@"ic_eleDoor_close"];
        self.eleDoorLabel.text = @"电门已关闭";
    }
}
- (void)updateWeatherUI{
    if (!self.weatherModel) {
        self.weaLabel.hidden = YES;
        self.weaHunImageView.hidden = YES;
        self.weaTenImageView.hidden = YES;
        self.weaPerImageView.hidden = YES;
        self.weaDuImageView.hidden = YES;
        return;
    }
    self.weaLabel.hidden = YES;
    self.weaHunImageView.hidden = NO;
    self.weaTenImageView.hidden = NO;
    self.weaPerImageView.hidden = NO;
    self.weaDuImageView.hidden = NO;
    self.weaLabel.text = _weatherModel.weather;
    [self setTempImageWithTemp:_weatherModel.temperature.integerValue];
}

-(void)setTempImageWithTemp:(NSInteger)temp
{
    
    NSInteger tenNum = labs(temp)/10;
    NSInteger perNum =labs(temp)%10;
    
    NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)tenNum];
    NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)perNum];
    if (temp <0) {
        
        self.weaHunWidConstraint.constant = 8;
        self.weaHunImageView.image = [UIImage imageNamed:@"ic_bike_-"];
        
    }else
    {
        self.weaHunWidConstraint.constant = 0;
    }
    
    if (tenNum==0) {
        self.weaTenWidConstraint.constant = 0;
    }else
    {
        self.weaTenWidConstraint.constant = 10.5;
        self.weaTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
    }
    self.weaPerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
    self.weaDuImageView.image = [UIImage imageNamed:@"ic_bike_du"];
}


- (IBAction)viewClickedToPush:(UITapGestureRecognizer *)sender {
    
    CGPoint clickPointWea = [sender locationInView:self.weaTapView];
    if(CGRectContainsPoint(self.weaTapView.bounds, clickPointWea)){
        if ([self.delegate respondsToSelector:@selector(viewTapToRefreshWeather:)]) {
            [self.delegate viewTapToRefreshWeather:self];
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(viewTapToPushBikeDetailWithView:)]) {
        [self.delegate viewTapToPushBikeDetailWithView:self];
    }
}
- (IBAction)handleNoBatt:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(buttonClickedToPushBattDetail:)]) {
        [self.delegate buttonClickedToPushBattDetail:sender];
    }
    
}

-(UIImage *)fitSmallImage:(UIImage *)image
{
    if (nil == image)
    {
        return nil;
    }
    CGSize size = [self fitsize:image.size];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:rect];
    UIImage *newing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newing;
}

- (CGSize)fitsize:(CGSize)thisSize
{
    if(thisSize.width == 0 && thisSize.height ==0)
        return CGSizeMake(0, 0);
    CGFloat hscale = thisSize.height/IMAGE_MAX_SIZE_GEIGHT;
    CGSize newSize = CGSizeMake(thisSize.width/hscale, thisSize.height/hscale);
    return newSize;
}

@end
