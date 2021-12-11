//
//  UILabeL+AjustFont.m
//  G100
//
//  Created by 曹晓雨 on 2016/10/28.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "UILabeL+AjustFont.h"

@implementation UILabel (AjustFont)

- (UIFont *)adjustFont:(UIFont *)font multiple:(CGFloat)multiple
{
    UIFont *newFont=nil;
    if (IS_IPHONE_4s){
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize-IPHONE4_INCREMENT *multiple];
    }else if (IS_IPHONE_6){
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize-IPHONE6_INCREMENT *multiple];
    }
    else if (IS_IPHONE_5s)
    {
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize-IPHONE5_INCREMENT *multiple];
    }
    else{
        newFont = font;
    }
    return newFont;
}
+ (UIFont *)adjustFontWithFont:(UIFont *)font multiple:(CGFloat)multiple
{
    UIFont *newFont=nil;
    if (IS_IPHONE_4s){
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize-IPHONE4_INCREMENT *multiple];
    }else if (IS_IPHONE_6){
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize-IPHONE6_INCREMENT *multiple];
    }
    else if (IS_IPHONE_5s)
    {
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize-IPHONE5_INCREMENT *multiple];
    }
    else{
        newFont = font;
    }
    return newFont;
}
+ (UIFont *)adjustFontWithLabel:(UILabel *)label multiple:(CGFloat)multiple
{
    UIFont *newFont=nil;
    if (IS_IPHONE_4s){
        newFont = [UIFont fontWithName:label.font.fontName size:label.font.pointSize-IPHONE4_INCREMENT *multiple];
    }else if (IS_IPHONE_6){
        newFont = [UIFont fontWithName:label.font.fontName size:label.font.pointSize-IPHONE6_INCREMENT *multiple];
    }
    else if (IS_IPHONE_5s)
    {
        newFont = [UIFont fontWithName:label.font.fontName size:label.font.pointSize-IPHONE5_INCREMENT *multiple];
    }
    else{
        newFont = label.font;
    }
    return newFont;
}

+ (void)adjustAllLabel:(UIView *)adjustview multiple:(CGFloat)multiple
{
    for (UIView *view in adjustview.subviews) {
        if ([view.class isSubclassOfClass:[UILabel class]]) {
            ((UILabel *)view).font =  [UILabel adjustFontWithLabel:(UILabel *)view multiple:multiple];
        }
        if ([view.class isSubclassOfClass:[UIView class]]) {
            [[self class] adjustAllLabel:view multiple:multiple];
        }
        if ([view.class isSubclassOfClass:[UIImageView class]]) {
            [[self class] adjustAllLabel:view multiple:multiple];
        }
    }
}

@end
