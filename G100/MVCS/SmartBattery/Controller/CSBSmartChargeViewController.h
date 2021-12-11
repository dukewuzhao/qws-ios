//
//  G100BattAnimateViewController.h
//  Demobase
//
//  Created by sunjingjing on 16/12/13.
//  Copyright © 2016年 sunjingjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BatteryDomain.h"

@interface CSBSmartChargeViewController : UIViewController

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;
@property (nonatomic, copy) NSString *batteryid;
@property (nonatomic, strong) G100BatteryDomain *batteryDomain;

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated;

- (void)becameActived;

@end
