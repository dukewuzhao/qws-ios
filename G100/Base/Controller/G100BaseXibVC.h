//
//  G100BaseXibVC.h
//  G100
//
//  Created by Tilink on 15/4/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

@interface G100BaseXibVC : G100BaseVC <UIScrollViewDelegate>

/**
 *  xib 加载的导航栏视图
 */
@property (weak, nonatomic) IBOutlet UIView * navigationView;
/**
 *  xib 加载的内容视图
 */
@property (weak, nonatomic) IBOutlet UIView * substanceView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subStanceViewtoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *substanceViewtoBottomConstraint;

@end
