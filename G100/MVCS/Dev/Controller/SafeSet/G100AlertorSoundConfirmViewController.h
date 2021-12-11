//
//  G100AlertorSoundConfirmViewController.h
//  G100
//
//  Created by yuhanle on 16/9/7.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

@interface G100AlertorSoundConfirmViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

@property (nonatomic, strong) G100DevAlertorSoundFunc *func;

@end
