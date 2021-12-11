//
//  G100BattGPSView.h
//  G100
//
//  Created by sunjingjing on 16/12/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100BatteryDomain.h"

@protocol G100BattGPSTapDelegate <NSObject>

@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapToPushBattGPSDetailWithView:(UIView *)touchedView;

@end

@class YLProgressBar;
@interface G100BattGPSView : G100CardBaseView

@property (weak, nonatomic) IBOutlet YLProgressBar *progressBarView;
@property (strong, nonatomic) G100BatteryDomain *batteryDomain;
@property (weak, nonatomic) id<G100BattGPSTapDelegate> delegate;
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

/**
     更新UI数据
 */
- (void)updateBattDataUI;


/**
    更新电门状态
 @param state 电门状态
 */
- (void)updateEleDoorState:(NSInteger)state;

@end
