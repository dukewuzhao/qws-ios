//
//  G100ManuallyBindDevViewController.m
//  G100
//
//  Created by yuhanle on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ManuallyBindDevViewController.h"
#import "G100AlertConfirmClickView.h"

@interface G100ManuallyBindDevViewController ()

@property (nonatomic, strong) UITextField *qrTextField;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) G100AlertConfirmClickView *sureBtn;

@property (copy, nonatomic) void (^completionBlock) (NSString *);

@end

@implementation G100ManuallyBindDevViewController

- (void)dealloc {
    DLog(@"手动输入绑定设备页面已释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialData];
    
    [self setupView];
}

- (void)initialData {
    if (!_userid) {
        _userid = [[G100InfoHelper shareInstance] buserid];
    }
}

- (void)setupView {
    [self setNavigationTitle:@"手动绑定"];
    
    self.qrTextField = [[UITextField alloc] init];
    self.qrTextField.backgroundColor = [UIColor whiteColor];
    [self.qrTextField setKeyboardType:UIKeyboardTypeASCIICapable];
    self.qrTextField.returnKeyType = UIReturnKeyDone;
    self.qrTextField.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:self.qrTextField];
    
    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.font = [UIFont systemFontOfSize:14];
    self.hintLabel.text = @"请输入二维码下方的编码";
    self.hintLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:self.hintLabel];
    
    __weak __typeof__(self) weakSelf = self;
    self.sureBtn = [G100AlertConfirmClickView confirmClickView];
    [self.sureBtn.confirmButton setTitle:@"确认绑定" forState:UIControlStateNormal];
    self.sureBtn.confirmClickBlock = ^(){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf sureButtonClick];
    };
    [self.view addSubview:self.sureBtn];
    
    [self.qrTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@10);
        make.trailing.equalTo(@-10);
        make.top.equalTo(kNavigationBarHeight + 16);
        make.height.equalTo(@40);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.qrTextField.mas_leading);
        make.top.equalTo(self.qrTextField.mas_bottom).with.offset(@5);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@10);
        make.trailing.equalTo(@-10);
        make.top.equalTo(self.hintLabel.mas_bottom).equalTo(@15);
        make.height.equalTo(@40);
    }];
    
    if (_qrcode.length)  _qrTextField.text = _qrcode;
}

#pragma mark - Private method
- (void)sureButtonClick {
    DLog(@"确认绑定新的设备");
    if (self.qrTextField.isFirstResponder) {
        [self.qrTextField resignFirstResponder];
    }
    if (self.completionBlock) {
        self.completionBlock([_qrTextField.text trim]);
    }
}

#pragma mark - Public method
- (void)setCompletionWithBlock:(void (^)(NSString *))completionBlock {
    self.completionBlock = completionBlock;
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
