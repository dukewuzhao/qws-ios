//
//  G100PersonProfileViewController.m
//  G100
//
//  Created by yuhanle on 16/7/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PersonProfileViewController.h"
#import "PersonProfileHeaderView.h"
#import "ThirdAccountViewController.h"
#import "ChangePhoneNumViewController.h"

#import "ModifyUsernameViewController.h"
#import "ModifyRealnameViewController.h"
#import "ModifyIDCarNumViewController.h"

#import "G100BaseArrowItem.h"
#import "G100BaseLabelItem.h"
#import "G100BaseCell.h"
#import "PersonThirdAccountCell.h"

#import "G100PickActionSheet.h"

#import "G100AccountDomain.h"
#import "G100UserDomain.h"
#import "G100TrAccountDomain.h"
#import <WXApi.h>
#import "G100Mediator+Login.h"
#import "G100HomeSetViewController.h"

static NSString * const kBaseItemKeyUserNickName     = @"nick_name";
static NSString * const kBaseItemKeyUserRealName     = @"real_name";
static NSString * const kBaseItemKeyUserIDCardNumber = @"id_card_no";
static NSString * const kBaseItemKeyUserPhoneNumber  = @"phone_num";
static NSString * const kBaseItemKeyUserGender       = @"gender";
static NSString * const kBaseItemKeyUserBirthday     = @"birthday";
static NSString * const kBaseItemKeyUserThirdAcconut = @"third_account";
static NSString * const kBaseItemKeyUserExitAcconut  = @"exit_account";
static NSString * const kBaseItemKeyUserHomeAddress  = @"home_Address";

static NSString * const kHintAccompaniedHint = @"骑卫士已陪伴您%@天";

@interface G100PersonProfileViewController () <UITableViewDelegate, UITableViewDataSource, PersonProfileHeaderViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) PersonProfileHeaderView *profileHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *thirdAccountArray;

@property (nonatomic, strong) UIView *exitBtnView;
@property (nonatomic, strong) UILabel *accompaniedHintLabel;
@property (nonatomic, assign) MASConstraint *hintLabelConstraintTop;

@property (nonatomic, strong) G100BaseArrowItem *nick_nameItem;
@property (nonatomic, strong) G100BaseArrowItem *real_nameItem;
@property (nonatomic, strong) G100BaseArrowItem *id_card_noItem;
@property (nonatomic, strong) G100BaseArrowItem *phone_numItem;
@property (nonatomic, strong) G100BaseArrowItem *genderItem;
@property (nonatomic, strong) G100BaseArrowItem *birthdayItem;
@property (nonatomic, strong) G100BaseArrowItem *thirdAccountItem;
@property (nonatomic, strong) G100BaseArrowItem *homeAddressItem;

@property (nonatomic, strong) G100BaseLabelItem *exitAccountItem;

@property (nonatomic, strong) G100AccountDomain *account;
/** 记录初始用户信息*/
@property (nonatomic, strong) G100UserDomain *initialUserInfo;

@end

@implementation G100PersonProfileViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperUserInfoDidChangeNotification object:nil];
}

#pragma mark - setup
- (void)initialData {
    [self dataArray];
    
    if ([[UserManager shareManager] getAsynchronousWithKey:@"localthirdaccount"]) {
        NSArray * localAccount = [[UserManager shareManager] getAsynchronousWithKey:@"localthirdaccount"];
        for (NSInteger i = 0; i < localAccount.count; i++) {
            G100TrAccountDomain * domain = [[G100TrAccountDomain alloc] initWithDictionary:localAccount[i]];
            [self.thirdAccountArray addObject:domain];
        }
    }else {
        ;
    }
}

- (void)setupNavigationBarView {
    self.navigationBarView.backgroundColor = [UIColor clearColor];
}

