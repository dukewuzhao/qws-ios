//
//  G100MenuHeaderView.m
//  G100
//
//  Created by William on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MenuHeaderView.h"
#import "UIImage+Effection.h"
#import <UIImageView+WebCache.h>
#import "G100UserDomain.h"
#import <SDWebImage/SDWebImageManager.h>

@interface G100MenuHeaderView ()

@property (strong, nonatomic) IBOutlet UIView *infoDisplayView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *broadsideWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomsideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelSideConstraint;

@end

@implementation G100MenuHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.broadsideWidthConstraint.constant = self.bottomsideConstraint.constant = 20 * (WIDTH/414.0);
    if (WIDTH<414) {
        self.labelSideConstraint.constant = 8;
    }
    self.infoDisplayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesutreClick)];
    [self.headerImageView addGestureRecognizer:tapGesture];
    self.v_height = 200;
    
    self.headerBackgroundImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
    
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = 6.0f;
}

+ (instancetype)loadMenuHeaderView {
    return [[[NSBundle mainBundle]loadNibNamed:@"G100MenuHeaderView" owner:self options:nil]lastObject];
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return width*0.7;
}

- (IBAction)menu_userRegister:(UIButton *)sender {
    if (self.userActionTap) {
        self.userActionTap(0);
    }
    
}

- (IBAction)menu_userLogin:(UIButton *)sender {
    if (self.userActionTap) {
        self.userActionTap(1);
    }
}

- (void)tapGesutreClick {
    if (_headerTapClick) {
        self.headerTapClick();
    }
}

- (void)setUserid:(NSString *)userid {
    _userid = userid;
    
    if (!IsLogin()) {
        self.user_loginBtn.hidden = NO;
        self.user_registerBtn.hidden = NO;
        
        self.userNameLabel.hidden = YES;
        self.userPhoneLabel.hidden = YES;
        
        self.headerImageView.image = [UIImage imageNamed:@"ic_default_male"];
        self.headerBackgroundImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
    }else {
        self.userNameLabel.hidden = NO;
        self.userPhoneLabel.hidden = NO;
        
        self.user_loginBtn.hidden = YES;
        self.user_registerBtn.hidden = YES;
        G100UserDomain *userInfo = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:userid];
        self.userNameLabel.text = userInfo.nick_name;
        self.userPhoneLabel.text = [NSString shieldImportantInfo:userInfo.phone_num];
        
        // 根据性别设置头像和背景
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:userInfo.icon] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.headerImageView.image = image;
                    self.headerBackgroundImageView.image = [image fx_defaultGaussianBlurImage];
                }else {
                    if ([userInfo.gender isEqualToString:@"1"]) {
                        self.headerImageView.image = [UIImage imageNamed:@"ic_default_male"];
                        self.headerBackgroundImageView.image = [[UIImage imageNamed:@"ic_default_male"] fx_defaultGaussianBlurImage];
                    }else {
                        self.headerImageView.image = [UIImage imageNamed:@"ic_default_female"];
                        self.headerBackgroundImageView.image = [[UIImage imageNamed:@"ic_default_female"] fx_defaultGaussianBlurImage];
                    }
                }
            });
        }];
    }
}

- (void)drawRect:(CGRect)rect {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 6);
    self.layer.shadowRadius = 6;
    self.layer.shadowOpacity = 0.6;
}

@end
