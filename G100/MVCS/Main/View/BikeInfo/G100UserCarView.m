//
//  G100UserCarView.m
//  G100
//
//  Created by sunjingjing on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UserCarView.h"
#import "G100NoCarView.h"
#import <UIImageView+WebCache.h>

#define IMAGE_MAX_SIZE_WIDTH 160
#define IMAGE_MAX_SIZE_GEIGHT 40
@interface G100UserCarView ()

@property (weak, nonatomic) IBOutlet UIImageView *hunImageView;

@property (weak, nonatomic) IBOutlet UIImageView *tenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *perImageView;

@property (weak, nonatomic) IBOutlet UIImageView *sHunImageView;

@property (weak, nonatomic) IBOutlet UIImageView *sTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sPerImageView;
@property (weak, nonatomic) IBOutlet UILabel *eleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hunWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tenWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *perWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sHunWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sTenWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sPerWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) NSInteger num;

@property (assign, nonatomic) NSInteger lastMile;

@property (assign, nonatomic) NSInteger percentNew;
@end

@implementation G100UserCarView

+ (instancetype)showView
{

    return [[[NSBundle mainBundle] loadNibNamed:@"G100UserCarView" owner:nil options:nil] firstObject];
}

-(instancetype)initWithIsDevice:(BOOL)hasDevice
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"G100UserCarView" owner:nil options:nil] firstObject];
    if (self) {
        if (hasDevice) {
            
            self.lastPercent = -1;
            self.lastMile = -1;
            
            if (ISIPHONE_4 || ISIPHONE_5) {
                self.eleDoorState.font = [UIFont systemFontOfSize:8];
                self.driveMile.font = [UIFont systemFontOfSize:8];
                self.lowElecShow.titleLabel.font = [UIFont systemFontOfSize:8];
                self.eleLabel.font = [UIFont boldSystemFontOfSize:11];
            }
            EleShowView *eleView = [EleShowView sharedViewWithFrame:self.coulometryView.bounds option:self.lastPercent];
            eleView.backgroundColor = [UIColor clearColor];
            self.eleAnimaView = eleView;
            [self.coulometryView insertSubview:eleView atIndex:0];
            
            [self.eleAnimaView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
            //        userCar.carImageView.image = [UIImage imageNamed:@"ic_yadi_car"];
            //        userCar.barSacnImageView.image = [UIImage imageNamed:@"ic_yadi_logo"];
            [self setPercentAnimateWithPercent:self.lastPercent];
            [self setMilesAnimateWithMile:self.lastMile];
        }else
        {
            self.rightBgView.hidden = YES;
            self.clickedAniView.hidden = YES;
            //        userCar.carImageView.image = [UIImage imageNamed:@"ic_yadi_car"];
            //        userCar.barSacnImageView.image = [UIImage imageNamed:@"ic_yadi_logo"];
            [self performSelector:@selector(updateViewOfNoDevice) withObject:nil afterDelay:0.01];
        }

    }
    return self;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setupBaseView];
    //self.eleDoorState.text = @"电门未知";
}

