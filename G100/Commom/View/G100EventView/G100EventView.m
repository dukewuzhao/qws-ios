//
//  G100EventView.m
//  G100
//
//  Created by William on 16/2/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100EventView.h"
#import <UIImageView+WebCache.h>

@interface G100EventView ()

@property (weak, nonatomic) IBOutlet UIView *bottomHintView;

- (IBAction)dismissEventView:(UIButton *)sender;
- (IBAction)getEventDetail:(UIButton *)sender;

@end

@implementation G100EventView

+ (instancetype)loadXibEventViewWithEventDetailModel:(G100EventDetailDomain *)event {
    G100EventView *view = [[[NSBundle mainBundle] loadNibNamed:@"G100EventView_Poster" owner:self options:nil] lastObject];
    view.eventImageView.image = nil;
    view.event = event;
    view.containerView.alpha = 0.0;
    return view;
}

- (void)setEvent:(G100EventDetailDomain *)event {
    _event = event;
    
    if ([event.poster hasPrefix:@"http"]) {
        [self.eventImageView sd_setImageWithURL:[NSURL URLWithString:event.poster] placeholderImage:[[UIImage alloc] init]];
    }else {
        [self.eventImageView setImage:[UIImage imageNamed:event.poster]];
    }
    
    if (event.localtype == 1) {
        self.bottomHintView.hidden = NO;
    }else {
        self.bottomHintView.hidden = YES;
    }
}

#pragma mark - Over write
- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    self.frame = view.bounds;
    
    if (![self superview]) {
        [view addSubview:self];
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    [super dismissWithVc:vc animation:animation];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

#pragma mark - Public method
- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation completion:(void (^)(BOOL finished))completion {
    // 避免添加两次 动画执行两遍
    if ([self superview]) {
        return;
    }else {
        [self showInVc:vc view:view animation:animation];
    }
    
    if (animation) {
        CGRect orginFrame = self.containerView.frame;
        CGRect animateFrame = self.containerView.frame;
        
        animateFrame.origin.y = - animateFrame.size.height;
        self.containerView.frame = animateFrame;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.containerView.alpha = 1.0;
            self.containerView.frame = orginFrame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }else {
        if (completion) {
            completion(YES);
        }
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation completion:(void (^)(BOOL))completion {
    [self dismissWithVc:vc animation:YES];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (IBAction)dismissEventView:(UIButton *)sender {
    // 判断是否有活动图标展示 有的话缩放到右下角
    if (self.event.control.icon) {
        CGRect startRect = [self convertRect:self.eventImageView.frame fromView:self.containerView];
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:startRect];
        tmpImageView.image = self.eventImageView.image;
        
        [self removeAllSubviews];
        
        [self addSubview:tmpImageView];
        CGRect endRect = CGRectMake(WIDTH - 80, HEIGHT - 80, 51, 62);
        
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.6 animations:^{
            tmpImageView.frame = endRect;
            tmpImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [wself dismissWithVc:wself.popVc animation:YES];
            if (self.dismissBlock) {
                self.dismissBlock(self.event);
            }
        }];
    } else {
        [self dismissWithVc:self.popVc animation:YES];
        if (self.dismissBlock) {
            self.dismissBlock(self.event);
        }
    }
}

- (IBAction)getEventDetail:(UIButton *)sender {
    if (self.getDetailBlock) {
        self.getDetailBlock(self.event);
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

@end
