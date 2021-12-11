//
//  G100UserAndDevManagementViewController.m
//  G100
//
//  Created by William on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UserAndDevManagementViewController.h"
#import "G100UserManagementViewController.h"
#import "G100DevManagementViewController.h"

#import "G100BikeApi.h"
#import "G100BikeUsersDomain.h"

#import <UIImageView+WebCache.h>
#import "G100UserAndDevManagementCell.h"

@interface G100UserAndDevManagementViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@property (nonatomic, strong) NSMutableArray *userDataArray; //!< 用户模型
@property (nonatomic, strong) NSMutableArray *devDataArray; // !< 设备模型
@property (nonatomic, assign) BOOL hasLoadData;

@end

@implementation G100UserAndDevManagementViewController

#pragma mark - getter&setter
- (NSMutableArray *)userDataArray {
    if (!_userDataArray) {
        _userDataArray = [[NSMutableArray alloc] init];
    }
    return _userDataArray;
}
- (NSMutableArray *)devDataArray {
    if (!_devDataArray) {
        _devDataArray = [[NSMutableArray alloc] init];
    }
    return _devDataArray;
}

- (G100BikeDomain *)bikeDomain {
    if (!_bikeDomain) {
        _bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    }
    return _bikeDomain;
}

#pragma mark - setupView
- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [self.contentView addSubview:_tableView];
    
    [G100UserAndDevManagementCell registerToTableView:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.bottom.equalTo(@0);
    }];
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:@"用户与设备管理"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.devDataArray count]) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.userDataArray count];
    }
    
    return [self.devDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"user-device-%@", @(indexPath.section)];
    if (indexPath.section == 0) {
        G100UserAndDevManagementCell *userDevCell = [tableView dequeueReusableCellWithIdentifier:[G100UserAndDevManagementCell cellID] forIndexPath:indexPath];
        self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
            [userDevCell setDomainOfUser:[self.userDataArray safe_objectAtIndex:indexPath.row] bike:self.bikeDomain];
        return userDevCell;
        
    }else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        G100DeviceDomain *domain = [self.devDataArray safe_objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = domain.name;
        return cell;
    }

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 72;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, backView.v_width, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [backView addSubview:titleLabel];
    
    if (self.hasLoadData) {
        if (section == 0) {
            titleLabel.text = @"用户列表";
        }else if (section == 1) {
            titleLabel.text = @"设备列表";
        }
        
    }
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        G100UserDomain *domain = [self.userDataArray safe_objectAtIndex:indexPath.row];
        
        if (domain.isMaster || !self.bikeDomain.isMaster) {
            return;
        }else {
            ;
        }
        
        G100UserManagementViewController * viewController = [[G100UserManagementViewController alloc]init];
        viewController.userid = self.userid;
        viewController.bikeid = self.bikeid;
        viewController.userDomain = domain;
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        G100DevManagementViewController * viewController = [[G100DevManagementViewController alloc]init];
        G100DeviceDomain *domain = [self.devDataArray safe_objectAtIndex:indexPath.row];
        viewController.userid = self.userid;
        viewController.bikeid = self.bikeid;
        viewController.devid = [NSString stringWithFormat:@"%@", @(domain.device_id)];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - private method
- (void)loadBikesUsers:(NSString *)userid bikeid:(NSString *)bikeid showHUD:(BOOL)showHUD {
    __weak G100UserAndDevManagementViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [wself.userDataArray removeAllObjects];
            G100BikeUsersDomain *domain = [[G100BikeUsersDomain alloc] initWithDictionary:response.data];
            [wself.userDataArray addObjectsFromArray:domain.bikeusers];
            
            [wself.devDataArray removeAllObjects];
            [wself.devDataArray addObjectsFromArray:[[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:self.bikeid]];
            _hasLoadData = YES;
            [wself.tableView reloadData];
        }else {
            [wself showHint:response.errDesc];
        }
        [wself hideHud];
    };
    
    if (showHUD) {
        [self showHudInView:self.contentView hint:nil];
    }
    [[G100BikeApi sharedInstance] loadRelativeUserinfoWithBikeid:self.bikeid callback:callback];
}

#pragma mark - override
- (void)actionClickNavigationBarLeftButton {
    NSArray *devices = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:self.bikeid];
    
    //bugfixd: QWSIOS-403 车辆 A 下有一台设备,从实时追踪界面进入设备管理并解绑改设备,解绑设备后返回到实时追踪界面,需要修改
    if (devices.count > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        NSArray *vcs = [self.navigationController viewControllers];
        
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (UIViewController *vc in vcs) {
            if ([vc isKindOfClass:[NSClassFromString(@"G100DevGPSViewController") class]]) {
                [toRemove addObject:vc];
            }
        }
        
        NSMutableArray *result = [vcs mutableCopy];
        [result removeObjectsInArray:toRemove];
        [result removeLastObject];
        
        [self.navigationController setViewControllers:result.copy animated:YES];
    }
}

#pragma mark - 更新副用户绑定
- (void)BikeDomainDidChangeUpdateInfo:(NSNotification *)noti {
    if ([noti.userInfo[@"user_id"] integerValue] != [self.userid integerValue]) {
        return;
    }
    [self loadBikesUsers:self.userid bikeid:self.bikeid showHUD:NO];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hasLoadData = NO;
    [self setupView];
    
    [self loadBikesUsers:self.userid bikeid:self.bikeid showHUD:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BikeDomainDidChangeUpdateInfo:) name:CDDDataHelperBikeInfoDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.hasAppear) {
        [self loadBikesUsers:self.userid bikeid:self.bikeid showHUD:NO];
    }
    self.hasAppear = YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperBikeInfoDidChangeNotification object:nil];
}
@end
