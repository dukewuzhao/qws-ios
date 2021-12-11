//
//  G100CardRemoteCtrlView.h
//  G100CardRemoteCtrlView
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CardBaseView.h"
#import "G100CtrlTopStatusView.h"
#import "G100RTCollectionViewCell.h"

@class G100CtrlTopStatusView;
@class G100CardRemoteCtrlView;
@class G100RTCollectionViewCell;
@protocol G100CardRemoteCtrlViewDelegate <NSObject>

@optional
- (void)cardRemoteCtrlView:(G100CardRemoteCtrlView *)ctrlView switchDidChanged:(G100CtrlTopStatusView *)topStatusView status:(int)status;

- (void)cardRemoteCtrlView:(G100CardRemoteCtrlView *)ctrlView commandViewDidTapped:(G100RTCollectionViewCell *)rtCommandView;

@end

/**
 *  远程遥控卡片：
 *  1. 目前只支持GPS相关产品和蓝牙产品，随着子产品不同 提供的操作功能也会有差异
 *  2. 当手机连接上蓝牙则优先自动将开关切换至蓝牙，用户可手动选择。
 *  3. 当设备切换的时候背景颜色随着设备主题色改变
 *  4. 点击任何操作顶部会显示状态
 *  5. 各个产品具有哪些遥控功能请参照产品配置表
 *  6. 当没有开启蓝牙或者没有连接任何设备，蓝牙符号灰显示，同理当没有开启网络或者网络异常 GPS图标灰显
 *  7. 开关不可以手动向灰显方向打开，如果全部灰显，开关不可操作 下方功能也灰显示，不可操作
 */
@interface G100CardRemoteCtrlView : G100CardBaseView

/**
 *  0 未连接任何设备 灰显 1 蓝牙 2 GPS 3 同时拥有两种远程控制
 */
@property (nonatomic, assign) int rtStatus;

/**
 *  记录当前选中的远程控制模式状态 0 无 1 蓝牙 2 GPS
 */
@property (assign, nonatomic) int status;
/**
 *  是否正在发送指令
 */
@property (assign, nonatomic) BOOL isCommandSending;

@property (weak, nonatomic) id <G100CardRemoteCtrlViewDelegate> delegate;

/**
 *  顶部状态视图
 */
@property (strong, nonatomic) G100CtrlTopStatusView *topStatusView;
/**
 *  底部控制列表
 */
@property (strong, nonatomic) UICollectionView *ctrlBtnsView;
/**
 *  存放远程控制GPS指令 模型
 */
@property (strong, nonatomic) NSMutableArray *dataGPSArray;
/**
 *  存放远程控制蓝牙指令 模型
 */
@property (strong, nonatomic) NSMutableArray *dataBLEArray;

/**
 *  快速返回行高
 *
 *  @param item  item（待定类型）
 *  @param width width
 *
 *  @return 行高
 */
+ (CGFloat)heightForItem:(id)item width:(CGFloat)width;
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
/**
 设置设备的设防撤防状态
 
 @param status 1 设防已上传 2 设防 3 撤防已上传 4 撤防 0 其他
 */
- (void)mws_setupSecurityStatus:(int)status;

@end
