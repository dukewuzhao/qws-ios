//
//  G100RTCollectionViewCell.m
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/28.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import "G100RTCollectionViewCell.h"
#import "G100ClickEffectView.h"

#define kBLEColor [UIColor colorWithRed:26/255.0 green:152/255.0 blue:252/255.0 alpha:1.0]
#define kGPRSColor [UIColor colorWithHexString:@"FFFFFF"]
#define kEmptyColor [UIColor colorWithHexString:@"F2F2F2"]

#define kBLEColor1 [UIColor colorWithRed:26/255.0 green:152/255.0 blue:252/255.0 alpha:1.0]
#define kGPRSColor1 [UIColor colorWithRed:53/255.0 green:179/255.0 blue:30/255.0 alpha:1.0]

static CGFloat image2ItemW = 108/295.0;
static CGFloat image2ItemT = 54/270.0;

@interface G100RTCollectionViewCell () <G100TapAnimationDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *ctImageView;
@property (nonatomic, strong) UILabel *ctTextLabel;

@property (nonatomic, strong) G100ClickEffectView *clickEffectView;

@end

@implementation G100RTCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.rtCustomBgImage = NO;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithRed:22/255.0 green:175/255.0 blue:0/255.0 alpha:1.0];
    
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.image = [UIImage imageNamed:@"ic_remote_bg_first"];
    [self.contentView addSubview:self.bgImageView];
    
    self.ctImageView = [[UIImageView alloc] init];
    self.ctImageView.image = [UIImage imageNamed:@"ic_rc_garrison"];
    [self.contentView addSubview:_ctImageView];
    
    self.ctTextLabel = [[UILabel alloc] init];
    self.ctTextLabel.font = [UIFont systemFontOfSize:12];
    self.ctTextLabel.textAlignment = NSTextAlignmentCenter;
    self.ctTextLabel.textColor = [UIColor colorWithHexString:@"909090"];
    self.ctTextLabel.text = @"设防";
    [self.contentView addSubview:_ctTextLabel];
    
    self.clickEffectView = [[G100ClickEffectView alloc] init];
    self.clickEffectView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.clickEffectView];
    
    self.clickEffectView.delegate = self;
    self.bgImageView.hidden = YES;
    self.rtEnabled = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat sw = CGRectGetWidth(self.frame);
    self.bgImageView.frame = self.bounds;
    self.ctImageView.frame = CGRectMake((sw-sw*image2ItemW)/2.0, sw*image2ItemT, sw*image2ItemW, sw*image2ItemW);
    self.ctTextLabel.frame = CGRectMake(0, self.ctImageView.frame.origin.y+self.ctImageView.frame.size.height, sw, 24);
    self.clickEffectView.frame = self.bounds;
    
    /** 2.2.1 版本 隐藏自定义渐变背景色
    self.bgImageView.hidden = !_rtCustomBgImage;
    
    if (self.rtCustomBgImage) {
        _emptyView.backgroundColor = [UIColor clearColor];
    }else {
        _emptyView.backgroundColor = kEmptyColor;
    }
     */
}

- (void)setStatus:(int)status {
    _status = status;
    
    if (status == 0) {
        self.backgroundColor = [UIColor lightGrayColor];
    }else if (status == 1) {
        self.backgroundColor = kBLEColor;
    }else if (status == 2) {
        self.backgroundColor = kGPRSColor;
    }
}

#pragma mark - G100TapAnimationDelegate
- (void)viewTouchedEndWithView:(UIView *)touchedView touchPoint:(CGPoint)point{
    if ([self.emptyView superview] || self.rtCommand.rt_empty) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(cellDidTapped:indexPath:)]) {
        [_delegate cellDidTapped:self indexPath:self.indexPath];
    }
}

- (void)setRtCommand:(G100RTCommandModel *)rtCommand {
    _rtCommand = rtCommand;
    self.status = rtCommand.rt_status;
    
    if (rtCommand.rt_empty) {
        if (![self.emptyView superview]) {
            self.ctImageView.hidden = YES;
            self.ctTextLabel.hidden = YES;
            
            self.emptyView.frame = self.bounds;
            [self addSubview:self.emptyView];
        }
    }else {
        if ([self.emptyView superview]) {
            [self.emptyView removeFromSuperview];
        }
        
        self.ctImageView.hidden = NO;
        self.ctTextLabel.hidden = NO;
        
        self.ctImageView.tintColor = [UIColor colorWithHexString:rtCommand.tintColorStr.length ? rtCommand.tintColorStr : @"00c2a3"];
        self.ctImageView.image = [UIImage imageNamed:rtCommand.rt_image];
        self.ctTextLabel.text = rtCommand.rt_title;
    }
    
    self.rtEnabled = rtCommand.rt_enable;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.backgroundColor = kEmptyColor;
    }
    return _emptyView;
}

- (void)setRtEnabled:(BOOL)rtEnabled {
    _rtEnabled = rtEnabled;
    
    [self.clickEffectView setEffect_enabled:rtEnabled];
}

- (void)setRtCustomBgImage:(BOOL)rtCustomBgImage {
    _rtCustomBgImage = rtCustomBgImage;
    
    /** 2.2.1 版本 隐藏自定义渐变背景色
    self.bgImageView.hidden = !rtCustomBgImage;
    
    if (rtCustomBgImage) {
        // 最后一排用other 的图片
        if (self.indexPath.row > self.totalCount-5) {
            self.bgImageView.image = [UIImage imageNamed:@"ic_remote_bg_other"];
        }else {
            self.bgImageView.image = [UIImage imageNamed:@"ic_remote_bg_first"];
        }
    }
     */
}

@end
