//
//  UIColor+G100Color.h
//  G100
//
//  Created by yuhanle on 15/7/2.
//  Copyright (c) 2015年 tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (G100Color)

/**
 返回随机颜色
 */
+ (instancetype)randColor;

/**
 *  将16进制字符串转换成UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)color;

/**
 *  将16进制字符串转换成UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
