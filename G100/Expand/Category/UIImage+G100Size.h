//
//  UIImage+Size.h
//  G100
//
//  Created by yuhanle on 15/7/13.
//  Copyright (c) 2015年 tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (G100Size)

//修改image的大小
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

// 控件截屏
+ (UIImage *)imageWithCaputureView:(UIView *)view;

@end
