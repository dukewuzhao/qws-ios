//
//  G100TopHintView.m
//  G100
//
//  Created by 曹晓雨 on 2017/4/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100TopHintView.h"
#import "NSString+CalHeight.h"

@interface G100TopHintView ()

@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation G100TopHintView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUpData];
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithDefaultHintText{
    self = [super init];
    if (self) {
        self.hintText = @"抱歉，你没有权限操作，如要更改请通知主用户更改";
        [self setUpData];
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    self.hintLabel.text = self.hintText;
    [self addSubview:self.hintLabel];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(0);
        make.trailing.equalTo(0);
        make.top.equalTo(0);
        make.bottom.equalTo(0);
    }];
    
    self.hintLabel.userInteractionEnabled = NO;
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction)];
    [self addGestureRecognizer:tap];
}

- (void)setUpData{
    self.backgroundColor =  self.viewBackgroudColor = [UIColor colorWithHexString:@"ff6c00"];
    self.labelTextColor = [UIColor whiteColor];
    self.lableTextFont = [UIFont systemFontOfSize:14];
}

- (CGFloat)getHeightOfTopHintView{
    CGFloat height = [NSString heightWithText:self.hintText fontSize:self.lableTextFont Width:WIDTH];
    return height > 20 ? height : 20;
}

- (void)tapGestureAction{
    if ([self.delegate respondsToSelector:@selector(topViewClicked)]) {
        [self.delegate topViewClicked];
    }
}

- (UILabel *)hintLabel{
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc]init];
        _hintLabel.textColor = self.labelTextColor;
        _hintLabel.backgroundColor = self.viewBackgroudColor;
        _hintLabel.font = self.lableTextFont;
        _hintLabel.numberOfLines = 0;
    }
    return _hintLabel;
}
- (void)setViewBackgroudColor:(UIColor *)viewBackgroudColor{
    _viewBackgroudColor = viewBackgroudColor;
    self.backgroundColor = viewBackgroudColor;
    self.hintLabel.backgroundColor = viewBackgroudColor;
}

- (void)setLableTextFont:(UIFont *)lableTextFont{
    _lableTextFont = lableTextFont;
    self.hintLabel.font = lableTextFont;
}
- (void)setLabelTextColor:(UIColor *)labelTextColor{
    _labelTextColor = labelTextColor;
    self.hintLabel.textColor = labelTextColor;
}
- (void)setHintText:(NSString *)hintText{
    _hintText = hintText;
    self.hintLabel.text = hintText;
}

@end
