//
//  G100HomeSetViewController.h
//  G100
//
//  Created by sunjingjing on 2017/7/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100HomeSetViewController : G100BaseXibVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

@property (strong, nonatomic) UserHomeInfo *homeInfo; //家的地址

@property (copy, nonatomic) void (^setHomeBloc)(NSString *homeAddr);

@end
