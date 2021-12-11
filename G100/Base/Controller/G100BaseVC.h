//
//  G100BaseVC.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tilink_BaseNavigationBarView.h"

typedef void(^QWSSchemeOverBlock)();

@interface G100BaseVC : UIViewController

@property (strong, nonatomic) UIView   *contentView;
@property (strong, nonatomic) UIButton *rightNavgationButton;
@property (strong, nonatomic) Tilink_BaseNavigationBarView *navigationBarView;

@property (assign, nonatomic) BOOL     hasAppear;
@property (assign, nonatomic) BOOL     isPopAppear;
@property (assign, nonatomic) BOOL     leftBarButtonHidden;
@property (assign, nonatomic) BOOL     schemeBlockExecuted;
@property (assign, nonatomic) NSInteger popViewCount;
@property (copy, nonatomic)   QWSSchemeOverBlock schemeOverBlock;

+ (instancetype)loadXibViewController;

/**
 *  设置导航栏 重写该方法可以自定义
 */
- (void)setupNavigationBarView;

/**
 *  设置导航栏的标题
 *
 *  @param title 视图标题
 */
- (void)setNavigationTitle:(NSString *)title;

/**
 *  设置导航栏背景色
 *
 *  @param color 背景色
 */
- (void)setNavigationBarViewColor:(UIColor *)color;

/**
 *  设置导航栏标题的透明度
 *
 *  @param alpha 透明度 alpha 0.0 ~ 1.0
 */
- (void)setNavigationTitleAlpha:(CGFloat)alpha;

/**
 *   导航栏左侧点击事件 默认pop 可以自定义
 */
- (void)actionClickNavigationBarLeftButton;

/**
 *  push 一个新的页面
 *
 *  @param viewController 新的页面
 *  @param animated       YES/NO
 */
- (void)pushNextViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  pop 返回任意一个存在的页面
 *
 *  @param viewController 页面的名字
 *  @param animated       YES/NO
 *
 *  @return 成功或失败
 */
- (BOOL)popToAnyViewController:(NSString *)viewController animated:(BOOL)animated;

/**
 *  添加弹出框的个数
 */
- (void)addPopViewCount;
/**
 *  减少弹出框的个数
 */
- (void)reducePopViewCount;

@end
