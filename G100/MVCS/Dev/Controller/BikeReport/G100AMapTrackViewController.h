//
//  G100AMapTrackViewController.h
//  G100
//
//  Created by 温世波 on 15/11/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100AMapBaseViewController.h"

@interface G100AMapTrackViewController : G100AMapBaseViewController

@property (copy, nonatomic) NSString * userid;
@property (copy, nonatomic) NSString * bikeid;
// devid 车辆id
@property (copy, nonatomic) NSString * devid;

// 用于用车报告
@property (copy, nonatomic) NSString * dayStr;

// 用于用车报告
@property (copy, nonatomic) NSString * begintime;
@property (copy, nonatomic) NSString * endtime;

@end