- (void)setupBaseView
{
    self.lastPercent = -1;
    self.lastMile = -1;
    
    if (ISIPHONE_4 || ISIPHONE_5) {
        self.eleDoorState.font = [UIFont systemFontOfSize:8];
        self.driveMile.font = [UIFont systemFontOfSize:8];
        self.lowElecShow.titleLabel.font = [UIFont systemFontOfSize:8];
        self.eleLabel.font = [UIFont boldSystemFontOfSize:11];
    }else if (ISIPHONE_6)
    {
        self.eleDoorState.font = [UIFont systemFontOfSize:10];
        self.driveMile.font = [UIFont systemFontOfSize:10];
        self.lowElecShow.titleLabel.font = [UIFont systemFontOfSize:10];
        self.eleLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    [self.eleDoorState adjustsFontSizeToFitWidth];
    [self setPercentAnimateWithPercent:self.lastPercent];
    EleShowView *eleView = [EleShowView sharedViewWithFrame:self.coulometryView.bounds option:self.lastPercent];
    eleView.backgroundColor = [UIColor clearColor];
    self.eleAnimaView = eleView;
    [self.coulometryView insertSubview:eleView atIndex:0];
    
    [self.eleAnimaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
//    self.carImageView.image = [UIImage imageNamed:@"ic_yadi_car"];
//    self.barSacnImageView.image = [UIImage imageNamed:@"ic_yadi_logo"];
    [self setPercentAnimateWithPercent:self.lastPercent];
    [self setMilesAnimateWithMile:self.lastMile];
    [self setBackgroundWithPercent:self.lastPercent];
    self.noDevice.hidden = YES;
}
-(void)setBikeModel:(G100BikeModel *)bikeModel
{
    _bikeModel = bikeModel;
    [self updateBikeView];
    
}

- (void)updateBikeView
{
    
    self.carDescrip.text = _bikeModel.name;
    if ([_bikeModel.is_master isEqualToString:@"1"]) {
        self.isMasterImageView.hidden = NO;
        self.isMasterImageView.image = [UIImage imageNamed:@"icon_car_usermain"];
        if (_bikeModel.user_count > 1) {
            //self.userDescrip.hidden = NO;
            self.userDescrip.text = [NSString stringWithFormat:@"本车另有%ld位副用户",(long)_bikeModel.user_count-1];
            // self.viewBottomConstraint.constant = 10;
        }else
        {
            //self.userDescrip.hidden = YES;
            self.userDescrip.text = @"本车没有副用户";
            // self.viewBottomConstraint.constant = 0;
        }
    }else
    {
        self.isMasterImageView.hidden = YES;
        if (_bikeModel.user_count > 1) {
            //self.userDescrip.hidden = NO;
            self.userDescrip.text = [NSString stringWithFormat:@"本车另有%ld位用户",(long)_bikeModel.user_count-1];
            // self.viewBottomConstraint.constant = 10;
        }else
        {
            //self.userDescrip.hidden = YES;
            self.userDescrip.text = @"本车没有其他用户";
        }
    }
    if (_bikeModel.car_logo) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_bikeModel.car_logo] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.barSacnImageView.image = [self fitSmallImage:image];
                }else {
                    self.barSacnImageView.image = [self fitSmallImage:[UIImage imageNamed:@"g100_main_left_logo"]];
                }
            });
        }];
    }else
    {
         self.barSacnImageView.image = [self fitSmallImage:[UIImage imageNamed:@"g100_main_left_logo"]];
    }
    [self.settingButton.imageView sd_setImageWithURL:[NSURL URLWithString:_bikeModel.car_scanBar] placeholderImage:[UIImage imageNamed:@"icon_car_barsacn"]];
    if (_bikeModel.pic_small) {
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_bikeModel.pic_small] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.noDevice.hidden = YES;
                    self.carImageView.image = image;
                }else {
                    self.noDevice.hidden = NO;
                }
            });
        }];
       
    }else
    {
        self.carImageView.image = nil;
        self.noDevice.hidden = NO;
    }
}

-(void)updateEleDoorStateWithisOpen:(BOOL)isOpen
{
    if (isOpen) {
        
        self.eleDoorBgView.image = [UIImage imageNamed:@"bg_eleDoor_open"];
        self.eleDoorState.text = @"电门已打开";
        self.eleDoorState.textColor = [UIColor blackColor];
    }else
    {
        self.eleDoorBgView.image = [UIImage imageNamed:@"bg_eleDoor_close"];
        self.eleDoorState.text = @"电门已关闭";
        self.eleDoorState.textColor = [UIColor whiteColor];
    }
}

