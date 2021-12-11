//
//  G100DevUpdateViewController.m
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100DevUpdateViewController.h"
#import "G100UpdatingVersionView.h"
#import "G100BikeApi.h"
#import "G100UpdateVersionModel.h"
#import "NSDate+TimeString.h"

#import "G100UpdateVersionCell.h"
static dispatch_once_t onceToken;
static G100DevUpdateViewController *shareInstance = nil;
@interface G100DevUpdateViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) G100UpdatingVersionView *updateVersionView;
@property (nonatomic, assign) CGFloat currentProgress;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) NSTimer *checkTimer;

@property (nonatomic, assign) CGFloat scheduledTime; //预估时间
@property (nonatomic, assign) NSTimeInterval updateInterval; //已更新时间
@property (nonatomic, assign) NSTimeInterval leftInterval; //剩余时间
@property (nonatomic, assign) BOOL hasLoaded; //下载状态
@property (nonatomic, assign) BOOL isDownloadIng;
@property (nonatomic, assign) int upgrade_id;
@property (nonatomic, assign) int currentState; //0默认状态无更新 1有新版本 2用户已确认升级 3升级下载中 4升级中

@property (nonatomic, strong) UILabel *latestLabel;

@end

@implementation G100DevUpdateViewController {
    CGFloat checkValue;
}

- (void)dealloc {
    if ([_progressTimer isValid]) {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
    
    if ([_checkTimer isValid]) {
        [_checkTimer invalidate];
        _checkTimer = nil;
    }
}

+ (instancetype)shareSigleTon {
    dispatch_once(&onceToken, ^{
        shareInstance = [[G100DevUpdateViewController alloc] init];
    });
    return shareInstance;
}

+ (void)attempDealloc {
    /**
     *  只有置成0，GCD才会认为它从未执行过。它默认为0
     *  这样才能保证下次再次调用shareInstance的时候，再次创建对象
     */
    
    onceToken = 0;
    shareInstance = nil;
}

#pragma mark - Lazy Load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _tableView;
}
- (G100UpdatingVersionView *)updateVersionView {
    if (!_updateVersionView) {
        _updateVersionView = [G100UpdatingVersionView loadG100UpdatingVersionView];
    }
    return _updateVersionView;
}
- (UILabel *)latestLabel {
    if (!_latestLabel) {
        _latestLabel = [[UILabel alloc] init];
        _latestLabel.textAlignment = NSTextAlignmentCenter;
        _latestLabel.textColor = [UIColor blackColor];
        _latestLabel.numberOfLines = 0;
        _latestLabel.text = @"已是最新版本";
    }
    return _latestLabel;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100UpdateVersionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"G100UpdateVersionCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.row == 0) {
        cell.title = [NSString stringWithFormat:@"%@升级内容", self.updateVersionModel.firm.latest];
        cell.desc = self.updateVersionModel.firm.latest_desc;
    }else {
        cell.title = @"硬件升级提示";
        cell.desc = self.updateVersionModel.firm.upgrade_prompt;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *desc = @"";
    
    if (indexPath.row == 0) {
        desc = self.updateVersionModel.firm.latest_desc;
    }else {
        desc = self.updateVersionModel.firm.upgrade_prompt;
    }
    
    return [G100UpdateVersionCell heightForDesc:desc];
}
#pragma mark - 检查是否有更新
- (void)checkUpdateVersion {
    __weak typeof(self) wself = self;
    [[G100BikeApi sharedInstance] checkDeviceFirmWithBikeid:self.bikeid deviceid:self.devid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        
        if (requestSuccess) {
            wself.updateVersionModel = [[G100UpdateVersionModel alloc] initWithDictionary:response.data];
            if (wself.updateVersionModel.firm.state == 0) {
                [wself setupLatestVersionUI];
                [[UserManager shareManager]updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
                    [self performSelector:@selector(setupLatestVersionUI) withObject:nil afterDelay:1.0];
                }];
            }else if (wself.updateVersionModel.firm.state == 1) {
                //有最新版本 有新版本 或者 升级失败成功
                NSNumber *upgradeID = [[G100InfoHelper shareInstance]getUpgradeIDWithDevid:self.devid];
                if ([upgradeID integerValue] > 0) {
                    [wself checkHisInfo];
                }else{
                    [wself setupUpdateVersionUIWithError:NO]; //不存在上次升级结果
                }
            }else { //正在升级/下载
                wself.isDownloadIng = YES;
                [wself setupUpdatingVersionUI];
            
                if (![wself.checkTimer isValid]) {
                    wself.checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:wself selector:@selector(getUpdateData) userInfo:nil repeats:YES];
                    [wself.checkTimer fire];
                }
                [wself checkUnFinshed];
                [wself checkHisInfo];
            }
            [wself.tableView reloadData];
        }else {
            [wself showHint:response.errDesc];
        }
    }];
}
#pragma mark - 升级
- (void)confirmUpdate {
    __weak typeof(self) wself = self;
    [[G100BikeApi sharedInstance] confirmDeiveFirmUpdateWithBikeid:self.bikeid deviceid:self.devid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            wself.isDownloadIng = YES;
            if (![wself.checkTimer isValid]) {
                wself.checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:wself selector:@selector(getUpdateData) userInfo:nil repeats:YES];
                [wself.checkTimer fire];
            }
            
            [wself checkUnFinshed];
            
            [wself setupUpdatingVersionUI];
            [wself.updateVersionView showUpdateHint:@"检查车辆升级条件" warnning:NO];
        }else {
            [wself.updateVersionView.reDetectionBtn setTitle:@"重新检测" forState:UIControlStateNormal];
            [wself.updateVersionView showUpdateHint:response.errDesc warnning:YES];
        }
    }];
}

