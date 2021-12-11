//
//  G100BikeTestView.h
//  G100
//
//  Created by sunjingjing on 2017/4/17.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"

@protocol G100BikeTestViewTapDelegate <NSObject>

@optional
/**
 点击跳转评分页面
 
 @param touchedView 被点击的View
 */
- (void)viewTapToPushTestDetailWithView:(UIView *)touchedView;
@end

@class G100TestResultDomain;
@interface G100BikeTestView : G100CardBaseView

@property(nonatomic,weak) id<G100BikeTestViewTapDelegate> delegate;

@property (strong, nonatomic) G100TestResultDomain *testResultDomin;
/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)showView;

/**
 *  根据View的宽度算出View的高
 *
 *  @param width
 *
 *  @return View的高
 */
+ (float)heightWithWidth:(float)width;
@end
