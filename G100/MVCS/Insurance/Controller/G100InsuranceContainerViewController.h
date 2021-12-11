//
//  G100InsuranceContainerViewController.h
//  G100
//
//  Created by yuhanle on 2017/8/7.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"
#import "G100InsuranceOrderListViewController.h"

@interface G100InsuranceContainerViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;

@property (assign, nonatomic) InsuranceOrderType insuranceOrderType;

@end
