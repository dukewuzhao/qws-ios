//
//  G100CardSlantView.h
//  G100
//
//  Created by sunjingjing on 16/10/21.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CardBaseView.h"
@interface G100CardSlantView : G100CardBaseView

/**
 创建倾斜View

 @param leftColor  左边view颜色
 @param rightColor 右边View颜色

 @return view
 */
- (instancetype)initWithFrame:(CGRect)frame leftViewColor:(UIColor *)leftColor rightViewColor:(UIColor *)rightColor;

@end
