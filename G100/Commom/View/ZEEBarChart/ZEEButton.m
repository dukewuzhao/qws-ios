//
//  ZEEButton.m
//  ZFChartView
//
//  Created by yuhanle on 2016/12/12.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZEEButton.h"
#import "UIColor+Zirkfied.h"


@interface ZEEButton ()

@property (nonatomic, strong) UIView *bgView;

@end

@implementation ZEEButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 15.0;
    
    self.bgView = [[UIView alloc] init];
    self.bgView.frame = self.bounds;
    self.bgView.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.3];
    [self insertSubview:self.bgView atIndex:0];
    
    self.bgView.hidden = YES;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.titleLabel.font = _selectedFont ? : [UIFont boldSystemFontOfSize:14];
        self.bgView.hidden = NO;
    }else {
        self.titleLabel.font = _normalFont ? : [UIFont systemFontOfSize:14];
        self.bgView.hidden = YES;
    }
}

@end