#pragma mark - 检查当前更新状态 更新数据
- (void)getUpdateData {
    __weak typeof(self) wself = self;
    [[G100BikeApi sharedInstance] checkDeviceFirmWithBikeid:self.bikeid deviceid:self.devid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            wself.updateVersionModel = [[G100UpdateVersionModel alloc] initWithDictionary:response.data];
            
            wself.currentState = wself.updateVersionModel.firm.state; //当前更新状态
            wself.updateInterval = wself.updateVersionModel.ts - wself.updateVersionModel.firm.upgrade_begin_time;
            
            [wself updateUpgradeID];
            [wself.tableView reloadData];
            
        }else {
            [wself.updateVersionView showUpdateHint:response.errDesc warnning:YES];
        }
    }];
}

- (void)checkUnFinshed {
    if (!_progressTimer) {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkUnFinshed) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    }
    
    self.currentState = self.updateVersionModel.firm.state;
    self.updateInterval = self.updateVersionModel.ts - self.updateVersionModel.firm.upgrade_begin_time;
    self.leftInterval = self.updateVersionModel.firm.upgrade_total_est - self.updateInterval;
    
    // 根据状态分别调用不同操作
    if (self.currentState <= 2) {
        [self checkStatus];
    }else if (self.currentState <= 3) {
        [self checkLoadStatus];
    }else if (self.currentState <= 4) {
        [self checkUpdateStatus];
    }
}

#pragma mark - 1. 下载前检查状态
- (void)checkStatus {
    if (self.currentState != 2 ) {
        [self checkHisInfo];
        return;
    }
    if (self.updateInterval > 5) { //检查已经用时超过5s
        checkValue = 0.19;
    }else{
        checkValue += 0.04 ;
    }
    if (checkValue >= 0.19) {
        checkValue = 0.19;
    }
    
    [self updateUI];
}

#pragma mark - 2. 下载中
- (void)checkLoadStatus {
    if (self.currentState != 3) {
        [self checkHisInfo];
        return;
    }
    if (self.leftInterval > 0) {
        if (checkValue < 0.2) {
        //每秒进度 * 已经下载时间 + 检测进度(0.2)
        checkValue = 0.2 + ((0.99 - 0.2)/self.leftInterval * self.updateInterval);
        }
        checkValue += (0.99 - 0.2)/self.leftInterval;
    }else{
         checkValue = 0.49;
    }
    if (checkValue >= 0.49 ) {
        checkValue = 0.49;
    }
    [self.updateVersionView showUpdateHint:@"系统下载中" warnning:NO];
    [self updateUI];
}

