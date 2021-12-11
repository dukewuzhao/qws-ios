//
//  G100DevLogsViewController.m
//  G100
//
//  Created by Tilink on 15/2/27.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100DevLogsViewController.h"
#import "G100AMapTrackViewController.h"
#import "G100DevUsageSummaryDomain.h"
#import "TQMultistageTableView.h"
#import "DevLogsLocalDomain.h"
#import "G100DevLogsDomain.h"

#import "DevLogsHeaderView.h"
#import "DevLogsCommonCell.h"
#import "DevLogsOpenView.h"
#import "G100TopTipsView.h"

#import "MJRefresh.h"
#import "G100BikeApi.h"
#import "G100UserApi.h"
#import "DatabaseOperation.h"
#import "NotificationHelper.h"

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface G100DevLogsViewController () <DevLogsHeaderViewDelegate, TQTableViewDelegate, TQTableViewDataSource, UIScrollViewDelegate> {
    char *_expandedSections;
}

@property (strong, nonatomic) NSMutableArray  * dataArray;
@property (strong, nonatomic) NSMutableArray  * shakeArray;
@property (strong, nonatomic) NSMutableArray  * driveDaySummary;
@property (strong, nonatomic) TQMultistageTableView * mTableView;
@property (nonatomic, strong) G100TopTipsView * topTipsView;
// 记录scrollView的最后一次位置
@property (nonatomic, assign) CGFloat         lastContentOffset;

@end

@implementation G100DevLogsViewController

-(void)dealloc {
    DLog(@"用车报告已释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.driveDaySummary = [[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc]init];
    self.shakeArray = [[NSMutableArray alloc]init];
    
    [self setNavigationTitle:@"用车报告"];
    
    self.mTableView = [[TQMultistageTableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.backgroundColor = [UIColor clearColor];
    self.mTableView.tableView.backgroundColor = [UIColor clearColor];
    [self.mTableView.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.mTableView.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 15);
    self.mTableView.tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    self.mTableView.tableView.estimatedRowHeight = 0;
    self.mTableView.tableView.estimatedSectionHeaderHeight = 0;
    self.mTableView.tableView.estimatedSectionFooterHeight = 0;
    
    [self.contentView addSubview:_mTableView];
    
    // 注册 Cell
    [self.mTableView.tableView registerNib:[UINib nibWithNibName:kNibNameDevLogsNormalCell
                                                          bundle:nil]
                    forCellReuseIdentifier:kNibNameDevLogsNormalCell];
    [self.mTableView.tableView registerNib:[UINib nibWithNibName:kNibNameDevLogsErrorCell
                                                          bundle:nil]
                    forCellReuseIdentifier:kNibNameDevLogsErrorCell];
    [self.mTableView.tableView registerNib:[UINib nibWithNibName:kNibNameDevLogsNormalDriveCell
                                                          bundle:nil]
                    forCellReuseIdentifier:kNibNameDevLogsNormalDriveCell];
    [self.mTableView.tableView registerNib:[UINib nibWithNibName:kNibNameDevLogsUnNormalDriveCell
                                                          bundle:nil]
                    forCellReuseIdentifier:kNibNameDevLogsUnNormalDriveCell];
    
    // 获取toptips的提示
    [self getPagePromptWithPage:@"bikeusagereport" ShowHUD:NO];
    
    // 获取日概要
    [self getDaySummaryFormServer:YES];
    
    __weak G100DevLogsViewController * wself = self;
    MJRefreshHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (!wself.devid) {
            return;
        }
        
        [wself getDaySummaryFormServer:NO];
    }];
    header.lastUpdatedTimeKey = NSStringFromClass([self class]);
    self.mTableView.tableView.mj_header = header;
}

#pragma mark - 清空数据
-(void)noDataForYourDeviceWithSection:(NSInteger)section {
    if (section == -1) {
        // 所有数据空    清空所有数据
        [_dataArray removeAllObjects];
        [_shakeArray removeAllObjects];
        [_driveDaySummary removeAllObjects];
    }else {
        // 清空某天数据
        [_dataArray replaceObjectAtIndex:section withObject:@[]];
    }
    
    [_mTableView reloadData];
}

-(void)getPagePromptWithPage:(NSString *)page ShowHUD:(BOOL)showHUD {
    __weak G100DevLogsViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            NSString * prompt = response.data[@"prompt"];
            if (prompt.length && prompt) {
                // 有提示信息才显示
                // 判断是否是演示样机
                NSInteger accoutnType = [[[UserAccount sharedInfo] appwatermarking] type];
                if (accoutnType) {
                    wself.topTipsView = [[G100TopTipsView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 30)
                                                              backgroundColor:MyBackColor
                                                                         tips:prompt];
                    wself.mTableView.tableView.tableHeaderView = wself.topTipsView;
                }else {
                    wself.mTableView.tableView.tableHeaderView = nil;
                }
            }else {
                wself.mTableView.tableView.tableHeaderView = nil;
            }
        }else {
            wself.mTableView.tableView.tableHeaderView = nil;
        }
    };
    
    [[G100UserApi sharedInstance] getPagePromptInfoWithPage:page channel:@"0" callback:callback];
}

