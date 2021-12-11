//
//  UILabel+CalHeight.m
//  G100
//
//  Created by 曹晓雨 on 2016/11/7.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "UILabel+CalHeight.h"

@implementation UILabel (CalHeight)

+ (CGFloat)heightWithText:(NSString *)text fontSize:(UIFont *)font Width:(CGFloat)width {
    CGSize size = CGSizeMake(width, 2000);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize expectedLabelSize = [text boundingRectWithSize:size
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:attributes
                                                  context:nil].size;
    
    return expectedLabelSize.height;
}

@end
