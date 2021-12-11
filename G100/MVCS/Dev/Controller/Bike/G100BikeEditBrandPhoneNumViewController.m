//
//  G100BikeEditBrandPhoneNumViewController.m
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeEditBrandPhoneNumViewController.h"
#import "G100AlertConfirmClickView.h"
#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "G100BikeUpdateInfoDomain.h"

@interface G100BikeEditBrandPhoneNumViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *inputTextFiled;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) G100AlertConfirmClickView *resetServiceBtn;
@property (strong, nonatomic) G100BikeUpdateInfoDomain *bikeUpdateInfo;
@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@end

@implementation G100BikeEditBrandPhoneNumViewController

#pragma mark - public method
- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid oldNumber:(NSString *)oldNumber {
    if (self = [super init]) {
        self.userid = userid;
        self.bikeid = bikeid;
        self.oldNumber = oldNumber;
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
        [_inputTextFiled setKeyboardType:UIKeyboardTypePhonePad];
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

- (G100AlertConfirmClickView *)resetServiceBtn {
    if (!_resetServiceBtn) {
        _resetServiceBtn = [G100AlertConfirmClickView confirmClickView];
        [_resetServiceBtn.confirmButton addTarget:self action:@selector(resetFactoryPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
        [_resetServiceBtn.confirmButton setTitle:@"恢复默认客服电话" forState:UIControlStateNormal];
    }
    return _resetServiceBtn;
}
-(G100BikeUpdateInfoDomain *)bikeUpdateInfo
{
    if (!_bikeUpdateInfo) {
        _bikeUpdateInfo = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid].bikeUpdateInfo;
    }
    return _bikeUpdateInfo;
}
-(G100BikeDomain *)bikeDomain {
    _bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    return _bikeDomain;
}
#pragma mark - setupView
- (void)setupView {
    [self setNavigationTitle:@"编辑厂商电话"];
    
    [self.contentView addSubview:self.inputTextFiled];
    [self.contentView addSubview:self.hintLabel];
    if (self.brand_id > 0 ) {
         [self.contentView addSubview:self.resetServiceBtn];
    }
   
    
    self.inputTextFiled.placeholder = @"";
    if ([[self.oldNumber trim] length]) {
        self.inputTextFiled.text = self.oldNumber;
    }
    self.hintLabel.text = @"记下车企的客服电话，以备不时之需";
    
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
    
     if (self.brand_id > 0) {
    [self.resetServiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.inputTextFiled);
        make.trailing.equalTo(self.inputTextFiled);
        make.top.equalTo(self.hintLabel.mas_bottom).equalTo(@10);
        make.height.equalTo(@40);
    }];
     }
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

- (void)resetFactoryPhoneNumber {
    if (self.defaultNumber.length == 0) {
        [self showWarningHint:@"没有默认客服电话"];
        return;
    }
    
    self.saveButton.enabled = YES;
    self.inputTextFiled.text = self.defaultNumber;
}

-(void)rightButtonClick {
    if (![self.inputTextFiled.text trim].length) {
        [self showWarningHint:@"厂商电话不能空着"];
        return;
    }
    
    if (![self validateNumber:self.inputTextFiled.text]) {
        [self showWarningHint:@"号码只能是数字"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showWarningHint:kError_Network_NotReachable];
        return;
    }
    
    [self.inputTextFiled resignFirstResponder];
    [self updateDevInfo:@{@"custservicenum" : self.inputTextFiled.text}];
}

- (void)updateDevInfo:(NSDictionary *)bikeInfo {
    __weak __typeof__(self) wself = self;
    [self showHudInView:self.contentView hint:@"修改中"];
    self.bikeUpdateInfo.brand.service_num = bikeInfo[@"custservicenum"];
    [[G100BikeApi sharedInstance] updateBikeProfileWithBikeid:self.bikeid bikeType:self.bikeDomain.bike_type profile:[self.bikeUpdateInfo mj_keyValues] progress:nil callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeInfoWithUserid:wself.userid bikeid:wself.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    if (wself.sureBlock) {
                        wself.sureBlock(wself.inputTextFiled.text);
                    }
                    [wself showHint:@"保存成功"];
                    [wself.navigationController popViewControllerAnimated:YES];
                }else{
                    if (response) {
                        [wself showHint:response.errDesc];
                    }
                }
            }];
        }else{
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    }];
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"-0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (toBeString.length > 13) {
        [self showHint:@"已到输入上限"];
        return NO;
    }
    
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
            if (toBeString.length > 13) {
                textField.text = [toBeString subEmojiStringToIndex:13];
                [self showHint:@"已到输入上限"];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 13) {
            textField.text = [toBeString subEmojiStringToIndex:13];
            [self showHint:@"已到输入上限"];
        }
    }
    
    if ([_inputTextFiled.text isEqualToString:self.oldNumber]) {
        _saveButton.enabled = NO;
    }else {
        _saveButton.enabled = YES;
    }
}

- (void)actionClickNavigationBarLeftButton {
    if (self.sureBlock) {
        self.sureBlock(self.inputTextFiled.text);
    }
    
    [super actionClickNavigationBarLeftButton];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    
    self.saveButton.hidden = YES;
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