#pragma mark - 获取服务器的日概要
-(void)getDaySummaryFormServer:(BOOL)showHUD {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        [self.mTableView.tableView.mj_header endRefreshing];
        
        return;
    }
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            if (!NOT_NULL(response.data)) {
                if (showHUD) {
                    [self hideHud];
                }
                [self showHint:@"无数据"];
                [self noDataForYourDeviceWithSection:-1];
                [self.mTableView.tableView.mj_header endRefreshing];
                return;
            }
            
            [self.dataArray removeAllObjects];
            [self.shakeArray removeAllObjects];
            [self.driveDaySummary removeAllObjects];
            
            NSArray * result = [response.data objectForKey:@"usage_summary"];
            
            if (!NOT_NULL(result)) {
                if (showHUD) {
                    [self hideHud];
                }
                [self showHint:@"无数据"];
                [self noDataForYourDeviceWithSection:-1];
                [self.mTableView.tableView.mj_header endRefreshing];
                return;
            }
            
            if (result && result.count) {
                for (NSDictionary * dict in result) {
                    G100DevUsageSummaryDomain * model = [[G100DevUsageSummaryDomain alloc]initWithDictionary:dict];

                    [self.driveDaySummary addObject:model];
                    [self.dataArray addObject:@[]];
                    [self.shakeArray addObject:@[]];
                }
                
                [self reloadAllData];
                [self setupExpandedSections];
                
                [self getDevLogsFromServer:0 showHUD:NO];
            }else {
                if (showHUD) {
                    [self hideHud];
                }
                
                [self showHint:@"无数据"];
                [self noDataForYourDeviceWithSection:-1];
                [self.mTableView.tableView.mj_header endRefreshing];
            }
        }else {
            if (showHUD) {
                [self hideHud];
            }
            
            if (response) {
                [self showHint:response.errDesc];
            }
            [self.mTableView.tableView.mj_header endRefreshing];
        }
    };
    
    if (showHUD) {
        [self showHudInView:self.contentView hint:@"正在查询"];
    }
    
    [[G100BikeApi sharedInstance] loadDevDayDriveSummaryWithBikeid:self.bikeid devid:self.devid callback:callback];
}

#pragma mark - 更新仅有一天的数据
-(void)getDevLogsFromServer:(NSInteger)section showHUD:(BOOL)showHUD {
    if (kNetworkNotReachability) {
        [self hideHud];
        [self showHint:kError_Network_NotReachable];
        [self.mTableView.tableView.mj_header endRefreshing];
        return;
    }
    
    DevLogsHeaderView * sectionHeaderView = (DevLogsHeaderView *)[self.mTableView tableView:_mTableView.tableView viewForHeaderInSection:section];
    NSString * begintime = [NSString stringWithFormat:@"%@ 00:00:00", sectionHeaderView.timeStr];
    NSString * endtime = [NSString stringWithFormat:@"%@ 23:59:59", sectionHeaderView.timeStr];
    
    __weak G100DevLogsViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself.mTableView.tableView.mj_header endRefreshing];
        [wself hideHud];
        
        if (requestSuccess) {
            if (!NOT_NULL(response)) {
                [self noDataForYourDeviceWithSection:section];
                return;
            }
            
            NSArray * result = [response.data objectForKey:@"devmsg"];
            if (!NOT_NULL(result)) {
                [self noDataForYourDeviceWithSection:section];
                return;
            }
            
            NSMutableArray * dayModelArr = [[NSMutableArray alloc]init];
            if ([result count]) {
                for (int i = 0; i < [result count]; i++) {
                    NSDictionary * dict = [result safe_objectAtIndex:i];
                    G100DevLogsDomain * logsModel = [[G100DevLogsDomain alloc]initWithDictionary:dict];
                    // 按照时间分组                    
                    [dayModelArr addObject:logsModel];
                }
                
                [wself analyseDevLogsArrayNew:dayModelArr section:section];
            }else {
                [self noDataForYourDeviceWithSection:section];
            }
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    if (showHUD) {
        [self showHudInView:self.contentView hint:@"正在查询"];
    }
    //[[G100DevApi sharedInstance] loadListDevMsgWithDevid:self.devid begintime:begintime endtime:endtime callback:callback];
    [[G100BikeApi sharedInstance] loadListDevMsgWithBikeid:self.bikeid devid:self.devid begintime:begintime endtime:endtime callback:callback];
}

