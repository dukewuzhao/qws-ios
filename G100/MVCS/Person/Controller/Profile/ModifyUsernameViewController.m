//
//  ModifyUsernameViewController.m
//  G100
//
//  Created by Tilink on 15/4/21.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ModifyUsernameViewController.h"
#import "G100UserApi.h"

@interface ModifyUsernameViewController () <UITextFieldDelegate> {
    UITextField * _nickTF;
    UIButton * _saveButton;
}

@end

@implementation ModifyUsernameViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [_nickTF becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:@"修改昵称"];
    [self configRightButton];
    
    _saveButton.enabled = NO;
    _nickTF = [[UITextField alloc]initWithFrame:CGRectZero];
    [_nickTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_nickTF setBorderStyle:UITextBorderStyleRoundedRect];
    _nickTF.placeholder = @"昵称";
    _nickTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nickTF.text = self.username;
    _nickTF.returnKeyType = UIReturnKeyDone;
    _nickTF.delegate = self;
    [self.contentView addSubview:_nickTF];
    
    [_nickTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@30);
        make.trailing.equalTo(@-20);
        make.leading.equalTo(@20);
        make.height.equalTo(@40);
    }];
}

-(void)configRightButton {
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame = CGRectMake(0, 0, 30, 30);
    [_saveButton setImage:[[UIImage imageNamed:@"ic_user_save"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightNavgationButton:_saveButton];
}

#pragma mark - UITextFieldDelegate
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (toBeString.length > 10) {
        [self showHint:@"已到输入上限"];
        return NO;
    }
    
    return YES;
}
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self rightButtonClick];
    
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (!_saveButton.enabled) {
        _saveButton.enabled = YES;
    }
    
    NSString *toBeString = textField.text;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    NSString *lang = current.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 10) {
                textField.text = [toBeString subEmojiStringToIndex:10];
                [self showHint:@"已到输入上限"];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 10) {
            textField.text = [toBeString subEmojiStringToIndex:10];
            [self showHint:@"已到输入上限"];
        }
    }
}

-(void)updateUserInfo:(NSDictionary *)userinfo {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak ModifyUsernameViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid] complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    if (wself.sureBlock) {
                        wself.sureBlock(_nickTF.text);
                    }
                    
                    [wself showHint:@"昵称修改成功"];
                    [wself.navigationController popViewControllerAnimated:YES];
                }
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [self showHudInView:self.contentView hint:@"修改中"];
    [[G100UserApi sharedInstance] sv_updateUserdataWithUserinfo:userinfo callback:callback];
}

-(void)rightButtonClick {
    if ([NSString checkNickname:_nickTF.text]) {
        [self showHint:[NSString checkNickname:_nickTF.text]];
        return;
    }
    
    if ([_nickTF.text isEqualToString:_username]) {
        _saveButton.enabled = NO;
        return;
    }
    
    [_nickTF resignFirstResponder];
    //[self updateUserInfo:@{ @"nickname" : _nickTF.text} ];
    
    if (self.sureBlock) {
        self.sureBlock(_nickTF.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
