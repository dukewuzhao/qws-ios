//
//  NSString+CalHeight.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/16.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CalHeight)

+ (CGFloat)heightWithText:(NSString *)text fontSize:(UIFont *)font Width:(CGFloat)width;

@end
