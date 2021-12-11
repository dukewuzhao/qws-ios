//
//  BindWaitingView.m
//  G100
//
//  Created by 温世波 on 15/11/17.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "BindWaitingView.h"
#import "G100AnimationHud.h"

#import "G100ThemeInfoDoamin.h"
#import <UIImageView+WebCache.h>

@interface BindWaitingView ()

@property (assign, nonatomic) BOOL isWaiting;
@property (weak, nonatomic) IBOutlet UILabel *waitingTitleLabel;
@property (weak, nonatomic) IBOutlet G100AnimationHud *hudView;

@property (weak, nonatomic) IBOutlet UILabel *devLocatorNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *brandLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *devModelNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *channelLogoImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *devModelNameLabelCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brandLogoImageViewConstraintW;

@end

@implementation BindWaitingView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = KEY_WINDOW.bounds;
    self.devLocatorNameLabel.numberOfLines = 0;
    self.topViewConstraintHeight.constant = kNavigationBarHeight;
}

+ (instancetype)bindWaitingView {
    BindWaitingView * waitingView = [[[NSBundle mainBundle] loadNibNamed:@"BindWaitingView" owner:self options:nil] lastObject];
    waitingView.isWaiting = NO;
    waitingView.waitingTitleLabel.hidden = YES;
    waitingView.devLocatorNameLabel.hidden = YES;
    waitingView.brandLogoImageView.hidden = YES;
    waitingView.devModelNameLabel.hidden = YES;
    waitingView.channelLogoImageView.hidden = YES;
    return waitingView;
}

- (void)setWaitingTitle:(NSString *)waitingTitle {
    _waitingTitle = waitingTitle.copy;
    [self.waitingTitleLabel setText:waitingTitle];
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    [self showInView:view animation:animation];
}

- (void)showInView:(UIView *)view animation:(BOOL)animation {
    if (![self superview]) {
        [view addSubview:self];
        self.isWaiting = YES;
    }
    
    G100AnimationHud * hud = [G100AnimationHud animationHud];
    hud.hintText = @"努力绑定中...";
    [hud showInView:self animation:YES];
    
    self.hudView = hud;
}

- (void)dismissWithAnimation:(BOOL)animation {
    [self.hudView stopAnimation];
    
    [super dismissWithVc:self.popVc animation:animation];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

#pragma mark - 设置显示信息
- (void)setBindResult:(G100DevBindResultDomain *)bindResult {
    self.waitingTitleLabel.hidden = NO;
    if (bindResult.locatorname.length) {
        self.devLocatorNameLabel.hidden = NO;
        self.devLocatorNameLabel.text = bindResult.locatorname;
    }
    
    self.brandLogoImageView.hidden = NO;
    self.devModelNameLabel.hidden = NO;
    self.channelLogoImageView.hidden = NO;
    
    __block CGFloat totoalW = 0; // name和logo的总宽度
    if (bindResult.pic_big.length) {
        [self.channelLogoImageView sd_setImageWithURL:[NSURL URLWithString:bindResult.pic_big] placeholderImage:[UIImage imageNamed:@""]];
    }else {
        self.channelLogoImageView.hidden = YES;
    }
    
    if (bindResult.logo_small.length) {
        self.brandLogoImageView.hidden = NO;
        self.devModelNameLabelCenterX.constant = 0;

        [self.brandLogoImageView sd_setImageWithURL:[NSURL URLWithString:bindResult.logo_small] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                UIImage * brandLogoImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:bindResult.logo_small];
                
                if (brandLogoImage) {
                    CGFloat w = brandLogoImage.size.width * 24.0 / brandLogoImage.size.height;
                    self.brandLogoImageViewConstraintW.constant = w;
                    totoalW += w;
                }
                
            }else {
                self.brandLogoImageView.hidden = YES;
                self.devModelNameLabelCenterX.constant = 0;
            }
            
            if (bindResult.model.length) {
                self.devModelNameLabel.hidden = NO;
                self.devModelNameLabel.text = bindResult.model;
                
                if (bindResult.logo_small.length) {
                    totoalW ? totoalW += 10 : 0;
                    
                    // 计算label的宽度
                    CGSize labelSize = [bindResult.model calculateSize:CGSizeMake(1000, 18) font:[UIFont systemFontOfSize:15]];
                    totoalW += labelSize.width + 1;
                    self.devModelNameLabelCenterX.constant = totoalW / 2.0 - (labelSize.width + 1) / 2.0;
                }else {
                    self.devModelNameLabelCenterX.constant = 0;
                }
            }else {
                self.devModelNameLabel.text = @"";
                self.devModelNameLabel.hidden = YES;
                self.devModelNameLabelCenterX.constant = totoalW / 2.0 + 10;
            }
        }];
    }else {
        self.brandLogoImageView.hidden = YES;
        self.devModelNameLabelCenterX.constant = 0;
    }
    
    if (bindResult.model.length) {
        self.devModelNameLabel.hidden = NO;
        self.devModelNameLabel.text = bindResult.model;
        
        if (bindResult.logo_small.length) {
            totoalW ? totoalW += 10 : 0;
            
            // 计算label的宽度
            CGSize labelSize = [bindResult.model calculateSize:CGSizeMake(1000, 18) font:[UIFont systemFontOfSize:15]];
            totoalW += labelSize.width + 1;
            self.devModelNameLabelCenterX.constant = totoalW / 2.0 - (labelSize.width + 1) / 2.0;
        }else {
            self.devModelNameLabelCenterX.constant = 0;
        }
    }else {
        self.devModelNameLabel.text = @"";
        self.devModelNameLabel.hidden = YES;
        self.devModelNameLabelCenterX.constant = totoalW / 2.0 + 10;
    }
}

- (void)stopAnimation {
    [self.hudView stopAnimation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
