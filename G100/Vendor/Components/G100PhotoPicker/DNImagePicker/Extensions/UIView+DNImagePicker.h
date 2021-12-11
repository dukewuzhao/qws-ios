//
//  UIView+DNImagePicker.h
//  JKImagePicker
//
//  Created by DingXiao on 15/2/11.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DNImagePicker)

@property (nonatomic) CGFloat dn_left;
@property (nonatomic) CGFloat dn_top;
@property (nonatomic) CGFloat dn_right;
@property (nonatomic) CGFloat dn_bottom;
@property (nonatomic) CGFloat dn_width;
@property (nonatomic) CGFloat dn_height;

@property (nonatomic) CGFloat dn_centerX;
@property (nonatomic) CGFloat dn_centerY;

@property (nonatomic) CGPoint dn_origin;
@property (nonatomic) CGSize dn_size;
@end
