//
//  G100ToastView.h
//  G100
//
//  Created by William on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ToastShowType) {
    ToastShowTypeNotification,
    ToastShowTypeWarning
};

@class G100ToastLabel;
@interface G100ToastView : UIView

+ (instancetype)showToastAddedTo:(UIView *)view;

/** label */
@property (nonatomic, strong) G100ToastLabel * label;
/** 文字内容 */
@property (nonatomic, strong) NSString * labelText;
/** y轴偏移量 */
@property (nonatomic, assign) CGFloat yOffset;
/** toast显示类型 通知类提示 重要提示 */
@property (nonatomic, assign) ToastShowType type;

/**
 *  延迟隐藏toast
 */
- (void)hideDelay;

/**
 *  立即隐藏toast
 */
- (void)hideNow;

@end