- (void)updateEleDoorStateWithremove
{
    self.eleDoorBgView.image = [UIImage imageNamed:@"bg_eleDoor_close"];
    self.eleDoorState.text = @"电瓶未检测";
    self.eleDoorState.textColor = [UIColor whiteColor];
}
- (void)setPercentAnimateWithPercent:(NSInteger)percent
{
    
    if (percent <= 0)
    {
        self.hunWidConstraint.constant = 0;
        self.tenWidConstraint.constant = 20;
        self.perWidConstraint.constant = 20;
        self.perImageView.image = [UIImage imageNamed:@"icon_wea_-0"];
        self.tenImageView.image = [UIImage imageNamed:@"icon_wea_-0"];
        
    }else if (percent<10 && percent >0) {
        
        self.hunWidConstraint.constant = 0;
        self.tenWidConstraint.constant = 0;
        if (percent == 1) {
            self.perWidConstraint.constant = 14;
        }else
        {
            self.perWidConstraint.constant = 23;
        }
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_big%ld",(long)percent];
        self.perImageView.image = [UIImage imageNamed:imageNamePer];
        
    }else if(percent >99)
        
    {
        self.hunWidConstraint.constant = 14;
        self.tenWidConstraint.constant = 20;
        self.perWidConstraint.constant = 20;
        self.hunImageView.image = [UIImage imageNamed:@"ic_big1"];
        self.tenImageView.image = [UIImage imageNamed:@"ic_big0"];
        self.perImageView.image = [UIImage imageNamed:@"ic_big0"];
    }else
    {
        NSInteger ten = percent/10;
        NSInteger per = percent%10;
        self.hunWidConstraint.constant = 0;
        if (ten == 1) {
            self.tenWidConstraint.constant = 14;
        }else
        {
           self.tenWidConstraint.constant = 20;
        }
        if (per == 1) {
            self.perWidConstraint.constant = 14;
        }else
        {
            self.perWidConstraint.constant = 20;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_big%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_big%ld",(long)per];
        self.tenImageView.image = [UIImage imageNamed:imageNameTen];
        self.perImageView.image = [UIImage imageNamed:imageNamePer];
    }
    
}

- (void)setMilesAnimateWithMile:(NSInteger)mile
{
    
    if (mile<10 && mile >0) {
        
        self.sHunWidConstraint.constant = 0;
        self.sTenWidConstraint.constant = 0;
        if (mile == 1) {
            self.sPerWidConstraint.constant = 8;
        }else
        {
            self.sPerWidConstraint.constant = 12;
        }
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_car_small%ld",(long)mile];
        self.sPerImageView.image = [UIImage imageNamed:imageNamePer];
        
    }else if (mile <= 0)
    {
     
        self.sHunWidConstraint.constant = 0;
        self.sTenWidConstraint.constant = 12;
        self.sPerWidConstraint.constant = 12;
        self.sTenImageView.image = [UIImage imageNamed:@"icon_wea_-0"];
        self.sPerImageView.image = [UIImage imageNamed:@"icon_wea_-0"];
    }else if(mile >99)
        
    {
        self.sHunWidConstraint.constant = 8;
        self.sTenWidConstraint.constant = 12;
        self.sPerWidConstraint.constant = 12;
        self.sHunImageView.image = [UIImage imageNamed:@"ic_car_small1"];
        self.sTenImageView.image = [UIImage imageNamed:@"ic_car_small0"];
        self.sPerImageView.image = [UIImage imageNamed:@"ic_car_small0"];
    }else
    {
        NSInteger ten = mile/10;
        NSInteger per = mile%10;
        self.sHunWidConstraint.constant = 0;
        if (ten == 1) {
            self.sTenWidConstraint.constant = 8;
        }else
        {
            self.sTenWidConstraint.constant = 12;
        }
        if (per == 1) {
            self.sPerWidConstraint.constant = 8;
        }else
        {
            self.sPerWidConstraint.constant = 12;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_car_small%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_car_small%ld",(long)per];
        self.sTenImageView.image = [UIImage imageNamed:imageNameTen];
        self.sPerImageView.image = [UIImage imageNamed:imageNamePer];
    }

}

-(void)beginAnimateWithIsAnimate:(BOOL)isAnimate
{
   
    self.percentNew = _bikeModel.soc;
    if (!isAnimate) {
        
        [self updateEleDataUI];
        [self.eleAnimaView setViewWithPercent:self.percentNew isAnimate:NO];
        return;
    }
    self.num = 0;
    //NSInteger rand = arc4random()%100;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.eleAnimaView setViewWithPercent:self.percentNew isAnimate:YES];
    });
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(tempChanged:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }

}

