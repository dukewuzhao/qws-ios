//
//  G100BikeDetailViewController.m
//  G100
//
//  Created by yuhanle on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeDetailViewController.h"
#import "G100BaseArrowItem.h"
#import "G100BaseCell.h"

#import "G100BikeApi.h"
#import "G100BikeDomain.h"
#import "G100ThemeManager.h"

#import "BikeDetailHeaderView.h"
#import "BikeQRCodeView.h"

#import "G100Mediator+Management.h"

#import "G100BikeEditBikeNameViewController.h"
#import "G100BikeEditBrandViewController.h"
#import "G100BikeEditBrandPhoneNumViewController.h"
#import "G100BikeEditFeatureViewController.h"
#import "G100PhotoBrowserViewController.h"
#import "G100DeleteBikeViewController.h"

#import "G100PhotoShowModel.h"

#import "G100WebViewController.h"
#import "G100UrlManager.h"

static NSString *const kBaseItemBikeDetailBikeName           = @"kBaseItemBikeDetailBikeName";
static NSString *const kBaseItemBikeDetailBrandName          = @"kBaseItemBikeDetailBrandName";
static NSString *const kBaseItemBikeDetailFactoryPhoneNumber = @"kBaseItemBikeDetailFactoryPhoneNumber";
static NSString *const KBaseItemBikeDetailBattery            = @"KBaseItemBikeDetailBattery";
static NSString *const KBaseItemBikeDetailVoltage            = @"KBaseItemBikeDetailVoltage";
static NSString *const kBaseItemBikeDetailFeatureInfo        = @"kBaseItemBikeDetailFeatureInfo";
static NSString *const kBaseItemBikeDetailUserAndDevice      = @"kBaseItemBikeDetailUserAndDevice";
static NSString *const kBaseItemBikeDetailBikeLostRecord     = @"kBaseItemBikeDetailBikeLostRecord";
static NSString *const kBaseItemBikeDetailUnbind             = @"kBaseItemBikeDetailUnbind";
static NSString *const kBaseItemBikeDetailDelete             = @"kBaseItemBikeDetailDelete";

static NSString *const kHintDeleteBikeIsMaster              = @"所有设备都将解绑，所有副用户也将会解绑 ";
static NSString *const kHintDeleteBikeNotMaster             = @"删除后将解绑该车辆";

@interface G100BikeDetailViewController () <UITableViewDelegate, UITableViewDataSource, BikeDetailHeaderViewDelegate>

@property (nonatomic, assign) BOOL isMaster;
@property (nonatomic, strong) G100BaseArrowItem *itemBikeName;
@property (nonatomic, strong) G100BaseArrowItem *itemBrandName;
@property (nonatomic, strong) G100BaseArrowItem *itemFactoryPhoneNumber;
@property (nonatomic, strong) G100BaseArrowItem *itemBattery;
@property (nonatomic, strong) G100BaseArrowItem *itemFeatureInfo;
@property (nonatomic, strong) G100BaseArrowItem *itemUserAndDevice;
@property (nonatomic, strong) G100BaseArrowItem *itemUnbindAndDelete;
@property (nonatomic, strong) G100BaseArrowItem *itemDelete;

@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BikeDetailHeaderView *headerView;

////添加下拉放大效果需用
//@property(nonatomic,assign)CGFloat height;

@end

@implementation G100BikeDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperBikeInfoDidChangeNotification object:nil];
}

#pragma mark - setter&getter
- (G100BaseArrowItem *)itemBikeName {
    if (!_itemBikeName) {
        _itemBikeName = [[G100BaseArrowItem alloc] init];
        _itemBikeName.title = @"车辆名称";
        _itemBikeName.subtitle = @"";
        _itemBikeName.itemkey = kBaseItemBikeDetailBikeName;
    }
    return _itemBikeName;
}

- (G100BaseArrowItem *)itemBrandName {
    if (!_itemBrandName) {
        _itemBrandName = [[G100BaseArrowItem alloc] init];
        _itemBrandName.title = @"车辆品牌";
        _itemBrandName.subtitle = @"";
        _itemBrandName.itemkey = kBaseItemBikeDetailBrandName;
    }
    return _itemBrandName;
}

