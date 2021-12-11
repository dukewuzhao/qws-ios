//
//  G100GarageBikeBottomView.m
//  G100
//
//  Created by yuhanle on 2017/3/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100GarageBikeBottomView.h"

@implementation G100GarageBikeBottomView

- (void)setResultWithResult:(NSString *)result unit:(NSString *)unit desc:(NSString *)desc {
    self.unitLabel.text = unit;
    self.desLabel.text = desc;
    self.resultLabel.text = result;
    
    // 设置结果 斜体
    CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
    UIFontDescriptor *font_desc = [UIFontDescriptor fontDescriptorWithName:self.resultLabel.font.fontName matrix:matrix];
    UIFont *font = [UIFont fontWithDescriptor:font_desc size:26];
    
    self.resultLabel.font = font;
    
    CGSize size = [self.resultLabel.text calculateSize:CGSizeMake(100, 26) font:font];
    self.resultConstraintW.constant = size.width + 5;
}

@end
