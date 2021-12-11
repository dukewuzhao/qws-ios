//
//  G100StartPageView.m
//  G100
//
//  Created by 温世波 on 15/12/15.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100StartPageView.h"
#import "G100StartPageManager.h"
#import <UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <UMShare/UMShare.h>
//#import <UMAnalytics/MobClick.h>
@interface G100StartPageView () {
    NSTimer * _cutdownTimer;
    NSInteger _totalTime;
}

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainLabel;

@property (weak, nonatomic) IBOutlet UIButton *tapButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skipConstraintTop;

- (IBAction)skipButtonClick:(UIButton *)sender;
- (IBAction)tapButtonClick:(UIButton *)sender;

@end


@implementation G100StartPageView

+ (BOOL)canShowStartPageView {
    G100StartPageDomain * page = [[G100StartPageManager sharedInstance] loadStartPageDomain];
    if (!page) {
        return NO;
    }else {
        BOOL isInCache = [[SDWebImageManager sharedManager].imageCache diskImageExistsWithKey:page.picture];
        
        if (isInCache) {
            return YES;
        }else {
            // 如果不存在则下载，下次启动时使用
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:page.picture] options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
            }];
        }
    }
    
    return NO;
}

+ (instancetype)startPageView {
    G100StartPageView * page = [[[NSBundle mainBundle] loadNibNamed:@"G100StartPageView" owner:self options:nil] lastObject];
    [page.tapButton setBackgroundImage:CreateImageWithColor([UIColor colorWithHexString:@"000000" alpha:0.5])
                              forState:UIControlStateHighlighted];
    return page;
}

- (void)showInView:(UIView *)view animated:(BOOL)animated {
    if (!_page) {
        _page = [[G100StartPageManager sharedInstance] loadStartPageDomain];
    }
    
    if (_page.picture) {
        UIImage *startImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:_page.picture];
        
        if (startImage) {
            self.bgImageView.image = startImage;
        }else {
            [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:_page.picture]];
        }
    }
    
    // 存在跳转链接 则显示跳转事件
    if (_page.url.length) {
        self.tapButton.hidden = NO;
    }else {
        self.tapButton.hidden = YES;
    }
    
    self.skipConstraintTop.constant = kNavigationBarHeight - 40;
    
    if (!_cutdownTimer) {
        _cutdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(cutdownTimerEvent:) userInfo:nil repeats:YES];
    }
    
    _totalTime = _page.displaytime ? : 3.0;
    
    [self updateTimeRemainContentWithTime:_totalTime--];
    [view addSubview:self];
    
    // 友盟统计 广告页展示
    //[MobClick event:@"ad_show"];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated completeBlock:(void (^)(void (^)()))completeBlock {
    self.completeBlock = completeBlock;
    
    [self showInView:view animated:YES];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated completeBlock:(void (^)(void (^)()))completeBlock tappedBlock:(void (^)(G100StartPageDomain *))tappedBlock {
    self.completeBlock = completeBlock;
    self.tappedBlock = tappedBlock;
    
    [self showInView:view animated:YES];
}

- (void)cutdownTimerEvent:(NSTimer *)timer {
    
    [self updateTimeRemainContentWithTime:_totalTime--];
    
    if (_totalTime < 0) {
        if ([_cutdownTimer isValid]) {
            [_cutdownTimer invalidate];
            _cutdownTimer = nil;
        }
        
        // 计时结束
        [self dismissWithAnimated:YES];
    }
}

- (void)updateTimeRemainContentWithTime:(NSInteger)time {
    NSMutableAttributedString *timeRemainStr;
    NSString *status = [NSString stringWithFormat:@"%@s", @(time)];
    timeRemainStr = [[NSMutableAttributedString alloc] initWithString:status];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    [timeRemainStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                   NSParagraphStyleAttributeName:paragraph,
                                   NSForegroundColorAttributeName:RGBColor(15, 191, 15, 1)}
                           range:NSMakeRange(0, status.length - 1)];
    
    [timeRemainStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10],
                                   NSForegroundColorAttributeName:RGBColor(15, 191, 15, 1)}
                           range:NSMakeRange(status.length - 1, 1)];
    
    self.timeRemainLabel.attributedText = timeRemainStr;
}

- (void)dismissWithAnimated:(BOOL)animated {
    
    if ([_cutdownTimer isValid]) {
        [_cutdownTimer invalidate];
        _cutdownTimer = nil;
    }
    
    if ([self superview]) {
        
        if (_completeBlock) {
            __weak G100StartPageView * wself = self;
            self.completeBlock(^(){
                [wself removeFromSuperview];
            });
        }else {
            [self removeFromSuperview];
        }
    }
}

- (IBAction)skipButtonClick:(UIButton *)sender {
    [self dismissWithAnimated:YES];
}

- (IBAction)tapButtonClick:(UIButton *)sender {
    if (self.page.url.length) {
        [self dismissWithAnimated:NO];
        
        if (self.tappedBlock) {
            self.tappedBlock(self.page);
        }
        
        // 友盟统计 广告页点击量
        //[MobClick event:@"ad_click"];
    }
}

- (IBAction)tapButtonClickDown:(UIButton *)sender {
    [_cutdownTimer setFireDate:[NSDate distantFuture]];
}

- (IBAction)tapButtonClickCancel:(UIButton *)sender {
    [_cutdownTimer setFireDate:[NSDate distantPast]];
}

@end
