//
//  UIColor+Zirkfied.h
//  ZFChartView
//
//  Created by apple on 16/2/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Zirkfied)

@property (nonatomic, assign, readonly) CGFloat red;
@property (nonatomic, assign, readonly) CGFloat green;
@property (nonatomic, assign, readonly) CGFloat blue;
@property (nonatomic, assign, readonly) CGFloat alpha;

/**
 *  将16进制字符串转换成UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)color;

/**
 *  将16进制字符串转换成UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
