//
//  G100BatteryAnimateView.m
//  Demobase
//
//  Created by sunjingjing on 16/12/9.
//  Copyright © 2016年 sunjingjing. All rights reserved.
//

#import "G100BatteryAnimateView.h"

@implementation G100BatteryAnimateView
{
    CGRect fullRect;
    CGRect scaleRect;
    CGRect waveRect;
    
    CGFloat currentLinePointY;
    CGFloat targetLinePointY;
    CGFloat amplitude;//振幅
    
    CGFloat currentPercent;//当前百分比，用于保存第一次显示时的动画效果
    
    CGFloat a;
    CGFloat b;
    
    BOOL increase;
    BOOL isFirst;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        fullRect = frame;
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    a = 1.5;
    b = 0;
    increase = NO;
    _backWaterColor = [UIColor colorWithRed:0.0/255.0 green:183.0/255.0 blue:190.0/255.0 alpha:1.00];
    _frontWaterColor = [UIColor colorWithRed:0.0/255.0 green:204.0/255 blue:193.0/255 alpha:1.0];
    _waterBgColor = [UIColor colorWithRed:193.0/255.0 green:193.0/255 blue:194.0/255 alpha:1.0];
    _percent = 0.45;
   // [self initDrawingRects];
    
    [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
}

- (void)initDrawingRects
{

    waveRect = fullRect;
    currentLinePointY = waveRect.size.height;
    targetLinePointY = waveRect.size.height * (1 - _percent);
    amplitude = (waveRect.size.height / 320.0) * 10;
    [self setNeedsDisplay];
}

// 覆盖drawRect方法，你可以在此自定义绘画和动画
- (void)drawRect:(CGRect)rect
{
    if (!isFirst) {
        fullRect = rect;
        waveRect = fullRect;
        currentLinePointY = waveRect.size.height;
        targetLinePointY = waveRect.size.height * (1 - _percent);
        amplitude = (waveRect.size.height / 320.0) * 10;
        isFirst = YES;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    //[self drawBackground:context];
    if (self.percent > 0.2) {
        [self drawWave:context];
    }else{
        [self drawWaveLowEle:context];
    }
    //[self drawLabel:context];
    
}

/**
 *  画波浪
 *
 *  @param context 全局context
 */
- (void)drawWave:(CGContextRef)context {
    
    CGMutablePathRef frontPath = CGPathCreateMutable();
    CGMutablePathRef backPath = CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_frontWaterColor CGColor]);
    float frontY = currentLinePointY;
    float backY = currentLinePointY;
    
    CGFloat radius = waveRect.size.width / 2;
    
    CGPoint frontStartPoint = CGPointMake(0, currentLinePointY);
    CGPoint frontEndPoint = CGPointMake(0, currentLinePointY );
    
    CGPoint backStartPoint = CGPointMake(0, currentLinePointY);
    CGPoint backEndPoint = CGPointMake(0, currentLinePointY);
    
    for(float x = 0; x <= waveRect.size.width; x++){
        
        //前浪绘制
        frontY = a * sin( x / 180 * M_PI + 4 * b / M_PI ) * amplitude + currentLinePointY;
        
        CGFloat frontCircleY = frontY;
        if (currentLinePointY < radius) {
            frontCircleY = radius - sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (frontY < frontCircleY) {
                frontY = frontCircleY;
            }
        } else if (currentLinePointY > radius) {
            frontCircleY = radius + sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (frontY > frontCircleY) {
                frontY = frontCircleY;
            }
        }
        
        if (fabs(0 - x) < 0.001) {
            frontStartPoint = CGPointMake(x , frontY );
            CGPathMoveToPoint(frontPath, NULL, frontStartPoint.x, frontStartPoint.y);
        }
        
        frontEndPoint = CGPointMake(x, frontY);
        CGPathAddLineToPoint(frontPath, nil, frontEndPoint.x, frontEndPoint.y);
        
        //后波浪绘制
        backY = a * cos( x / 180 * M_PI + 3 * b / M_PI ) * amplitude + currentLinePointY;
        CGFloat backCircleY = backY;
        if (currentLinePointY < radius) {
            backCircleY = radius - sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (backY < backCircleY) {
                backY = backCircleY;
            }
        } else if (currentLinePointY > radius) {
            backCircleY = radius + sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (backY > backCircleY) {
                backY = backCircleY;
            }
        }
        
        if (fabs(0 - x) < 0.001) {
            backStartPoint = CGPointMake(x , backY);
            CGPathMoveToPoint(backPath, NULL, backStartPoint.x, backStartPoint.y);
        }
        
        backEndPoint = CGPointMake(x, backY);
        CGPathAddLineToPoint(backPath, nil, backEndPoint.x, backEndPoint.y);
    }
    
    CGPoint centerPoint = CGPointMake(fullRect.size.width / 2, fullRect.size.height / 2);
    
    //绘制前浪圆弧
    CGFloat frontStart = [self calculateRotateDegree:centerPoint point:frontStartPoint];
    CGFloat frontEnd = [self calculateRotateDegree:centerPoint point:frontEndPoint];
    
    CGPathAddArc(frontPath, nil, centerPoint.x, centerPoint.y, waveRect.size.width / 2, frontEnd, frontStart, 0);
    CGContextAddPath(context, frontPath);
    CGContextFillPath(context);
    //推入
    CGContextSaveGState(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(frontPath);
    
    //绘制后浪圆弧
    CGFloat backStart = [self calculateRotateDegree:centerPoint point:backStartPoint];
    CGFloat backEnd = [self calculateRotateDegree:centerPoint point:backEndPoint];
    CGPathAddArc(backPath, nil, centerPoint.x, centerPoint.y, waveRect.size.width / 2, backEnd, backStart, 0);
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextAddPath(context, backPath);
    CGContextFillPath(context);
    //推入
    CGContextSaveGState(context);
    CGContextDrawPath(context, kCGPathStroke);
    
    UIBezierPath *gPath = [UIBezierPath bezierPathWithCGPath:backPath];
    [gPath fill];
    CGContextSaveGState(context);
    [gPath addClip];
     CGPathRelease(backPath);
     CGGradientRef myGradient;
     CGColorSpaceRef myColorspace;
     size_t num_locations = 2;
     CGFloat locations[2] = { 0.0, 1.0 };
     CGFloat components[8] = { 0.0, 255.0/255.0,228.0/255.0, 1.0,  // Start color
         0.0, 183.0/255.0, 190.0/255.0, 1 }; // End color
     
     myColorspace = CGColorSpaceCreateDeviceRGB();
     myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
     CGContextDrawLinearGradient(context, myGradient, CGPointMake(0.0f,currentLinePointY), CGPointMake(0.0f,waveRect.size.height),kCGGradientDrawsBeforeStartLocation);
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    CGContextRestoreGState(context);
}

/**
 *  画波浪
 *
 *  @param context 全局context
 */
- (void)drawWaveLowEle:(CGContextRef)context {
    
    CGMutablePathRef frontPath = CGPathCreateMutable();
    CGMutablePathRef backPath = CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_frontWaterColor CGColor]);
    float frontY = currentLinePointY;
    float backY = currentLinePointY;
    
    CGFloat radius = waveRect.size.width / 2;
    
    CGPoint frontStartPoint = CGPointMake(0, currentLinePointY);
    CGPoint frontEndPoint = CGPointMake(0, currentLinePointY );
    
    CGPoint backStartPoint = CGPointMake(0, currentLinePointY);
    CGPoint backEndPoint = CGPointMake(0, currentLinePointY);
    
    for(float x = 0; x <= waveRect.size.width; x++){
        
        //前浪绘制
        frontY = a * sin( x / 180 * M_PI + 4 * b / M_PI ) * amplitude + currentLinePointY;
        
        CGFloat frontCircleY = frontY;
        if (currentLinePointY < radius) {
            frontCircleY = radius - sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (frontY < frontCircleY) {
                frontY = frontCircleY;
            }
        } else if (currentLinePointY > radius) {
            frontCircleY = radius + sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (frontY > frontCircleY) {
                frontY = frontCircleY;
            }
        }
        
        if (fabs(0 - x) < 0.001) {
            frontStartPoint = CGPointMake(x , frontY );
            CGPathMoveToPoint(frontPath, NULL, frontStartPoint.x, frontStartPoint.y);
        }
        
        frontEndPoint = CGPointMake(x, frontY);
        CGPathAddLineToPoint(frontPath, nil, frontEndPoint.x, frontEndPoint.y);
        
        //后波浪绘制
        backY = a * cos( x / 180 * M_PI + 3 * b / M_PI ) * amplitude + currentLinePointY;
        CGFloat backCircleY = backY;
        if (currentLinePointY < radius) {
            backCircleY = radius - sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (backY < backCircleY) {
                backY = backCircleY;
            }
        } else if (currentLinePointY > radius) {
            backCircleY = radius + sqrt(pow(radius, 2) - pow((radius - x), 2));
            if (backY > backCircleY) {
                backY = backCircleY;
            }
        }
        
        if (fabs(0 - x) < 0.001) {
            backStartPoint = CGPointMake(x , backY);
            CGPathMoveToPoint(backPath, NULL, backStartPoint.x, backStartPoint.y);
        }
        
        backEndPoint = CGPointMake(x, backY);
        CGPathAddLineToPoint(backPath, nil, backEndPoint.x, backEndPoint.y);
    }
    
    CGPoint centerPoint = CGPointMake(fullRect.size.width / 2, fullRect.size.height / 2);
    
    //绘制前浪圆弧
    CGFloat frontStart = [self calculateRotateDegree:centerPoint point:frontStartPoint];
    CGFloat frontEnd = [self calculateRotateDegree:centerPoint point:frontEndPoint];
    
    CGPathAddArc(frontPath, nil, centerPoint.x, centerPoint.y, waveRect.size.width / 2, frontEnd, frontStart, 0);
    CGContextAddPath(context, frontPath);
    CGContextFillPath(context);
    //推入
    CGContextSaveGState(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(frontPath);
    
    //绘制后浪圆弧
    CGFloat backStart = [self calculateRotateDegree:centerPoint point:backStartPoint];
    CGFloat backEnd = [self calculateRotateDegree:centerPoint point:backEndPoint];
    CGPathAddArc(backPath, nil, centerPoint.x, centerPoint.y, waveRect.size.width / 2, backEnd, backStart, 0);
    CGContextSetFillColorWithColor(context, [_backWaterColor CGColor]);
    CGContextAddPath(context, backPath);
    CGContextFillPath(context);
    //推入
    CGContextSaveGState(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
}

/**
 *  画背景界面
 *
 *  @param context 全局context
 */
- (void)drawBackground:(CGContextRef)context {
    
    //画背景圆
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_waterBgColor CGColor]);
    CGPoint centerPoint = CGPointMake(fullRect.size.width / 2, fullRect.size.height / 2);
    CGPathAddArc(path, nil, centerPoint.x, centerPoint.y, waveRect.size.width / 2, 0, 2 * M_PI, 0);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
}

