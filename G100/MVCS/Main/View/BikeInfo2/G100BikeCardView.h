//
//  G100BikeCardView.h
//  G100
//
//  Created by sunjingjing on 16/10/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100BikeInfoView.h"
#import "G100BattInfoView.h"

@interface G100BikeCardView : UIView

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) G100BikeInfoView *bikeInfoView;
@property (strong, nonatomic) G100BattInfoView *battInfoView;
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
+ (CGFloat)heightForItem:(id)item width:(CGFloat)width;

- (instancetype)initViewWithDevice:(BOOL)hasDevice;


- (void)updateBikeInfoViewHeightWithIsDev:(BOOL)hasDev;
@end
