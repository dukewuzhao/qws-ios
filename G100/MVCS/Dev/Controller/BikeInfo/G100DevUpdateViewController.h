//
//  G100DevUpdateViewController.h
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"
#import "G100UpdateVersionModel.h"

@interface G100DevUpdateViewController : G100BaseVC

+ (instancetype)shareSigleTon;
+ (void)attempDealloc;

@property (nonatomic, strong) G100UpdateVersionModel *updateVersionModel;
@property (nonatomic, strong) NSString *bikeid;
@property (nonatomic, strong) NSString *devid;
@property (nonatomic, strong) NSString *userid;

@end
