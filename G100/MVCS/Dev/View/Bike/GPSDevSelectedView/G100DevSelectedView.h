//
//  G100DevSelectedView.h
//  G100
//
//  Created by yuhanle on 2016/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    G100DevSelectedViewOpenStateClose = 0,
    G100DevSelectedViewOpenStateOpen = 1
} G100DevSelectedViewOpenState;

@class G100DeviceDomain;
@class G100DevSelectedView;
@protocol G100DevSelectedViewDelegate <NSObject>

@optional
- (void)G100DevSelectedView:(G100DevSelectedView *)selectedView device:(G100DeviceDomain *)device;

- (void)G100DevSelectedView:(G100DevSelectedView *)selectedView device:(G100DeviceDomain *)device visiableState:(BOOL)visiableState;

- (BOOL)G100DevSelectedView:(G100DevSelectedView *)selectedView visibleDevice:(G100DeviceDomain *)device;

@end

@interface G100DevSelectedView : UIView

/** 右上角的锚点*/
@property (nonatomic, assign) CGPoint acpoint;
/** 数据源*/
@property (nonatomic, strong) NSArray *dataArray;
/** 视图详情的显示状态*/
@property (nonatomic, assign) G100DevSelectedViewOpenState openState;

@property (nonatomic, weak) id <G100DevSelectedViewDelegate> delegate;

/**
 全部反选
 */
- (void)invertSelection;

/**
 选中某个设备

 @param index 设备下标
 */
- (void)selectedDeviceAtIndex:(NSInteger)index;

@end