#pragma mark - 3.下载完成 开始升级
- (void)checkUpdateStatus {
    if (self.currentState != 4) { //升级检查
        [self checkHisInfo];
        return;
    }
    if (self.leftInterval > 0) {
        if (checkValue < 0.5) {
            //升级用时 = 服务器时间戳 - 升级开始时间戳
            NSTimeInterval upgradeTime = self.updateVersionModel.ts - self.updateVersionModel.firm.upgrade_begin_time;
            // 下载完成时间为整个预估时间的30%
            // CGFloat loadTime =  self.updateVersionModel.firm.upgrade_total_est * 0.3;
            // 每秒进度 * 升级用时 +下载进度(0.5)
            checkValue = 0.5 + ((0.99 - 0.5)/self.leftInterval * upgradeTime);
        }
        checkValue += (0.99 - 0.5)/self.leftInterval;
    }else{
         checkValue = 0.99;
    }
    if (checkValue >= 0.99 ) {
        checkValue = 0.99;
    }
    [self.updateVersionView showUpdateHint:@"系统升级中\n禁止移除车辆的电瓶、禁止骑行！" warnning:NO];
    [self updateUI];
}

#pragma mark - 检查更新历史
- (void)checkHisInfo {
    //更新结果
    G100DeviceFirmUpgradeHisModel *hisModel = self.updateVersionModel.upgrade_his.firstObject;
    NSNumber *upgradeID = [[G100InfoHelper shareInstance]getUpgradeIDWithDevid:self.devid];
    if (upgradeID.intValue == hisModel.upgrade_id) {
        if (hisModel.result == 1) { //成功
            [self destroyUpdateDataTimer];
            [self destroyCheckTimer];
            
            checkValue = 1;
            [self updateUI];
            [[UserManager shareManager]updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
                [self performSelector:@selector(setupLatestVersionUI) withObject:nil afterDelay:0.6];
            }];
        }else if (hisModel.result == 2){ //失败
            [self destroyUpdateDataTimer];
            [self destroyCheckTimer];
            
            [self setupUpdateVersionUIWithError:YES]; //存在上次升级结果
            //判断失败原因 显示对应提示
            [self updateErrorUI:hisModel.reason];
        }
        
        self.isDownloadIng = NO;
        [[G100InfoHelper shareInstance]setUpgradeID:[NSNumber numberWithInt:0] devid:self.devid];        
        [G100DevUpdateViewController attempDealloc];
    }else{
        if (self.updateVersionModel.firm.state == 1) {
           [[G100InfoHelper shareInstance]setUpgradeID:[NSNumber numberWithInt:0] devid:self.devid];
            [self setupUpdateVersionUIWithError:NO];
        }
    }
}

- (void)updateErrorUI:(NSInteger)reason {
    NSString *errorHint = @"升级失败";
    NSString *btnTitle = @"重新检查";
    NSString *progressValue = @"0%";
    self.updateVersionView.reDetectionBtn.hidden = NO;
    self.updateVersionView.hintLabel.hidden = NO;
    switch (reason) {
        case 1:
        {
            errorHint = @"车辆网络信号差，你可以移动车辆至空旷区域后重新升级。";
            progressValue = @"19%";
        }
            break;
        case 2:
        {
            errorHint = @"电瓶已拔出，无法进行升级，请插入电池后重新升级。";
            progressValue = @"19%";
        }
            break;
        case 3:
        {
            errorHint = @"骑行中，无法继续升级，请停车后重新升级";
            progressValue = @"19%";
        }
            break;
        case 4:
        {
             progressValue = @"19%";
        }
            break;
        case 5:
        {
            errorHint = @"下载超时";
            btnTitle = @"重新升级";
            progressValue = @"49%";
        }
            break;
        case 6:
        {
            errorHint = @"升级失败，请重新升级。";
            btnTitle = @"重新升级";
            progressValue = @"99%";
        }
            break;
        case 7:
        {
            errorHint = @"升级超时，请重新升级。";
            btnTitle = @"重新升级";
            progressValue = @"99%";
        }
            break;
        default:
        {
            errorHint = @"升级失败，请重新升级。";
            btnTitle = @"重新升级";
            progressValue = @"99%";
        }
            break;
    }
    
    self.updateVersionView.predictTimeLabel.hidden = YES;
    self.updateVersionView.progressLabel.text = self.updateVersionView.progressView.progress == 0 ?progressValue :self.updateVersionView.progressLabel.text;
    
    self.updateVersionView.progressView.progress = self.updateVersionView.progressView.progress == 0 ? progressValue.intValue * 0.01 : self.updateVersionView.progressView.progress;
    [self.updateVersionView.reDetectionBtn setTitle:btnTitle forState:UIControlStateNormal];
    [self.updateVersionView showUpdateHint:errorHint warnning:YES];
}

