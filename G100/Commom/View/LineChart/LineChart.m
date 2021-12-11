//
//  LineChart.m
//  lineChartDemo
//
//  Created by 曹晓雨 on 2017/8/16.
//  Copyright © 2017年 曹晓雨. All rights reserved.
//

#import "LineChart.h"
@interface LineChart ()
@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat scaleX;
//layer
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *lineLayerArray;//线图层
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *fillLayerArray;//填充图层
//@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *nomarlPointLayerArray;//普通点图层 //暂无
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *highSpeedPointLayerArray;//超速图层
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *lowSpeedPointLayerArray;//低俗点图层

//path
@property (nonatomic, strong) NSMutableArray <UIBezierPath *> *linePathArray;//线数组
//@property (nonatomic, strong) NSMutableArray <UIBezierPath *> *normalPointPathArray;//普通点 //暂无
@property (nonatomic, strong) NSMutableArray <UIBezierPath *> *highSpeedPathArray;//超速点
@property (nonatomic, strong) NSMutableArray <UIBezierPath *> *lowSpeedPathArray;//低俗点

//indicate Line
@property (nonatomic, strong) UIView *horizonLine;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *curveValueLabel;
@property (nonatomic, strong) UIView *indicatePoint;
@end
@implementation LineChart
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UILongPressGestureRecognizer *longPGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGestureRecognizerHandle:)];
        [longPGR setMinimumPressDuration:0.3f];
        [longPGR setAllowableMovement:frame.size.width - self.chartMarginLeft - self.chartMarginBottom];
        [self addGestureRecognizer:longPGR];
    }
    return self;
}

- (void)setChartDatas:(NSMutableArray<LineChartData *> *)chartDatas{
    if (chartDatas != _chartDatas) {
        _chartDatas =chartDatas;
        [self computeMaxYandMinY];
        [self drawXLabelsAndYLabels];
        [self initLayers];
    }
    
}
- (void)strokeChart{
    _linePathArray = @[].mutableCopy;
    _highSpeedPathArray = @[].mutableCopy;
    _lowSpeedPathArray = @[].mutableCopy;
    [self calculateBezierPathsForChart];
    for (int i = 0; i < _lineLayerArray.count; i ++) {
        _lineLayerArray[i].path = _linePathArray[i].CGPath;
        if (self.displayAnimated) {
            
        }
    }
    for (int i = 0; i < _highSpeedPointLayerArray.count; i ++) {
        _highSpeedPointLayerArray[i].path = _highSpeedPathArray[i].CGPath;
        if (self.displayAnimated) {
            
        }
    }
    for (int i = 0; i < _lowSpeedPointLayerArray.count; i ++) {
        _lowSpeedPointLayerArray[i].path = _lowSpeedPathArray[i].CGPath;
    }
    
    //在第一个数据上添加默认定点
//    [self drawIndicatesWith:CGPointMake(0, 0)];
}

- (void)updateChartWithChartData:(NSMutableArray<LineChartData *> *)chartData{
    
}

- (void)drawRect:(CGRect)rect{
    
    CGFloat vMargin = (rect.size.height - self.chartMarginTop - self.chartMarginBottom) / self.stepCount;
    CGFloat hMargin = (rect.size.width - self.chartMarginLeft - self.chartMarginRight)/ (self.stepCount - 1.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, self.axisWidth);
    CGContextSetStrokeColorWithColor(ctx, [self.axisColor CGColor]);
    
    CGContextMoveToPoint(ctx, self.chartMarginLeft, self.chartMarginTop + self.stepCount * vMargin);
    CGContextAddLineToPoint(ctx, rect.size.width - self.chartMarginRight, self.chartMarginTop + self.stepCount * vMargin);
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, self.chartMarginLeft , self.chartMarginTop);
    CGContextAddLineToPoint(ctx, self.chartMarginLeft, rect.size.height - self.chartMarginBottom);
    CGContextStrokePath(ctx);
    [super drawRect:rect];
}

#pragma mark - 横纵坐标值
- (void)drawXLabelsAndYLabels{
    //clear labels
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    [self drawXLabels];
    [self drawYLabels];
}

