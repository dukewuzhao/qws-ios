//
//  RequestVCView.h
//  G100
//
//  Created by Tilink on 15/3/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"
#import "G100UserApi.h"

typedef void(^RequestVC)();
@interface RequestVCView : G100PopBoxBaseView <UITextFieldDelegate>

@property (copy, nonatomic) RequestVC requestVCAgainEvent;
@property (copy, nonatomic) RequestVC requestVCSureEvent;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UITextField *testField;
@property (weak, nonatomic) IBOutlet UILabel *timeRemain;
@property (weak, nonatomic) IBOutlet UIButton *sendAgain;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *waningLabel;

@property (copy, nonatomic) NSString * phoneNumber;
@property (assign, nonatomic) G100VerificationCodeUsage verificationCodeUsage;

- (void)setupView;

- (void)startTime;

- (void)endTime;

- (IBAction)buttonClick:(UIButton *)sender;

@end
