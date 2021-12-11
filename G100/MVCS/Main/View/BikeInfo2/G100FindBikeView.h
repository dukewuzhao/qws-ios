//
//  G100FindBikeView.h
//  G100
//
//  Created by sunjingjing on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100DevFindLostListDomain.h"
@protocol G100FindBikeViewTapDelegate <NSObject>

@optional
/**
 点击跳转寻车记录页面
 
 @param touchedView 被点击的View
 */
- (void)viewTapToPushRecordFindBikeWithView:(UIView *)touchedView;
@end

@interface G100FindBikeView : G100CardBaseView

@property(nonatomic,weak) id<G100FindBikeViewTapDelegate> delegate;

@property (strong, nonatomic) G100DevFindLostDomain *devLostModel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redDotImageView;
@property (weak, nonatomic) IBOutlet UILabel *recordShow;
@property (weak, nonatomic) IBOutlet UIImageView *findImageView;
@property (strong, nonatomic) NSString *latestTime;

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
