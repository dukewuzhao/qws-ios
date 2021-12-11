//
//  G100FuncReminderSetViewController.m
//  G100
//
//  Created by 天奕 on 16/1/6.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100FuncReminderSetViewController.h"
#import "G100FuncSetNoPromptViewController.h"
#import "G100FuncSetPromptTimeViewController.h"
#import "G100FuncSetOverSpeedViewController.h"

#import "G100TableViewSwitchCell.h"
#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "G100DeviceDomain.h"
#import "G100BikeDomain.h"

static NSString * const funset_acc_open_notice = @"accopennotice";
static NSString * const funset_acc_overSpped   = @"overSpeedCell";
@interface G100FuncReminderSetViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) NSMutableArray * cellIdentifiersArray;

@property (strong, nonatomic) NSMutableArray * cellTitleArray;

@property (strong, nonatomic) NSMutableArray * cellNoticeArray;

@property (nonatomic, strong) NSString *overSpeedDetail;

@property (assign, nonatomic) BOOL isSwitching;
@end

@implementation G100FuncReminderSetViewController

- (void)dealloc {
    DLog(@"更多设置页面已释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNRefreshCarList object:nil];
}

- (void)initialDataSource {
    _cellIdentifiersArray = @[@"cell", @"cell"].mutableCopy;
    _cellTitleArray       = @[@"忽略相同类型提醒", @"提醒时长设置"].mutableCopy;
    _cellNoticeArray      = @[@"收到车辆报警提醒并选择忽略，一定时间内相同类型提醒不再提示。丢车模式下无法设置",
                              @"收到前台车辆报警提醒时持续响铃时间"].mutableCopy;
    
    G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    G100BikeDomain * bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];

    if (bikeDomain.max_speed_on) {
        _overSpeedDetail = @"已开启";
    }else {
        _overSpeedDetail = @"已关闭";
    }
    
    if (devDomain.func.alertor.switch_on == DEV_ALERTOR_TYPE_HASALARM) {
        [_cellIdentifiersArray addObject:@"cell"];
        [_cellTitleArray addObject:@"超速设置"];
    }else {
        [_cellIdentifiersArray addObject:funset_acc_open_notice];
        [_cellTitleArray addObject:@"电门打开提醒"];
        [_cellNoticeArray addObject:@"打开电门是否报警提醒(在部分车型上可能存在误报)"];
        
        [_cellIdentifiersArray addObject:funset_acc_overSpped];
        [_cellTitleArray addObject:@"超速设置"];
    }
    
    [self.contentTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationTitle:@"更多提醒设置"];
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialDataSource) name:kGNRefreshCarList object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [[UserManager shareManager] updateDevInfoWithUserid:self.userid
                                                 bikeid:self.bikeid
                                                  devid:self.devid
                                               complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            // 初始化数据
            [self initialDataSource];
            [weakSelf.contentTableView reloadData];
        }
    }];
    // 初始化数据
    [self initialDataSource];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier = _cellIdentifiersArray[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.userInteractionEnabled = YES;
    cell.textLabel.text = self.cellTitleArray[indexPath.section];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    
    if (indexPath.section == 0) {
        G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
        if ([devDomain isLostDevice]) {
            cell.userInteractionEnabled = NO;
            cell.detailTextLabel.text = @"无法设置";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else {
            NSString * timestr = @"无";
            if (devDomain.security.ignore_notify_time == 0) {
                
            }else {
                timestr = [NSString stringWithFormat:@"%@分钟内", @(devDomain.security.ignore_notify_time)];
            }
            cell.detailTextLabel.text = timestr;
        }
        
    }else if (indexPath.section == 1) {
        NSInteger time = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid].alarm_bell_time;
        if (time == 0) {
            cell.detailTextLabel.text = @"持续";
        }else if (time == 60) {
            cell.detailTextLabel.text = @"1分钟";
        }else if (time == 180) {
            cell.detailTextLabel.text = @"3分钟";
        }else if (time == 300) {
            cell.detailTextLabel.text = @"5分钟";
        }else if (time == 600) {
            cell.detailTextLabel.text = @"10分钟";
        }
    }else if (indexPath.section == self.cellTitleArray.count - 1){
        cell.detailTextLabel.text = _overSpeedDetail;
    }
    else {
        if ([cellIdentifier isEqualToString:funset_acc_open_notice]) {
            G100TableViewSwitchCell * kSwitchCell = [tableView dequeueReusableCellWithIdentifier:@"G100TableViewSwithCell"];
            if (!kSwitchCell) {
                kSwitchCell = [[[NSBundle mainBundle] loadNibNamed:@"G100TableViewSwitchCell" owner:self options:nil] lastObject];
            }
            
            G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
            kSwitchCell.hintTitleLabel.text = self.cellTitleArray[indexPath.section];
            kSwitchCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (devDomain.security.acc_on_notify) {
                kSwitchCell.rightSwitch.on = YES;
            }else {
                kSwitchCell.rightSwitch.on = NO;
            }
            
            kSwitchCell.openStatus = kSwitchCell.rightSwitch.on;
            __weak G100FuncReminderSetViewController * wself = self;
            kSwitchCell.rightSwitchBlock = ^(BOOL result){
                [wself updateAccNotifyWithBikeid:wself.bikeid accnotify:result ? 1 : 0 complete:nil];
            };
            
            return kSwitchCell;
        }        
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return 30.0f;
    }
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(self.cellNoticeArray.count < section + 1) {
        return 0.1;
    }
    NSString * content = self.cellNoticeArray[section];
    
    if (!content.length) {
        return 0.1;
    }else {
        CGSize contentSize = [content calculateSize:CGSizeMake(WIDTH - 35, 1000) font:[UIFont systemFontOfSize:14]];
        return contentSize.height + 8;
    }
    
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(self.cellNoticeArray.count < section + 1) {
        return nil;
    }
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, backView.v_width - 35, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:14];
    
    [backView addSubview:titleLabel];
    
    titleLabel.text = self.cellNoticeArray[section];
    
    // 计算footer的高度
    CGSize contentSize = [titleLabel.text calculateSize:CGSizeMake(titleLabel.v_width, 1000) font:titleLabel.font];
    backView.v_height = titleLabel.v_height = contentSize.height + 8;
    
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        G100DeviceDomain * devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
        G100FuncSetNoPromptViewController * funcSetNoPrompt = [[G100FuncSetNoPromptViewController alloc] initWithNibName:@"G100FuncSetNoPromptViewController" bundle:nil];
        funcSetNoPrompt.userid = self.userid;
        funcSetNoPrompt.bikeid = self.bikeid;
        funcSetNoPrompt.devid = self.devid;
        funcSetNoPrompt.pushIgnoreTime = devDomain.security.ignore_notify_time;
        [self.navigationController pushViewController:funcSetNoPrompt animated:YES];
    }else if (indexPath.section == 1) {
        G100FuncSetPromptTimeViewController *setPromptTime = [[G100FuncSetPromptTimeViewController alloc]initWithNibName:@"G100FuncSetPromptTimeViewController" bundle:nil];
        setPromptTime.userid = self.userid;
        setPromptTime.bikeid = self.bikeid;
        setPromptTime.devid = self.devid;
        NSInteger selected;
        NSInteger time = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid].alarm_bell_time;
        if (time == 0) {
            selected = 4;
        }else if (time == 60) {
            selected = 0;
        }else if (time == 180) {
            selected = 1;
        }else if (time == 300) {
            selected = 2;
        }else if (time == 600) {
            selected = 3;
        }else {
            selected = 3;
        }
        
        setPromptTime.selected = selected;
        [self.navigationController pushViewController:setPromptTime animated:YES];
    }else if (indexPath.section == self.cellTitleArray.count - 1){
        G100FuncSetOverSpeedViewController *overSpeedVC = [[G100FuncSetOverSpeedViewController alloc]initWithNibName:@"G100FuncSetOverSpeedViewController" bundle:nil];
        overSpeedVC.userid = self.userid;
        overSpeedVC.bikeid = self.bikeid;
        overSpeedVC.devid = self.devid;
        [self.navigationController pushViewController:overSpeedVC animated:YES];
    }
}

-(void)updateAccNotifyWithBikeid:(NSString *)bikeid accnotify:(NSInteger)accnotify complete:(void (^)())completeBlock {
    __weak G100FuncReminderSetViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        
        if (requestSuccess) {
            // 刷新设备列表
            if (completeBlock) {
                completeBlock();
            }
            [[UserManager shareManager] updateDevListWithUserid:self.userid bikeid:self.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [wself.contentTableView reloadData];
                }
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [self showHudInView:self.contentTableView hint:nil];
    [[G100BikeApi sharedInstance] setAccNotifyWithBikeid:bikeid notify:accnotify callback:callback];
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
