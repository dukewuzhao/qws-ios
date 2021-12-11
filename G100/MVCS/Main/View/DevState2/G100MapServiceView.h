//
//  G100MapServiceView.h
//  G100
//
//  Created by sunjingjing on 17/2/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
@protocol G100MapServiceViewDelegate <NSObject>

@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)mapServiceView:(UIView *)touchedView buttonClicked:(UIButton *)button;

- (void)mapServiceView:(UIView *)touchedView viewTaped:(UIView *)view;
@end

@interface G100MapServiceView : G100CardBaseView

@property(nonatomic,weak) id<G100MapServiceViewDelegate> delegate;

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