- (void)drawYLabels{
    CGFloat vMargin = (self.bounds.size.height - self.chartMarginTop - self.chartMarginBottom) / self.stepCount;
    
    NSString *leftY = [self formatYLabelWith:_maxY];
    CGRect leftRect = [self caculatRectWithString:leftY andFont:self.yLabelFont];
    UILabel *leftYLabel = [[UILabel alloc]initWithFrame:CGRectMake( 10, 5 , leftRect.size.width +self.yLabelWidthPadding, leftRect.size.height)];
    leftYLabel.text = leftY;
    leftYLabel.textAlignment = NSTextAlignmentCenter;
    leftYLabel.font = [UIFont boldSystemFontOfSize:12];
    leftYLabel.textColor = self.yLabelColor;
    [self addSubview:leftYLabel];
    
//    if (_maxY == _minY) {
//        CGFloat step = (_maxY * 2.0f)/self.stepCount;
//        for (int i = 0; i < self.stepCount + 1; i ++) {
//            NSString *leftY = [self formatYLabelWith:_maxY * 2.0f - i * step];
//            CGRect leftRect = [self caculatRectWithString:leftY andFont:self.yLabelFont];
//            UILabel *leftYLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.chartMarginLeft, self.chartMarginTop + i * vMargin - leftRect.size.height , leftRect.size.width +self.yLabelWidthPadding, leftRect.size.height)];
//            leftYLabel.text = leftY;
//            leftYLabel.textAlignment = NSTextAlignmentCenter;
//            leftYLabel.font = self.yLabelFont;
//            leftYLabel.textColor = self.yLabelColor;
//            [self addSubview:leftYLabel];
//
//        }
//    }else
//    {
//        CGFloat step = (_maxY - _minY)/self.stepCount;
//        for (int i = 0; i < self.stepCount + 1; i ++) {
//            NSString *leftY = [self formatYLabelWith:_maxY - i * step];
//            CGRect leftRect = [self caculatRectWithString:leftY andFont:self.yLabelFont];
//            UILabel *leftYLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.chartMarginLeft, self.chartMarginTop + i * vMargin - leftRect.size.height , leftRect.size.width + self.yLabelWidthPadding, leftRect.size.height)];
//            leftYLabel.text = leftY;
//            leftYLabel.textAlignment = NSTextAlignmentCenter;
//            leftYLabel.font = self.yLabelFont;
//            leftYLabel.textColor = self.yLabelColor;
//            [self addSubview:leftYLabel];
//        }
//    }
}

- (void)drawXLabels{
    //only show left and right
    
    NSString *rightX = [[[_chartDatas firstObject].sets firstObject].items lastObject].rawX;
    CGRect rightRect = [self caculatRectWithString:rightX andFont:self.xLabelFont];
    UILabel *rightXLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width - self.chartMarginRight - rightRect.size.width, self.bounds.size.height - self.chartMarginBottom, rightRect.size.width, rightRect.size.height+5)];
    rightXLabel.textColor = self.xLabelColor;
    rightXLabel.font = [UIFont boldSystemFontOfSize:12];
    rightXLabel.text = rightX;
    [self addSubview:rightXLabel];
}