- (void)drawLabel:(CGContextRef)context {
    
    NSMutableAttributedString *attriButedText = [self formatBatteryLevel:_percent * 100];
    CGRect textSize = [attriButedText boundingRectWithSize:CGSizeMake(400, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    NSMutableAttributedString *attriLabelText = [self formatLabel:@"当前电量"];
    CGRect labelSize = [attriLabelText boundingRectWithSize:CGSizeMake(400, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGPoint textPoint = CGPointMake(fullRect.size.width / 2 - textSize.size.width / 2, fullRect.size.height / 2 - textSize.size.height / 2 - labelSize.size.height / 2);
    CGPoint labelPoint = CGPointMake(fullRect.size.width / 2 - labelSize.size.width / 2, textPoint.y + textSize.size.height);
    
    [attriButedText drawAtPoint:textPoint];
    [attriLabelText drawAtPoint:labelPoint];
    
    //推入
    CGContextSaveGState(context);
}

/**
 *  实时调用产生波浪的动画效果
 */
-(void)animateWave
{
    if (targetLinePointY == self.frame.size.height ||
        currentLinePointY == 0) {
        return;
    }
    
    if (targetLinePointY < currentLinePointY) {
        currentLinePointY -= 1;
        currentPercent = (waveRect.size.height - currentLinePointY) / waveRect.size.height;
    }
    if (targetLinePointY > currentLinePointY) {
        currentLinePointY += 1;
        currentPercent = (waveRect.size.height - currentLinePointY) / waveRect.size.height;
    }
    if (increase) {
        a += 0.01;
    } else {
        a -= 0.01;
    }
    
    
    if (a <= 1) {
        increase = YES;
    }
    
    if (a >= 1.5) {
        increase = NO;
    }
    
    b += 0.1;
    
    [self setNeedsDisplay];
}

/**
 * Core Graphics rotation in context
 */
- (void)rotateContext:(CGContextRef)context fromCenter:(CGPoint)center_ withAngle:(CGFloat)angle
{
    CGContextTranslateCTM(context, center_.x, center_.y);
    CGContextRotateCTM(context, angle);
    CGContextTranslateCTM(context, -center_.x, -center_.y);
}

/**
 *  根据圆心点和圆上一个点计算角度
 *
 *  @param centerPoint 圆心点
 *  @param point       圆上的一个点
 *
 *  @return 角度
 */
- (CGFloat)calculateRotateDegree:(CGPoint)centerPoint point:(CGPoint)point {
    
    CGFloat rotateDegree = asin(fabs(point.y - centerPoint.y) / (sqrt(pow(point.x - centerPoint.x, 2) + pow(point.y - centerPoint.y, 2))));
    
    //如果point纵坐标大于原点centerPoint纵坐标(在第一和第二象限)
    if (point.y > centerPoint.y) {
        //第一象限
        if (point.x >= centerPoint.x) {
            rotateDegree = rotateDegree;
        }
        //第二象限
        else {
            rotateDegree = M_PI - rotateDegree;
        }
    } else //第三和第四象限
    {
        if (point.x <= centerPoint.x) //第三象限，不做任何处理
        {
            rotateDegree = M_PI + rotateDegree;
        }
        else //第四象限
        {
            rotateDegree = 2 * M_PI - rotateDegree;
        }
    }
    return rotateDegree;
}

/**
 *  格式化电量的Label的字体
 *
 *  @param percent 百分比
 *
 *  @return 电量百分比文字参数
 */
-(NSMutableAttributedString *) formatBatteryLevel:(NSInteger)percent
{
    UIColor *textColor = [UIColor whiteColor];
    NSMutableAttributedString *attrText;
    
    NSString *percentText=[NSString stringWithFormat:@"%ld %%",(long)percent];
    
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    
    NSShadow *shadowText = [[NSShadow alloc] init];
    shadowText.shadowOffset = CGSizeMake(2.0, 2.0);
    shadowText.shadowColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255 blue:0.0/255 alpha:0.3];
    shadowText.shadowBlurRadius = 2.0f;
    if (percent<10) {
        attrText=[[NSMutableAttributedString alloc] initWithString:percentText];
        UIFont *capacityNumberFont=[UIFont fontWithName:@"Helvetica-BoldOblique" size:60];
        UIFont *capacityPercentFont=[UIFont fontWithName:@"Helvetica-BoldOblique" size:30];
        [attrText addAttribute:NSFontAttributeName value:capacityNumberFont range:NSMakeRange(0, 1)];
        [attrText addAttribute:NSFontAttributeName value:capacityPercentFont range:NSMakeRange(2, 1)];
        [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, 3)];
        [attrText  addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, 3)];
        
    } else {
        attrText=[[NSMutableAttributedString alloc] initWithString:percentText];
        UIFont *capacityNumberFont=[UIFont fontWithName:@"Helvetica-BoldOblique" size:60];
        UIFont *capacityPercentFont=[UIFont fontWithName:@"Helvetica-BoldOblique" size:30];
        
        
        if (percent>=100) {
            
            [attrText addAttribute:NSFontAttributeName value:capacityNumberFont range:NSMakeRange(0, 3)];
            [attrText addAttribute:NSFontAttributeName value:capacityPercentFont range:NSMakeRange(4, 1)];
            [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, 5)];
            [attrText addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, 5)];
        } else {
            [attrText addAttribute:NSFontAttributeName value:capacityNumberFont range:NSMakeRange(0, 2)];
            [attrText addAttribute:NSFontAttributeName value:capacityPercentFont range:NSMakeRange(3, 1)];
            [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, 4)];
            [attrText  addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, 4)];
            [attrText addAttribute:NSShadowAttributeName value:shadowText range:NSMakeRange(0, 4)];
        }
        
    }
    
    
    return attrText;
}