-(void)setupExpandedSections {
    if (_expandedSections != NULL)
    {
        free(_expandedSections);
        _expandedSections = NULL;
    }
    
    _expandedSections = (char *)malloc((self.dataArray.count) * sizeof(char));
    memset(_expandedSections, 0, (self.dataArray.count) * sizeof(char));
    _expandedSections[0] = 1;
}

-(void)reloadAllData {
    [self.mTableView reloadData];
}

-(CGFloat)findLastCellY {
    return MAX(self.mTableView.tableView.contentSize.height - 120, _mTableView.v_height);
}

#pragma mark - 分析某一天的用车报告       // 已经在数组里       请求数据
- (void)analyseDevLogsArrayNew:(NSArray *)logsArray section:(NSInteger)section {
    // 按日按等级将信息分组
    NSMutableArray * openCellArr = [[NSMutableArray alloc]init];
    NSMutableArray * openArr = [[NSMutableArray alloc]init];
    NSMutableArray * contentArray = [[NSMutableArray alloc]init];
    
    NSInteger index = 0;
    NSInteger count = 0;
    NSString * timeStr = [[NSString alloc]init];
    DevLogsLocalDomain * localDomain = [[DevLogsLocalDomain alloc]init];    // 内容domain
    localDomain.hasYanzhong = NO;
    
    G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance]findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    if (bikeDomain.max_speed != 0) {
        localDomain.overSpeedOpen = YES;
    }
    for (NSInteger i = 0; i < logsArray.count; i++) {
        G100DevLogsDomain * model = [logsArray safe_objectAtIndex:i];
        localDomain.topSpeedOpen = bikeDomain.max_speed_on;
        
        if (model.type == REPT_MSG_CODE_DEV_SHAKE) {
            // 震动消息 折叠处理
            count++;
            if ([model.msg integerValue] == DEV_SHAKE_LIGHT) {
                model.msg = @"轻微震动";
            }else if ([model.msg integerValue] == DEV_SHAKE_MEDIUM) {
                model.msg = @"中等震动";
            }else if ([model.msg integerValue] == DEV_SHAKE_SERIOUS){
                model.msg = @"严重震动";
                localDomain.hasYanzhong = YES;
            }
            
            [openCellArr addObject:model];
            timeStr = [model.ts substringWithRange:NSMakeRange(11, 8)];
            
            if (i == index) {
                localDomain.ts = timeStr;
            }
            
            if (i == [logsArray count] - 1) {
                if (openCellArr.count && openCellArr) {
                    [openArr addObject:openCellArr.copy];
                    //
                    localDomain.type = 1;
                    localDomain.title = @"车辆震动";
                    localDomain.msg = [NSString stringWithFormat:@"%ld次 ", (long)count];
                    
                    [contentArray addObject:localDomain.copy];
                    [openCellArr removeAllObjects];
                }
                
                index += i;
            }
        }else {
            index++;
            
            if (openCellArr.count && openCellArr) {
                if (i == index) {
                    localDomain.ts = timeStr;
                }
                
                [openArr addObject:openCellArr.copy];
                
                localDomain.type = 1;
                localDomain.title = @"车辆震动";
                localDomain.msg = [NSString stringWithFormat:@"%ld次 ", (long)count];
                
                [contentArray addObject:localDomain.copy];
                [openCellArr removeAllObjects];
            }
            
            localDomain.hasYanzhong = NO;
            // 否则加入一个空数组
            [openArr addObject:@[@""]];
            // 初始化数据    重新计数
            count = 0;
            
            if (model.type == REPT_MSG_CODE_NORMAL_DRIVE || model.type == REPT_MSG_CODE_UNNORMAL_DRIVE) {
                // 行驶记录
                localDomain = [localDomain initWithDictionary:[model.msg tl_specialJSONObject]];
                localDomain.ts = [model.ts substringWithRange:NSMakeRange(11, 8)];
                localDomain.type = model.type;
                localDomain.title = model.title;
            }else {
                localDomain = [localDomain initWithDictionary:[model mj_keyValues]];
                localDomain.ts = [model.ts substringWithRange:NSMakeRange(11, 8)];
                localDomain.type = model.type;
                localDomain.title = model.title;
            }
            
            [contentArray addObject:localDomain.copy];
        }

    }
    
    [self.shakeArray replaceObjectAtIndex:section withObject:openArr.copy];
    [self.dataArray replaceObjectAtIndex:section withObject:contentArray.copy];
    
    DevLogsHeaderView * headerView = (DevLogsHeaderView *)[self.mTableView.tableView headerViewForSection:section];
    [self headerView:headerView section:section expanded:YES];
}

