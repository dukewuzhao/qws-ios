//
//  UILabel+CalHeight.h
//  G100
//
//  Created by 曹晓雨 on 2016/11/7.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CalHeight)
+ (CGFloat)heightWithText:(NSString *)text fontSize:(UIFont*)font Width:(CGFloat)width;
@end