#pragma mark - 画折线 加layer
- (void)initLayers{
    //clear layers
    for (CALayer *layer in self.lineLayerArray) {
        [layer removeFromSuperlayer];
    }
    for (CALayer *layer in self.fillLayerArray) {
        [layer removeFromSuperlayer];
    }
    for (CALayer *layer in self.highSpeedPointLayerArray) {
        [layer removeFromSuperlayer];
    }
    for (CALayer *layer in self.lowSpeedPointLayerArray) {
        [layer removeFromSuperlayer];
    }
    //init layers
    //    self.lineLayerArray = [NSMutableArray arrayWithCapacity:_chartDatas.count ];
    //    self.fillLayerArray = [NSMutableArray arrayWithCapacity:_chartDatas.count];
    self.lineLayerArray = [NSMutableArray array];
    self.fillLayerArray = [NSMutableArray array];
    self.highSpeedPointLayerArray = @[].mutableCopy;
    self.lowSpeedPointLayerArray = @[].mutableCopy;
    
    for (LineChartData *data in _chartDatas) {
        //line shapelayer
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.frame = self.bounds;
        lineLayer.lineCap = kCALineCapRound;
        lineLayer.lineJoin = kCALineJoinBevel;
        lineLayer.fillColor = nil;
        lineLayer.strokeColor = [data.lineColor CGColor];
        lineLayer.lineWidth = data.lineWidth;
        [self.layer addSublayer:lineLayer];
        [self.lineLayerArray addObject:lineLayer];
        
        
        //fillSharpLayer
        if (data.fillColor) {
            CAShapeLayer *fillLayer = [CAShapeLayer layer];
            fillLayer.frame = self.bounds;
            fillLayer.lineCap = kCALineCapRound;
            fillLayer.lineJoin = kCALineJoinBevel;
            fillLayer.fillColor = [data.fillColor CGColor];
            fillLayer.strokeColor = nil;
            [self.layer addSublayer:lineLayer];
            [self.fillLayerArray addObject:lineLayer];
        }
        for (ChartPointSet *set in data.sets) {
            if (set.type == LineChartPointSetTypeHighSpeed) {
                CAShapeLayer *fillLayer = [CAShapeLayer layer];
                fillLayer.frame = self.bounds;
                fillLayer.lineCap = kCALineCapRound;
                fillLayer.lineJoin = kCALineJoinBevel;
                fillLayer.fillColor = [set.buyPointColor CGColor];
                fillLayer.strokeColor = nil;
                [self.layer addSublayer:fillLayer];
                [self.highSpeedPointLayerArray addObject:fillLayer];
                
            }else if (set.type == LineChartPointSetTypeLowSpeed){
                CAShapeLayer *fillLayer = [CAShapeLayer layer];
                fillLayer.frame = self.bounds;
                fillLayer.lineCap = kCALineCapRound;
                fillLayer.lineJoin = kCALineJoinBevel;
                fillLayer.fillColor = [set.relocatePointColor CGColor];
                fillLayer.strokeColor = nil;
                [self.layer addSublayer:fillLayer];
                [self.lowSpeedPointLayerArray addObject:fillLayer];
                
            }
        }
        
    }
}


#pragma mark - 画折线 贝塞尔
- (void)calculateBezierPathsForChart{
    CGFloat height = self.bounds.size.height - self.chartMarginTop - self.chartMarginBottom;
    int i = 0;
    for (LineChartData *data in _chartDatas) {
        if (i == 0) { //正常画线
            i ++;
            for (ChartPointSet *set in data.sets) {
                if (set.type == LineChartPointSetTypeNone) {
                    UIBezierPath *path = [UIBezierPath bezierPath];
                    for (int i = 0; i < set.items.count; i ++) {
                        ChartPointItem *item = set.items[i];
                        item.x = self.chartMarginLeft + i * _scaleX;
                        item.y = _minY == _maxY ? height/2.0f + self.chartMarginTop : (_maxY - [item.rawY floatValue])*(height / (_maxY - _minY)) + self.chartMarginTop;
                        CGPoint point = CGPointMake(item.x, item.y);
                        if (i == 0) {
                            [path moveToPoint:point];
                        }else{
                            [path addLineToPoint:point];
                        }
                        
                        for (ChartPointSet *buySet in data.sets) {
                            if (buySet.type == LineChartPointSetTypeHighSpeed) {
                                for (ChartPointItem *buyItem in buySet.items) {
                                    if ([buyItem.rawX isEqualToString:item.rawX]) {
                                        buyItem.x = point.x;
                                        buyItem.y = point.y;
                                        UIBezierPath *buyPath = [UIBezierPath bezierPath];
                                        [buyPath addArcWithCenter:point radius:set.pointRadius startAngle:0.0f endAngle:M_PI *2.0f clockwise:YES];
                                        [_highSpeedPathArray addObject:buyPath];
                                    }
                                }
                            }else if (buySet.type == LineChartPointSetTypeLowSpeed){
                                for (ChartPointItem *relocateItem in buySet.items) {
                                    if ([relocateItem.rawX isEqualToString:item.rawX]) {
                                        relocateItem.x = point.x;
                                        relocateItem.y = point.y;
                                        UIBezierPath *relocatePath = [UIBezierPath bezierPath];
                                        [relocatePath addArcWithCenter:point radius:set.pointRadius startAngle:0.0f endAngle:M_PI *2.0f clockwise:YES];
                                        [_lowSpeedPathArray addObject:relocatePath];
                                    }
                                }
                            }
                        }
                    }
                    [_linePathArray addObject:path];
                }
            }
            
        }else{   //超速画线
            for (ChartPointSet *set in data.sets) {
                UIBezierPath *path = [UIBezierPath bezierPath];
                for (int i = 0; i < set.items.count; i ++) {
                    ChartPointItem *item = set.items[i];
                    item.x = self.chartMarginLeft + i * _scaleX;
                    item.y = _minY == _maxY ? height/2.0f + self.chartMarginTop : (_maxY - [item.rawY floatValue])*(height / (_maxY - _minY)) + self.chartMarginTop;
                    CGPoint point = CGPointMake(item.x, item.y);
                    if (i == 0) {
                        [path moveToPoint:point];
                    }else{
                        if (item.rawY.floatValue > self.maxSpeed) {
                            [path addLineToPoint:point];
                        }else{
                            [path moveToPoint:point];
                        }
                    }
                }
                [_linePathArray addObject:path];
            }
        }
    }
    
}