/**
 *  显示信息Label参数
 *
 *  @param text 显示的文字
 *
 *  @return 相关参数
 */
-(NSMutableAttributedString *) formatLabel:(NSString*)text
{
    UIColor *textColor = [UIColor whiteColor];
    NSMutableAttributedString *attrText;
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    attrText=[[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
    [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, text.length)];
    [attrText  addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, text.length)];
    
    return attrText;
}

#pragma mark - Setter

- (void)setPercent:(CGFloat)percent {
    _percent = percent;
    currentPercent = percent;
    targetLinePointY = waveRect.size.height * (1 - _percent);
    [self initDrawingRects];
}

- (void)setWaterBgColor:(UIColor *)waterBgColor {
    _waterBgColor = waterBgColor;
    [self initDrawingRects];
}

- (void)setFrontWaterColor:(UIColor *)frontWaterColor {
    _frontWaterColor = frontWaterColor;
    [self initDrawingRects];
}

- (void)setBackWaterColor:(UIColor *)backWaterColor {
    _backWaterColor = backWaterColor;
    [self initDrawingRects];
}

- (void)setIsCharging:(BOOL)isCharging{
    _isCharging = isCharging;
    if (isCharging) {
        amplitude = (waveRect.size.height / 320.0) * 10;
    }else{
        amplitude = (waveRect.size.height / 320.0) * 5;
    }
}
//    //使用rgb颜色空间
//    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();

