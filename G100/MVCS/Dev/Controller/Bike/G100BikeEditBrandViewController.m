//
//  G100BikeEditBikeNameViewController.m
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeEditBrandViewController.h"
#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "G100BikeUpdateInfoDomain.h"

@interface G100BikeEditBrandViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextField *inputTextFiled;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UITableView *brandTableView;
@property (nonatomic, strong) NSMutableArray <G100BrandInfoDomain *> *dataArray;

@property (nonatomic, copy) NSString *selectedBrandName;
@property (strong, nonatomic) G100BikeUpdateInfoDomain *bikeUpdateInfo;
@property (nonatomic, strong) G100BikeDomain *bikeDomain;


@end

@implementation G100BikeEditBrandViewController

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

- (UITableView *)brandTableView {
    if (!_brandTableView) {
        _brandTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _brandTableView.delegate = self;
        _brandTableView.dataSource = self;
        _brandTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _brandTableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
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
    [self setNavigationTitle:@"编辑品牌"];
    
    [self.contentView addSubview:self.inputTextFiled];
    [self.contentView addSubview:self.hintLabel];
    [self.contentView addSubview:self.brandTableView];
    
    self.inputTextFiled.placeholder = @"";
    if ([[self.oldName trim] length]) {
        self.inputTextFiled.text = self.oldName;
        self.selectedBrandName = self.oldName;
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
    
    [self.brandTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.bottom.equalTo(@0);
        make.top.equalTo(self.inputTextFiled.mas_bottom).with.offset(10);
    }];
    
    self.hintLabel.hidden = YES;
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
        [self showWarningHint:@"品牌名不能空着"];
        return;
    }
    
    if (kNetworkNotReachability) {
        [self showWarningHint:kError_Network_NotReachable];
        return;
    }
    
    [self.inputTextFiled resignFirstResponder];
    [self updateBikeInfo:@{@"cust_brand" : self.inputTextFiled.text}];
}

- (void)updateBikeInfo:(NSDictionary *)bikeInfo {
    __weak __typeof__(self) wself = self;
    [self showHudInView:self.contentView hint:@"修改中"];
    self.bikeUpdateInfo.brand.name = bikeInfo[@"cust_brand"];
    [[G100BikeApi sharedInstance] updateBikeProfileWithBikeid:self.bikeid bikeType:self.bikeDomain.bike_type  profile:[self.bikeUpdateInfo mj_keyValues] progress:nil callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    G100BrandInfoDomain *domain = [self.dataArray safe_objectAtIndex:indexPath.row];
    cell.textLabel.text = domain.name;
    
    if ([cell.textLabel.text isEqualToString:self.selectedBrandName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    G100BrandInfoDomain *domain = [self.dataArray safe_objectAtIndex:indexPath.row];
    self.selectedBrandName = domain.name;
    self.inputTextFiled.text = self.selectedBrandName;
    [self.brandTableView reloadData];
    
    if ([_inputTextFiled.text isEqualToString:self.oldName]) {
        _saveButton.enabled = NO;
    }else {
        _saveButton.enabled = YES;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
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
    }else {
        _saveButton.enabled = YES;
    }
    
    self.selectedBrandName = _inputTextFiled.text;
    [self.brandTableView reloadData];
}

#pragma mark - 
- (void)fetchedBanrdsData:(BOOL)showHUD {
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [self.dataArray removeAllObjects];
        
        if (requestSuccess) {
            NSArray *brands = response.data[@"brands"];
            for (NSDictionary *brand in brands) {
                G100BrandInfoDomain *domain = [[G100BrandInfoDomain alloc] initWithDictionary:brand];
                [self.dataArray addObject:domain];
            }
        }
        
        [self.brandTableView reloadData];
    };
    
    [[G100BikeApi sharedInstance] getBikeBrandsWithBikeType:self.bikeType :callback];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 刷新品牌列表
    [self fetchedBanrdsData:NO];
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