- (void)tempChanged:(NSTimer *)timer
{
    
    NSInteger sum = 0;
    if (self.percentNew < 0) {
        
        if (self.lastPercent <0) {
            return;
        }
        sum = self.lastPercent/3;
    }else
    {
        sum = (self.lastPercent + self.percentNew + 25)/3;
    }
    if (self.num >= sum) {
        
        [self updateEleDataUI];
        [self.timer invalidate];
        self.timer =nil;
        self.num = 0;
        return;
    }
    NSInteger rand = arc4random()%100;
    [self setPercentAnimateWithPercent:rand];
    [self setMilesAnimateWithMile:rand];
    self.num++;
}

- (void)updateEleDataUI
{
    [self setPercentAnimateWithPercent:self.percentNew];
    [self setMilesAnimateWithMile:(NSInteger)_bikeModel.expecteddistance];
    [self setBackgroundWithPercent:self.percentNew];
    if (self.percentNew <=0) {
        [self updateEleDoorStateWithremove];
    }else
    {
        [  self updateEleDoorStateWithisOpen:self.bikeModel.eleDoorState];
    }
    if (self.percentNew<=10 && self.percentNew >0) {
        
        if (self.lowElecShow.hidden == YES) {
            [UIView animateWithDuration:0.5 animations:^{
                self.lowElecShow.hidden = NO;
            }];
        }
    }else
    {
        if (self.lowElecShow.hidden == NO) {
            [UIView animateWithDuration:0.5 animations:^{
                self.lowElecShow.hidden = YES;
            }];
        }
    }
    self.lastPercent = self.percentNew;
}
-(void)setBackgroundWithPercent:(NSInteger)percent
{
    
    [self.rBgImageView.layer removeAnimationForKey:@"bgTrans"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.rBgImageView.layer addAnimation:transition forKey:@"bgTrans"];
    if (percent >10) {
        
        [self.rBgImageView setImage:[UIImage imageNamed:@"bg_car_RBlack"]];
    }else
    {
        [self.rBgImageView setImage:[UIImage imageNamed:@"bg_car_RRed"]];
    }

}

+(float)heightWithWidth:(float)width
{
    return width/2;
}

-(void)updateViewOfNoDevice
{
    self.rightBgView.hidden = YES;
    self.clickedAniView.hidden = YES;
    if (!self.bikeModel.pic_small) {
        self.noDevice.hidden = NO;

    }else
    {
        self.noDevice.hidden = YES;
    }
    self.leftTorightleadConstraint.active = NO;
    self.leftTosuperTrailConstraint.active = YES;
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

}

-(void)updateViewOfAddedDevice
{
    self.rightBgView.hidden = NO;
    self.clickedAniView.hidden = NO;
    if (!self.bikeModel.pic_small) {
        self.noDevice.hidden = NO;
        
    }else
    {
        self.noDevice.hidden = YES;
    }
    self.leftTosuperTrailConstraint.active = NO;
    self.leftTorightleadConstraint.active = YES;
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

}
- (IBAction)qrClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(buttonClickedToScaleQRCode:)]) {
        [self.delegate buttonClickedToScaleQRCode:sender];
    }
    
}
-(UIImage *)fitSmallImage:(UIImage *)image
{
    if (nil == image)
    {
        return nil;
    }
    CGSize size = [self fitsize:image.size];
    self.logoWidthConstraint.constant = size.width;
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
