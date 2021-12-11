//
//  G100InsuranceCardView.h
//  G100
//
//  Created by sunjingjing on 16/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
@protocol G100InsuranceTapDelegate <NSObject>

@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapedToPushDetail:(UIView *)view;

@end

@class G100InsuranceBanner;
@interface G100InsuranceCardView : G100CardBaseView

@property(nonatomic,weak) id<G100InsuranceTapDelegate> delegate;
@property (strong, nonatomic) G100InsuranceBanner *insuranceBanner;
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
