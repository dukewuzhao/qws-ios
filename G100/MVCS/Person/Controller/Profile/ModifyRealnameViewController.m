//
//  ModifyRealnameViewController.m
//  G100
//
//  Created by yuhanle on 16/4/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "ModifyRealnameViewController.h"
#import "G100UserApi.h"

@interface ModifyRealnameViewController () <UITextFieldDelegate> {
    UITextField * _textField;
    UIButton * _saveButton;
}

@end

@implementation ModifyRealnameViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [_textField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:@"修改真实姓名"];
    [self configRightButton];
    
    _saveButton.enabled = NO;
    _textField = [[UITextField alloc]initWithFrame:CGRectZero];
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_textField setBorderStyle:UITextBorderStyleRoundedRect];
    _textField.placeholder = @"真实姓名";
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.text = self.realname;
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    [self.contentView addSubview:_textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
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
    if (toBeString.length > 6) {
        [self showHint:@"已到输入上限"];
        return NO;
    }
    
    return YES;
}
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self rightButtonClick];
    
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField
{
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
            if (toBeString.length > 6) {
                textField.text = [toBeString subEmojiStringToIndex:6];
                [self showHint:@"已到输入上限"];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 6) {
            textField.text = [toBeString subEmojiStringToIndex:6];
            [self showHint:@"已到输入上限"];
        }
    }
    
    if ([_textField.text isEqualToString:_realname]) {
        _saveButton.enabled = NO;
    }else {
        _saveButton.enabled = YES;
    }
}

-(void)rightButtonClick {
    if ([NSString checkName:_textField.text]) {
        [self showHint:[NSString checkName:_textField.text]];
        return;
    }
    
    if ([_textField.text isEqualToString:_realname]) {
        _saveButton.enabled = NO;
        return;
    }
    
    [_textField resignFirstResponder];
    
    if (self.sureBlock) {
        self.sureBlock(_textField.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
