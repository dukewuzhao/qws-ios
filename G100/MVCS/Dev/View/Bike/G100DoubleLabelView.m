//
//  G100DoubleLabelView.m
//  G100
//
//  Created by yuhanle on 2016/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DoubleLabelView.h"

@interface G100DoubleLabelView ()

@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *viceLabel;

@end

@implementation G100DoubleLabelView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.mainFontSize = 17;
        self.viceFontSize = 12;
        
        [self setupView];
    }
    return self;
}

#pragma mark - Lazy Load
- (UILabel *)mainLabel {
    if (!_mainLabel) {
        _mainLabel = [[UILabel alloc] init];
        _mainLabel.font = [UIFont boldSystemFontOfSize:self.mainFontSize];
        _mainLabel.textColor = [UIColor whiteColor];
        _mainLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _mainLabel;
}

- (UILabel *)viceLabel {
    if (!_viceLabel) {
        _viceLabel = [[UILabel alloc] init];
        _viceLabel.font = [UIFont systemFontOfSize:self.viceFontSize];
        _viceLabel.textColor = [UIColor whiteColor];
        _viceLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _viceLabel;
}

#pragma mark - Setup View
- (void)setupView {
    self.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7];
    
    [self addSubview:self.mainLabel];
    [self addSubview:self.viceLabel];
    
    // Masonry 布局
    [self.mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(@-15);
        make.top.equalTo(@5);
    }];
    
    [self.viceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(@-15);
        make.bottom.equalTo(@-5);
    }];
    
    self.mainText = @"老婆大人的红色小牛";
    self.viceText = @"本车已绑定5台设备";
}

#pragma mark - Settet & Getter
- (void)setMainFontSize:(CGFloat)mainFontSize {
    _mainFontSize = mainFontSize;
    if (self.normalMainText) {
        self.mainLabel.font = [UIFont systemFontOfSize:mainFontSize];
    }else{
        self.mainLabel.font = [UIFont boldSystemFontOfSize:mainFontSize];
    }
}
    
- (void)setLeftTextAlignment:(BOOL)leftTextAlignment{
    _leftTextAlignment = leftTextAlignment;
    _mainLabel.textAlignment = self.leftTextAlignment ? NSTextAlignmentLeft : NSTextAlignmentCenter;
    _viceLabel.textAlignment = self.leftTextAlignment ? NSTextAlignmentLeft : NSTextAlignmentCenter;
}
    
- (void)setViceFontSize:(CGFloat)viceFontSize {
    _viceFontSize = viceFontSize;
    self.viceLabel.font = [UIFont systemFontOfSize:viceFontSize];
}

- (void)setMainText:(NSString *)mainText {
    _mainText = mainText;
    self.mainLabel.text = mainText;
}

- (void)setViceText:(NSString *)viceText {
    _viceText = viceText;
    self.viceLabel.text = viceText;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(8.0f, 8.0f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
