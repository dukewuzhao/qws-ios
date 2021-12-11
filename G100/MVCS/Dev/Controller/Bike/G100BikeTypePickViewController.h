//
//  G100BikeTypePickViewController.h
//  G100
//
//  Created by William on 16/4/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef enum : NSInteger{
    G100BikeTypeScooter = 1,
    G100BikeTypeTwoWheeled,
    G100BikeTypeThreeWheeled,
    G100BikeTypeFourWheeled,
    G100BikeTypeElectric,
    G100BikeTypeMotor,
    G100BikeTypeOther = 99
}G100BikeType;

@interface G100BikeTypePickViewController : G100BaseVC

@property (nonatomic, copy) NSString * devTypeStr;

@property (nonatomic, copy) void (^completePickBlock)(NSString *devTypeStr, NSInteger devType);

@property (nonatomic, assign) NSInteger bikeType;
@end
