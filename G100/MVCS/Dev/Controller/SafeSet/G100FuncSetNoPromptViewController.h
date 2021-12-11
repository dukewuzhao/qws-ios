//
//  G100FuncSetNoPromptViewController.h
//  G100
//
//  Created by 温世波 on 15/12/31.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100FuncSetNoPromptViewController : G100BaseXibVC

@property (copy, nonatomic) NSString * userid;
@property (copy, nonatomic) NSString * bikeid;
@property (copy, nonatomic) NSString * devid;

@property (nonatomic, assign) NSInteger pushIgnoreTime;

@end