- (G100BaseArrowItem *)itemFactoryPhoneNumber {
    if (!_itemFactoryPhoneNumber) {
        _itemFactoryPhoneNumber = [[G100BaseArrowItem alloc] init];
        _itemFactoryPhoneNumber.title = @"厂商电话";
        _itemFactoryPhoneNumber.subtitle = @"";
        _itemFactoryPhoneNumber.itemkey = kBaseItemBikeDetailFactoryPhoneNumber;
    }
    return _itemFactoryPhoneNumber;
}
- (G100BaseArrowItem *)itemBattery
{
    if (!_itemBattery) {
        _itemBattery = [[G100BaseArrowItem alloc]init];
        _itemBattery.title = @"电池";
        _itemBattery.subtitle = @"";
        _itemBattery.itemkey = KBaseItemBikeDetailBattery;
    }
    return _itemBattery;
}

- (G100BaseArrowItem *)itemFeatureInfo {
    if (!_itemFeatureInfo) {
        _itemFeatureInfo = [[G100BaseArrowItem alloc] init];
        _itemFeatureInfo.title = @"特征信息";
        _itemFeatureInfo.subtitle = @"";
        _itemFeatureInfo.itemkey = kBaseItemBikeDetailFeatureInfo;
    }
    return _itemFeatureInfo;
}

- (G100BaseArrowItem *)itemUserAndDevice {
    if (!_itemUserAndDevice) {
        _itemUserAndDevice = [[G100BaseArrowItem alloc] init];
        _itemUserAndDevice.title = @"用户与设备管理";
        _itemUserAndDevice.subtitle = @"";
        _itemUserAndDevice.itemkey = kBaseItemBikeDetailUserAndDevice;
    }
    return _itemUserAndDevice;
}


- (G100BaseArrowItem *)itemUnbindAndDelete {
    if (!_itemUnbindAndDelete) {
        _itemUnbindAndDelete = [[G100BaseArrowItem alloc] init];
        _itemUnbindAndDelete.title = @"删除车辆";
        _itemUnbindAndDelete.subtitle = @"";
        _itemUnbindAndDelete.itemkey = kBaseItemBikeDetailUnbind;
    }
    return _itemUnbindAndDelete;
}

- (G100BaseArrowItem *)itemDelete {
    if (!_itemDelete) {
        _itemDelete = [[G100BaseArrowItem alloc] init];
        _itemDelete.title = @"删除车辆";
        _itemDelete.subtitle = @"";
        _itemDelete.itemkey = kBaseItemBikeDetailDelete;
    }
    return _itemDelete;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _tableView;
}

- (BikeDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [BikeDetailHeaderView loadViewFromNib];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        if (![self.bikeDomain isMOTOBike]) {
            _dataArray = @[@[self.itemBikeName,
                             self.itemBrandName,
                             self.itemFactoryPhoneNumber,
                             self.itemBattery,
                             self.itemFeatureInfo,
                             self.itemUserAndDevice],
                           @[self.itemUnbindAndDelete],
                           @[self.itemDelete]
                           ].mutableCopy;

        }else{
            _dataArray = @[@[self.itemBikeName,
                             self.itemBrandName,
                             self.itemFactoryPhoneNumber,
                             self.itemFeatureInfo,
                             self.itemUserAndDevice],
                           @[self.itemUnbindAndDelete],
                           @[self.itemDelete]
                           ].mutableCopy;

        }
    }
    return _dataArray;
}

- (G100BikeDomain *)bikeDomain {
    if (!_bikeDomain) {
        _bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    }
    return _bikeDomain;
}

