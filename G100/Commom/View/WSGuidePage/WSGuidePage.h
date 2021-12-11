//
//  WSGuidePage.h
//  G100
//
//  Created by 温世波 on 15/11/5.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSIntroductionViewController.h"

@protocol WSGuidePageDelegate <NSObject>

@end

@interface WSGuidePage : NSObject

@property (nonatomic, weak) id <WSGuidePageDelegate> delegate;
@property (nonatomic, strong) UIViewController * onViewController;

/**
 * 判断是否需要展示引导页
 */
+ (BOOL)hasGuidePageForShow;

/**
 *  当前vc中弹出引导页
 *
 *  @param onViewController 当前vc
 *  @param animated         是否动画
 *  @param immediatly       是否需要判断新版本
 */
-(WSIntroductionViewController *)showGuidePageViewOnViewController:(UIViewController *)onViewController animated:(BOOL)animated immediatly:(BOOL)immediatly;
/**
 *  隐藏
 *
 *  @param animated 是否动画
 */
-(void)hideGuidePageView:(BOOL)animated;

@end
