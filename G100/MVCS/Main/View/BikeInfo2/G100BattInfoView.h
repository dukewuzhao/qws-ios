//
//  G100BattInfoView.h
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100BikeManager.h"

@protocol G100BattNoCountDelegate <NSObject>
/**
 点击进入电池设置界面
 
 @param button 电量无法计算按钮
 */
- (void)buttonClickedToPushBattDetail:(UIButton *)button;

@end
@interface G100BattInfoView : G100CardBaseView

@property (strong, nonatomic) G100BikeModel *bikeModel;

@property(nonatomic,weak) id<G100BattNoCountDelegate> delegate;
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
