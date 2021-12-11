//
//  G100TopHintTableView.h
//  G100
//
//  Created by 曹晓雨 on 2017/4/20.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100TopHintModel.h"

@protocol G100TopTableViewClickActionDelegate <NSObject>

/**
 用户点击续费回调

 @param deviceDomain 续费设备信息
 */
- (void)topTableViewClickedWithDevice:(G100DeviceDomain *)deviceDomain;

/**
 用户点击领取保险回调

 @param insuranceBanner 领取保险
 */
- (void)topTableViewClickedWithInsurance:(G100InsuranceBanner *)insuranceBanner;

/**
 用户点击设备更新回调

 @param waitUpdateInfo 更新信息
 */
- (void)topTableViewClickedWithUpdateVersion:(G100UpdateVersionModel *)waitUpdateInfo;

@end

@interface G100TopHintTableView : UIView

@property (nonatomic, strong) G100TopHintModel *topHintModel;
@property (nonatomic, weak) id<G100TopTableViewClickActionDelegate> delegate;

@end
