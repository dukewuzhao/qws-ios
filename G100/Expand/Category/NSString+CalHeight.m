//
//  NSString+CalHeight.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/16.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "NSString+CalHeight.h"

@implementation NSString (CalHeight)

+ (CGFloat)heightWithText:(NSString *)text fontSize:(UIFont *)font Width:(CGFloat)width {
    CGSize size = CGSizeMake(width, 2000);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle.copy };
    
    CGSize expectedLabelSize = [text boundingRectWithSize:size
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:attributes
                                                  context:nil].size;
    
    return expectedLabelSize.height + 6;
}

@end