//    /*指定渐变色
//     space:颜色空间
//     components:颜色数组,注意由于指定了RGB颜色空间，那么四个数组元素表示一个颜色（red、green、blue、alpha），
//     如果有三个颜色则这个数组有4*3个元素
//     locations:颜色所在位置（范围0~1），这个数组的个数不小于components中存放颜色的个数
//     count:渐变个数，等于locations的个数
//     */
//    CGFloat compoents[12]={
//        248.0/255.0,86.0/255.0,86.0/255.0,1,
//        249.0/255.0,127.0/255.0,127.0/255.0,1,
//        1.0,1.0,1.0,1.0
//    };
//    CGFloat locations[3]={0,0.3,1.0};
//    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, compoents, locations, 3);
//
//    /*绘制径向渐变
//     context:图形上下文
//     gradient:渐变色
//     startCenter:起始点位置
//     startRadius:起始半径（通常为0，否则在此半径范围内容无任何填充）
//     endCenter:终点位置（通常和起始点相同，否则会有偏移）
//     endRadius:终点半径（也就是渐变的扩散长度）
//     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，但是到结束位置之后不再绘制，
//     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，但到结束点之后继续填充
//     */
//    CGContextDrawRadialGradient(context, gradient, CGPointMake(waveRect.size.width/2, waveRect.size.height/2),0, CGPointMake(waveRect.size.width/2,  waveRect.size.height/2),  waveRect.size.height/2, kCGGradientDrawsAfterEndLocation);
//    //释放颜色空间
//    CGColorSpaceRelease(colorSpace);
@end
