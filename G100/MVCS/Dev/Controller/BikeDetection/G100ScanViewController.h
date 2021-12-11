//
//  G100ScanViewController.h
//  G100
//
//  Created by Tilink on 15/3/1.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

typedef void(^G100TestOverAnimate)(G100TestResultDomain *testResult);

@interface G100ScanViewController : G100BaseXibVC

@property (nonatomic, copy) NSString * userid;
@property (nonatomic, copy) NSString * bikeid;
@property (nonatomic, copy) NSString * devid;

@property (assign, nonatomic) NSInteger endScore;

@property (copy, nonatomic) G100TestOverAnimate testOverAnimter;

@end
