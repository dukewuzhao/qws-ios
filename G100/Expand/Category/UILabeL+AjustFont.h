//
//  UILabeL+AjustFont.h
//  G100
//
//  Created by 曹晓雨 on 2016/10/28.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (AjustFont)

#define IS_IPHONE_4s ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5s ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0f)

#define IPHONE4_INCREMENT 3
#define IPHONE5_INCREMENT 6
#define IPHONE6_INCREMENT 2
#define IPHONE6PLUS_INCREMENT 1

/**
 弃用
 */
- (UIFont *)adjustFont:(UIFont *)font multiple:(CGFloat)multiple;

/**
 @param font 无label 根据自定义font进行适配
 @param multiple newfont = 默认缩小font的数值 *  multiple (不改变默认缩小值 传1)
 @return
 */
+ (UIFont *)adjustFontWithFont:(UIFont *)font multiple:(CGFloat)multiple;
/**
 @param label  根据屏幕尺寸自适应一个label文字大小
 @param multiple newfont = 默认缩小font的数值 *  multiple (不改变默认缩小值 传1)
 @return
 */
+ (UIFont *)adjustFontWithLabel:(UILabel *)label multiple:(CGFloat)multiple;


/**
 根据屏幕尺寸自适应一个View上所有label文字大小

 @param adjustview 需要自适应尺寸label的父view
 @param multiple  newfont = 默认缩小font的数值 *  multiple (不改变默认缩小值 传1)
 */
+ (void)adjustAllLabel:(UIView *)adjustview multiple:(CGFloat)multiple;

@end