#pragma mark - TQTableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataArray count];
}
- (NSInteger)mTableView:(TQMultistageTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataArray safe_objectAtIndex:section] count];
}
- (UITableViewCell *)mTableView:(TQMultistageTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DevLogsLocalDomain * domain = [[_dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    NSString * idenfierID = [DevLogsCommonCell idForRow:domain];
    
    DevLogsCommonCell * devLogsCell = [tableView dequeueReusableCellWithIdentifier:idenfierID];
    [devLogsCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [devLogsCell setLogsLocalDomain:domain];
    
    __weak DevLogsCommonCell * weakCell = devLogsCell;
    __weak G100DevLogsViewController * wself = self;
    if (domain.type == REPT_MSG_CODE_NORMAL_DRIVE ||
        domain.type == REPT_MSG_CODE_UNNORMAL_DRIVE) {
        devLogsCell.openEvent = ^(){
            // 行驶记录
            G100AMapTrackViewController * track = [[G100AMapTrackViewController alloc] init];
            track.userid = wself.userid;
            track.bikeid = wself.bikeid;
            track.devid = wself.devid;
            track.begintime = weakCell.begintime;
            track.endtime = weakCell.endtime;
            [wself.navigationController pushViewController:track animated:YES];
        };
    }else if (domain.type == REPT_MSG_CODE_UNNORMAL_DATA ||
              domain.type == REPT_MSG_CODE_DEV_SHAKE ||
              domain.type == REPT_MSG_CODE_SWITCH_OPEN ||
              domain.type == REPT_MSG_CODE_SWITCH_CLOSE ||
              domain.type == REPT_MSG_CODE_BATTERY_IN ||
              domain.type == REPT_MSG_CODE_BATTERY_OUT ||
              domain.type == REPT_MSG_CODE_VOLTAGE_LOW ||
              domain.type == REPT_MSG_CODE_ALARM_REMOVE ||
              domain.type == REPT_MSG_CODE_SWITCH_ILLEGAL_OPEN) {
        if ([_mTableView isOpenCellWithIndexPath:indexPath]) {
            devLogsCell.rightUpView.selected = YES;
        }else {
            devLogsCell.rightUpView.selected = NO;
        }
        
        if (devLogsCell.type == REPT_MSG_CODE_DEV_SHAKE) {
            devLogsCell.openEvent = ^(){
                // attempt to delete row 0 from section 0 which only contains 0 rows before the update (null)
                NSArray *tmp = [[wself.shakeArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
                if (![tmp count]) {
                    return;
                }
                [wself.mTableView openCellViewWithIndexPath:indexPath];
            };
        }
    }else if (domain.type == REPT_MSG_CODE_DEV_FAULT ||
              domain.type == REPT_MSG_CODE_ILLEGAL_DIS ||
              domain.type == REPT_MSG_CODE_MATCH_FAULT ||
              domain.type == REPT_MSG_CODE_COMM_FAULT) {
        devLogsCell.openEvent = nil;
    }
    
    return devLogsCell;
}

#pragma mark - Table view delegate
- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  1.3.7 修复 *** -[__NSArrayM objectAtIndex:]: index 18446744073709551615 beyond bounds [0 .. 12]
     */
    if ([_dataArray count] < indexPath.section+1) {
        return 44;
    }
    if ([[_dataArray safe_objectAtIndex:indexPath.section] count] < indexPath.row+1) {
        return 44;
    }
    
    DevLogsLocalDomain * domain = [[_dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    return [DevLogsCommonCell heightForRow:domain];
}

- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70;
}

- (CGFloat)mTableView:(TQMultistageTableView *)tableView heightForOpenCellAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_shakeArray count] < indexPath.section+1) {
        return 44;
    }
    if ([[_shakeArray safe_objectAtIndex:indexPath.section] count] < indexPath.row+1) {
        return 44;
    }
    
    NSArray * tmp = [[_shakeArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    CGFloat tmpHeight = tmp.count * 32 + 10;
    
    if (ISIPHONE_4) {
        return tmpHeight < 200 ? tmpHeight: 200;
    }else {
        return tmpHeight;
    }
}

- (UIView *)mTableView:(TQMultistageTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DevLogsHeaderView * sectionHeaderView = [[[NSBundle mainBundle]loadNibNamed:@"DevLogsHeaderView" owner:self options:nil]lastObject];
    sectionHeaderView.delegate = self;
    G100DevUsageSummaryDomain * model = [_driveDaySummary safe_objectAtIndex:section];
    [sectionHeaderView showSectionHeaderWithModel:model section:section expanded:_expandedSections[section]];
    if (section == 0) {
        sectionHeaderView.topSeperator.hidden = YES;
        sectionHeaderView.leftSeperatorTopMargin.constant = 28;
    }
    
    return sectionHeaderView;
}

- (UIView *)mTableView:(TQMultistageTableView *)tableView openCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    backView.backgroundColor = [UIColor clearColor];
    
    UIImageView * tmpView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 0, _mTableView.v_width - 60, HEIGHT)];
    tmpView.contentMode = UIViewContentModeScaleToFill;
    tmpView.image = [[UIImage imageNamed:@"ic_dev_logs_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 60, 10, 10) resizingMode:UIImageResizingModeStretch];
    [backView addSubview:tmpView];
    
    NSArray * tmp = [[_shakeArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    for (NSInteger i = 0; i < [tmp count]; i++) {
        G100DevLogsDomain * model = tmp[i];
        DevLogsOpenView * openView = [[DevLogsOpenView alloc]initWithFrame:CGRectMake(0, 5 + i * 32, tmpView.v_width, 32) time:[model.ts substringWithRange:NSMakeRange(11, 8)] title:model.title message:model.msg];
        
        if (i == [tmp count] - 1) {
            openView.seperatorLine.hidden = YES;
        }
        
        [tmpView addSubview:openView];
    }
    
    tmpView.v_height = 32 * [tmp count];
    backView.v_height = tmpView.v_height + 10;
    
    UIView * ser = [[UIView alloc]initWithFrame:CGRectMake(50, -10, 1, tmpView.v_height + 20)];
    ser.backgroundColor = [UIColor lightGrayColor];
    [backView addSubview:ser];
    
    // iPhone4上性能问题
    if (ISIPHONE_4) {
        UIView * serq = [[UIView alloc]initWithFrame:CGRectMake(50, -10, 1, tmpView.v_height + 20)];
        serq.backgroundColor = [UIColor lightGrayColor];
        
        UIView * bview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 200)];
        UIScrollView * openCellView = [[UIScrollView alloc]initWithFrame:CGRectMake(60, 0, WIDTH - 60, 200)];
        openCellView.bounces = NO;
        openCellView.delegate = self;
        openCellView.tag = 1000;
        openCellView.showsHorizontalScrollIndicator = NO;
        
        [openCellView addSubview:backView];
        
        tmpView.v_left = 0;
        
        backView.v_width = openCellView.v_width;
        [ser removeFromSuperview];
        
        if (backView.v_height < 200) {
            openCellView.v_height = backView.v_height;
        }
        
        bview.v_height = openCellView.v_height;
        
        openCellView.contentSize = backView.frame.size;
        [bview addSubview:openCellView];
        
        [bview addSubview:serq];
        
        return bview;
    }else {
        return backView;
    }
}

/*
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1000) {
        ScrollDirection scrollDirection;
        if (self.lastContentOffset > scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionDown;
        else if (self.lastContentOffset < scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionUp;
        else scrollDirection = ScrollDirectionNone;
        
        self.lastContentOffset = scrollView.contentOffset.x;
        
        // do whatever you need to with scrollDirection here.
        if (scrollView.contentOffset.y == 0 && scrollDirection == ScrollDirectionDown) {
            // 到顶了
            scrollView.scrollEnabled = NO;
        }else if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.v_height && scrollDirection == ScrollDirectionUp) {
            scrollView.scrollEnabled = NO;
        }else {
            scrollView.scrollEnabled = YES;
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (scrollView.tag == 1000) {
        [scrollView resignFirstResponder];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1000 && scrollView.contentOffset.y < 0) {
        CGPoint currentContentOffset = _mTableView.tableView.contentOffset;
        
        [_mTableView.tableView setContentOffset:CGPointMake(currentContentOffset.x,
                                                            currentContentOffset.y + scrollView.contentOffset.y)
                                      animated:YES];
    }
}
 */

-(void)mTableView:(TQMultistageTableView *)tableView didOpenCellAtIndexPath:(NSIndexPath *)indexPath {
    DevLogsCommonCell * tmpcell = (DevLogsCommonCell *)[tableView cellForRowAtIndexPath:indexPath];
    tmpcell.rightUpView.selected = YES;
}
-(void)mTableView:(TQMultistageTableView *)tableView didCloseCellAtIndexPath:(NSIndexPath *)indexPath {
    DevLogsCommonCell * tmpcell = (DevLogsCommonCell *)[tableView cellForRowAtIndexPath:indexPath];
    tmpcell.rightUpView.selected = NO;
}

-(void)mTableView:(TQMultistageTableView *)tableView didOpenHeaderAtIndexPath:(NSInteger)section {
    
}

-(void)mTableView:(TQMultistageTableView *)tableView didCloseHeaderAtIndexPath:(NSInteger)section {
    CGRect rect = [_mTableView.tableView rectForFooterInSection:section];
    rect.origin.y -= 70;
    
    CGFloat conffsetY = _mTableView.tableView.contentOffset.y;
    if (rect.origin.y < conffsetY) {
        // 滑出屏幕
        // 关闭某一组后   置顶
        _mTableView.tableView.contentOffset = rect.origin;
    }
}

- (void)mTableView:(TQMultistageTableView *)tableView didSelectHeaderAtSection:(NSInteger)section {
    NSArray * tmp = [_dataArray safe_objectAtIndex:section];
    if (tmp.count) {
        [self.mTableView openOrCloseHeaderWithSection:section];
    }else {
        [self getDevLogsFromServer:section showHUD:YES];
    }
}

#pragma mark - devHeaderViewDelegate
-(void)headerView:(DevLogsHeaderView *)headerView section:(NSInteger)section expanded:(BOOL)expanded {
    [self mTableView:self.mTableView didSelectHeaderAtSection:section];
    for (NSInteger i = 0; i < [_dataArray count]; i++) {
        DevLogsHeaderView * tmpView = (DevLogsHeaderView *)[self.mTableView tableView:self.mTableView.tableView viewForHeaderInSection:section];
        tmpView.selectButton.selected = NO;
        _expandedSections[i] = 0;
    }
    
    _expandedSections[section] = expanded;
    headerView.selectButton.selected = expanded;
    
    [self.mTableView.tableView reloadData];
    
    // 滚动到选中的组
    [self scrollToOpenSection];
}

#pragma mark - 滚动到展开的某一组
-(void)scrollToOpenSection {
    NSInteger index = [self theOpenSection];
    if (index >= 0) {
        NSInteger sectionCount = [_mTableView.tableView numberOfSections];
        NSInteger sectionRowCount = [_mTableView.tableView numberOfRowsInSection:index];
        if (sectionCount > 0 && sectionRowCount > index) {
            // 先判断该组行数是否大于0
            [_mTableView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}

-(NSInteger)theOpenSection {
    for (NSInteger i = 0; i < [_dataArray count]; i++) {
        // 确保选择的某行有数据
        NSArray * tmp = [_dataArray safe_objectAtIndex:i];
        if (_expandedSections[i] && tmp.count >= 1) {
            return i;
        }
    }
    
    return -1;
}

#pragma mark - Life Cycle
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NotificationHelper shareInstance] nh_newBadge:0];
    [[DatabaseOperation operation] countUnreadNumberWithUserid:[self.userid integerValue] success:^(NSInteger personalUnreadNum, NSInteger systemUnreadNum) {
        // 设置消息未读条数
        [[NotificationHelper shareInstance] nh_newBadge:personalUnreadNum+systemUnreadNum];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
