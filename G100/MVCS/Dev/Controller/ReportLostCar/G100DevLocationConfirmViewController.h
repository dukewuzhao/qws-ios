//
//  G100DevLocationConfirmViewController.h
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDevMapViewController.h"

typedef void(^G100LocationConfirmFinishedBlock)();

@interface G100DevLocationConfirmViewController : G100BaseDevMapViewController

@property (nonatomic, copy) G100LocationConfirmFinishedBlock locatinCofirmFinished;
// 保存用户确认位置经纬度
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@end
