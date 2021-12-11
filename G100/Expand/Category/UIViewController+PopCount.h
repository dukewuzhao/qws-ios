//
//  UIViewController+PopCount.h
//  G100
//
//  Created by yuhanle on 16/3/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PopCount)

@property (assign, nonatomic) NSInteger popViewCount; //!< 记录vc 弹出框的个数

- (void)addPopViewCount;

- (void)reducePopViewCount;

@end
