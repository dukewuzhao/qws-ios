//
//  UIImage+Tint.h
//  G100
//
//  Created by William on 16/7/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;

@end
