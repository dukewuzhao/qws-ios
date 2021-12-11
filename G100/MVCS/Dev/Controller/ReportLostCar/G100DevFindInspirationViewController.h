//
//  G100DevFindInspirationViewController.h
//  G100
//
//  Created by yuhanle on 16/4/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100DevFindInspirationViewController : G100BaseXibVC

@property (nonatomic, assign) NSInteger lostid;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid; //!< 需要传递的设备id

@property (nonatomic, copy) NSString *httpUrl; //!< 需要load的网址

@end
