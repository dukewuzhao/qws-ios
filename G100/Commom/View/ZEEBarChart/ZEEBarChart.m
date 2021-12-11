//
//  ZEEBarChart.m
//  ZFChartView
//
//  Created by apple on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ZEEBarChart.h"
#import "ZEEGenericAxis.h"
#import "NSString+Zirkfied.h"
#import "ZFMethod.h"
#import "UIColor+Zirkfied.h"

@interface ZEEBarChart() <ZEEGenericAxisDelegete>

/** 通用坐标轴图表 */
@property (nonatomic, strong) ZEEGenericAxis * genericAxis;
/** 存储柱状条的数组 */
@property (nonatomic, strong) NSMutableArray * barArray;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray * colorArray;
/** 存储popoverLaber数组 */
@property (nonatomic, strong) NSMutableArray * popoverLaberArray;
/** 存储value文本颜色的数组 */
@property (nonatomic, strong) NSMutableArray * valueTextColorArray;
/** 存储bar渐变色的数组 */
@property (nonatomic, strong) NSMutableArray * gradientColorArray;
/** 顶部数据的数组 */
@property (nonatomic, strong) NSMutableArray * topTitleArray;
/** bar宽度 */
@property (nonatomic, assign) CGFloat barWidth;
/** bar与bar之间的间距 */
@property (nonatomic, assign) CGFloat barPadding;
/** value文本颜色 */
@property (nonatomic, strong) UIColor * valueTextColor;

@end

@implementation ZEEBarChart

/**
 *  初始化变量
 */
- (void)commonInit{
    [super commonInit];

    _overMaxValueBarColor = ZFRed;
    _isShadow = YES;
    _barWidth = ZFAxisLineItemWidth;
    _barPadding = ZFAxisLinePaddingForBarLength;
    _valueTextColor = ZFBlack;
    self.valueOnChartFont = [UIFont systemFontOfSize:17];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self drawGenericChart];
    }
    
    return self;
}

#pragma mark - 坐标轴

/**
 *  画坐标轴
 */
- (void)drawGenericChart{
    self.genericAxis = [[ZEEGenericAxis alloc] initWithFrame:CGRectMake(30, 0, self.frame.size.width-60, self.frame.size.height)];
    self.genericAxis.aDelegate = self;
    [self.genericAxis hiddenYAxisLine];
    [self addSubview:self.genericAxis];
    
    // 设置图表背景透明 以显示图片背景
    self.genericAxis.backgroundColor = [UIColor clearColor];
    self.genericAxis.xAxisLine.backgroundColor = [UIColor clearColor];
    self.genericAxis.xAxisLine.axisColor = [UIColor clearColor];
    
    CGFloat yPos = self.genericAxis.yLineMaxValueYPos;
    CGFloat height = self.genericAxis.yLineMaxValueHeight;
    
    // 设置图表背景渐变图位置
    CGRect frame = CGRectMake(30, 0, self.frame.size.width-60, self.frame.size.height);
    frame.origin.y = yPos;
    frame.size.height = height+1;
    self.gradientBgView.frame = frame;
    
    [self insertSubview:self.gradientBgView atIndex:0];
    
    // 调整genericAxis 的位置
    CGRect genericAxisFrame = self.genericAxis.frame;
    genericAxisFrame.origin.y = yPos;
    self.genericAxis.frame = genericAxisFrame;
    
    // 设置左下角导向按钮位置
    CGRect btnFrame = self.leftGuideBtn.frame;
    
    btnFrame.origin.x = 15;
    btnFrame.origin.y = yPos + height + 20;
    
    self.leftGuideBtn.frame = btnFrame;
}

#pragma mark - 柱状条

/**
 *  画柱状条
 */
