//
//  G100SettingsViewController.m
//  G100
//
//  Created by William on 16/7/6.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100SettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "G100WebViewController.h"
#import "G100AboutUsViewController.h"

#import "G100InfoHelper.h"

#import <AlibcTradeSDK/AlibcTradeSDK.h>
#import <AlibabaAuthSDK/ALBBSDK.h>
#import <AlibcLinkPartnerSDK/ALPTBLinkPartnerSDK.h>

#import "G100Mediator+OfflineMap.h"

@interface G100SettingsViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSInteger selectedIndex;
    BOOL sender_on;
}

@property (strong, nonatomic) UITableView * contentTableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSArray * netPickArray;
@property (strong, nonatomic) UISwitch * netSwitch;

@end

@implementation G100SettingsViewController

#pragma mark - lazy loading

- (NSArray *)netPickArray {
    if (!_netPickArray) {
        _netPickArray = @[ @"每隔30秒刷新一次", @"每隔1分钟刷新一次", @"每隔2分钟刷新一次" ];
    }
    return _netPickArray;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        if (IsLogin()) {
            _dataArray = @[ @[@"修改密码"], @[ @"离线地图",@"2G/3G/4G下刷新地图" ], @[@"淘宝账号授权"], @[ @"帮助", @"用户协议",@"隐私政策", @"关于" ] ].mutableCopy;
        }else{
            _dataArray = @[ @[@"淘宝账号授权"], @[ @"帮助", @"用户协议",@"隐私政策", @"关于" ] ].mutableCopy;
        }
        
    }
    return _dataArray;
}

