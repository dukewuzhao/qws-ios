//
//  G100NewBikeViewController.m
//  G100
//
//  Created by yuhanle on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100NewBikeViewController.h"
#import "G100BaseArrowItem.h"
#import "G100BaseCell.h"

#import "G100BikeApi.h"
#import "GTMBase64.h"
#import "G100PhotoShowModel.h"
#import "G100BikeUpdateInfoDomain.h"

#import "G100BikeEditFeatureViewController.h"

@interface G100NewBikeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *bikeNameTextField;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) G100BikeUpdateInfoDomain *bikeInfo;

@end

@implementation G100NewBikeViewController

- (void)dealloc {
    DLog(@"添加车辆页面释放");
}

- (void)setupView {
    UILabel *hintLabel = [[UILabel alloc]init];
    hintLabel.text = @"给你的爱车起个昵称吧";
    [self.contentView addSubview:hintLabel];
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    UIImage * selectedImage = [[UIImage imageNamed:@"ic_alarm_option_yes_down"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    UIImage * normalImage = [[UIImage imageNamed:@"ic_alarm_option_yes_up"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    
    [_nextBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_nextBtn setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [_nextBtn setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextBtn setTintColor:[UIColor whiteColor]];
    [_nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_nextBtn];
    
    _bikeNameTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    [_bikeNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_bikeNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    _bikeNameTextField.placeholder = @"车辆名称";
    [_bikeNameTextField setReturnKeyType:UIReturnKeyDone];
    _bikeNameTextField.delegate = self;
    _bikeNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.contentView addSubview:_bikeNameTextField];
    
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(50);
        make.leading.trailing.equalTo(20);
        make.height.equalTo(30);
    }];
    [_bikeNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hintLabel.mas_bottom).offset(20);
        make.trailing.equalTo(@-20);
        make.leading.equalTo(@20);
        make.height.equalTo(@40);
    }];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_bikeNameTextField.mas_bottom).offset(50);
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.height.equalTo(40);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([NSString checkBikeName:_bikeNameTextField.text]) {
        [self showWarningHint:[NSString checkBikeName:_bikeNameTextField.text]];
        return YES;
    }
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField {
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
        else {
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else {
        if (toBeString.length > 10) {
            textField.text = [toBeString subEmojiStringToIndex:10];
            [self showHint:@"已到输入上限"];
        }
    }
}

-(void)nextBtnClicked {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    if ([NSString checkBikeName:_bikeNameTextField.text]) {
        [self showWarningHint:[NSString checkBikeName:_bikeNameTextField.text]];
        return;
    }
    
    if ([_bikeNameTextField isFirstResponder]) {
        [_bikeNameTextField resignFirstResponder];
    }
    
    G100BikeEditFeatureViewController *newBikeFeature = [[G100BikeEditFeatureViewController alloc] init];
    newBikeFeature.userid = self.userid;
    newBikeFeature.entranceFrom = BikeEditFeatureEntranceFromAddBike;
    
    self.bikeInfo.name = _bikeNameTextField.text;
    newBikeFeature.bikeInfo = self.bikeInfo;
    
    __weak typeof(self) wself = self;
    newBikeFeature.bikeFeatureBlock = ^(G100BikeUpdateInfoDomain *bikeInfo){
        wself.bikeInfo = bikeInfo;
        wself.bikeNameTextField.text = bikeInfo.name;
    };
    
    [self.navigationController pushViewController:newBikeFeature animated:YES];
}

#pragma mark - 重写父类方法
- (void)actionClickNavigationBarLeftButton {
    if (self.bikeNameTextField.text != nil && self.bikeNameTextField.text.length != 0) {
        // 有信息变动 提示用户保存
        __weak typeof(self) wself = self;
        [MyAlertView MyAlertWithTitle:nil message:@"你是否放弃添加车辆" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [wself.navigationController popViewControllerAnimated:YES];
            }
            else {
                [wself saveInfo];
            }
        } cancelButtonTitle:@"放弃" otherButtonTitles:@"不放弃"];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/** 保存信息 - 添加车辆 */
- (void)saveInfo {
    // 检测电动车名字输入
    if ([NSString checkBikeName:[self.bikeInfo.name trim]]) {
        [self showHint:[NSString checkBikeName:[self.bikeInfo.name trim]]];
        return;
    }
    
    __weak G100NewBikeViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeListWithUserid:wself.userid updateType:BikeListAddType complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [wself showHint:@"车辆添加成功"];
                    [wself.navigationController popViewControllerAnimated:YES];
                }
            }];
        }else {
            [wself showHint:response.errDesc];
        }
    };
    
    [self showHudInView:self.view hint:@"正在添加"];
    [[G100BikeApi sharedInstance] addBikeWithUserid:self.userid bikeInfo:[self.bikeInfo mj_keyValues] callback:callback];
}

- (G100BikeUpdateInfoDomain *)bikeInfo {
    if (!_bikeInfo) {
        _bikeInfo = [[G100BikeUpdateInfoDomain alloc] init];
    }
    
    return _bikeInfo;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationTitle:@"添加车辆"];
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasAppear) {
        [self.bikeNameTextField becomeFirstResponder];
    }
    
    self.hasAppear = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
