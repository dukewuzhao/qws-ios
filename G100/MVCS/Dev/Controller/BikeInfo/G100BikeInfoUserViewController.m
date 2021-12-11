//
//  G100BikeInfoUserViewController.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoUserViewController.h"
#import "G100BikeUsersDomain.h"
#import "G100BikeApi.h"
#import "G100BikeInfoUserDetailView.h"

#import "UILabeL+AjustFont.h"
#import "G100BikeUserDisCell.h"

#import "G100PushMsgDomain.h"
#import "BindApplicationView.h"

@interface G100BikeInfoUserViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <G100UserDomain *>*userDataArray;
@property (nonatomic, strong) NSMutableArray <G100UserDomain *>*auditingDataArray;

@end

@implementation G100BikeInfoUserViewController

#pragma mark - Private Method
- (void)loadBikesUsers:(NSString *)userid bikeid:(NSString *)bikeid showHUD:(BOOL)showHUD {
    __weak G100BikeInfoUserViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [wself.userDataArray removeAllObjects];
            [wself.auditingDataArray removeAllObjects];
            
            G100BikeUsersDomain *domain = [[G100BikeUsersDomain alloc] initWithDictionary:response.data];
            [wself.userDataArray addObjectsFromArray:domain.bikeusers];
            [wself.auditingDataArray addObjectsFromArray:domain.auditing];
            
            if ([wself.delegate respondsToSelector:@selector(featchUserListFinished)]) {
                [wself.delegate featchUserListFinished];
            }
            
        }else {
            [wself.topParentViewController showHint:response.errDesc];
        }
        [wself hideHud];
    };
    
    if (showHUD) {
        // [self showHudInView:self.view hint:nil];
    }
    [[G100BikeApi sharedInstance] loadRelativeUserinfoWithBikeid:self.bikeid callback:callback];
}

#pragma mark - UITableViewDeledate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userDataArray.count + self.auditingDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    G100BikeUserDisCell *cell = [tableView dequeueReusableCellWithIdentifier:@"G100BikeUserDisCell"];
    
    G100UserDomain *user = [[G100UserDomain alloc] init];
    if (indexPath.row < self.userDataArray.count) {
        user = [self.userDataArray safe_objectAtIndex:indexPath.row];
        user.user_status = 1;
    } else {
        user = [self.auditingDataArray safe_objectAtIndex:indexPath.row-self.userDataArray.count];
        user.user_status = 2;
    }
    
    if ([self.userid isEqualToString:user.userid]) {
        [cell setUserDomain:user isYourself:YES];
    } else {
        [cell setUserDomain:user isYourself:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    G100UserDomain *userDomain = [[G100UserDomain alloc] init];
    if (indexPath.row < self.userDataArray.count) {
        userDomain = [self.userDataArray safe_objectAtIndex:indexPath.row];
        userDomain.user_status = 1;
    } else {
        userDomain = [self.auditingDataArray safe_objectAtIndex:indexPath.row-self.userDataArray.count];
        userDomain.user_status = 2;
    }
    
    if (self.bikeInfoModel.bike.isMaster) {
        if ([self.userid isEqualToString:userDomain.userid]){
            return;
        }
        
        if (userDomain.user_status == 1) {
            // 正常的副用户
            G100BikeInfoUserDetailView * appview = [[[NSBundle mainBundle]loadNibNamed:@"G100BikeInfoUserDetailView" owner:self options:nil]lastObject];
            
            [appview showBindApplicationViewWithVc:self.topParentViewController view:self.topParentViewController.view user:userDomain buttonClick:^(NSInteger tag, BOOL hasChanged,NSString *comment) {
                if (tag == 1) {
                    if (hasChanged) {
                        [self updateDevInfoWithComment:comment userDomain:userDomain onView:appview];
                    }else{
                        if ([appview superview]) {
                            [appview removeFromSuperview];
                        }
                    }
                }else if (tag == 2){
                    [self deleteUserWithUserDomain:userDomain onView:appview];
                }else if (tag == 3){
                    [self dismissAppviewWithCommnet:comment userDomain:userDomain onView:appview];
                }
            } animated:YES];
        } else if (userDomain.user_status == 2) {
            // 待审核的用户
            G100PushMsgDomain *pushDomain = [[G100PushMsgDomain alloc] init];
            pushDomain.msgid = 0;
            
            NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
            pushDomain.mcts = [[formatter dateFromString:userDomain.created_time] timeIntervalSince1970];
            NSDictionary *addvalDict = @{
                                         @"devid" : self.bikeid,
                                         @"nickname" : userDomain.nick_name,
                                         @"phone" : userDomain.phone_num,
                                         @"requestor" : userDomain.userid
                                         };
            
            pushDomain.addval = [addvalDict mj_JSONString];
            
            BindApplicationView * appview = [[[NSBundle mainBundle]loadNibNamed:@"BindApplicationView" owner:self options:nil] lastObject];
            [appview showBindApplicationViewWithVc:self.topParentViewController
                                              view:self.topParentViewController.view
                                              user:pushDomain
                                       buttonClick:^(NSInteger index){
                                           [self loadBikesUsers:self.userid bikeid:self.bikeid showHUD:NO];
                                       }
                                          animated:YES];
        } else {
            
        }
    }
}
#pragma mark - 修改备注
- (void)updateDevInfoWithComment:(NSString *)comment userDomain:(G100UserDomain *)userDomain onView:(UIView *)appView{
    __weak __typeof__(self) wself = self;
    [self showHudInView:CURRENTVIEWCONTROLLER.view hint:@"修改中"];
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeInfoWithUserid:self.userid bikeid:self.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [wself showHint:@"修改成功"];
                    if ([appView superview]) {
                        [appView removeFromSuperview];
                    }
                    [wself loadBikesUsers:wself.userid bikeid:wself.bikeid showHUD:NO];
                }else{
                    if (response) {
                        [wself showHint:response.errDesc];
                    }
                }
            }];
            
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    [[G100UserApi sharedInstance] sv_commentUserWithUserid:userDomain.userid bikeid:self.bikeid comment:comment callback:callback];
}
#pragma mark - 删除用户
- (void)deleteUserWithUserDomain:(G100UserDomain *)userDomain onView:(UIView *)appview{
    NSString *noticeStr = [NSString stringWithFormat:@"删除用户后, 用户%@将不能使用您的车辆",userDomain.nickname];
    G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithReactiveView];
    [pop showPopingViewWithTitle:@"提醒" content:noticeStr noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
        if (index == 2) {
            
            // 删除用户
            __weak G100BikeInfoUserViewController * wself = self;
            [[G100BikeApi sharedInstance] removeBikeUserWithUserid:userDomain.userid bikeid:self.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [[UserManager shareManager] updateBikeInfoWithUserid:wself.userid bikeid:wself.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                        [wself showHint:@"删除成功"];
                        
                        if ([appview superview]) {
                            [appview removeFromSuperview];
                        }
                        [wself.tableView reloadData];
                    }];
                }
                
                [wself loadBikesUsers:wself.userid bikeid:wself.bikeid showHUD:NO];
            }];
            
        }
        [pop dismissWithVc:self animation:YES];
    } onViewController:self.topParentViewController onBaseView:self.topParentViewController.view];
}
#pragma mark - 修改备注后关闭弹出view操作
- (void)dismissAppviewWithCommnet:(NSString *)comment userDomain:(G100UserDomain *)userDomain onView:(UIView *)appview{
    __weak G100BikeInfoUserViewController * wself = self;
    G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithReactiveView];
    [pop showPopingViewWithTitle:@"保存本次编辑" content:@"" noticeType:ClickEventBlockCancel otherTitle:@"不保存" confirmTitle:@"保存" clickEvent:^(NSInteger index) {
        if (index == 1) {
            if ([appview superview]) {
                [appview removeFromSuperview];
            }
            [pop dismissWithVc:self animation:YES];
            [wself.tableView reloadData];

        }else if(index == 2){
            [pop dismissWithVc:self animation:YES];
            [wself updateDevInfoWithComment:comment userDomain:userDomain onView:appview];
        }
    
    } onViewController:self.topParentViewController onBaseView:self.topParentViewController.view];
}

