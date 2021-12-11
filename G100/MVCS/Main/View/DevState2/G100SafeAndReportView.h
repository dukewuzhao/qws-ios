//
//  G100SafeAndReportView.h
//  G100
//
//  Created by sunjingjing on 17/2/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"

@protocol G100CardSafeSetAndReportViewTapDelegate <NSObject>

@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapToPushCardSafeSetDetailWithView:(UIView *)touchedView;

/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapToPushCardReportDetailWithView:(UIView *)touchedView;

@end

@interface G100SafeAndReportView : G100CardBaseView

@property (weak, nonatomic) IBOutlet UILabel *safeSetInfo;
@property (weak, nonatomic) IBOutlet UIImageView *safeSetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bikeReportImageView;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImageView;

@property(nonatomic,weak) id <G100CardSafeSetAndReportViewTapDelegate> delegate;
@property (assign, nonatomic) DEV_SECSET_MODE safeMode; //!< 安防等级
@property (assign, nonatomic) NSInteger unreadMsgCount; //!< 未读消息数

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
