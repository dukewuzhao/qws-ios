//
//  ThirdAccountViewController.m
//  G100
//
//  Created by Tilink on 15/6/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ThirdAccountViewController.h"
#import "G100TrAccountDomain.h"
#import "ThirdAccountCell.h"
#import "G100UserApi.h"
#import "MJRefresh.h"
#import <UMShare/UMShare.h>
#import "G100FunctionViewController.h"
#import "G100NewPromptBox.h"
#import "G100ThirdAuthManager.h"
#import <WXApi.h>
@interface ThirdAccountViewController () <G100TrAccountDomainDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL hasAppear;
}

@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableArray *prlist;
@property (strong, nonatomic) NSMutableArray *localDictArray;
// 三方登录信息
@property (copy, nonatomic) NSString *partner;
@property (copy, nonatomic) NSString *partneraccount;
@property (copy, nonatomic) NSString *partneraccounttoken;
@property (copy, nonatomic) NSString *partneruseruid;

@property (assign, nonatomic) UserLoginType loginType;

@end

@implementation ThirdAccountViewController

-(void)dealloc {
    DLog(@"三方帐号页面已释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:@"第三方帐号"];
    
    self.dataArray = [[NSMutableArray alloc]init];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.bottom.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
    
    self.loginType = [UserManager shareManager].loginType;
    self.localDictArray = [[NSMutableArray alloc]init];
    
    if ([[UserManager shareManager]getAsynchronousWithKey:@"localthirdaccount"]) {
        NSArray * localAccount = [[UserManager shareManager]getAsynchronousWithKey:@"localthirdaccount"];
        for (NSInteger i = 0; i < localAccount.count; i++) {
            G100TrAccountDomain * domain = [[G100TrAccountDomain alloc]initWithDictionary:localAccount[i]];
            [_dataArray addObject:domain];
        }
    }else {
        
    }
    
    __weak ThirdAccountViewController * wself = self;
    MJRefreshHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself requsetThirdAccountInfoShowHUD:NO];
    }];
    header.lastUpdatedTimeKey = NSStringFromClass([self class]);
    self.tableView.mj_header = header;
    hasAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewControllerBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (hasAppear) {
        [self requsetThirdAccountInfoShowHUD:NO];
    }else {
        [self requsetThirdAccountInfoShowHUD:YES];
        hasAppear = YES;
    }
}
- (void)viewControllerBecomeActive{
    [self requsetThirdAccountInfoShowHUD:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * indentifier = @"thirdaccountcell";
    ThirdAccountCell * trCell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (trCell == nil) {
        trCell = [[[NSBundle mainBundle]loadNibNamed:@"ThirdAccountCell" owner:self options:nil]lastObject];
    }
    
    trCell.delegate = self;
    G100TrAccountDomain * domain = [_dataArray safe_objectAtIndex:indexPath.row];
    
    [trCell showCellWithDomain:domain];
    
    return trCell;
}

-(void)authorizeorCancelWithAccount:(G100TrAccountDomain *)domain On_off:(BOOL)isBind {
    if (domain.isBind) {
        // 已绑定  解绑
        [self unbindPartnerRelationWithDomain:domain showHUD:YES];
    }else {
        // 绑定第三方帐号
        self.partner = domain.partner;
        switch (domain.accountType) {
            case SinaAccountType:
            {
                [self getSina];
            }
                break;
            case WxAccountType:
            {
                [self getWx];
            }
                break;
            case QQAccountType:
            {
                [self getQQ];
            }
                break;
            default:
                break;
        }
    }
    
    [self requsetThirdAccountInfoShowHUD:NO];
}

-(void)unbindPartnerRelationWithDomain:(G100TrAccountDomain *)domain showHUD:(BOOL)showHUD {
    __weak ThirdAccountViewController * wself = self;
    __block G100NewPromptDefaultBox *box = nil;
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (showHUD) {
            [wself hideHud];
        }
        if (requestSuccess) {
            [wself showHint:@"取消授权成功"];
            [wself requsetThirdAccountInfoShowHUD:NO];
            // 从本地移除友盟存储的所有数据
            [wself cancelAuthosizedWithType:domain.accountType];
            
            if (domain.accountType == WxAccountType) {
                if (box) {
                    [box dismissWithVc:wself animation:YES];
                }
            }
        }else {
            if (NOT_NULL(response)) {
                [wself showHint:response.errDesc];
                [wself requsetThirdAccountInfoShowHUD:NO];
            }
        }
    };
    
    // 判断该用户是否开通了微信报警
    G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:self.userid];
    if ([userDomain isOpenWxAlarmPush] && domain.accountType == WxAccountType) {
        // 如果用户解绑微信帐号 而且此时用户已经开通了任何设备的微信报警提醒 则提醒用户危险
        box = [G100NewPromptDefaultBox promptAlertViewWithDefaultStyle];
        [box showPromptBoxWithTitle:@"提醒" content:@"您已开通微信报警服务，\n如果解绑微信帐号，\n将无法收到微信报警" confirmButtonTitle:@"放弃解绑" cancelButtonTitle:@"确认解绑" event:^(NSInteger index) {
            if (index == 0) {
                [box dismissWithVc:wself animation:YES];
            }else if (index == 1) {
                if (showHUD) {
                    [wself showHudInView:wself.contentView hint:@"正在解绑"];
                }
                [[G100UserApi sharedInstance] sv_unbindPartnerRelationWithPartner:domain.partner partnerAccount:domain.partner_account partnertoken:domain.partner_account_token partner_user_uid:domain.partner_user_uid callback:callback];
            }
            
        } onViewController:wself onBaseView:wself.view];
        
    }else {
        if (showHUD) {
            [self showHudInView:self.contentView hint:@"正在解绑"];
        }
         [[G100UserApi sharedInstance] sv_unbindPartnerRelationWithPartner:domain.partner partnerAccount:domain.partner_account partnertoken:domain.partner_account_token partner_user_uid:domain.partner_user_uid callback:callback];
    }
}

