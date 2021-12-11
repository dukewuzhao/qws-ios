//
//  G100BikeInfoView.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeInfoView2.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Tint.h"
#import "NSDate+TimeString.h"
#define IMAGE_MAX_SIZE_WIDTH 160
#define IMAGE_MAX_SIZE_GEIGHT 40
@interface G100BikeInfoView2 ()

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
@property (weak, nonatomic) IBOutlet UILabel *bikeUserDesc;
@property (weak, nonatomic) IBOutlet UILabel *bikeUserName;

@property (weak, nonatomic) IBOutlet UIImageView *safeImageView;
@property (weak, nonatomic) IBOutlet UILabel *safeLabel;
@property (weak, nonatomic) IBOutlet UIButton *bikeBarButton;
@property (weak, nonatomic) IBOutlet UILabel *bikeTestTime;
@property (weak, nonatomic) IBOutlet UILabel *bikeTestTitle;
@property (weak, nonatomic) IBOutlet UIView *testTapView;
@property (weak, nonatomic) IBOutlet UIImageView *testHunImageView;
@property (weak, nonatomic) IBOutlet UIImageView *testTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *testPerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testPerWidBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testPerWidSmallConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testTenwidBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testTenWidSmallConstraint;

@property (weak, nonatomic) IBOutlet UILabel *bikeTestFenLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeTestDefault;
@property (weak, nonatomic) IBOutlet UILabel *notestDate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *safeWidthConstraint;

@end

@implementation G100BikeInfoView2

+ (instancetype)loadBikeInfoView{
    
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BikeInfoView2" owner:nil options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.safeLabel.hidden = YES;
    self.safeImageView.hidden = YES;
    self.bikeUserName.hidden = YES;
}

+ (float)heightWithWidth:(float)width{
        return 80*width/197;
}

-(void)setBikeModel:(G100BikeModel *)bikeModel{
    if (![[bikeModel.car_logo substringToIndex:4] isEqualToString:@"http"]) {
        bikeModel.car_logo = [NSString stringWithFormat:@"https://%@",bikeModel.car_logo];
    }
    _bikeModel = bikeModel;
    [self updateBikeUI];
}


-(void)setTestResultDomin:(G100TestResultDomain *)testResultDomin{
    _testResultDomin = testResultDomin;
    [self updateTestResultUI];
}

- (void)setWeatherModel:(G100WeatherModel *)weatherModel{
    _weatherModel = weatherModel;
    [self updateWeatherUI];
}

- (void)updateBikeUI
{
    
    //self.bikeUserName.text = _bikeModel.name;
//    if (self.bikeModel.user_count) {
//        self.bikeUserDesc.text = [NSString stringWithFormat:@"本车共有%ld位用户",(long)self.bikeModel.user_count];
//    }else{
//        self.bikeUserDesc.text = @"本车共有1位用户";
//    }
    if (!_bikeModel) {
        return;
    }
    self.bikeUserDesc.hidden = YES;
    self.bikeBarButton.hidden = YES;
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
//    [self.bikeBarButton.imageView sd_setImageWithURL:[NSURL URLWithString:_bikeModel.car_scanBar] placeholderImage:[UIImage imageNamed:@"ic_bike_barScan"]];
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
}

- (void)updateSafeState{
    if (self.bikeModel.setSafeMode == 2 || self.bikeModel.setSafeMode == 3) {
        self.safeLabel.text = @"设防";
        self.safeImageView.image = [UIImage imageNamed:@"ic_bike_sfang"];
        self.safeImageView.hidden = NO;
        self.safeLabel.hidden = NO;
        self.safeWidthConstraint.constant = 20;
    }else if (self.bikeModel.setSafeMode == 4 || self.bikeModel.setSafeMode == 1){
        self.safeLabel.text = @"撤防";
        self.safeImageView.image = [UIImage imageNamed:@"ic_bike_cfang"];
        self.safeImageView.hidden = NO;
        self.safeLabel.hidden = NO;
        self.safeWidthConstraint.constant = 20;
    }else if (self.bikeModel.setSafeMode == -1){
        self.safeLabel.hidden = YES;
        self.safeImageView.hidden = YES;
    }else if (self.bikeModel.setSafeMode == -2){
        self.safeLabel.text = @"设/撤防未知";
        self.safeLabel.hidden = NO;
        self.safeImageView.hidden = YES;
        self.safeWidthConstraint.constant = 0;
    }
}

