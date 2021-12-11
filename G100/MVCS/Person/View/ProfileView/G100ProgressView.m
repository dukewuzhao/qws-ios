//
//  G100ProgressView.m
//  G100
//
//  Created by yuhanle on 16/4/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ProgressView.h"

#define kProgressDefaultColor  @"FFB600"
#define KProgressDeafaltColor2 [UIColor colorWithRed:0.54 green:0.90 blue:0.56 alpha:1.00]
#define kProgressDefaultHeight 5

@interface G100ProgressView ()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation G100ProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    CGRect frame = self.frame;
    self.backgroundColor = [UIColor clearColor];
    frame.size.height = kProgressDefaultHeight;
    self.frame = frame;
    
    _progressView = [[UIView alloc] init];
    // 默认的进读条颜色
//    _progressView.backgroundColor = [UIColor colorWithHexString:kProgressDefaultColor];
    _progressView.backgroundColor = KProgressDeafaltColor2;
    [self addSubview:_progressView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width = _progress * self.bounds.size.width;
    _progressView.frame = frame;
}

- (void)setColorHexStr:(NSString *)colorHexStr {
    _colorHexStr = colorHexStr;
    _progressView.backgroundColor = [UIColor colorWithHexString:colorHexStr];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    CGRect frame = _progressView.frame;
    frame.size.width = self.frame.size.width*progress;
    [UIView animateWithDuration:0.3f animations:^{
        _progressView.frame = frame;
    }];
}

@end
