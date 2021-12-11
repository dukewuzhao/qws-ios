//
//  G100UserManagementViewController.m
//  G100
//
//  Created by William on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UserManagementViewController.h"
#import "G100UserEditCommentViewController.h"
#import "G100DevApi.h"
#import "G100BikeApi.h"

@interface G100UserManagementViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSArray * basicsArray;

@property (nonatomic, strong) NSMutableArray * devDataArray;

@end


@implementation G100UserManagementViewController

#pragma mark - lazy loading
- (NSArray *)basicsArray {
    if (!_basicsArray) {
        _basicsArray = @[@"备注", @"电话", @"绑定时间"];
    }
    return _basicsArray;
}

- (NSMutableArray *)devDataArray {
    if (!_devDataArray) {
        _devDataArray = [[NSMutableArray alloc] init];
    }
    return _devDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    NSArray *devices = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:self.bikeid];
    
    // 主设备排在第一位 其他按照SEQ的顺序排列
    for (G100DeviceDomain *device in [devices sortedArrayUsingComparator:^NSComparisonResult(G100DeviceDomain * preDevice, G100DeviceDomain * nextDevice) {
        // 先按照主副设备排序 若相同则按照seq 排序
        NSComparisonResult result = [[NSNumber numberWithInteger:nextDevice.isMainDevice] compare:[NSNumber numberWithInteger:preDevice.isMainDevice]];
        if (result == NSOrderedSame) {
            result = [[NSNumber numberWithInteger:preDevice.seq] compare:[NSNumber numberWithInteger:nextDevice.seq]];
        }
        
        return result;
    }]) {
        [self.devDataArray addObject:device];
    }
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [self.contentView addSubview:_tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.bottom.equalTo(@0);
    }];
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:self.userDomain.nick_name.length ? self.userDomain.nick_name : @"用户"];
    [self.navigationBarView setNavigationTitleLabelWidth:self.view.frame.size.width - 100];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.userid isEqualToString:self.userDomain.userid] || self.userDomain.isMaster) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }else if (section == 1) {
        return 1;
    }else{
        return [self.devDataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.basicsArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = self.userDomain.comment.length ? self.userDomain.comment : self.userDomain.nickname ;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.row == 1) {
            cell.detailTextLabel.text = self.userDomain.phone_num;
        }else if (indexPath.row == 2){
            cell.detailTextLabel.text = [self.userDomain.created_time substringToIndex:10];
        }
    }else if (indexPath.section == 2) {
        G100DeviceDomain *domain = [self.devDataArray safe_objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"是否允许使用设备%@", domain.name];
        UISwitch * devSwitch = [[UISwitch alloc]init];
        devSwitch.on = YES; // 默认开启
        cell.accessoryView = devSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (indexPath.section == 1) {
        cell.textLabel.text = @"删除用户";
        cell.textLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 30.0f;
    }
    return 12.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, backView.v_width, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [backView addSubview:titleLabel];
    
    if (section == 1) {
        titleLabel.text = @"权限设置";
    }
    
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.userDomain.phone_num]]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", self.userDomain.phone_num]]];
            }else {
                MyAlertTitle(@"电话拨打失败");
            }
        }else if (indexPath.row == 0){
            G100UserEditCommentViewController *commentVC = [[G100UserEditCommentViewController alloc] initWithUserid:[NSString stringWithFormat:@"%ld",self.userDomain.user_id] bikeid:self.bikeid oldComment:self.userDomain.comment.length ? self.userDomain.comment : self.userDomain.nickname];
            commentVC.sureBlock = ^(NSString *userComment){
                self.userDomain.comment = userComment;
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:commentVC animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *noticeStr = [NSString stringWithFormat:@"删除用户后, 用户%@将不能使用您的车辆",_userDomain.nickname];
            
            G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithReactiveView];
                [pop showPopingViewWithTitle:@"提醒" content:noticeStr noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
                    if (index == 2) {
                       
                       // 删除用户
                        __weak G100UserManagementViewController * wself = self;
                        [[G100BikeApi sharedInstance] removeBikeUserWithUserid:self.userDomain.userid bikeid:self.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                            if (requestSuccess) {
                                [[UserManager shareManager] updateBikeInfoWithUserid:wself.userid bikeid:wself.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                                    [wself showHint:@"删除成功"];
                                    [wself.navigationController popViewControllerAnimated:YES];
                                }];
                            }
                        }];

                    }
                    [pop dismissWithVc:self animation:YES];
                } onViewController:self onBaseView:self.view];

        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