- (void)updateTestResultUI{
    if (!self.testResultDomin) {
        self.bikeTestDefault.hidden = NO;
        self.testHunImageView.hidden = YES;
        self.testTenImageView.hidden = YES;
        self.testPerImageView.hidden = YES;
        self.bikeTestFenLabel.hidden = YES;
        self.bikeTestTime.hidden = YES;
        self.bikeTestTitle.hidden = YES;
        self.notestDate.hidden = YES;
        self.notestDate.text = @"";
        return;
    }
    self.bikeTestDefault.hidden = YES;
    self.bikeTestFenLabel.hidden = NO;
    self.bikeTestTime.hidden = YES;
    self.bikeTestTitle.hidden = NO;
    int days = [NSDate getTimeIntervalDaysFromNowWithDateStr:[_testResultDomin.lastTestTime substringToIndex:10]];
    if (days >= 5) {
        if (days >99) {
            self.notestDate.text = [NSString stringWithFormat:@"99+天没有检测啦!"];
        }else{
            self.notestDate.text = [NSString stringWithFormat:@"%d天没有检测啦!",days];
        }
        self.notestDate.hidden = NO;
    }else{
        self.notestDate.hidden = YES;
        self.notestDate.text = @"";
    }
    [self updateTestGradeWithGrade:_testResultDomin.score];
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
    self.weaLabel.hidden = NO;
    self.weaHunImageView.hidden = NO;
    self.weaTenImageView.hidden = NO;
    self.weaPerImageView.hidden = NO;
    self.weaDuImageView.hidden = NO;
    self.weaLabel.text = _weatherModel.weather;
    [self setTempImageWithTemp:_weatherModel.temperature.integerValue];
}


- (void)updateTestGradeWithGrade:(NSInteger)grade
{
    if (grade<10 && grade >=0) {
        
        self.testHunImageView.hidden = YES;
        self.testTenImageView.hidden = YES;
        self.testPerImageView.hidden = NO;
        /*
        if (grade == 1) {
            self.testPerWidBigConstraint.priority = 700;
            self.testPerWidSmallConstraint.priority = 999;
        }else
        {
            self.testPerWidSmallConstraint.priority = 700;
            self.testPerWidBigConstraint.priority = 999;
        }
        */
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)grade];
        self.testPerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
        
    }else if(grade < 0)
    {
        self.testHunImageView.hidden = YES;
        self.testTenImageView.hidden = YES;
        self.testPerImageView.hidden = YES;
    }else if(grade >99)
    {
        self.testHunImageView.hidden = NO;
        self.testTenImageView.hidden = NO;
        self.testPerImageView.hidden = NO;
        /*
        self.testPerWidSmallConstraint.priority = 700;
        self.testPerWidBigConstraint.priority = 999;
        self.testTenWidSmallConstraint.priority = 700;
        self.testTenwidBigConstraint.priority = 999;
         */
        self.testHunImageView.image = [[UIImage imageNamed:@"icon_elec1"] imageWithTintColor:[UIColor whiteColor]];
        self.testTenImageView.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor whiteColor]];
        self.testPerImageView.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor whiteColor]];
    }else
    {
        NSInteger ten = grade/10;
        NSInteger per = grade%10;
        self.testHunImageView.hidden = YES;
        self.testTenImageView.hidden = NO;
        self.testPerImageView.hidden = NO;
        /*
        if (ten == 1) {
            self.testTenwidBigConstraint.priority = 700;
            self.testTenWidSmallConstraint.priority = 999;
        }else
        {
            self.testTenWidSmallConstraint.priority = 700;
            self.testTenwidBigConstraint.priority = 999;
        }
        
        if (per == 1) {
            self.testPerWidBigConstraint.priority = 700;
            self.testPerWidSmallConstraint.priority = 999;
        }else
        {
            self.testPerWidSmallConstraint.priority = 700;
            self.testPerWidBigConstraint.priority = 999;
        }
         */
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.testTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor whiteColor]];
        self.testPerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor whiteColor]];
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
        self.weaHunImageView.image = [UIImage imageNamed:@"ic_bike_-"];
        
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
        self.weaTenImageView.image = [UIImage imageNamed:imageNameTen];
    }
    
    if (perNum == 1) {
        
        self.weaPerWidConstraint.constant = 6.25;
    }else
    {
        self.weaPerWidConstraint.constant = 12.5;
        
    }
    self.weaPerImageView.image = [UIImage imageNamed:imageNamePer];
    self.weaDuImageView.image = [UIImage imageNamed:@"ic_bike_du"];
}

- (IBAction)bikeBarClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(buttonClickedToScaleQRCode:)]) {
        [self.delegate buttonClickedToScaleQRCode:sender];
    }
}

- (IBAction)viewClickedToPush:(UITapGestureRecognizer *)sender {
    CGPoint clickPoint = [sender locationInView:self.testTapView];
    CGPoint clickPointWea = [sender locationInView:self.weaTapView];
    if (CGRectContainsPoint(self.testTapView.bounds, clickPoint)) {
        if ([self.delegate respondsToSelector:@selector(viewTapToPushTestDetailWithView:)]) {
            [self.delegate viewTapToPushTestDetailWithView:self];
        }
        return;
    }
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
