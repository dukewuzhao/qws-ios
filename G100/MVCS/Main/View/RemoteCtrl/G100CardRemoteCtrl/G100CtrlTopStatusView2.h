//
//  G100CtrlTopStatusView.h
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CustomSwitch.h"

@class G100RTCommandModel;
@class G100CtrlTopStatusView;
@protocol G100CtrlTopStatusViewDelegate <NSObject>

@optional

- (void)valueDidChanged:(G100CtrlTopStatusView *)mwsTopStatusView status:(int)status;

@end

@interface G100CtrlTopStatusView : UIView

/**
 *  0 未连接任何设备 灰显 1 蓝牙 2 GPS 3 同时拥有两种远程控制
 */
@property (nonatomic, assign) int status;
/**
 *  开关滑块的状态 0 左 1 右
 */
@property (nonatomic, assign) int mwsSwitchStatus;
/**
 *  自定义滑块视图
 */
@property (nonatomic, strong) G100CustomSwitch *mwsSwitch;
@property (nonatomic, weak) id <G100CtrlTopStatusViewDelegate> delegate;

/**
 *  正在发送指令 需要状态视图执行发送过程中的动画
 *
 *  @param command 指令对应id
 */
- (void)mws_sendCommand:(G100RTCommandModel *)command;
/**
 *  发送指令完成 停止动画 恢复状态
 *
 *  @param command 指令对应id
 *  @param result  指令发送结果 0 失败 1 成功 2 用户取消（暂不支持取消指令）
 */
- (void)mws_completeCommand:(G100RTCommandModel *)command result:(int)result;
/**
 *  设置GPRS信号等级 0 是无信号  1 2 3
 *
 *  @param level 信号等级
 */
- (void)mws_setupGPRS_signalLevel:(int)level;
/**
 *  设置蓝牙信号强度 0 无信号 1 有
 *
 *  @param level 信号等级
 */
- (void)mws_setupBLE_signalLevel:(int)level;
/**
 *  设置卡片标题文案
 *
 *  @param cardTitle 卡片标题文案
 */
- (void)mws_setupCardTitle:(NSString *)cardTitle;
/**
 *  设置卡片详细描述
 *
 *  @param cardDetail 卡片详细描述
 */
- (void)mws_setupCardDetail:(NSString *)cardDetail;

@end
