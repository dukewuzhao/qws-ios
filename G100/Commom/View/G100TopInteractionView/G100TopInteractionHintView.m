//
//  G100TopInteractionHintView.m
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import "G100TopInteractionHintView.h"

#define kMWSHintDefaultBackgroundColor [UIColor colorWithRed:255.0/255.0 green:153/255.0 blue:0.0 alpha:1.0]
#define kMWSHintTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kMWSHintTextFont [UIFont systemFontOfSize:14]

#define kMWSTBMargin 6
#define kMWSLRMargin 15
#define kMWSCloseBtnWidth 16
#define kMWSTextLabelWidth [UIScreen mainScreen].bounds.size.width-kMWSCloseBtnWidth-2*kMWSLRMargin

@interface G100TopInteractionHintView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation G100TopInteractionHintView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = kMWSHintDefaultBackgroundColor;
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = kMWSHintTextFont;
    self.textLabel.textColor = kMWSHintTextColor;
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTapped:)];
    [self addGestureRecognizer:tapGesture];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
}

- (void)tapGestureTapped:(UITapGestureRecognizer *)tapGesutre {
    NSLog(@"用户点击了hint视图");
    [UIView animateWithDuration:0.3 animations:^{
        CGRect oldRect = self.frame;
        oldRect.origin.y -= self.frame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = oldRect;
        }];
    } completion:^(BOOL finished) {
        if (self.didSelectedHintBlock) {
            self.didSelectedHintBlock();
        }
        
        [self removeFromSuperview];
    }];
}

- (void)closeBtnClick:(UIButton *)sender {
    NSLog(@"用户点击了关闭hint按钮");
    CGRect oldRect = self.frame;
    oldRect.origin.y -= self.frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = oldRect;
    } completion:^(BOOL finished) {
        if (self.closeHintBlock) {
            self.closeHintBlock();
        }
        
        [self removeFromSuperview];
    }];
}

- (CGFloat)mws_heightForHint:(NSString *)hint {
    CGSize size = [hint boundingRectWithSize:CGSizeMake(kMWSTextLabelWidth, 999)
                                     options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kMWSHintTextFont}
                                       context:nil].size;
    self.mws_height = (size.height + 2*kMWSTBMargin) > 30 ? (size.height + 2*kMWSTBMargin) : 30;
    return self.mws_height;
}

- (void)mws_showHint:(NSString *)hint animated:(BOOL)animated complete:(void (^)())complete {
    self.textLabel.text = hint;
    
    if (animated) {
        CGRect oldRect = self.frame;
        oldRect.origin.y += self.frame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = oldRect;
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }else {
        if (complete) {
            complete();
        }
    }
}

- (void)mws_dismissWithAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect oldRect = self.frame;
            oldRect.origin.y -= self.frame.size.height;
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = oldRect;
            }];
        } completion:^(BOOL finished) {
            if (self.closeHintBlock) {
                self.closeHintBlock();
            }
            
            [self removeFromSuperview];
        }];
    }else {
        if (self.closeHintBlock) {
            self.closeHintBlock();
        }
        
        [self removeFromSuperview];
    }
}

#pragma mark - 布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.closeBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-16-kMWSLRMargin,
                                     (CGRectGetHeight(self.frame)-16)/2.0,
                                     16,
                                     16);
    self.textLabel.frame = CGRectMake(kMWSLRMargin,
                                      kMWSTBMargin,
                                      kMWSTextLabelWidth,
                                      CGRectGetHeight(self.frame)-2*kMWSTBMargin);
}

@end