- (void)drawNormalPathWithItems:(NSMutableArray *)items WithScale:(CGFloat)scale{
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < items.count; i ++) {
        ChartPointItem *item = items[i];
        if (i == 0) {
            [path moveToPoint:CGPointMake(self.chartMarginLeft, (_maxY - [item.rawY floatValue])*scale)];
        }else{
            [path addLineToPoint:CGPointMake(self.chartMarginLeft + i * _scaleX, (_maxY - [item.rawY floatValue])*scale)];
        }
    }
    [_linePathArray addObject:path];
}

#pragma mark - 计算y轴最大 最小值
- (void)computeMaxYandMinY{
    _maxY = - MAXFLOAT;
    _minY = MAXFLOAT;
    
    LineChartData *data = _chartDatas[0];
    for (ChartPointSet *set in data.sets) {
        if (set.type == LineChartPointSetTypeNone) {
            _scaleX = (self.bounds.size.width - self.chartMarginLeft - self.chartMarginRight)/(set.items.count - 1.000f);
            for (ChartPointItem *item in set.items) {
                if ([item.rawY floatValue] >= _maxY) {
                    _maxY = [item.rawY floatValue];
                }
                if ([item.rawY floatValue] <= _minY) {
                    _minY = [item.rawY floatValue];
                }
            }
        }
    }
}

