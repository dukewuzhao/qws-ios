//
//  G100DevLostNewTagViewController.m
//  G100
//
//  Created by yuhanle on 16/4/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevLostNewTagViewController.h"
#import "IQTextView.h"
#import "G100BikeApi.h"

#import "G100PhotoPickerView.h"
#import "G100PhotoShowModel.h"
#import "NSString+Tool.h"

@interface G100DevLostNewTagViewController () <G100PhotoPickerDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) IQTextView *msgTextView;
@property (nonatomic, strong) G100PhotoPickerView *photoPickerView;

@property (nonatomic, strong) UILabel *wordLimitLabel;

@property (nonatomic, strong) NSMutableArray *imgArray;

@end

@implementation G100DevLostNewTagViewController

#pragma mark - G100PhotoPickerDelegate
- (void)pickerView:(G100PhotoPickerView*)pickerView hasChangedPhotos:(NSArray*)photos {
    [self.imgArray removeAllObjects];
    
    for (G100PhotoShowModel *model in photos) {
        NSString *base64 = [GTMBase64 stringByEncodingData:model.data];
        [self.imgArray addObject:base64];
    }
}

#pragma mark - 发送信息
- (void)tl_sendMsgButtonClick {
    NSString *msg = [_msgTextView text];
    
    if ([NSString isEmpty:msg]) {//限制全部空格
        msg = @"";
    }
    
    if (0 == msg.length && self.imgArray.count == 0) {
        [self showWarningHint:@"内容不能为空"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak G100DevLostNewTagViewController *wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        wself.rightButton.enabled = YES;
        if (requestSuccess) {
            [wself showHint:@"发送成功"];
            [wself.navigationController popViewControllerAnimated:YES];
        }else {
            if (response.errDesc.length) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [[G100BikeApi sharedInstance] addFindLostRecordWithBikeid:_bikeid
                                                   lostid:self.lostid
                                                     desc:[msg trim]
                                                  picture:self.imgArray.copy
                                                 callback:callback];
    
    self.rightButton.enabled = NO;
    [self showHudInView:self.view hint:@"发送中"];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *toBeString = textView.text;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    NSString *lang = current.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 48) {
                textView.text = [toBeString subEmojiStringToIndex:48];
            }
            self.wordLimitLabel.text = [NSString stringWithFormat:@"(%@/48)", @(textView.text.length <= 48 ? textView.text.length : 48)];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 48) {
            textView.text = [toBeString subEmojiStringToIndex:48];
        }
        self.wordLimitLabel.text = [NSString stringWithFormat:@"(%@/48)", @(textView.text.length <= 48 ? textView.text.length : 48)];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] ) {
        [self tl_sendMsgButtonClick];
        return NO;
    }
    return YES;
}
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (toBeString.length > 48) {
        return NO;
    }
    
    return YES;
}
 */

#pragma mark - setupData
- (void)setupData {
    
}

- (NSMutableArray *)imgArray {
    if (!_imgArray) {
        _imgArray = [[NSMutableArray alloc] init];
    }
    return _imgArray;
}

#pragma mark - setupView
- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _rightButton.frame = CGRectMake(0, 0, 40, 30);
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_rightButton setTitle:@"发送" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(tl_sendMsgButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}
- (IQTextView *)msgTextView {
    if (!_msgTextView) {
        _msgTextView = [[IQTextView alloc] init];
        _msgTextView.font = [UIFont systemFontOfSize:16];
        _msgTextView.textColor = [UIColor colorWithHexString:@"000000"];
        _msgTextView.placeholder = @"这一刻的想法";
        [_msgTextView setReturnKeyType:UIReturnKeySend];
        _msgTextView.delegate = self;
    }
    return _msgTextView;
}
- (G100PhotoPickerView *)photoPickerView {
    if (!_photoPickerView) {
        _photoPickerView = [[G100PhotoPickerView alloc] initWithPoint:CGPointMake(20, 150)];
        _photoPickerView.delegate = self;
        _photoPickerView.isAllowEdit = YES;
        _photoPickerView.maxSeletedNumber = 3;
    }
    return _photoPickerView;
}
- (UILabel *)wordLimitLabel {
    if (!_wordLimitLabel) {
        _wordLimitLabel = [[UILabel alloc] init];
        _wordLimitLabel.textColor = [UIColor colorWithHexString:@"B0B0B0"];
        _wordLimitLabel.font = [UIFont systemFontOfSize:12.0f];
        _wordLimitLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _wordLimitLabel;
}

- (void)setupView {
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.msgTextView];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBarView.mas_bottom);
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.height.equalTo(@240);
    }];
    
    [_msgTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.height.equalTo(@100);
    }];
    
    [self.containerView addSubview:self.photoPickerView];
    [self.containerView addSubview:self.wordLimitLabel];
    
    [_wordLimitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.top.equalTo(self.msgTextView.mas_bottom).with.offset(@10);
    }];
    self.wordLimitLabel.text = @"(0/48)";
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:@"我来写一条"];
    [self setRightNavgationButton:self.rightButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupData];
    
    [self setupView];
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