#pragma mark - Private Method
- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadUserData)
                                                 name:@"ViceUserApply" object:nil];
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadUserData{
    [self loadBikesUsers:self.userid bikeid:self.bikeid showHUD:NO];
}

#pragma mark - Public Method
- (CGFloat)heightForItem:(id)item width:(CGFloat)width {
    return 70 * self.userDataArray.count + self.auditingDataArray.count + 46;
}

- (void)setBikeInfoModel:(G100BikeInfoCardModel *)bikeInfoModel {
    _bikeInfoModel = bikeInfoModel;
    
    [self.tableView reloadData];
}

#pragma mark - Lazy Load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"G100BikeUserDisCell" bundle:nil] forCellReuseIdentifier:@"G100BikeUserDisCell"];
    }
    return _tableView;
}
- (NSMutableArray *)userDataArray{
    if (!_userDataArray) {
        _userDataArray = [NSMutableArray array];
    }
    return _userDataArray;
}

- (NSMutableArray<G100UserDomain *> *)auditingDataArray {
    if (!_auditingDataArray) {
        _auditingDataArray = [[NSMutableArray alloc] init];
    }
    return _auditingDataArray;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 顶部车辆用户提示
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 46)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, WIDTH, 46)];
    label.text = @"车辆用户";
    label.textColor = [UIColor blackColor];
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium"size:17];
    
    if (font) {
        label.font = font;
    }else{
        label.font = [UIFont boldSystemFontOfSize:17];
    }
    
    [view addSubview:label];
    
    UIView *seperatorView = [[UIView alloc] init];
    seperatorView.backgroundColor = [UIColor colorWithHexString:@"dedede"];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:seperatorView];
    [self.view addSubview:view];
    
    // 布局
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(@0);
        make.height.equalTo(@46);
    }];
    
    [seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(view.mas_bottom);
        make.right.equalTo(-20);
        make.height.equalTo(@1);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(seperatorView.mas_bottom).with.offset(@-1);
        make.left.right.bottom.equalTo(0);
    }];
    
    [UILabel adjustAllLabel:self.view multiple:0.5];
    
    // 请求用户数据
    [self loadBikesUsers:self.userid bikeid:self.bikeid showHUD:YES];
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadBikesUsers:self.userid bikeid:self.bikeid showHUD:NO];
}

- (void)dealloc{
    [self removeNotification];
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
