//
//  G100BattInfoView.h
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100BikeManager.h"
@interface G100BattInfoView2 : G100CardBaseView

@property (strong, nonatomic) G100BikeModel *bikeModel;
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
+ (CGFloat)heightWithWidth:(CGFloat)width;

- (void)updateBattDataUI;

@end
