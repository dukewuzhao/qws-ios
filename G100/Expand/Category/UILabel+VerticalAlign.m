//
//  UILabel+VerticalAlign.m
//  G100
//
//  Created by sunjingjing on 16/7/6.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "UILabel+VerticalAlign.h"

@implementation UILabel (VerticalAlign)

- (void)alignTop {
    NSDictionary *attributes = @{NSFontAttributeName:self.font};
    CGSize fontSize = [self.text sizeWithAttributes:attributes];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;
    //expected width of label
    CGRect theStringRect = [self.text boundingRectWithSize:CGSizeMake(finalWidth,finalHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    int newLinesToPad = (finalHeight  - theStringRect.size.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

- (void)alignBottom {
    NSDictionary *attributes = @{NSFontAttributeName:self.font};
    CGSize fontSize = [self.text sizeWithAttributes:attributes];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGRect theStringRect = [self.text boundingRectWithSize:CGSizeMake(finalWidth,finalHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    int newLinesToPad = (finalHeight  - theStringRect.size.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}

@end
