//
//  G100BikeInfoDeviceViewController.h
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BikeInfoCardModel.h"

@interface G100BikeInfoDeviceViewController : UIViewController

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;

@property (nonatomic, strong) G100BikeInfoCardModel *bikeInfoModel;

+ (CGFloat)heightForItem:(id)item width:(CGFloat)width;

@end