#pragma mark - 添加拖动手势
- (void)longGestureRecognizerHandle:(UILongPressGestureRecognizer*)longResture{
    if (longResture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [longResture locationInView:self];
        [self drawIndicatesWith:point];
    }else if (longResture.state == UIGestureRecognizerStateEnded){
        [_horizonLine removeFromSuperview];
        [_curveValueLabel removeFromSuperview];
        _horizonLine = nil;
        _curveValueLabel = nil;
        self.draggingComplete();
    }else if (longResture.state == UIGestureRecognizerStateBegan){
        [self.speedLabel removeFromSuperview];
        [self.timeLabel removeFromSuperview];
        self.speedLabel = nil;
        self.timeLabel = nil;
    }
}
- (void)moveLineWithPoint:(CGPoint)point{
    [self autoDrawIndicatesWith:point];
}
- (void)autoDrawIndicatesWith:(CGPoint )point{
    LineChartData *data = _chartDatas[0];
    for (ChartPointSet *set in data.sets) {
        if (set.type == LineChartPointSetTypeNone) {
            for (ChartPointItem *item in set.items) {
                if (item.x >= point.x - _scaleX/2.0f && item.x <= point.x + _scaleX/2.0f) {
                    NSLog(@"%f, %f",point.x, point.y);
                    self.verticalLine.frame = CGRectMake(item.x - 2.0f, self.chartMarginTop, 4.0f, self.bounds.size.height - self.chartMarginTop - self.chartMarginBottom);
                    self.indicatePoint.frame = CGRectMake(item.x - 3.0f, item.y - 3.0f, 6.0f, 6.0f);
                    if (item.x <= self.chartMarginLeft + 35.0f) {
                        self.speedLabel.frame = CGRectMake(self.chartMarginLeft, self.chartMarginTop - 15.0f, 70.0f, 15.0f);
                        self.timeLabel.frame = CGRectMake(self.chartMarginLeft,  self.frame.size.height -  self.chartMarginBottom + 5.0f, 70.0f, 15.0f);
                    }
                    else if (item.x >= self.bounds.size.width - 35.0f - self.chartMarginRight)
                    {
                        self.speedLabel.frame = CGRectMake(self.bounds.size.width - self.chartMarginRight - 70.0f, self.chartMarginTop - 15.0f, 70.0f, 15.0f);
                        self.timeLabel.frame = CGRectMake(self.bounds.size.width - self.chartMarginRight - 70.0f,  self.frame.size.height -  self.chartMarginBottom + 5.0f, 70.0f, 15.0f);
                    }else{
                        self.speedLabel.frame = CGRectMake(item.x - 35.0f, self.chartMarginTop - 15.0f, 70.0f, 15.0f);
                        self.timeLabel.frame = CGRectMake(item.x - 35.0f, self.frame.size.height -  self.chartMarginBottom + 5.0f, 70.0f, 15.0f);
                    }
                    _speedLabel.text = [self formatYLabelWith:[item.rawY floatValue]];
                    _timeLabel.text = item.rawX;
                    
                    _verticalLine.hidden = NO;
                    _indicatePoint.hidden = NO;
                    _speedLabel.hidden = NO;
                    _timeLabel.hidden = NO;
                    break;
                }
            }
        }
    }
}
#pragma mark - 添加拖动时 线和点
- (void)drawIndicatesWith:(CGPoint )point{
    LineChartData *data = _chartDatas[0];
    for (ChartPointSet *set in data.sets) {
        if (set.type == LineChartPointSetTypeNone) {
            int i = 0;
            for (ChartPointItem *item in set.items) {
                if (item.x >= point.x - _scaleX/2.0f && item.x <= point.x + _scaleX/2.0f) {
                    self.valueChanged(i);
                    NSLog(@"%f, %f,%d",item.x, item.y,i);
                    self.verticalLine.frame = CGRectMake(item.x - 2.0f, self.chartMarginTop, 4.0f, self.bounds.size.height - self.chartMarginTop - self.chartMarginBottom);
                    self.indicatePoint.frame = CGRectMake(item.x - 3.0f, item.y - 3.0f, 6.0f, 6.0f);
                    if (item.x <= self.chartMarginLeft + 35.0f) {
                        self.speedLabel.frame = CGRectMake(self.chartMarginLeft, self.chartMarginTop - 15.0f, 70.0f, 15.0f);
                        self.timeLabel.frame = CGRectMake(self.chartMarginLeft,  self.frame.size.height -  self.chartMarginBottom + 5.0f, 70.0f, 15.0f);
                    }
                    else if (item.x >= self.bounds.size.width - 35.0f - self.chartMarginRight)
                    {
                        self.speedLabel.frame = CGRectMake(self.bounds.size.width - self.chartMarginRight - 70.0f, self.chartMarginTop - 15.0f, 70.0f, 15.0f);
                        self.timeLabel.frame = CGRectMake(self.bounds.size.width - self.chartMarginRight - 70.0f,  self.frame.size.height -  self.chartMarginBottom + 5.0f, 70.0f, 15.0f);
                    }else{
                        self.speedLabel.frame = CGRectMake(item.x - 35.0f, self.chartMarginTop - 15.0f, 70.0f, 15.0f);
                        self.timeLabel.frame = CGRectMake(item.x - 35.0f, self.frame.size.height -  self.chartMarginBottom + 5.0f, 70.0f, 15.0f);
                    }
                    _speedLabel.text = [self formatYLabelWith:[item.rawY floatValue]];
                    _timeLabel.text = item.rawX;
                    
                    _verticalLine.hidden = NO;
                    _indicatePoint.hidden = NO;
                    _speedLabel.hidden = NO;
                    _timeLabel.hidden = NO;
                    break;
                }
                  i++;
            }
        }
    }
}


- (UIView *)horizonLine{
    if(!_horizonLine){
        _horizonLine = [[UIView alloc]initWithFrame:CGRectMake(self.chartMarginLeft, self.bounds.size.height/2.0f - 2.0f, self.bounds.size.width - self.chartMarginLeft - self.chartMarginRight, 4.0f)];
        _horizonLine.backgroundColor = [UIColor clearColor];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(0.0f,0.0f, self.bounds.size.width - self.chartMarginLeft - self.chartMarginRight, 4.0f);
        layer.strokeColor = self.xIndicateLineColor.CGColor;
        layer.lineWidth = self.xIndicateLineWidth;
        layer.lineDashPattern = @[@2.0f, @2.0f];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0.0f, 2.0f)];
        [path addLineToPoint:CGPointMake(_horizonLine.bounds.size.width, 2.0f)];
        layer.path = path.CGPath;
        [_horizonLine.layer addSublayer:layer];
        _horizonLine.hidden = YES;
        [self addSubview: _horizonLine];
    }
    return _horizonLine;
}