#pragma mark - 第三方登录
-(void)getWx {
    __weak ThirdAccountViewController * wself = self;
    [G100ThirdAuthManager getThirdWechatAccountWithPresentVC:self complete:^(UMSocialUserInfoResponse *thirdAccount, NSError *error) {
        if (error) {
            
        }else {
            [wself authSuccessWith:thirdAccount];
        }
    }];
}

-(void)getQQ {
    __weak ThirdAccountViewController * wself = self;
    [G100ThirdAuthManager getThirdQQAccountWithPresentVC:self complete:^(UMSocialUserInfoResponse *thirdAccount, NSError *error) {
        if (error) {
            
        }else {
            [wself authSuccessWith:thirdAccount];
        }
    }];
}

-(void)getSina {
    __weak ThirdAccountViewController * wself = self;
    [G100ThirdAuthManager getThirdSinaAccountWithPresentVC:self complete:^(UMSocialUserInfoResponse *thirdAccount, NSError *error) {
        if (error) {
            
        }else {
            [wself authSuccessWith:thirdAccount];
        }
    }];
}

#pragma mark - 授权成功
-(void)authSuccessWith:(UMSocialUserInfoResponse *)snsAccount {
    self.partneraccount = snsAccount.openid.length ? snsAccount.openid :snsAccount.uid;
    self.partneruseruid = snsAccount.uid;
    
    // 制作用户的临时密码 临时密码格式：360[渠道][用户id]QWS[YYYYMMDD] + md5
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * pw = [formatter stringFromDate:[NSDate date]];
    
    self.partneraccounttoken = [[NSString stringWithFormat:@"360%@%@QWS%@", self.partner, self.partneraccount, pw] stringFromMD5];
    
    // 判断是否存在第三方登录信息
    __weak ThirdAccountViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            // 调登录接口   此处肯定不存在该帐号
            [wself showHint:@"该平台已绑定其他帐号"];
            [wself requsetThirdAccountInfoShowHUD:NO];
        }else {
            // 不存在  去注册
            if (response) {
                if (response.errCode == 57) {
                    [wself authorizeBindThird];
                }else if (response.errCode == 56) {
                    [wself showHint:@"请检查系统时间是否正确"];
                }
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_checkThirdAccountWithpPartner:_partner
                                                    partneraccount:_partneraccount
                                               partneraccounttoken:_partneraccounttoken
                                                    partneruseruid:_partneruseruid
                                                          callback:callback];
}

-(void)authorizeBindThird {
    __weak ThirdAccountViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        [wself hideHud];
        if (requestSucces) {
            [wself showHint:@"授权成功"];
            
            /** 20160630 1.4.1 版本 去掉该提示
            // 授权绑定微信成功以后 提示用户前往安防设置开通微信消息报警提醒 如果用户没有绑定任何设备则不提示
            if ([wself.partner isEqualToString:@"wx"] && IsBind()) {
                // 提醒用户去安防设置 设置微信报警推送
                G100NewPromptDefaultBox *box = [G100NewPromptDefaultBox promptAlertViewWithDefaultStyle];
                [box showPromptBoxWithTitle:@"您已成功绑定微信" content:@"您还可以设置\n通过微信等接收报警通知" confirmButtonTitle:@"去设置" cancelButtonTitle:@"忽略" event:^(NSInteger index) {
                    if (index == 0) {
                        G100FunctionViewController *funVC = [[G100FunctionViewController alloc] init];
                        funVC.userid = wself.userid;
                        funVC.devid  = wself.devid;
                        [wself.navigationController pushViewController:funVC animated:YES];
                    }else if (index == 1) {
                        
                    }
                    
                    [box dismissWithVc:wself animation:YES];
                } onViewController:wself onBaseView:wself.view];
            }
             */
            
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
        
        // 注册成功
        [wself requsetThirdAccountInfoShowHUD:NO];
    };
    [[G100UserApi sharedInstance] sv_bindPartnerRelationPartner:_partner partneraccount:_partneraccount partnertoken:_partneraccounttoken partner_user_uid:_partneruseruid callback:callback];
}

