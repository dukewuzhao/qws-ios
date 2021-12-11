//
//  G100UserCarView.h
//  G100
//
//  Created by sunjingjing on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CardBaseView.h"
#import "EleShowView.h"
#import "G100ClickEffectView.h"
#import "G100BikeManager.h"

@protocol G100ScaleQRCodeDelegate <NSObject>

- (void)buttonClickedToScaleQRCode:(UIButton *)button;

@end

@interface G100UserCarView : G100CardBaseView
/**
 *  车的图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;

/**
 *  车的商家logo
 */
@property (weak, nonatomic) IBOutlet UIImageView *barSacnImageView;

/**
 *  主用户显示
 */
@property (weak, nonatomic) IBOutlet UIImageView *isMasterImageView;

/**
 *  用户对当前车辆的描述
 */
@property (weak, nonatomic) IBOutlet UILabel *carDescrip;

/**
 *  当前车辆的主副用户情况
 */
@property (weak, nonatomic) IBOutlet UILabel *userDescrip;

/**
 *  有电源设备时右边View
 */
@property (weak, nonatomic) IBOutlet UIView *rightBgView;

/**
 *  不同电量情况对应背景View
 */
@property (weak, nonatomic) IBOutlet UIImageView *rBgImageView;

/**
 *  二维码
 */
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

/**
 *  电量显示View
 */
@property (weak, nonatomic) IBOutlet UIView *coulometryView;

/**
 *  续航里程描述
 */
@property (weak, nonatomic) IBOutlet UILabel *driveMile;

/**
 *  低电量，充电提醒（默认隐藏）
 */
@property (weak, nonatomic) IBOutlet UIButton *lowElecShow;

/**
 *  电门开关状态
 */
@property (weak, nonatomic) IBOutlet UILabel *eleDoorState;

/**
 *  不同电门状态下的背景
 */
@property (weak, nonatomic) IBOutlet UIImageView *eleDoorBgView;

/**
 *  电量圆环
 */
@property (strong, nonatomic) EleShowView *eleAnimaView;

/**
 *  无车辆图片时显示
 */
@property (weak, nonatomic) IBOutlet UIView *noDevice;

/**
 *  右侧电量点击动画
 */
@property (weak, nonatomic) IBOutlet G100ClickEffectView *clickedAniView;

/**
 *  左侧车辆点击动画
 */
@property (weak, nonatomic) IBOutlet G100ClickEffectView *leftClickedView;

/**
 *  self数据模型
 */
@property (strong, nonatomic) G100BikeModel *bikeModel;
/**
 *  上次保存电量
 */
@property (assign, nonatomic) NSInteger lastPercent;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftTosuperTrailConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftTorightleadConstraint;

@property(nonatomic,weak) id<G100ScaleQRCodeDelegate> delegate;

/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)showView;


- (instancetype)initWithIsDevice:(BOOL)hasDevice;
/**
 *  根据View的宽度算出View的高
 *
 *  @param width
 *
 *  @return View的高
 */
+ (float)heightWithWidth:(float)width;

/**
 *  开始执行电量变化动画
 */
- (void)beginAnimateWithIsAnimate:(BOOL)isAnimate;

/**
 *  更新电门状态
 *
 *  @param isOpen 开/关
 */
- (void)updateEleDoorStateWithisOpen:(BOOL)isOpen;

/**
 *  无设备时隐藏右边视图
 */
- (void)updateViewOfNoDevice;

/**
 *  添加完设备后更新右侧电量View
 */
- (void)updateViewOfAddedDevice;

@end
