//
//  G100WeatherAndCarView.h
//  G100
//
//  Created by sunjingjing on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100WeatherView.h"
#import "CarDetectionView.h"
#import "G100NoCarView.h"

@interface G100WeatherAndCarView : UIView

/**
 *  天气占位View
 */
@property (weak, nonatomic) IBOutlet UIView *weatherView;

/**
 *  车辆检测占位View
 */
@property (weak, nonatomic) IBOutlet UIView *carDeteView;

/**
 *  天气显示View
 */
@property (strong, nonatomic) G100WeatherView *weaView;

/**
 *  车辆检测显示View
 */
@property (strong, nonatomic) CarDetectionView *carView;

@property (strong, nonatomic) G100NoCarView *noCarView;

/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)showView;


- (instancetype)initViewWithIsBike:(BOOL)hasBike andIsDevice:(BOOL)hasDevice;
/**
 *  根据View的宽度算出View的高
 *
 *  @param width
 *
 *  @return View的高
 */

- (void)updateViewWithisDevice:(BOOL)isDevice andIsBike:(BOOL)isBike;


+ (CGFloat)heightWithWidth:(CGFloat)width;

@end
