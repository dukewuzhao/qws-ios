//
//  ChangePhoneNumViewController.h
//  G100
//
//  Created by Tilink on 15/4/2.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface ChangePhoneNumViewController : G100BaseXibVC

@property (nonatomic, copy) NSString *userid;

+ (instancetype)loadNibViewController:(NSString *)userid;

@end