#pragma mark - setupView
- (void)setupView {
    
    [self setNavigationBarViewColor:[UIColor clearColor]];
    
    [self.view insertSubview:self.headerView belowSubview:self.navigationBarView];
    [self.view insertSubview:self.tableView belowSubview:self.headerView];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(@0);
        float   height =( ([UIScreen mainScreen].bounds.size.height)/736)*240;
        make.height.equalTo(height);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.leading.trailing.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:self.userid];
    [self.headerView setCurrentUserName:userDomain.nick_name];
    [self.headerView setBikeDomain:self.bikeDomain];
    
    [self.navigationBarView removeFromSuperview];
    
    //为 self.headerView 添加阴影效果
    [[self.headerView layer] setShadowOffset:CGSizeMake(0, 2)];
    [[self.headerView layer] setShadowRadius:2];
    [[self.headerView layer] setShadowOpacity:0.8];
    [[self.headerView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    
}

#pragma mark - setupData
- (void)setupData {
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    
    self.isMaster = [self.bikeDomain isMaster];
    
    self.itemBikeName.subtitle = self.bikeDomain.name;
    self.itemFeatureInfo.subtitle = self.bikeDomain.feature.integrity > 0 ? [NSString stringWithFormat:@"完整度 %@%%", @(self.bikeDomain.feature.integrity)] : @"快来补全信息吧";
   
  
    // 判断车辆品牌是否是预置品牌
    if (self.bikeDomain.brand.brand_id == 0) {
        self.itemBrandName.subtitle = self.bikeDomain.brand.name;
        self.itemFactoryPhoneNumber.subtitle = self.bikeDomain.brand.service_num;
    }else if (self.bikeDomain.brand.brand_id > 0) {
        if (self.bikeDomain.brand.name.length) {
            self.itemBrandName.subtitle = self.bikeDomain.brand.name;
        }else {
            // 预置品牌 需要从本地加载数据
            __weak G100BikeDetailViewController * wself = self;
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    wself.itemBrandName.subtitle = theme.theme_channel_info.name;
                    [wself.tableView reloadData];
                }
            }];
        }
        
        if (self.bikeDomain.brand.service_num.length) {
            self.itemFactoryPhoneNumber.subtitle = self.bikeDomain.brand.service_num;
        }else {
            // 预置品牌 需要从本地加载数据
            __weak G100BikeDetailViewController * wself = self;
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    wself.itemFactoryPhoneNumber.subtitle = theme.theme_channel_info.servicenum;
                    [wself.tableView reloadData];
                }
            }];
        }
    }
    
    [self.dataArray removeAllObjects];
    if (![self.bikeDomain isMOTOBike]) {
        if (self.isMaster) {
            self.dataArray = @[@[self.itemBikeName,
                                 self.itemBrandName,
                                 self.itemFactoryPhoneNumber,
                                 self.itemBattery,
                                 self.itemFeatureInfo,
                                 self.itemUserAndDevice],
                               @[self.itemUnbindAndDelete],
                               ].mutableCopy;
            
        }else {
            self.dataArray = @[@[self.itemBikeName,
                                 self.itemBrandName,
                                 self.itemFactoryPhoneNumber,
                                 self.itemBattery,
                                 self.itemFeatureInfo,
                                 self.itemUserAndDevice],
                               @[self.itemDelete]
                               ].mutableCopy;
        }
    }else{
        if (self.isMaster) {
            self.dataArray = @[@[self.itemBikeName,
                                 self.itemBrandName,
                                 self.itemFactoryPhoneNumber,
                                 self.itemFeatureInfo,
                                 self.itemUserAndDevice],
                               @[self.itemUnbindAndDelete],
                               ].mutableCopy;
            
        }else {
            self.dataArray = @[@[self.itemBikeName,
                                 self.itemBrandName,
                                 self.itemFactoryPhoneNumber,
                                 self.itemFeatureInfo,
                                 self.itemUserAndDevice],
                               @[self.itemDelete]
                               ].mutableCopy;
        }
    }

}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataArray safe_objectAtIndex:section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.001;
    }
    
    NSString * text = kHintDeleteBikeIsMaster;
    NSArray *array = [self.dataArray safe_objectAtIndex:section];
    
    if ([array containsObject:self.itemUnbindAndDelete]) {
        text = kHintDeleteBikeIsMaster;
    }else {
        text = kHintDeleteBikeNotMaster;
    }
    
    CGSize contentSize = [text calculateSize:CGSizeMake(WIDTH - 30, 1000) font:[UIFont systemFontOfSize:14]];
    return contentSize.height + 8;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100BaseItem *item = [[self.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    G100BaseCell *viewCell = [G100BaseCell cellWithTableView:tableView item:item];
    viewCell.item = item;
    
    if ([item.itemkey isEqualToString:kBaseItemBikeDetailDelete] ||
        [item.itemkey isEqualToString:kBaseItemBikeDetailUnbind]) {
        viewCell.textLabel.textColor = [UIColor redColor];
        [viewCell setAccessoryType:UITableViewCellAccessoryNone];
    }else if ([item.itemkey isEqualToString:kBaseItemBikeDetailBrandName]) {
        viewCell.textLabel.textColor = [UIColor blackColor];
        if (self.bikeDomain.brand.brand_id == 0 && self.bikeDomain.isMaster) {
            [viewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }else {
            [viewCell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if ([item.itemkey isEqualToString:KBaseItemBikeDetailBattery])
    {
        viewCell.textLabel.textColor = [UIColor blackColor];
            [viewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else {
        viewCell.textLabel.textColor = [UIColor blackColor];
        [viewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        if ([item.itemkey isEqualToString:kBaseItemBikeDetailBikeName] ||
            [item.itemkey isEqualToString:kBaseItemBikeDetailFactoryPhoneNumber]) {
            if (self.bikeDomain.isMaster) {
                [viewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }else {
                [viewCell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
        
    }
    
    return viewCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, backView.v_width - 30, 30)];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    
    [backView addSubview:label];
    
    NSArray *array = [self.dataArray safe_objectAtIndex:section];
    
    if ([array containsObject:self.itemUnbindAndDelete]) {
        label.text = kHintDeleteBikeIsMaster;
    }else {
        label.text = kHintDeleteBikeNotMaster;
    }
    
    CGSize contentSize = [label.text calculateSize:CGSizeMake(WIDTH - 30, 1000) font:[UIFont systemFontOfSize:14]];
    backView.v_height = label.v_height = contentSize.height + 8;
    
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    G100BaseItem *item = [[self.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    
    if ([item.itemkey isEqualToString:kBaseItemBikeDetailBikeName]) {
        if (!self.bikeDomain.isMaster) {
            return;
        }
        // 车辆名称
        if (![UserAccount sharedInfo].appfunction.mybikes_bikedetail_rename.enable && IsLogin()) {
            return;
        };
        G100BikeEditBikeNameViewController *bikeNameVC = [[G100BikeEditBikeNameViewController alloc] initWithUserid:self.userid bikeid:self.bikeid oldName:self.bikeDomain.name];
        bikeNameVC.sureBlock = ^(NSString *result){
            [self setNavigationTitle:result];
            self.itemBikeName.subtitle = result;
            self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid
                                                                            bikeid:self.bikeid];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:bikeNameVC animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemBikeDetailBrandName]) {
        if (!self.bikeDomain.isMaster) {
            return;
        }
        if (self.bikeDomain.brand.brand_id != 0) {
            return;
        }else {
            
        }
        
        // 品牌
        G100BikeEditBrandViewController *bikeBrandVC = [[G100BikeEditBrandViewController alloc] initWithUserid:self.userid
                                                                                                        bikeid:self.bikeid
                                                                                                       oldName:self.bikeDomain.brand.name];
        bikeBrandVC.bikeType = self.bikeDomain.bike_type;
        bikeBrandVC.sureBlock = ^(NSString *result){
            self.itemBrandName.subtitle = result;
            self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid
                                                                            bikeid:self.bikeid];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:bikeBrandVC animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemBikeDetailFactoryPhoneNumber]) {
        if (!self.bikeDomain.isMaster) {
            return;
        }
        // 电话
        G100BikeEditBrandPhoneNumViewController *bikePhoneNumVC = [[G100BikeEditBrandPhoneNumViewController alloc] initWithUserid:self.userid
                                                                                                                           bikeid:self.bikeid
                                                                                                                        oldNumber:self.bikeDomain.brand.service_num];
        bikePhoneNumVC.sureBlock = ^(NSString *result){
            self.itemFactoryPhoneNumber.subtitle = result;
            self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid
                                                                            bikeid:self.bikeid];
            [self.tableView reloadData];
        };
        bikePhoneNumVC.brand_id = self.bikeDomain.brand.brand_id;
        // 判断车辆品牌是否是预置品牌
        if (self.bikeDomain.brand.brand_id == 0) {
            bikePhoneNumVC.defaultNumber = nil;
        }else if (self.bikeDomain.brand.brand_id > 0) {
            if (!self.bikeDomain.brand.service_num.length) {
                bikePhoneNumVC.defaultNumber = nil;
            }else {
                // 预置品牌 需要从本地加载数据
                [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                    if (success) {
                        bikePhoneNumVC.defaultNumber = theme.theme_channel_info.servicenum;
                    }
                }];
            }
        }
        
        bikePhoneNumVC.oldNumber = self.itemFactoryPhoneNumber.subtitle;
        [self.navigationController pushViewController:bikePhoneNumVC animated:YES];
    }
    else if ([item.itemkey isEqualToString:KBaseItemBikeDetailBattery])
    {    //电池类型
        NSString *isMaster = [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isMaster]];
        G100WebViewController *webVc = [[G100WebViewController alloc]init];
        webVc.httpUrl = [[G100UrlManager sharedInstance] getBatteryAndVoltageUrlWithUserid:self.userid
                                                                                    bikeid:self.bikeid
                                                                                  isMaster:isMaster
                                                                                     devid:[NSString stringWithFormat:@"%ld",(long)self.bikeDomain.mainDevice.device_id]
                                                                                  model_id:self.bikeDomain.mainDevice.model_id];
        [self.navigationController pushViewController:webVc animated:YES];
    }
    else if ([item.itemkey isEqualToString:kBaseItemBikeDetailFeatureInfo]) {
        // 特征信息
        G100BikeEditFeatureViewController *bikeFeatureVC = [[G100BikeEditFeatureViewController alloc] initWithUserid:self.userid
                                                                                                              bikeid:self.bikeid
                                                                                                        entranceFrom:0];
        [self.navigationController pushViewController:bikeFeatureVC animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemBikeDetailUserAndDevice]) {
        // 用户与设备管理
        UIViewController * viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForManagement:self.userid
                                                                                                             bikeid:self.bikeid];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemBikeDetailUnbind]) {
        // 解绑所有设备并删除车辆 仅限主用户操作
        G100DeleteBikeViewController * deleteBike = [[G100DeleteBikeViewController alloc]initWithNibName:@"G100DeleteBikeViewController" bundle:nil];
        deleteBike.userid = self.userid;
        deleteBike.bikeid = self.bikeid;
        deleteBike.bikeDomain = self.bikeDomain;
        [self.navigationController pushViewController:deleteBike animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemBikeDetailDelete]) {
        // 删除车辆 仅限副用户操作
        __weak typeof(self) weakSelf = self;
        G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithReactiveView];
        pop.contentAlignment = PopContentAlignmentLeft;
        [pop showPopingViewWithTitle:@"删除车辆" content:kHintDeleteBikeNotMaster noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (index == 2) {
                [[G100BikeApi sharedInstance] deleteBikeWithUserid:strongSelf.userid bikeid:strongSelf.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                    if (requestSuccess) {
                        [[UserManager shareManager] updateBikeListWithUserid:strongSelf.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                            if (requestSuccess) {
                                [strongSelf showHint:@"删除成功"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:kGNDeleteBikeSuccess
                                                                                    object:response
                                                                                  userInfo:@{@"userid" : EMPTY_IF_NIL(strongSelf.userid),
                                                                                             @"bikeid" : EMPTY_IF_NIL(strongSelf.bikeid)}];
                                [strongSelf.navigationController popViewControllerAnimated:YES];
                            }else {
                                [strongSelf showHint:response.errDesc];
                            }
                            
                            [[G100InfoHelper shareInstance] clearRelevantDataWithUserid:strongSelf.userid bikeid:strongSelf.bikeid];
                        }];
                    }else {
                        [strongSelf showHint:response.errDesc];
                    }
                }];
            }
            [pop dismissWithVc:strongSelf animation:YES];
        } onViewController:self onBaseView:self.view];
    }else {
        // 默认操作
        
    }
}


#pragma mark - BikeDetailHeaderViewDelegate
- (void)bikeDetailHeaderView:(BikeDetailHeaderView *)view qrcodeBtnClick:(UIButton *)button {
    BikeQRCodeView *qrView = [BikeQRCodeView loadViewFromNibWithTitle:@"扫描车辆二维码绑定"
                                                               qrcode:[NSString stringWithFormat:@"%@", self.bikeDomain.add_url]];
    [qrView showInVc:self view:self.view animation:YES];
}

//返回按钮代理方法
- (void)bikeDetailHeaderView:(BikeDetailHeaderView *)view icon_backButtonClick:(UIButton *)button
{

    [self.navigationController popViewControllerAnimated:YES];

}

//点击背景视图,跳转界面
- (void)bikeDetailHeaderView:(BikeDetailHeaderView *)view backImageViewTapgesture:(UIImageView *)imageView
{
    G100BikeFeatureDomain * feature = self.bikeDomain.feature;
    if (feature.pictures.count) {
        G100PhotoBrowserViewController * controller  = [[G100PhotoBrowserViewController alloc]initWithPhotos:[G100PhotoShowModel showModelWithUrlArray:feature.pictures]currentIndex:0];
        [controller setDelBtnHidden:YES];
        controller.isShowCoverBtn = NO;
        [self.navigationController pushViewController:controller animated:YES];
    }else {
        
    }
   
}

- (void)noti_bikeInfoDidChange:(NSNotification *)notification {
    [self setupData];
    [self.tableView reloadData];
    
    G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:self.userid];
    [self.headerView setCurrentUserName:userDomain.nick_name];
    [self.headerView setBikeDomain:self.bikeDomain];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupData];
    
    [self setupView];
    
    [self setLeftBarButtonHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_bikeInfoDidChange:)
                                                 name:CDDDataHelperBikeInfoDidChangeNotification
                                               object:nil];
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