#pragma mark - 更新本地的升级ID
- (void)updateUpgradeID {
    //更新upgrade_id
    if (self.updateVersionModel.firm.upgrade_id.intValue != 0) {
        G100InfoHelper *infoHelper = [G100InfoHelper shareInstance];
        [infoHelper setUpgradeID:self.updateVersionModel.firm.upgrade_id devid:self.devid];
    }
}
- (void)updateUI {
    NSLog(@"%f-----%f", (0.99 - 0.49)/self.scheduledTime, checkValue);
    if (checkValue == 1) {
        self.updateVersionView.predictTimeLabel.hidden = YES;
        [self.updateVersionView showUpdateHint:@"恭喜你,系统升级已完成" warnning:NO];
    }else {
        self.updateVersionView.predictTimeLabel.hidden = NO;
        self.updateVersionView.predictTimeLabel.text = [NSString stringWithFormat:@"预计剩余时间:%@",[NSDate getMMSSFromSS:self.updateVersionModel.firm.upgrade_left_est]];
    }
    
    [self.updateVersionView.progressView setProgress:checkValue animated:YES];
    self.updateVersionView.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",checkValue * 100];
    
}

#pragma mark - Private Method
- (void)destroyUpdateDataTimer {
    if ([_progressTimer isValid]) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}
- (void)destroyCheckTimer {
    if ([_checkTimer isValid]) {
        [self.checkTimer invalidate];
        self.checkTimer = nil;
    }
}

#pragma mark - setupView
- (void)setupView {
    
    [self.view addSubview:self.updateVersionView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.latestLabel];
    
    [self.latestLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(kNavigationBarHeight + 36));
        make.centerX.equalTo(self.view);
    }];
    
    [G100UpdateVersionCell registerNibCell:self.tableView];
    
    [self.updateVersionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(240.0/414*WIDTH));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(@kNavigationBarHeight);
        make.bottom.equalTo(self.updateVersionView.mas_top);
    }];
    self.latestLabel.hidden = YES;
    self.tableView.hidden = YES;
    self.updateVersionView.hidden = YES;
    
    if (!self.isDownloadIng) {
        self.updateVersionView.progressView.progress = 0.0;
        self.updateVersionView.progressLabel.text = @"0%";
    }
    
    __weak typeof(self) wself = self;
    self.updateVersionView.bottomBtnBlock = ^(){
        wself.updateVersionView.progressBackView.hidden = NO;
        wself.updateVersionView.progressLabel.text = @"0%";
        wself.updateVersionView.progressView.progress = 0;
        wself.updateInterval = 0;
        wself.leftInterval = 0;
        [wself confirmUpdate];
    };
}
#pragma mark - 显示最新版本
- (void)setupLatestVersionUI {
     G100DeviceDomain *devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid
                                                                  bikeid:self.bikeid
                                                                   devid:self.devid];
    self.latestLabel.hidden = NO;
   
    self.latestLabel.text = [NSString stringWithFormat:@"%@\n已是最新版本", devDomain.firm];
    
    self.tableView.hidden = YES;
    self.updateVersionView.hidden = YES;
    self.updateVersionView.reDetectionBtn.hidden = YES;
}
#pragma mark - 显示需要更新版本
- (void)setupUpdateVersionUIWithError:(BOOL)hasError {
    if (hasError) {
        self.updateVersionView.progressBackView.hidden = NO;
    }else{
        self.updateVersionView.progressBackView.hidden = YES;
    }
    self.latestLabel.hidden = YES;
    self.tableView.hidden = NO;
    self.updateVersionView.hidden = NO;
    self.updateVersionView.reDetectionBtn.hidden = NO;
    [self.updateVersionView.reDetectionBtn setTitle:@"立即升级" forState:UIControlStateNormal];
}
- (void)setupUpdatingVersionUI{
    self.latestLabel.hidden = YES;
    self.tableView.hidden = NO;
    self.updateVersionView.hidden = NO;
    self.updateVersionView.progressBackView.hidden = NO;
    self.updateVersionView.reDetectionBtn.hidden = YES;
    self.updateVersionView.predictTimeLabel.hidden = NO;
}
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationTitle:@"硬件版本升级"];
    
    
    [self setupView];
    
    [self showHudInView:self.view hint:@"正在检查更新"];
    
//    [self checkUpdateVersion];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkUpdateVersion];
    [self getUpdateData];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.checkTimer invalidate];
    [self.progressTimer invalidate];
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
