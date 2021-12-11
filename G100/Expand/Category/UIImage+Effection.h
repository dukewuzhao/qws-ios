//
//  UIImage+Effection.h
//  G100
//
//  Created by William on 16/7/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Effection)

+ (UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;

- (UIImage *)fx_defaultGaussianBlurImage;

@end