- (UIView *)verticalLine{
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width/2.0f - 2.0f, self.chartMarginTop, 4.0f, self.bounds.size.height - self.chartMarginTop - self.chartMarginBottom)];
        _verticalLine.backgroundColor = [UIColor clearColor];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(0.0f, 0.0f, 4.0f, self.bounds.size.height - self.chartMarginTop - self.chartMarginBottom);
        layer.strokeColor = self.yIndicateLineColor.CGColor;
        layer.lineWidth = self.yIndicateLineWidth;
//        layer.lineDashPattern = @[@2.0f, @2.0f];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(2.0f, 0.0f)];
        [path addLineToPoint:CGPointMake(2.0f, _verticalLine.bounds.size.height)];
        layer.path = path.CGPath;
        [_verticalLine.layer addSublayer:layer];
        _verticalLine.hidden = YES;
        [self addSubview:_verticalLine];
    }
    return _verticalLine;
}

- (UIView *)indicatePoint{
    if (!_indicatePoint) {
        _indicatePoint = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width/2.0f - 3.0f, self.bounds.size.height/2.0f - 3.0f, 6.0f, 6.0f)];
        _indicatePoint.backgroundColor = [UIColor clearColor];
        CAShapeLayer *indicatePointBackLayer = [CAShapeLayer layer];
        indicatePointBackLayer.frame = CGRectMake(0.0f, 0.0f, 6.0f, 6.0f);
        indicatePointBackLayer.fillColor= self.indicatePointBackColor.CGColor;
        UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(3.0f, 3.0f) radius:3.0f startAngle:0.0f endAngle:M_PI *2.0f clockwise:YES];
        indicatePointBackLayer.path = path1.CGPath;
        [_indicatePoint.layer addSublayer:indicatePointBackLayer];
        
        CAShapeLayer *indicatePointLayer = [CAShapeLayer layer];
        indicatePointLayer.frame = CGRectMake(0.0f, 0.0f, 6.0f, 6.0f);
        indicatePointLayer.fillColor= self.indicatePointColor.CGColor;
        UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(3.0f, 3.0f) radius:2.0f startAngle:0.0f endAngle:M_PI *2.0f clockwise:YES];
        indicatePointLayer.path = path2.CGPath;
        [_indicatePoint.layer addSublayer:indicatePointLayer];
        
        _indicatePoint.hidden = YES;
        [self addSubview:_indicatePoint];
        
    }
    return _indicatePoint;
}


- (UILabel *)speedLabel{
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc]init];
        _speedLabel.font = self.xIndicateLabelFont;
        _speedLabel.textColor = self.xIndicateLabelTextColor;
        _speedLabel.backgroundColor = self.xIndicateLabelBackgroundColor;
        _speedLabel.textAlignment =NSTextAlignmentCenter;
        _speedLabel.hidden = YES;
        [self addSubview:_speedLabel];
    }
    return _speedLabel;
}
- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = self.xIndicateLabelFont;
        _timeLabel.textColor = self.xIndicateLabelTextColor;
        _timeLabel.backgroundColor = self.xIndicateLabelBackgroundColor;
        _timeLabel.textAlignment =NSTextAlignmentCenter;
        _timeLabel.hidden = YES;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}
- (UILabel *)curveValueLabel{
    if (!_curveValueLabel) {
        _curveValueLabel = [[UILabel alloc]init];
        _curveValueLabel.font = self.yIndicateLabelFont;
        _curveValueLabel.textColor = self.yIndicateLabelTextColor;
        _curveValueLabel.backgroundColor = self.yIndicateLabelBackgroundColor;
        _curveValueLabel.textAlignment =NSTextAlignmentCenter;
        _curveValueLabel.hidden = YES;
        [self addSubview:_curveValueLabel];
    }
    return _curveValueLabel;
}

#pragma mark tools
- (CGRect )caculatRectWithString:(NSString *)string andFont:(UIFont *)font{
    return [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]
                                context:nil];
}

- (NSString *)formatYLabelWith:(CGFloat)value{
    if (self.signedValue) {
        if (value > 0) {
            return [NSString stringWithFormat:@"%.0f%@",value,self.yLabelSuffix];
            
        }else
        {
            return [NSString stringWithFormat:@"%.0f%@",value,self.yLabelSuffix];
        }
        
    }else
    {
        return [NSString stringWithFormat:@"%.0f%@",value,self.yLabelSuffix];
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
