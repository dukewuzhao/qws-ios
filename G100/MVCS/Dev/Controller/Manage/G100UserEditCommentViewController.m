//
//  G100UserEditCommentViewController.m
//  G100
//
//  Created by sunjingjing on 17/1/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100UserEditCommentViewController.h"
#import "G100UserApi.h"

@interface G100UserEditCommentViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *inputTextFiled;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation G100UserEditCommentViewController

#pragma mark - public method
- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid oldComment:(NSString *)oldComment {
    if (self = [super init]) {
        self.userid = userid;
        self.bikeid = bikeid;
        self.oldComment = oldComment;
    }
    return self;
}
#pragma mark- setter&getter
- (UITextField *)inputTextFiled {
    if (!_inputTextFiled) {
        _inputTextFiled = [[UITextField alloc] init];
        _inputTextFiled.backgroundColor = [UIColor whiteColor];
        _inputTextFiled.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _inputTextFiled.layer.borderWidth = 1.0f;
        _inputTextFiled.font = [UIFont systemFontOfSize:15];
        _inputTextFiled.delegate = self;
        [_inputTextFiled addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    }
    return _inputTextFiled;
}
- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.font = [UIFont systemFontOfSize:13];
        _hintLabel.textColor = [UIColor lightGrayColor];
    }
    return _hintLabel;
}

#pragma mark - setupView
- (void)setupView {
    [self setNavigationTitle:@"编辑用户备注"];
    
    [self.contentView addSubview:self.inputTextFiled];
    [self.contentView addSubview:self.hintLabel];
    
    self.inputTextFiled.placeholder = @"10个字以内的中英文、数字、符号、空格";
    if ([[self.oldComment trim] length]) {
        self.inputTextFiled.text = self.oldComment;
    }
    self.hintLabel.text = @"给用户添加一个备注";
    
    [self.inputTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-10);
        make.leading.equalTo(@10);
        make.top.equalTo(self.navigationBarView.mas_bottom).with.offset(10);
        make.height.equalTo(@40);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.inputTextFiled.mas_leading);
        make.top.equalTo(self.inputTextFiled.mas_bottom).with.offset(10);
    }];
}

- (void)setupNavigationBarView {
    [self configRightButton];
}

-(void)configRightButton {
    _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _saveButton.frame = CGRectMake(0, 0, 60, 30);
    _saveButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightNavgationButton:_saveButton];
    
    _saveButton.enabled = NO;
}

-(void)rightButtonClick {
    if (![self.inputTextFiled.text trim].length) {
        [self showWarningHint:@"备注不能为空"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showWarningHint:kError_Network_NotReachable];
        return;
    }
    
    [self.inputTextFiled resignFirstResponder];
    [self updateDevInfo:@{@"comment" : self.inputTextFiled.text}];
}

- (void)updateDevInfo:(NSDictionary *)bikeInfo {
    __weak __typeof__(self) wself = self;
    [self showHudInView:self.contentView hint:@"修改中"];
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeInfoWithUserid:self.userid bikeid:self.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    if (wself.sureBlock) {
                        wself.sureBlock(wself.inputTextFiled.text);
                    }
                    [wself showHint:@"修改成功"];
                    [wself.navigationController popViewControllerAnimated:YES];
                }else{
                    if (response) {
                        [wself showHint:response.errDesc];
                    }
                }
            }];
            
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    [[G100UserApi sharedInstance] sv_commentUserWithUserid:self.userid bikeid:self.bikeid comment:bikeInfo[@"comment"] callback:callback];
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
 return NO;
 }
 
 return YES;
 }
 */

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
        }
    }
    
    if ([_inputTextFiled.text isEqualToString:self.oldComment]) {
        _saveButton.enabled = NO;
    }else {
        _saveButton.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.inputTextFiled becomeFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
