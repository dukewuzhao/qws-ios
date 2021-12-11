//
//  G100RedDotButton.m
//  G100
//
//  Created by William on 16/7/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100RedDotButton.h"

@interface G100RedDotButton ()

@property (strong, nonatomic) UIImageView * redDotView;

@end

@implementation G100RedDotButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupUI];
    [self initData];
}

- (UIImageView *)redDotView {
    if (!_redDotView) {
        _redDotView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_main_red_dot"]];
    }
    return _redDotView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self initData];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
        [self initData];
    }
    return self;
}

- (void)initData {
    self.hasRedDot = NO;
}

- (void)setupUI {
    [self addSubview:self.redDotView];
    [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@10);
        make.top.equalTo(@2);
        make.right.equalTo(@-2);
    }];
}

- (void)setHasRedDot:(BOOL)hasRedDot {
    _hasRedDot = hasRedDot;
    self.redDotView.hidden = !hasRedDot;
}

@end
