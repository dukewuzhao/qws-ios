//
//  G100CardBaseViewController.h
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BikeDomain.h"
#import "G100CardManager.h"

@class G100CardModel;
@interface G100CardBaseViewController : UIViewController

/**
 *  用户id
 */
@property (nonatomic, copy) NSString *userid;
/**
 *  车辆id
 */
@property (nonatomic, copy) NSString *bikeid;
/**
 *  设备id
 */
@property (nonatomic, copy) NSString *devid;
/**
 *  车辆模型
 */
@property (nonatomic, strong) G100BikeDomain *bikeDomain;
/**
 *  卡片模型 拥有
 */
@property (nonatomic, strong) G100CardModel *cardModel;

@property (nonatomic, assign) BOOL hasAppear;

/**
 *  即将滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillAppear:(BOOL)animated;
/**
 *  已经滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidAppear:(BOOL)animated;
/**
 *  即将离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillDisappear:(BOOL)animated;
/**
 *  已经离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidDisappear:(BOOL)animated;

/**
 *  释放资源
 */
- (void)freeIt;

@end
