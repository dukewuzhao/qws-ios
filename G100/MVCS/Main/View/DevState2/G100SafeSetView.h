//
//  G100SafeSetView.h
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
@protocol G100CardSafeSetViewTapDelegate <NSObject>

@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapToPushCardSafeSetDetailWithView:(UIView *)touchedView;
@end
@interface G100SafeSetView : G100CardBaseView

@property (weak, nonatomic) IBOutlet UILabel *safeSetInfo;

@property (weak, nonatomic) IBOutlet UIImageView *safeSetBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *safeSetImageView;

@property(nonatomic,weak) id<G100CardSafeSetViewTapDelegate> delegate;
@property (assign, nonatomic) DEV_SECSET_MODE safeMode; //!< 安防等级

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