- (void)drawBar:(NSMutableArray *)valueArray{
    id subObject = valueArray.firstObject;
    if ([subObject isKindOfClass:[NSString class]]) {
        for (NSInteger i = 0; i < valueArray.count; i++) {
            CGFloat xPos = self.genericAxis.axisStartXPos + self.genericAxis.groupPadding + (_barWidth + self.genericAxis.groupPadding) * i;
            CGFloat yPos = 0;
            CGFloat width = _barWidth;
            CGFloat height = self.genericAxis.yLineMaxValueHeight;
            
            ZFBar * bar = [[ZFBar alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
            bar.groupIndex = 0;
            bar.barIndex = i;
            //当前数值超过y轴显示上限时，柱状改为红色
            if ([self.genericAxis.xLineValueArray[i] floatValue] / self.genericAxis.yLineMaxValue <= 1) {
                bar.percent = ([self.genericAxis.xLineValueArray[i] floatValue] - self.genericAxis.yLineMinValue) / (self.genericAxis.yLineMaxValue - self.genericAxis.yLineMinValue);
                bar.barColor = _colorArray.firstObject;
                
                bar.isOverrun = NO;
            }else{
                bar.percent = 1.f;
                bar.barColor = _overMaxValueBarColor;
                bar.isOverrun = YES;
            }
            bar.isShadow = _isShadow;
            bar.isAnimated = self.isAnimated;
            bar.opacity = self.opacity;
            bar.shadowColor = self.shadowColor;
            bar.gradientAttribute = _gradientColorArray ? _gradientColorArray[i] : nil;
            [bar strokePath];
            [self.barArray addObject:bar];
            [self.genericAxis addSubview:bar];
            
            [bar addTarget:self action:@selector(barAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }else if ([subObject isKindOfClass:[NSArray class]]){
        if ([[subObject firstObject] isKindOfClass:[NSString class]]) {
            //bar总数
            NSInteger count = [valueArray count] * [subObject count];
            for (NSInteger i = 0; i < count; i++) {
                //每组bar的下标
                NSInteger barIndex = i % [subObject count];
                //组下标
                NSInteger groupIndex = i / [subObject count];
                
                CGFloat xPos = self.genericAxis.axisStartXPos + self.genericAxis.groupPadding * (barIndex + 1) + self.genericAxis.groupWidth * barIndex + (_barWidth + _barPadding) * groupIndex;
                CGFloat yPos = 0;
                CGFloat width = _barWidth;
                CGFloat height = self.genericAxis.yLineMaxValueHeight;
                
                ZFBar * bar = [[ZFBar alloc] initWithFrame:CGRectMake(xPos, yPos, width, height)];
                bar.groupIndex = groupIndex;
                bar.barIndex = barIndex;
                //当前数值超过y轴显示上限时，柱状改为红色
                if ([valueArray[groupIndex][barIndex] floatValue] / self.genericAxis.yLineMaxValue <= 1) {
                    bar.percent = ([valueArray[groupIndex][barIndex] floatValue] - self.genericAxis.yLineMinValue) / (self.genericAxis.yLineMaxValue - self.genericAxis.yLineMinValue);
                    bar.barColor = _colorArray[groupIndex];
                    bar.isOverrun = NO;
                }else{
                    bar.percent = 1.f;
                    bar.barColor = _overMaxValueBarColor;
                    bar.isOverrun = YES;
                }
                bar.isShadow = _isShadow;
                bar.isAnimated = self.isAnimated;
                bar.opacity = self.opacity;
                bar.shadowColor = self.shadowColor;
                bar.gradientAttribute = _gradientColorArray ? _gradientColorArray[groupIndex] : nil;
                [bar strokePath];
                [self.barArray addObject:bar];
                [self.genericAxis addSubview:bar];
                
                [bar addTarget:self action:@selector(barAction:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

/**
 *  设置x轴valueLabel
 */
- (void)setValueLabelOnChart:(NSMutableArray *)valueArray{
    id subObject = valueArray.firstObject;
    if ([subObject isKindOfClass:[NSString class]]) {
        for (NSInteger i = 0; i < self.barArray.count; i++) {
            ZFBar * bar = self.barArray[i];
            //label的中心点
            CGRect rect = [self.genericAxis.xLineValueArray[i] stringWidthRectWithSize:CGSizeMake(_barWidth + _barPadding * 0.5, 30) font:self.valueOnChartFont];
            CGPoint label_center = CGPointMake(bar.center.x, bar.endYPos + rect.size.height/2.0);
            
            ZFLabel * popoverLabel = [[ZFLabel alloc] initWithFrame:CGRectMake(0, 0, _barWidth, rect.size.height + 10)];
            popoverLabel.text = self.topTitleArray[i];
            popoverLabel.font = self.valueOnChartFont;
            popoverLabel.center = label_center;
            popoverLabel.textColor = [UIColor whiteColor];
            popoverLabel.shadowColor = self.valueLabelShadowColor;
            popoverLabel.hidden = self.isShowAxisLineValue ? NO : YES;
            [popoverLabel setIsFadeInAnimation:YES];
            [self.popoverLaberArray addObject:popoverLabel];
            [self.genericAxis addSubview:popoverLabel];
            
            // 值==0 隐藏bar 上的显示值
            NSInteger value = [self.genericAxis.xLineValueArray[i] integerValue];
            popoverLabel.hidden = !value;
        }
        
    }else if ([subObject isKindOfClass:[NSArray class]]){
        if ([[subObject firstObject] isKindOfClass:[NSString class]]) {
            for (NSInteger i = 0; i < self.barArray.count; i++) {
                ZFBar * bar = self.barArray[i];
                NSInteger barIndex = i % [subObject count];
                NSInteger groupIndex = i / [subObject count];
                //label的中心点
                CGRect rect = [valueArray[groupIndex][barIndex] stringWidthRectWithSize:CGSizeMake(_barWidth + _barPadding * 0.5, 30) font:self.valueOnChartFont];
                CGPoint label_center = CGPointMake(bar.center.x, bar.endYPos + rect.size.height + 10);
                
                ZFLabel * popoverLabel = [[ZFLabel alloc] initWithFrame:CGRectMake(0, 0, _barWidth, rect.size.height/2.0)];
                popoverLabel.text = self.topTitleArray[i];
                popoverLabel.font = self.valueOnChartFont;
                popoverLabel.center = label_center;
                popoverLabel.textColor = [UIColor whiteColor];
                popoverLabel.shadowColor = self.valueLabelShadowColor;
                popoverLabel.hidden = self.isShowAxisLineValue ? NO : YES;
                [popoverLabel setIsFadeInAnimation:YES];
                [self.popoverLaberArray addObject:popoverLabel];
                [self.genericAxis addSubview:popoverLabel];
                
                // 值==0 隐藏bar 上的显示值
                NSInteger value = [self.genericAxis.xLineValueArray[i] integerValue];
                popoverLabel.hidden = !value;
            }
        }
    }
}

#pragma mark - 点击事件

/**
 *  bar点击事件
 *
 *  @param sender bar
 */
- (void)barAction:(ZFBar *)sender{
    if ([self.delegate respondsToSelector:@selector(barChart:didSelectBarAtGroupIndex:barIndex:bar:)]) {
        [self.delegate barChart:self didSelectBarAtGroupIndex:sender.groupIndex barIndex:sender.barIndex bar:sender];
        [self.genericAxis configSelectedBarAtGroupIndex:sender.barIndex];
        [self resetBar:sender popoverLabel:nil];
    }
}

#pragma mark - 重置Bar原始设置

- (void)resetBar:(ZFBar *)sender popoverLabel:(ZFPopoverLabel *)label{
    for (ZFBar * bar in self.barArray) {
        if (bar != sender) {
            bar.barColor = bar.isOverrun ? _overMaxValueBarColor : _colorArray[bar.groupIndex];
            bar.isAnimated = NO;
            bar.opacity = self.opacity;
            [bar strokePath];
            //复原
            bar.isAnimated = self.isAnimated;
        }
    }
    
    if (!self.isShowAxisLineValue) {
        for (ZFPopoverLabel * popoverLabel in self.popoverLaberArray) {
            if (popoverLabel != label) {
                popoverLabel.hidden = YES;
            }
        }
    }
}

#pragma mark - 清除控件

/**
 *  清除之前所有柱状条
 */
- (void)removeAllBar{
    [self.barArray removeAllObjects];
    NSArray * subviews = [NSArray arrayWithArray:self.genericAxis.subviews];
    for (UIView * view in subviews) {
        if ([view isKindOfClass:[ZFBar class]]) {
            [(ZFBar *)view removeFromSuperview];
        }
    }
}

/**
 *  清除柱状条上的Label
 */
- (void)removeLabelOnChart{
    [self.popoverLaberArray removeAllObjects];
    NSArray * subviews = [NSArray arrayWithArray:self.genericAxis.subviews];
    for (UIView * view in subviews) {
        if ([view isKindOfClass:[ZFLabel class]]) {
            [(ZFLabel *)view removeFromSuperview];
        }
    }
}

#pragma mark - public method

/**
 *  重绘
 */
- (void)strokePath{
    [self.colorArray removeAllObjects];
    [self.valueTextColorArray removeAllObjects];
    
    if ([self.dataSource respondsToSelector:@selector(valueArrayInGenericChart:)]) {
        self.genericAxis.xLineValueArray = [NSMutableArray arrayWithArray:[self.dataSource valueArrayInGenericChart:self]];
    }
    
    if ([self.dataSource respondsToSelector:@selector(nameArrayInGenericChart:)]) {
        self.genericAxis.xLineNameArray = [NSMutableArray arrayWithArray:[self.dataSource nameArrayInGenericChart:self]];
    }
    
    if ([self.delegate respondsToSelector:@selector(colorArrayInGenericChart:)]) {
        _colorArray = [NSMutableArray arrayWithArray:[self.dataSource colorArrayInGenericChart:self]];
    }else{
        _colorArray = [NSMutableArray arrayWithArray:[[ZFMethod shareInstance] cachedRandomColor:self.genericAxis.xLineValueArray]];
    }
    
    if (self.isResetAxisLineMaxValue) {
        if ([self.dataSource respondsToSelector:@selector(axisLineMaxValueInGenericChart:)]) {
            self.genericAxis.yLineMaxValue = [self.dataSource axisLineMaxValueInGenericChart:self];
        }else{
            NSLog(@"请返回一个最大值");
            return;
        }
    }else{
        self.genericAxis.yLineMaxValue = [[ZFMethod shareInstance] cachedMaxValue:self.genericAxis.xLineValueArray];
        
        if (self.genericAxis.yLineMaxValue == 0.f) {
            if ([self.dataSource respondsToSelector:@selector(axisLineMaxValueInGenericChart:)]) {
                self.genericAxis.yLineMaxValue = [self.dataSource axisLineMaxValueInGenericChart:self];
            }else{
                NSLog(@"当前所有数据的最大值为0, 请返回一个固定最大值, 否则没法绘画图表");
                return;
            }
        }
    }
    
    if (self.isResetAxisLineMinValue) {
        if ([self.dataSource respondsToSelector:@selector(axisLineMinValueInGenericChart:)]) {
            if ([self.dataSource axisLineMinValueInGenericChart:self] > [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray]) {
                self.genericAxis.yLineMinValue = [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray];
                
            }else{
                self.genericAxis.yLineMinValue = [self.dataSource axisLineMinValueInGenericChart:self];
            }

        }else{
            self.genericAxis.yLineMinValue = [[ZFMethod shareInstance] cachedMinValue:self.genericAxis.xLineValueArray];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(axisLineSectionCountInGenericChart:)]) {
        self.genericAxis.yLineSectionCount = [self.dataSource axisLineSectionCountInGenericChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(barWidthInBarChart:)]) {
        _barWidth = [self.delegate barWidthInBarChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(paddingForGroupsInBarChart:)]) {
        self.genericAxis.groupPadding = [self.delegate paddingForGroupsInBarChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(paddingForBarInBarChart:)]) {
        _barPadding = [self.delegate paddingForBarInBarChart:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(valueTextColorArrayInBarChart:)]) {
        id color = [self.delegate valueTextColorArrayInBarChart:self];
        id subObject = self.genericAxis.xLineValueArray.firstObject;
        if ([subObject isKindOfClass:[NSString class]]) {
            if ([color isKindOfClass:[UIColor class]]) {
                [self.valueTextColorArray addObject:color];
            }else if ([color isKindOfClass:[NSArray class]]){
                self.valueTextColorArray = [NSMutableArray arrayWithArray:color];
            }
            
        }else if ([subObject isKindOfClass:[NSArray class]]){
            if ([color isKindOfClass:[UIColor class]]) {
                for (NSInteger i = 0; i < self.genericAxis.xLineValueArray.count; i++) {
                    [self.valueTextColorArray addObject:color];
                }
                
            }else if ([color isKindOfClass:[NSArray class]]){
                self.valueTextColorArray = [NSMutableArray arrayWithArray:color];
            }
        }
        
    }else{
        id subObject = self.genericAxis.xLineValueArray.firstObject;
        if ([subObject isKindOfClass:[NSString class]]) {
            [self.valueTextColorArray addObject:_valueTextColor];
        }else if ([subObject isKindOfClass:[NSArray class]]){
            for (NSInteger i = 0; i < self.genericAxis.xLineValueArray.count; i++) {
                [self.valueTextColorArray addObject:_valueTextColor];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(gradientColorArrayInBarChart:)]) {
        _gradientColorArray = [NSMutableArray arrayWithArray:[self.delegate gradientColorArrayInBarChart:self]];
    }
    
    if ([self.delegate respondsToSelector:@selector(topTitleArrayInZEEBarChart:)]) {
        _topTitleArray = [NSMutableArray arrayWithArray:[self.delegate topTitleArrayInZEEBarChart:self]];
    }
    
    self.genericAxis.groupWidth = [self cachedGroupWidth:self.genericAxis.xLineValueArray];
    
    [self removeAllBar];
    [self removeLabelOnChart];
    self.genericAxis.xLineNameLabelToXAxisLinePadding = self.xLineNameLabelToXAxisLinePadding;
    self.genericAxis.isAnimated = self.isAnimated;
    self.genericAxis.isShowAxisArrows = self.isShowAxisArrows;
    self.genericAxis.valueType = self.valueType;
    [self.genericAxis strokePath];
    [self drawBar:self.genericAxis.xLineValueArray];
    [self setValueLabelOnChart:self.genericAxis.xLineValueArray];
    
    [self.genericAxis bringSubviewToFront:self.genericAxis.yAxisLine];
    [self.genericAxis bringSectionToFront];
    [self bringSubviewToFront:self.topicLabel];
    [self bringSubviewToFront:self.xTopDescLabel];
}

/**
 *  求每组宽度
 */
- (CGFloat)cachedGroupWidth:(NSMutableArray *)array{
    id subObject = array.firstObject;
    if ([subObject isKindOfClass:[NSArray class]]) {
        return array.count * _barWidth + (array.count - 1) * _barPadding;
    }
    
    return _barWidth;
}

- (void)scrollToRight:(BOOL)animated {
    CGPoint contentOffset = self.genericAxis.contentOffset;
    contentOffset.x = self.genericAxis.contentSize.width - self.genericAxis.bounds.size.width;
    [self.genericAxis setContentOffset:contentOffset animated:animated];
}

- (void)scrollToLeft:(BOOL)animated {
    CGPoint contentOffset = self.genericAxis.contentOffset;
    contentOffset.x = 0;
    [self.genericAxis setContentOffset:contentOffset animated:animated];;
}

- (void)configSelectedBarAtGroupIndex:(NSInteger)idx {
    [self.genericAxis configSelectedBarAtGroupIndex:idx];
}

#pragma mark - ZEEGenericAxisDelegete
- (void)axis:(ZEEGenericAxis *)axis selectedBarIdx:(NSInteger)barIdx {
    if ([self.delegate respondsToSelector:@selector(barChart:didSelectBarAtGroupIndex:barIndex:bar:)]) {
        ZFBar *bar = self.barArray[barIdx];
        [self.delegate barChart:self didSelectBarAtGroupIndex:bar.groupIndex barIndex:bar.barIndex bar:bar];
        [self resetBar:bar popoverLabel:nil];
    }
}

#pragma mark - 重写setter,getter方法

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.genericAxis.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setUnit:(NSString *)unit{
    self.genericAxis.unit = unit;
}

- (void)setUnitColor:(UIColor *)unitColor{
    self.genericAxis.unitColor = unitColor;
}

- (void)setAxisLineNameFont:(UIFont *)axisLineNameFont{
    self.genericAxis.xLineNameFont = axisLineNameFont;
}

- (void)setAxisLineNameNormalFont:(UIFont *)axisLineNameNormalFont {
    self.genericAxis.xLineNameNormalFont = axisLineNameNormalFont;
}

- (void)setAxisLineNameSelectedFont:(UIFont *)axisLineNameSelectedFont {
    self.genericAxis.xLineNameSelectedFont = axisLineNameSelectedFont;
}

- (void)setAxisLineValueFont:(UIFont *)axisLineValueFont{
    self.genericAxis.yLineValueFont = axisLineValueFont;
}

- (void)setAxisLineNameColor:(UIColor *)axisLineNameColor{
    self.genericAxis.xLineNameColor = axisLineNameColor;
}

- (void)setAxisLineValueColor:(UIColor *)axisLineValueColor{
    self.genericAxis.yLineValueColor = axisLineValueColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
}

- (void)setXAxisColor:(UIColor *)xAxisColor{
    self.genericAxis.xAxisColor = xAxisColor;
}

- (void)setYAxisColor:(UIColor *)yAxisColor{
    self.genericAxis.yAxisColor = yAxisColor;
}

- (void)setSeparateColor:(UIColor *)separateColor{
    self.genericAxis.separateColor = separateColor;
}

- (void)setIsShowXLineSeparate:(BOOL)isShowXLineSeparate{
    self.genericAxis.isShowXLineSeparate = isShowXLineSeparate;
}

- (void)setIsShowYLineSeparate:(BOOL)isShowYLineSeparate{
    self.genericAxis.isShowYLineSeparate = isShowYLineSeparate;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    self.genericAxis.contentOffset = contentOffset;
}

#pragma mark - 懒加载

- (NSMutableArray *)barArray{
    if (!_barArray) {
        _barArray = [NSMutableArray array];
    }
    return _barArray;
}

- (NSMutableArray *)popoverLaberArray{
    if (!_popoverLaberArray) {
        _popoverLaberArray = [NSMutableArray array];
    }
    return _popoverLaberArray;
}

- (NSMutableArray *)valueTextColorArray{
    if (!_valueTextColorArray) {
        _valueTextColorArray = [NSMutableArray array];
    }
    return _valueTextColorArray;
}

@end
