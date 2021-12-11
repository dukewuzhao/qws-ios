//
//  G100DevLostInfoViewController.h
//  G100
//
//  Created by yuhanle on 16/4/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

@interface G100DevLostInfoViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

// 丢车记录id
@property (nonatomic, assign) NSInteger lostid;
// 首次发布寻车记录的时间
@property (nonatomic, copy) NSString *firstPublishTime;

@end