#pragma mark - 删除授权
-(void)cancelAuthosizedWithType:(ThirdAccountType)accountType {
    // 删除授权
    switch (accountType) {
        case SinaAccountType:
        {
            [G100ThirdAuthManager cancelAuthWithPlatform:UMSocialPlatformType_Sina completion:nil];
        }
            break;
        case WxAccountType:{
            [G100ThirdAuthManager cancelAuthWithPlatform:UMSocialPlatformType_WechatSession completion:nil];
        }
            break;
        case QQAccountType:
        {
            [G100ThirdAuthManager cancelAuthWithPlatform:UMSocialPlatformType_QQ completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 请求刷新第三方帐号
-(void)requsetThirdAccountInfoShowHUD:(BOOL)showHUD {
    __weak ThirdAccountViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself.tableView.mj_header endRefreshing];
        if (showHUD) {
            [wself hideHud];
        }
        
        if (requestSuccess) {
            NSArray * prlist = [response.data objectForKey:@"partners"];
            if (prlist.count && NOT_NULL(prlist)) {
                wself.prlist = prlist.mutableCopy;
            }else {
                wself.prlist = nil;
            }
            
            [wself buildUI];
        }else {
            if (NOT_NULL(response)) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    if (showHUD) {
        [self showHudInView:self.contentView hint:@"正在刷新"];
    }
    [[G100UserApi sharedInstance] sv_getPartnerRelationWithCallback:callback];
}

-(void)buildUI {
    // 根据返回结果构造数据源
    // 清空数据源
    [_dataArray removeAllObjects];
    [_localDictArray removeAllObjects];
    NSDictionary * accountDict;
    if ([WXApi isWXAppInstalled]) {
        accountDict = @{@"sina" : @"新浪微博", @"qq" : @"QQ", @"wx" : @"微信"};
    }else{
        accountDict = @{@"sina" : @"新浪微博", @"qq" : @"QQ"};
    }
    NSArray * keys = [accountDict allKeys];
    for (NSString * key in keys) {
        G100TrAccountDomain * trAccount = [self searchThirdAccountWithKey:key];
        if (trAccount) {
            trAccount.isBind = YES;
            trAccount.accountName = [accountDict objectForKey:key];
        }else {
            trAccount = [[G100TrAccountDomain alloc]init];
            trAccount.isBind = NO;
            trAccount.partner = key;
            trAccount.accountName = [accountDict objectForKey:key];
        }
        
        if ([trAccount.partner isEqualToString:@"sina"]) {
            trAccount.accountType = SinaAccountType;
        }else if ([trAccount.partner isEqualToString:@"qq"]) {
            trAccount.accountType = QQAccountType;
        }else if ([trAccount.partner isEqualToString:@"wx"]) {
            trAccount.accountType = WxAccountType;
        }
        
        trAccount.enable = YES;
        switch (_loginType) {
            case UserLoginTypePhoneNum:
            {
                trAccount.enable = YES;
            }
                break;
            case UserLoginTypeWeixin:
            {
                if (trAccount.accountType == WxAccountType) {
                    trAccount.enable = NO;
                    trAccount.accountName = [NSString stringWithFormat:@"%@（当前在线）", trAccount.accountName];
                }
            }
                break;
            case UserLoginTypeQQ:
            {
                if (trAccount.accountType == QQAccountType) {
                    trAccount.enable = NO;
                    trAccount.accountName = [NSString stringWithFormat:@"%@（当前在线）", trAccount.accountName];
                }
            }
                break;
            case UserLoginTypeSina:
            {
                if (trAccount.accountType == SinaAccountType) {
                    trAccount.enable = NO;
                    trAccount.accountName = [NSString stringWithFormat:@"%@（当前在线）", trAccount.accountName];
                }
            }
                break;
            default:
                break;
        }
        
        [_dataArray addObject:trAccount];
        [_localDictArray addObject:[trAccount mj_keyValues]];
    }
    
    [[UserManager shareManager]setAsynchronous:_localDictArray.copy withKey:@"localthirdaccount"];
    
    [self.tableView reloadData];
}

-(G100TrAccountDomain *)searchThirdAccountWithKey:(NSString *)key {
    G100TrAccountDomain * trAccount = nil;
    
    if (!_prlist) {
        return nil;
    }
    
    for (NSDictionary * dict in _prlist) {
        if ([[dict objectForKey:@"partner"] isEqualToString:key]) {
            trAccount = [[G100TrAccountDomain alloc]initWithDictionary:dict];
            return trAccount;
        }
    }
    
    return trAccount;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
