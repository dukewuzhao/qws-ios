//
//  G100BikeReportView.h
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
@protocol G100CardBikeReportViewTapDelegate <NSObject>

@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapToPushCardReportDetailWithView:(UIView *)touchedView;
@end

@interface G100BikeReportView : G100CardBaseView

@property (weak, nonatomic) IBOutlet UILabel *bikeReportInfo;
@property (weak, nonatomic) IBOutlet UIImageView *bikeReportBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bikeReportImageView;
@property(nonatomic,weak) id<G100CardBikeReportViewTapDelegate> delegate;
@property (assign, nonatomic) NSInteger unreadMsgCount;

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