- (void)setupView {
    [self.view insertSubview:self.tableView belowSubview:self.navigationBarView];
    
    // 设置headerView
    CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat headerHeight = kScreenWidth / (414/194.0);
    headerHeight = ISIPHONEX ? 194 : headerHeight;
    
    [self.view insertSubview:self.profileHeaderView aboveSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"e9e9e9"]];
    
    [self.profileHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(@0);
        make.height.equalTo(headerHeight);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileHeaderView.mas_bottom);
        make.leading.bottom.trailing.equalTo(@0);
    }];
    
    /** 设置footerView
    self.exitBtnView.frame = CGRectMake(0, 0, kScreenWidth, 80);
    [self.tableView setTableFooterView:self.exitBtnView];
     */
    
    [self.view insertSubview:self.accompaniedHintLabel belowSubview:self.navigationBarView];
    [self.accompaniedHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.height.equalTo(@25);
        self.hintLabelConstraintTop = make.top.equalTo(@30);
    }];
    self.accompaniedHintLabel.alpha = 0.0;
    
    //为 self.headerView 添加阴影效果
    [[self.profileHeaderView layer] setShadowOffset:CGSizeMake(0, 2)];
    [[self.profileHeaderView layer] setShadowRadius:2];
    [[self.profileHeaderView layer] setShadowOpacity:0.8];
    [[self.profileHeaderView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
}

#pragma mark - 通知监听
- (void)userInfoDidChange:(NSNotification *)notification {
    self.userid = notification.userInfo[@"user_id"];
    self.account = [[G100InfoHelper shareInstance] findMyAccountInfoWithUserid:self.userid];
}

#pragma mark - UITableViewDelegate 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataArray safe_objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100BaseArrowItem *item = [[self.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    UITableViewCell *viewCell;
    if ([item.itemkey isEqualToString:kBaseItemKeyUserExitAcconut]) {
        // 退出当前帐号
        viewCell = [tableView dequeueReusableCellWithIdentifier:item.itemkey];
        if (!viewCell) {
            viewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:item.itemkey];
            viewCell.textLabel.textColor = [UIColor redColor];
            viewCell.textLabel.font = [UIFont systemFontOfSize:16];
            viewCell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        }
        viewCell.textLabel.text = item.title;
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserThirdAcconut]) {
        // 第三方帐号
        PersonThirdAccountCell *viewCell = (PersonThirdAccountCell *)[tableView dequeueReusableCellWithIdentifier:item.itemkey];
        if (!viewCell) {
            viewCell = [[PersonThirdAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:item.itemkey];
            viewCell.textLabel.font = [UIFont systemFontOfSize:16];
            viewCell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        }
        viewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        viewCell.leftTitleLabel.text = item.title;
        [viewCell setThirdAccountArray:self.thirdAccountArray];
//        if (![[[[UserAccount sharedInfo] appfunction] profile_otheraccount] enable]) {
//            viewCell.userInteractionEnabled = NO;
//            [viewCell setAccessoryType:UITableViewCellAccessoryNone];
//        }
        return viewCell;
    }else {
        viewCell = [G100BaseCell cellWithTableView:tableView item:item];
        ((G100BaseCell *)viewCell).item = item;
        
        if ([item.itemkey isEqualToString:kBaseItemKeyUserNickName] ||
            [item.itemkey isEqualToString:kBaseItemKeyUserRealName] ||
            [item.itemkey isEqualToString:kBaseItemKeyUserIDCardNumber] ||
            [item.itemkey isEqualToString:kBaseItemKeyUserPhoneNumber]||
            [item.itemkey isEqualToString:kBaseItemKeyUserHomeAddress]) {
            
            if (!item.subtitle.length) {
                viewCell.detailTextLabel.text = @"未填写";
            }else {
                if ([item.itemkey isEqualToString:kBaseItemKeyUserIDCardNumber] ||
                    [item.itemkey isEqualToString:kBaseItemKeyUserPhoneNumber]) {
                    viewCell.detailTextLabel.text = [NSString shieldImportantInfo:item.subtitle];
                }
            }
            if (![[[[UserAccount sharedInfo] appfunction] profile_nickname] enable] && [item.itemkey isEqualToString:kBaseItemKeyUserNickName]) {
                viewCell.userInteractionEnabled = NO;
                [viewCell setAccessoryType:UITableViewCellAccessoryNone];
            }
            if (![[[[UserAccount sharedInfo] appfunction] profile_modifyphonenum] enable] && [item.itemkey isEqualToString:kBaseItemKeyUserPhoneNumber]) {
                viewCell.userInteractionEnabled = NO;
                [viewCell setAccessoryType:UITableViewCellAccessoryNone];
            }
            if (![[[[UserAccount sharedInfo] appfunction] profile_birthday] enable] && [item.itemkey isEqualToString:kBaseItemKeyUserIDCardNumber]) {
                viewCell.userInteractionEnabled = NO;
                [viewCell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
        
        if ([item.itemkey isEqualToString:kBaseItemKeyUserGender] ||
            [item.itemkey isEqualToString:kBaseItemKeyUserBirthday]) {
            
            if (!item.subtitle.length || [item.subtitle isEqualToString:@""]) {
                viewCell.detailTextLabel.text = @"未填写";
            }
            if (![[[[UserAccount sharedInfo] appfunction] profile_gender] enable]) {
                viewCell.userInteractionEnabled = NO;
                [viewCell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    
    return viewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak G100PersonProfileViewController * wself = self;
    G100BaseArrowItem *item = [[self.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    if ([item.itemkey isEqualToString:kBaseItemKeyUserNickName]) {
        // 昵称
        ModifyUsernameViewController * modify = [[ModifyUsernameViewController alloc]init];
        modify.username = item.subtitle;
        modify.sureBlock = ^(NSString * nickname){
            item.subtitle = nickname;
            wself.account.user_info.nick_name = nickname;
            wself.profileHeaderView.nicknameLabel.text = wself.account.user_info.nick_name;
            [tableView reloadData];
        };
        [self.navigationController pushViewController:modify animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserRealName]) {
        // 真实姓名
        ModifyRealnameViewController * modify = [[ModifyRealnameViewController alloc]init];
        modify.realname = item.subtitle;
        modify.sureBlock = ^(NSString * realname){
            item.subtitle = realname;
            [tableView reloadData];
        };
        [self.navigationController pushViewController:modify animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserIDCardNumber]) {
        // 身份证
        ModifyIDCarNumViewController * modify = [[ModifyIDCarNumViewController alloc]init];
        modify.idcardno = item.subtitle;
        modify.sureBlock = ^(NSString * idcardno){
            item.subtitle = idcardno;
            [tableView reloadData];
        };
        [self.navigationController pushViewController:modify animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserPhoneNumber]) {
        // 手机号
        ChangePhoneNumViewController * change = [ChangePhoneNumViewController loadNibViewController:self.userid];
        [self.navigationController pushViewController:change animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserHomeAddress]) {
        // 家
        G100HomeSetViewController * home = [[G100HomeSetViewController alloc] init];
        home.homeInfo = self.account.user_info.homeinfo;
        home.userid = self.userid;
        home.setHomeBloc = ^(NSString *homeAddr) {
            item.subtitle = homeAddr;
            [tableView reloadData];
        };
        [self.navigationController pushViewController:home animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserGender]) {
        // 性别
        G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc] initWithTitle:@"性别" clickedAtIndex:^(NSInteger index) {
            if (index) {
                item.subtitle = index == 1 ? @"男" : @"女";
                if (!self.account.user_info.icon || self.account.user_info.icon.length == 00) {
                    [self.profileHeaderView setAvatarImageData:[UIImage imageNamed: index == 1 ? @"ic_default_male":@"ic_default_female"]];
                }
             [tableView reloadData];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女",nil];
        [actionSheet show];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserBirthday]) {
        // 生日
        [G100AlertView G100DatePickerWithTitle:@"生日" current:item.subtitle alertBlock:^(NSString * selectStr) {
            item.subtitle = selectStr;
            [tableView reloadData];
        }];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserExitAcconut]) {
        // 退出当前帐号
        if (![UserAccount sharedInfo].appfunction.logout.enable && IsLogin()) {
            return;
        };
        G100ReactivePopingView * popView = [G100ReactivePopingView popingViewWithReactiveView];
        [popView showPopingViewWithTitle:@"退出登录"
                                 content:@"退出登录"
                              noticeType:ClickEventBlockCancel
                              otherTitle:@"取消"
                            confirmTitle:@"确定"
                              clickEvent:^(NSInteger index) {
            __strong typeof(wself) strongSelf = wself;
            if (index == 2) {
                if (kNetworkNotReachability) {
                    [strongSelf showHint:kError_Network_NotReachable];
                    return;
                }
                // 退出登录
                API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
                    [strongSelf hideHud];
                    if (requestSuccess) {
                        [[UserManager shareManager] logoff];
                        // 跳转到登录界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                        [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                            [strongSelf.navigationController popToRootViewControllerAnimated:NO];
                        }];
                    }else {
                        if (response) {
                            [strongSelf showHint:response.errDesc];
                        }
                    }
                };
                [wself showHudInView:strongSelf.view hint:@"正在注销"];
                [[G100UserApi sharedInstance] sv_logoutWithCallback:callback];
            }
            [popView dismissWithVc:strongSelf animation:YES];
        }
                        onViewController:self
                              onBaseView:self.view];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserThirdAcconut]) {
        ThirdAccountViewController * third = [[ThirdAccountViewController alloc]init];
        third.userid = self.userid;
        [self.navigationController pushViewController:third animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

#pragma mark - PersonProfileHeaderViewDelegate
- (void)avatarImageViewDidTapped {
    if (![UserAccount sharedInfo].appfunction.profile_icon.enable && IsLogin()) {
        return;
    };
    __weak G100PersonProfileViewController * wself = self;
    G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc]initWithTitle:@"修改头像" clickedAtIndex:^(NSInteger index) {
        if (index) {
            [wself configPhotoPickWithIndex:index];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"相机",@"相册",nil];
    
    [actionSheet show];
}

- (void)configPhotoPickWithIndex:(NSInteger)buttonIndex {
    // 修改头像
    UIImagePickerController * pc = [[UIImagePickerController alloc]init];
    pc.allowsEditing = YES;
    pc.delegate = self;
    if (buttonIndex == 1) {
        // 设置资源类型 --》 先要检测要设置的资源类型是否可用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [pc setSourceType:UIImagePickerControllerSourceTypeCamera];
            // 根据开发习惯，UIImagePickerController以present的形式出现
            [self presentViewController:pc animated:YES completion:nil];
            
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                if (ISIOS8ADD) {
                    [MyAlertView MyAlertWithTitle:@"允许使用相机" message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"前去允许"];
                }else{
                    [MyAlertView MyAlertWithTitle:@"允许使用相机" message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机" delegate:self withMyAlertBlock:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了"];
                }
            }
        }else {
            UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"相机不可用" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
            [av show];
        }
    } else if (buttonIndex == 2) {
        // 相册选择
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            pc.navigationBar.barTintColor = Color_NavigationBGColor;
            pc.navigationItem.title = @"照片";
            
            [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:20]};
            
            [pc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:pc animated:YES completion:nil];
        }else {
            UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"相册不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            [av show];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate相关
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 选择完成 --> 判断选择完成的资源是image还是media
    NSString * str = [info objectForKey:UIImagePickerControllerMediaType];
    if ([str isEqualToString:(NSString *)kUTTypeImage]) {
        // 若果取到的资源是image --》 把image显示在——photoIv上
        UIImage * originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage * image = [self thumbnailWithImageWithoutScale:originalImage size:CGSizeMake(240, 240)];
        
        NSData * data = UIImageJPEGRepresentation(image, 1.0f);
        if (!data) {
            data = UIImagePNGRepresentation(image);
        }
        
        [self.profileHeaderView setAvatarImageData:image];
        
        if (kNetworkNotReachability) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self showHint:kError_Network_NotReachable];
            return;
        }
        
        NSString * pictureString = [GTMBase64 stringByEncodingData:data];
        __weak G100PersonProfileViewController * wself = self;
        API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
            [wself hideHud];
            if (requestSuccess) {
                // data     icon
                [wself.profileHeaderView setAvatarImageData:image];
                [[UserManager shareManager] updateUserInfoWithUserid:wself.userid complete:nil];
            }else {
                if (response) {
                    [wself showHint:response.errDesc];
                }
            }
        };
        [self showHudInView:self.view hint:@"上传头像"];
        [[G100UserApi sharedInstance] sv_updateUserdataWithUserinfo:@{ @"icon" : pictureString } callback:callback];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize {
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else {
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }else {
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return newimage;
}

#pragma mark - Private method
- (void)exitBtnClick:(UIButton *)button {
    __weak G100PersonProfileViewController * wself = self;
    G100ReactivePopingView * popView = [G100ReactivePopingView popingViewWithReactiveView];
    [popView showPopingViewWithTitle:@"退出登录"
                             content:@"退出登录"
                          noticeType:ClickEventBlockCancel
                          otherTitle:@"取消"
                        confirmTitle:@"确定"
                          clickEvent:^(NSInteger index) {
        if (index == 2) {
            if (kNetworkNotReachability) {
                [wself showHint:kError_Network_NotReachable];
                return;
            }
            // 退出登录
            API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
                [wself hideHud];
                if (requestSuccess) {
                    [[UserManager shareManager] logoff];
                    // 跳转到登录界面
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                    [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                        [wself.navigationController popToRootViewControllerAnimated:NO];
                    }];
                }else {
                    if (response) {
                        [wself showHint:response.errDesc];
                    }
                }
            };
            [wself showHudInView:wself.view hint:@"正在注销"];
            [[G100UserApi sharedInstance] sv_logoutWithCallback:callback];
        }
        [popView dismissWithVc:wself animation:YES];
    }
                    onViewController:self
                          onBaseView:self.view];
}

#pragma mark - 请求刷新第三方帐号
-(void)requsetThirdAccountInfoShowHUD:(BOOL)showHUD {
    __weak G100PersonProfileViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (showHUD) {
            [wself hideHud];
        }
        
        if (requestSuccess) {
            [wself.thirdAccountArray removeAllObjects];
            NSArray * prlist = [response.data objectForKey:@"partners"];
            if (prlist.count && NOT_NULL(prlist)) {
                for (NSInteger i = 0; i < prlist.count; i++) {
                    G100TrAccountDomain * domain = [[G100TrAccountDomain alloc]initWithDictionary:prlist[i]];
                    domain.isBind = YES;
                    if (![domain.partner isEqualToString:@"wx"] || [WXApi isWXAppInstalled]) {
                        [wself.thirdAccountArray addObject:domain];
                    }
                }
            }else {
                ;
            }
            [wself.tableView reloadData];
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

#pragma mark - Lazzy load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _tableView;
}
- (PersonProfileHeaderView *)profileHeaderView {
    if (!_profileHeaderView) {
        _profileHeaderView = [PersonProfileHeaderView loadNibXibView];
        _profileHeaderView.delegate = self;
    }
    return _profileHeaderView;
}
- (UIView *)exitBtnView {
    if (!_exitBtnView) {
        _exitBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        
        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [exitBtn setTintColor:[UIColor whiteColor]];
        exitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [exitBtn setTitle:@"退出当前帐号" forState:UIControlStateNormal];
        [exitBtn setBackgroundColor:RGBColor(36, 172, 28, 1.0)];
        [exitBtn addTarget:self action:@selector(exitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_exitBtnView addSubview:exitBtn];
        
        [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@40);
            make.bottom.equalTo(@-20);
            make.leading.equalTo(@20);
            make.trailing.equalTo(@-20);
        }];
    }
    return _exitBtnView;
}

- (UILabel *)accompaniedHintLabel {
    if (!_accompaniedHintLabel) {
        _accompaniedHintLabel = [[UILabel alloc] init];
        _accompaniedHintLabel.textColor = [UIColor whiteColor];
        _accompaniedHintLabel.text = [NSString stringWithFormat:kHintAccompaniedHint, @(1234)];
        _accompaniedHintLabel.font = [UIFont systemFontOfSize:14];
        _accompaniedHintLabel.textAlignment = NSTextAlignmentCenter;
        _accompaniedHintLabel.backgroundColor = MyGreenColor;
    }
    return _accompaniedHintLabel;
}

- (void)actionClickNavigationBarLeftButton {
    if ([self hasUserInfoChanged]) {
        __weak typeof(self) wself = self;
        G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
        [box showPopingViewWithTitle:@"提示"
                             content:@"你已修改个人信息，是否保存？"
                          noticeType:ClickEventBlockCancel
                          otherTitle:@"不保存"
                        confirmTitle:@"保存"
                          clickEvent:^(NSInteger index) {
            if (index == 2) {
                [wself uploadUserInfo:^(BOOL result) {
                    if (result) {
                        [wself.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else {
                if (index != 0) {
                    [wself.navigationController popViewControllerAnimated:YES];
                }
            }
            [box dismissWithVc:wself animation:YES];
        }
                    onViewController:self
                          onBaseView:self.view];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Items
- (G100BaseArrowItem *)nick_nameItem {
    if (!_nick_nameItem) {
        _nick_nameItem = [[G100BaseArrowItem alloc] init];
        _nick_nameItem.title = @"昵称";
        _nick_nameItem.isRequired = YES;
        _nick_nameItem.subtitle = self.account.user_info.nick_name;
        _nick_nameItem.itemkey = kBaseItemKeyUserNickName;
    }
    return _nick_nameItem;
}
- (G100BaseArrowItem *)real_nameItem {
    if (!_real_nameItem) {
        _real_nameItem = [[G100BaseArrowItem alloc] init];
        _real_nameItem.title = @"真实姓名";
        _real_nameItem.subtitle = self.account.user_info.real_name;
        _real_nameItem.itemkey = kBaseItemKeyUserRealName;
    }
    return _real_nameItem;
}
- (G100BaseArrowItem *)id_card_noItem {
    if (!_id_card_noItem) {
        _id_card_noItem = [[G100BaseArrowItem alloc] init];
        _id_card_noItem.title = @"身份证";
        _id_card_noItem.subtitle = self.account.user_info.id_card_no;
        _id_card_noItem.itemkey = kBaseItemKeyUserIDCardNumber;
    }
    return _id_card_noItem;
}
- (G100BaseArrowItem *)phone_numItem {
    if (!_phone_numItem) {
        _phone_numItem = [[G100BaseArrowItem alloc] init];
        _phone_numItem.title = @"手机号";
        _phone_numItem.isRequired = YES;
        _phone_numItem.subtitle = self.account.user_info.phone_num;
        _phone_numItem.itemkey = kBaseItemKeyUserPhoneNumber;
    }
    return _phone_numItem;
}
- (G100BaseArrowItem *)genderItem {
    if (!_genderItem) {
        _genderItem = [[G100BaseArrowItem alloc] init];
        _genderItem.title = @"性别";
        _genderItem.subtitle = [self.account.user_info.gender integerValue] == 1 ? @"男" : ([self.account.user_info.gender integerValue]== 2 ? @"女" : @"");
        _genderItem.itemkey = kBaseItemKeyUserGender;
    }
    return _genderItem;
}
- (G100BaseArrowItem *)birthdayItem {
    if (!_birthdayItem) {
        _birthdayItem = [[G100BaseArrowItem alloc] init];
        _birthdayItem.title = @"生日";
        _birthdayItem.subtitle = [self.account.user_info.birthday isEqualToString:@"0001-01-01"] == YES ? @"" : self.account.user_info.birthday;
        _birthdayItem.itemkey = kBaseItemKeyUserBirthday;
    }
    return _birthdayItem;
}
- (G100BaseArrowItem *)thirdAccountItem {
    if (!_thirdAccountItem) {
        _thirdAccountItem = [[G100BaseArrowItem alloc] init];
        _thirdAccountItem.title = @"第三方帐号";
        _thirdAccountItem.subtitle = @"";
        _thirdAccountItem.itemkey = kBaseItemKeyUserThirdAcconut;
    }
    return _thirdAccountItem;
}
-(G100BaseArrowItem *)homeAddressItem{
    if (!_homeAddressItem) {
        _homeAddressItem = [[G100BaseArrowItem alloc] init];
        _homeAddressItem.title = @"家的地址";
        _homeAddressItem.subtitle = [self.account.user_info.homeinfo.homeaddr stringByReplacingOccurrencesOfString:@"&" withString:@""];
        _homeAddressItem.itemkey = kBaseItemKeyUserHomeAddress;
    }
    return _homeAddressItem;
}
- (G100BaseLabelItem *)exitAccountItem {
    if (!_exitAccountItem) {
        _exitAccountItem = [[G100BaseLabelItem alloc] init];
        _exitAccountItem.title = @"退出登录";
        _exitAccountItem.subtitle = @"";
        _exitAccountItem.itemkey = kBaseItemKeyUserExitAcconut;
    }
    return _exitAccountItem;
}
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSArray arrayWithObjects:
                      @[self.nick_nameItem,
                        self.real_nameItem,
                        self.id_card_noItem,
                        self.phone_numItem,
                        self.genderItem,
                        self.birthdayItem,
                        self.thirdAccountItem],@[self.homeAddressItem], @[self.exitAccountItem], nil];
    }
    return _dataArray;
}
- (G100AccountDomain *)account {
    if (!_account) {
        _account = [[G100InfoHelper shareInstance] findMyAccountInfoWithUserid:self.userid];
     }
    
    return _account;
}

- (NSMutableArray *)thirdAccountArray {
    if (!_thirdAccountArray) {
        _thirdAccountArray = [[NSMutableArray alloc] init];
    }
    return _thirdAccountArray;
}

#pragma mark - 判断数据是否已经有修改
- (BOOL)hasUserInfoChanged {
    if (self.account.user_info == nil) {
        return NO;
    }
    
    // 判断昵称是否更改
    if (![self.initialUserInfo.nick_name isEqualToString:self.nick_nameItem.subtitle]) {
        return YES;
    }
    
    // 判断真实姓名是否更改
    if (![self.initialUserInfo.real_name isEqualToString:self.real_nameItem.subtitle]) {
        return YES;
    }
    
    // 判断身份证号是否更改
    if (![self.initialUserInfo.id_card_no isEqualToString:self.id_card_noItem.subtitle]) {
        return YES;
    }
    
    // 判断手机号是否更改 
    if (![self.initialUserInfo.phone_num isEqualToString:self.phone_numItem.subtitle]) {
        return YES;
    }
    
    // 判断性别是否更改
    NSString *final_gender = @"1";
    if ([self.genderItem.subtitle isEqualToString:@"男"]) {
        final_gender = @"1";
    }
    if ([self.genderItem.subtitle isEqualToString:@"女"]) {
        final_gender = @"2";
    }

    if (![self.initialUserInfo.gender isEqualToString:final_gender] && ![self.genderItem.subtitle isEqualToString:@""]) {
        return YES;
    }
    
    // 判断生日是否更改
    if (![self.initialUserInfo.birthday isEqualToString:self.birthdayItem.subtitle] && ![self.birthdayItem.subtitle isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 保存用户更改的资料信息
- (void)uploadUserInfo:(void (^)(BOOL result))complete {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    // 判断昵称是否更改
    if (![self.initialUserInfo.nick_name isEqualToString:self.nick_nameItem.subtitle]) {
        [userInfo setObject:EMPTY_IF_NIL(self.nick_nameItem.subtitle) forKey:@"nick_name"];
    }
    
    // 判断真实姓名是否更改
    if (![self.initialUserInfo.real_name isEqualToString:self.real_nameItem.subtitle]) {
        [userInfo setObject:EMPTY_IF_NIL(self.real_nameItem.subtitle) forKey:@"real_name"];
    }
    
    // 判断身份证号是否更改
    if (![self.initialUserInfo.id_card_no isEqualToString:self.id_card_noItem.subtitle]) {
        [userInfo setObject:EMPTY_IF_NIL(self.id_card_noItem.subtitle) forKey:@"id_card_no"];
    }
    
    // 判断手机号是否更改
    if (![self.initialUserInfo.phone_num isEqualToString:self.phone_numItem.subtitle]) {
        [userInfo setObject:EMPTY_IF_NIL(self.phone_numItem.subtitle) forKey:@"phone_num"];
    }
    
    // 判断性别是否更改
    NSString *final_gender = @"1";
    if ([self.genderItem.subtitle isEqualToString:@"男"]) {
        final_gender = @"1";
    }
    if ([self.genderItem.subtitle isEqualToString:@"女"]) {
        final_gender = @"2";
    }
    if (![self.initialUserInfo.gender isEqualToString:final_gender]) {
        [userInfo setObject:EMPTY_IF_NIL(final_gender) forKey:@"gender"];
    }
    
    // 判断生日是否更改
    if (![self.initialUserInfo.birthday isEqualToString:self.birthdayItem.subtitle]) {
        [userInfo setObject:EMPTY_IF_NIL(self.birthdayItem.subtitle) forKey:@"birthday"];
    }
    
    __weak G100PersonProfileViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [[UserManager shareManager] updateUserInfoWithUserid:wself.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [[G100InfoHelper shareInstance] updateMyUserInfoWithUserid:wself.userid userInfo:userInfo];
                    if (complete) {
                        complete(YES);
                    }
                }else {
                    if (complete) {
                        complete(NO);
                    }
                }
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
            
            if (complete) {
                complete(NO);
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_updateUserdataWithUserinfo:userInfo callback:callback];
}

#pragma mark - 显示隐藏提示文案
- (void)showAccompainedHintLabel {
    [self.hintLabelConstraintTop uninstall];
    
    [self.accompaniedHintLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        self.hintLabelConstraintTop = make.top.equalTo(@60);
    }];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.accompaniedHintLabel.alpha = 0.0;
        [self.accompaniedHintLabel.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
    [self performSelector:@selector(hideAccompainedHintLabel) withObject:nil afterDelay:3.0f];
}
- (void)hideAccompainedHintLabel {
    [self.hintLabelConstraintTop uninstall];
    
    [self.accompaniedHintLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        self.hintLabelConstraintTop = make.top.equalTo(@20);
    }];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.accompaniedHintLabel.alpha = 0.0;
        [self.accompaniedHintLabel.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialData];
    [self setupView];
    
    self.initialUserInfo = [[G100UserDomain alloc] initWithDictionary:[self.account.user_info mj_keyValues]];
    self.profileHeaderView.account = self.account;
    self.profileHeaderView.nicknameLabel.text = self.account.user_info.nick_name;
    
    //监听用户数据变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userInfoDidChange:)
                                                 name:CDDDataHelperUserInfoDidChangeNotification
                                               object:nil];
    __weak typeof(self) wself = self;
    [[UserManager shareManager] updateUserInfoWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            wself.account = [[G100InfoHelper shareInstance] findMyAccountInfoWithUserid:wself.userid];
            [wself.profileHeaderView setAccount:wself.account];
            [wself.tableView reloadData];
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requsetThirdAccountInfoShowHUD:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    if (!self.hasAppear) {
        [self showAccompainedHintLabel];
    }
    self.hasAppear = YES;
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
