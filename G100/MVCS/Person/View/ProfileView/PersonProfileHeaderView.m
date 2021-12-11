//
//  PersonProfileHeaderView.m
//  G100
//
//  Created by yuhanle on 16/7/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "PersonProfileHeaderView.h"
#import <UIImageView+WebCache.h>
#import "FXBlurView.h"
#import "UIImage+Effection.h"
#import "G100BikeDomain.h"

@interface PersonProfileHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *flurView;
@property (weak, nonatomic) IBOutlet UILabel *phonenumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *bikesNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *devicesNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *servicesNumLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraintH;
@property (weak, nonatomic) IBOutlet UIView *myView;

@end

@implementation PersonProfileHeaderView

+ (instancetype)loadNibXibView {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    FXBlurView *flureView = [[FXBlurView alloc] init];
    flureView.tintColor = [UIColor colorWithHexString:@"002356" alpha:0.6];
    [self.flurView addSubview:flureView];
    self.flurView.backgroundColor = [UIColor clearColor];
    
    [flureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.backImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
    // 添加点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewDidTapped)];
    [self.avatarImageView addGestureRecognizer:tapGesture];
    
    self.avatarImageView.userInteractionEnabled = YES;
    
    if ([[UIScreen mainScreen] bounds].size.width <= 320) {
        self.bottomViewConstraintH.constant = 60;
        self.bikesNumLabel.font = [UIFont systemFontOfSize:30];
        self.devicesNumLabel.font = [UIFont systemFontOfSize:30];
        self.servicesNumLabel.font = [UIFont systemFontOfSize:30];
    }
    
    self.myView.hidden = YES;
}

- (void)setAccount:(G100AccountDomain *)account {
    _account = account;
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:account.user_info.icon] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                self.backImageView.image = [image fx_defaultGaussianBlurImage];
            }else {
                if ([account.user_info.gender isEqualToString:@"1"]) {
                    self.backImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
                }else {
                    self.backImageView.image = [[UIImage imageNamed:@"ic_default_female"] fx_defaultGaussianBlurImage];
                }
            }
        });
    }];
    
    if ([account.user_info.gender isEqualToString:@"1"]) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:account.user_info.icon]
                                placeholderImage:[UIImage imageNamed:@"ic_default_male"]];
    }else {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:account.user_info.icon]
                                placeholderImage:[UIImage imageNamed:@"ic_default_female"]];
    }
    
   // self.nicknameLabel.text = account.user_info.nick_name;
    self.phonenumLabel.text = [NSString shieldImportantInfo:account.user_info.phone_num];
    self.bikesNumLabel.text = [NSString stringWithFormat:@"%@", @(account.user_info.bike_count)];
    
    NSInteger count = 0;
    for (G100BikeDomain *domain in account.bikes) {
        for (G100DeviceDomain *device in domain.devices) {
            if ([device isNormalDevice]) {
                count++;
            }
        }
    }
    
    self.devicesNumLabel.text = [NSString stringWithFormat:@"%@", @(account.user_info.device_count)];
    self.servicesNumLabel.text = [NSString stringWithFormat:@"%@", @(account.user_info.service_count)];
}

- (void)setAvatarImageData:(UIImage *)avatarImage {
    _avatarImageData = avatarImage;
    self.backImageView.image = [avatarImage fx_defaultGaussianBlurImage];
    [self.avatarImageView setImage:avatarImage];
}

- (void)avatarImageViewDidTapped {
    if ([_delegate respondsToSelector:@selector(avatarImageViewDidTapped)]) {
        [self.delegate avatarImageViewDidTapped];
    }
}

- (void)drawRect:(CGRect)rect {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 6);
    self.layer.shadowRadius = 6;
    self.layer.shadowOpacity = 0.6;
}

@end
