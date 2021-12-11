//
//  G100BikeEditBikeNameViewController.m
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeEditBikeNameViewController.h"
#import "G100BikeApi.h"
#import "G100BikeUpdateInfoDomain.h"
#import "G100BikeDomain.h"

@interface G100BikeEditBikeNameViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *inputTextFiled;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (strong, nonatomic) G100BikeUpdateInfoDomain *bikeUpdateInfo;
@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@end

@implementation G100BikeEditBikeNameViewController

#pragma mark - public method
- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid oldName:(NSString *)oldName {
    if (self = [super init]) {
        self.userid = userid;
        self.bikeid = bikeid;
        self.oldName = oldName;
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
        [_inputTextFiled setReturnKeyType:UIReturnKeyDone];
        _inputTextFiled.delegate = self;
        [_inputTextFiled addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    [self setNavigationTitle:@"编辑车辆名称"];
    
    [self.contentView addSubview:self.inputTextFiled];
    [self.contentView addSubview:self.hintLabel];
    
    self.inputTextFiled.placeholder = @"10个字以内的中英文、数字、符号、空格";
    if ([[self.oldName trim] length]) {
        self.inputTextFiled.text = self.oldName;
    }
    self.hintLabel.text = @"给爱车取一个容易记的名字";
    
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
    [_saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightNavgationButton:_saveButton];
    
    _saveButton.enabled = NO;
}

-(void)rightButtonClick {
    if ([NSString checkBikeName:self.inputTextFiled.text]) {
        [self showWarningHint:[NSString checkBikeName:self.inputTextFiled.text]];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showWarningHint:kError_Network_NotReachable];
        return;
    }
    
    [self.inputTextFiled resignFirstResponder];
    [self updateDevInfo:@{@"name" : self.inputTextFiled.text}];
}

- (void)updateDevInfo:(NSDictionary *)bikeInfo {
    __weak __typeof__(self) wself = self;
    [self showHudInView:self.contentView hint:@"修改中"];
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
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
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    self.bikeUpdateInfo.name = bikeInfo[@"name"];
    [[G100BikeApi sharedInstance] updateBikeProfileWithBikeid:self.bikeid bikeType:self.bikeDomain.bike_type profile:[self.bikeUpdateInfo mj_keyValues] progress:nil callback:callback];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.inputTextFiled.text isEqualToString:self.oldName]) {
        _saveButton.enabled = NO;
        [_saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        return YES;
    }
    if ([NSString checkBikeName:self.inputTextFiled.text]) {
        [self showWarningHint:[NSString checkBikeName:self.inputTextFiled.text]];
        return YES;
    }
    
    if (kNetworkNotReachability) {
        [self showWarningHint:kError_Network_NotReachable];
        return YES;
    }
    
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    [self updateDevInfo:@{@"name" : self.inputTextFiled.text}];
    
    return YES;
}
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
- (void)textFieldDidChange:(UITextField *)textField
{
    if (!_saveButton.enabled) {
        _saveButton.enabled = YES;
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    
    if ([_inputTextFiled.text isEqualToString:self.oldName]) {
        _saveButton.enabled = NO;
        [_saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else {
        _saveButton.enabled = YES;
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    
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