- (UISwitch *)netSwitch {
    if (!_netSwitch) {
        _netSwitch = [[UISwitch alloc] init];
        [_netSwitch addTarget:self action:@selector(netSwitchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _netSwitch;
}

- (UITableView *)contentTableView {
    if (!_contentTableView) {
        _contentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        _contentTableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _contentTableView;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationTitle:@"设置"];
    
    [self.contentView addSubview:self.contentTableView];
    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.right.bottom.equalTo(@0);
    }];
    
    // iOS 11 UI 显示bug 修复
    if ([self.contentTableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.contentTableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [self setup];
}

#pragma mark - init & setup
- (void)setup {
    selectedIndex = [[G100InfoHelper shareInstance] findMapRefreshStateWithUserid:self.userid];
    [self.netSwitch setOn:selectedIndex ? YES : NO];
    sender_on = selectedIndex ? YES : NO;
    
    if (selectedIndex != 0) {
        NSMutableArray * netArray = [NSMutableArray arrayWithArray:self.dataArray[1]];
        [netArray addObjectsFromArray:self.netPickArray];
        [self.dataArray replaceObjectAtIndex:1 withObject:netArray];
        [self.contentTableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    if (indexPath.section == 1 && IsLogin()) {
        if (indexPath.row == 1) {
            cell.accessoryView = self.netSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if (indexPath.row == 0){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else {
            if (indexPath.row == selectedIndex) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.dataArray[indexPath.section] safe_objectAtIndex:indexPath.row];
    
    if ((IsLogin() && indexPath.section == 2) || (!IsLogin() && indexPath.section == 0)) {
        // 淘宝授权结果显示
        BOOL isAuth = [[ALBBSession sharedInstance] isLogin];
        
        if (isAuth) {
            cell.detailTextLabel.text = @"取消授权";
        } else {
            cell.detailTextLabel.text = @"去授权";
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (IsLogin()) {
        if (indexPath.section == 0) {
            if (![[[[UserAccount sharedInfo] appfunction] profile_modifypassword] enable]) {
                return;
            }
            if (indexPath.row == 0) { /* 修改密码 */
                ChangePasswordViewController *changpw = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
                [self.navigationController pushViewController:changpw animated:YES];
            }
        }else if (indexPath.section == 1) {
            if (indexPath.row > 1) {
                selectedIndex = indexPath.row;
                [[G100InfoHelper shareInstance] updateMapRefreshStateWithUserid:self.userid state:selectedIndex];
                [self.contentTableView reloadData];
            }else if(indexPath.row == 0){
                UIViewController * viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForOfflineMap];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }else if (indexPath.section == 2) {
            // 淘宝账号授权
            BOOL isAuth = [[ALBBSession sharedInstance] isLogin];
            
            if (!isAuth) {
                [[ALBBSDK sharedInstance] auth:self successCallback:^(ALBBSession *session) {
                    [self performSelector:@selector(refreshTBUserInfo) withObject:nil afterDelay:1.0];
                } failureCallback:^(ALBBSession *session, NSError *error) {
                    
                }];
                
            }else {
                __weak typeof(self) wself = self;
                G100ReactivePopingView *popBox = [G100ReactivePopingView popingViewWithReactiveView];
                [popBox showPopingViewWithTitle:nil content:@"是否取消淘宝账号授权" noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"不取消" clickEvent:^(NSInteger index) {
                    if (index == 1) {
                        [[ALBBSDK sharedInstance] logout];
                        [wself performSelector:@selector(refreshTBUserInfo) withObject:nil afterDelay:1.0];
                    }
                    
                    [popBox dismissWithVc:wself animation:YES];
                } onViewController:self onBaseView:self.view];
            }
        }else if (indexPath.section == 3) {
            [self actionSelectedWithIndexPath:indexPath];
        }
    }else {
        if (indexPath.section == 0) {
            // 淘宝账号授权
            BOOL isAuth = [[ALBBSession sharedInstance] isLogin];
            
            if (!isAuth) {
                [[ALBBSDK sharedInstance] auth:self successCallback:^(ALBBSession *session) {
                    [self performSelector:@selector(refreshTBUserInfo) withObject:nil afterDelay:1.0];
                } failureCallback:^(ALBBSession *session, NSError *error) {
                    
                }];
                
            }else {
                __weak typeof(self) wself = self;
                G100ReactivePopingView *popBox = [G100ReactivePopingView popingViewWithReactiveView];
                [popBox showPopingViewWithTitle:nil content:@"是否取消淘宝账号授权" noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"不取消" clickEvent:^(NSInteger index) {
                    if (index == 1) {
                        [[ALBBSDK sharedInstance] logout];
                        [wself performSelector:@selector(refreshTBUserInfo) withObject:nil afterDelay:1.0];
                    }
                    [popBox dismissWithVc:wself animation:YES];
                } onViewController:self onBaseView:self.view];
            }
        } else {
            [self actionSelectedWithIndexPath:indexPath];
        }
    }
}

- (void)actionSelectedWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { /* 帮助 */
        G100WebViewController * helper = [G100WebViewController loadNibWebViewController];
        helper.webTitle = @"帮助中心";
        helper.httpUrl = @"https://m.qiweishi.com/service";
        [self.navigationController pushViewController:helper animated:YES];
    }else if (indexPath.row == 1) { /* 用户协议 */
        G100WebViewController * agreement = [G100WebViewController loadNibWebViewController];
        agreement.filename = @"regist_agreement.html";
        agreement.webTitle = @"用户协议";
        [self.navigationController pushViewController:agreement animated:YES];
    }else if (indexPath.row == 2) { /* 隐私政策 */
        G100WebViewController * agreement = [G100WebViewController loadNibWebViewController];
        agreement.httpUrl = @"https://www.qiweishi.com/privacy_policy.html";
        agreement.webTitle = @"隐私政策";
        [self.navigationController pushViewController:agreement animated:YES];
    }else if (indexPath.row == 3) {/* 关于 */
        if (![UserAccount sharedInfo].appfunction.about.enable && IsLogin()) {
            return;
        };
        G100AboutUsViewController * about = [[G100AboutUsViewController alloc]initWithNibName:@"G100AboutUsViewController" bundle:nil];
        [self.navigationController pushViewController:about animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1 && IsLogin()) {
        return 24.0f;
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (IsLogin() && section == 1) {
        UIView * contentFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 24)];
        UILabel * noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 4, WIDTH-24, 16)];
        noticeLabel.font = [UIFont systemFontOfSize:12.0f];
        noticeLabel.textColor = [UIColor darkGrayColor];
        noticeLabel.text = @"WIFI下每隔30秒刷新一次";
        [contentFooterView addSubview:noticeLabel];
        return contentFooterView;
    }
    return nil;
}

#pragma mark - 刷新淘宝授权信息
- (void)refreshTBUserInfo {
    [self.contentTableView reloadData];
}

#pragma mark - action
- (void)netSwitchAction:(UISwitch *)sender {
    if (sender.on == sender_on) {
        return;
    }
    
    sender_on = sender.on;
    
    NSMutableArray * netArray = [NSMutableArray arrayWithArray:self.dataArray[1]];
    if (sender.on) {
        if (netArray.count == 2) {
            [netArray addObjectsFromArray:self.netPickArray];
            selectedIndex = 2;
        }
    }else {
        if (netArray.count == 5) {
            [netArray removeObjectsInRange:NSMakeRange(2, self.netPickArray.count)];
            selectedIndex = 0;
        }
    }
    
    [[G100InfoHelper shareInstance] updateMapRefreshStateWithUserid:self.userid state:selectedIndex];
    
    [self.dataArray replaceObjectAtIndex:1 withObject:netArray];
    
    if (sender.on) {
        [self.contentTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1],
                                                        [NSIndexPath indexPathForRow:3 inSection:1],
                                                        [NSIndexPath indexPathForRow:4 inSection:1]] withRowAnimation:UITableViewRowAnimationMiddle];
    }else {
        [self.contentTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1],
                                                        [NSIndexPath indexPathForRow:3 inSection:1],
                                                        [NSIndexPath indexPathForRow:4 inSection:1]] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

@end
