//
//  ZEEGenericChart.m
//  ZFChartView
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZEEGenericChart.h"
#import "ZFColor.h"


@implementation ZEEGenericChart

/**
 *  初始化变量
 */
- (void)commonInit{
    _isAnimated = YES;
    _isShadowForValueLabel = YES;
    _opacity = 1.f;
    _valueOnChartFont = [UIFont systemFontOfSize:10.f];
    _xLineNameLabelToXAxisLinePadding = 0.f;
    _valueLabelPattern = kPopoverLabelPatternPopover;
    _valueType = kValueTypeInteger;
    _isShowAxisLineValue = YES;
    _isShowAxisArrows = YES;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp{
    //标题Label
    self.topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, self.frame.size.width-60, TOPIC_HEIGHT)];
    self.topicLabel.font = [UIFont systemFontOfSize:17];
    self.topicLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.topicLabel];
    
    self.gradientBgView = [[UIImageView alloc] init];
    self.gradientBgView.frame = CGRectMake(0, TOPIC_HEIGHT+35, self.frame.size.width, self.frame.size.height);
    
    self.xTopDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, TOPIC_HEIGHT+15, self.frame.size.width-60, 20)];
    self.xTopDescLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.xTopDescLabel];
    
    self.leftGuideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftGuideBtn.frame = CGRectMake(0, 0, 11, 7);
    [self addSubview:self.leftGuideBtn];
}

#pragma mark - 重写setter,getter方法

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.topicLabel.frame = CGRectMake(30, CGRectGetMinY(self.topicLabel.frame), self.frame.size.width-60, CGRectGetHeight(self.topicLabel.frame));
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
}

- (void)scrollToLeft:(BOOL)animated {

}

- (void)scrollToRight:(BOOL)animated {
    
}

- (void)configSelectedBarAtGroupIndex:(NSInteger)idx {
    
}

@end
