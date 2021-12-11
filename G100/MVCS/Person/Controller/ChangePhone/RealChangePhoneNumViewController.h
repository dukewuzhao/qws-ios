//
//  RealChangePhoneNumViewController.h
//  G100
//
//  Created by Tilink on 15/4/2.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface RealChangePhoneNumViewController : G100BaseXibVC

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendTestBtn;
@property (weak, nonatomic) IBOutlet UITextField *testTF;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
- (IBAction)sendTestEvent:(UIButton *)sender;

- (IBAction)btnEvent:(UIButton *)sender;

@property (copy, nonatomic) NSString * oldPhone;
@property (copy, nonatomic) NSString * oldTestword;

@end
