//
//  G100FuncSetOverSpeedViewController.h
//  G100
//
//  Created by 曹晓雨 on 2017/3/27.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100FuncSetOverSpeedViewController : G100BaseXibVC

@property (copy, nonatomic) NSString * userid;
@property (copy, nonatomic) NSString * bikeid;
@property (copy, nonatomic) NSString * devid;

@property (nonatomic, assign) NSInteger bikeType;
@property (assign, nonatomic) NSInteger selected;

@end
