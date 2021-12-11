//
//  CALayer+Addtion.m
//  G100
//
//  Created by 温世波 on 15/11/20.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "CALayer+Addtion.h"

@implementation CALayer (Addtion)

- (void)setBorderUIColor:(UIColor*)color {
    self.borderColor = color.CGColor;
}

- (UIColor*)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

-(void)setContentsUIImage:(UIImage*)bgImage{
    self.contents=(__bridge id)(bgImage.CGImage);
}
-(UIImage*)contentsUIImage{
    return self.contents;
}

@end
