//
//  Tilink_BaseNavigationBarView.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "Tilink_BaseNavigationBarView.h"

@implementation Tilink_BaseNavigationBarView {
    UIButton *_leftBarButton;
    UIButton *_rightBarButton;
    UILabel  *_titleLabel;
    CGFloat _titleWidth;
}

#pragma mark - initial method
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setupShadowView];
    }
    return self;
}

- (void)setupView {
    _leftBarButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _leftBarButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_leftBarButton setTintColor:[UIColor whiteColor]];
    [_leftBarButton setTitle:@"返回" forState:UIControlStateNormal];
    [_leftBarButton setExclusiveTouch:YES];
    [self addSubview:_leftBarButton];
    
    _rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarButton.frame = CGRectMake(WIDTH - 60, kNavigationBarHeight - 42, 60, 36);
    _rightBarButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_rightBarButton setContentEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 15)];
    [_rightBarButton setExclusiveTouch:YES];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.minimumScaleFactor = 0.8;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    self.backgroundColor = [UIColor blackColor];
}

- (void)setupShadowView {
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 2;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat sw = CGRectGetWidth(self.frame);
    CGFloat sh = CGRectGetHeight(self.frame);
    
    CGSize leftBtnTitleSize = [_leftBarButton.titleLabel.text calculateSize:CGSizeMake(sw, 24) font:[UIFont systemFontOfSize:14]];
    CGFloat leftBtnTitleW = leftBtnTitleSize.width + 2 > 70 ? 70 : leftBtnTitleSize.width + 2;
    _leftBarButton.frame = CGRectMake(0, sh - 42, leftBtnTitleW + 5 + 10 + 20, 36);
    [_leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(8, 20, 8, leftBtnTitleW + 5 + 20)];
    [_leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(8, -5 , 8, 0)];
    
    CGFloat titleLabelMaxW = (sw - (leftBtnTitleW + 5 + 10 + 20 + 15 + 20));
    CGSize titleLabelSize = [_titleLabel.text calculateSize:CGSizeMake(titleLabelMaxW, 36) font:[UIFont boldSystemFontOfSize:17]];
    _titleLabel.frame = CGRectMake(0, sh - 42, _titleWidth ? : titleLabelSize.width, 36);
    _titleLabel.v_centerX = self.v_centerX;
}

#pragma mark - lazy method
- (UIButton *)leftBarButton {
    return _leftBarButton;
}

- (UIButton *)rightBarButton {
    return _rightBarButton;
}

#pragma mark - public method
- (UILabel *)navigationBarTitleLabel {
    return _titleLabel;
}

- (void)setNavigationTitleLabelText:(NSString *)string {
    if (string.length > 0) {
        _titleLabel.text = string;
    } else{
        _titleLabel.text = @"";
    }
    
    [self layoutSubviews];
}

- (void)setNavigationBackGroundColor:(UIColor *)color {
    self.backgroundColor = color;
}

- (void)setRightBarButton:(UIButton *)button {
    if (button.frame.size.width == 0) {
        button.frame = _rightBarButton.frame;
    }else {
        // 根据传过来的button 的frame 加上偏移
        button.v_width   += 10;
        button.v_height  += 10;
        button.v_right   = _rightBarButton.v_right;
        button.v_centerY = _rightBarButton.v_centerY;
    }
    
    button.titleLabel.font = _rightBarButton.titleLabel.font;
    button.contentEdgeInsets = _rightBarButton.contentEdgeInsets;
    [self addSubview:button];
    
    [button setExclusiveTouch:YES];
    _rightBarButton = button;
    
    _rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)setNavigationTitleLabelAlpha:(CGFloat)alpha {
    _titleLabel.alpha = alpha;
}

- (void)setNavigationTitleLabelWidth:(CGFloat)width {
    _titleWidth = width;
    
    // 修复iOS 10 上显示位置错误的问题
    CGFloat sw = CGRectGetWidth(self.frame);
    CGFloat sh = CGRectGetHeight(self.frame);
    
    CGSize leftBtnTitleSize = [_leftBarButton.titleLabel.text calculateSize:CGSizeMake(sw, 24) font:[UIFont systemFontOfSize:14]];
    CGFloat leftBtnTitleW = leftBtnTitleSize.width + 2 > 70 ? 70 : leftBtnTitleSize.width + 2;
    _leftBarButton.frame = CGRectMake(0, sh - 42, leftBtnTitleW + 5 + 10 + 20, 36);
    [_leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(8, 20, 8, leftBtnTitleW + 5 + 20)];
    [_leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(8, -5 , 8, 0)];
    
    _titleLabel.frame = CGRectMake(0, sh - 42, _titleWidth ? : (sw - (leftBtnTitleW + 5 + 10 + 20 + 15 + 20))/2.0, 36);
    _titleLabel.v_centerX = self.v_centerX;
}

@end
