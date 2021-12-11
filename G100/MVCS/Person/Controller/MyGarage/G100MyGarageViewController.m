//
//  G100MyGarageViewController.m
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100MyGarageViewController.h"
#import "G100GarageBikeCell.h"

#import "G100Mediator+BikeDetail.h"
#import "G100Mediator+AddBike.h"

#import "EBKMovableCellTableView.h"

#import "G100BikeApi.h"

@interface G100MyGarageViewController () <UITableViewDelegate, UITableViewDataSource, EBKMovableCellTableViewDelegate, EBKMovableCellTableViewDataSource>

@property (nonatomic, strong) EBKMovableCellTableView *listView;

@property (nonatomic, strong) NSMutableArray *bikelist;

@property (nonatomic, strong) MJRefreshHeader *refreshHeader;

@property (nonatomic, strong) UIButton *addBikeBtn;

@end

@implementation G100MyGarageViewController

#pragma mark - Lazy Method
- (EBKMovableCellTableView *)listView {
    if (!_listView) {
        _listView = [[EBKMovableCellTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_listView registerNib:[UINib nibWithNibName:@"G100GarageBikeCell" bundle:nil] forCellReuseIdentifier:@"G100GarageBikeCell"];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
        
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
            _listView.separatorInset = UIEdgeInsetsZero;
        }

        if ([_listView respondsToSelector:@selector(setLayoutMargins:)]) {
            _listView.layoutMargins = UIEdgeInsetsZero;
        }
        
        _listView.gestureMinimumPressDuration = 1.0;
        _listView.drawMovalbeCellBlock = ^(UIView *movableCell){
            movableCell.layer.shadowColor = [UIColor grayColor].CGColor;
            movableCell.layer.masksToBounds = NO;
            movableCell.layer.cornerRadius = 0;
            movableCell.layer.shadowOffset = CGSizeMake(-5, 0);
            movableCell.layer.shadowOpacity = 0.4;
            movableCell.layer.shadowRadius = 5;
        };
    }
    return _listView;
}

- (NSMutableArray *)bikelist {
    if (!_bikelist) {
        _bikelist = [[NSMutableArray alloc] init];
    }
    return _bikelist;
}

- (MJRefreshHeader *)refreshHeader {
    if (!_refreshHeader) {
        __weak typeof(self) weakSelf = self;
        _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf beginRefreshData];
        }];
        _refreshHeader.lastUpdatedTimeKey = NSStringFromClass([self class]);
    }
    return _refreshHeader;
}

- (UIButton *)addBikeBtn {
    if (!_addBikeBtn) {
        _addBikeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    }
    
    return _addBikeBtn;
}

#pragma mark - 准备数据
- (void)setupData {
    [self.bikelist removeAllObjects];
    
    // 车库中包含所有状态的车辆
    NSArray *bikes = [[G100InfoHelper shareInstance] findMyAllBikeListWithUserid:self.userid];
    
    for (G100BikeDomain *bike in bikes) {
        NSArray *array = @[ bike ];
        [self.bikelist addObject:array];
    }
    
    [self.listView reloadData];
}

- (void)setupView {
    [self.contentView addSubview:self.listView];
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.listView.mj_header = self.refreshHeader;
    
    // 添加车辆入口
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 100)];
    
    [footerView addSubview:self.addBikeBtn];
    
    self.addBikeBtn.frame = CGRectMake((WIDTH - 240)/2.0, 20, 240, 40);
    [self.addBikeBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.addBikeBtn setTitle:@"新增车辆" forState:UIControlStateNormal];
    [self.addBikeBtn setBackgroundColor:[UIColor colorWithHexString:@"00B5B3"]];
    [self.addBikeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addBikeBtn addTarget:self action:@selector(addBike) forControlEvents:UIControlEventTouchUpInside];
    
    self.addBikeBtn.layer.cornerRadius = 7.0f;
    self.addBikeBtn.layer.masksToBounds = YES;
    
    self.listView.tableFooterView = footerView;
}

#pragma mark - 添加车辆
- (void)addBike {
    UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForAddBike:self.userid];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 刷新数据
- (void)beginRefreshData {
    __weak typeof(self) weakSelf = self;
    [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [self.refreshHeader endRefreshing];
        
        if (requestSuccess) {
            [weakSelf setupData];
        } else {
            [weakSelf showHint:response.errDesc];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 6.0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.bikelist.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.bikelist safe_objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100GarageBikeCell *bikeCell = [tableView dequeueReusableCellWithIdentifier:@"G100GarageBikeCell"];
    bikeCell.bike = [[self.bikelist safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    
    bikeCell.backgroundColor = [UIColor clearColor];
    
    return bikeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    G100BikeDomain *bike = [[_bikelist safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    
    if (![bike isNormalBike]) {
        return;
    }
    
    UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeDetail:self.userid
                                                                                                        bikeid:[NSString stringWithFormat:@"%@", @(bike.bike_id)]];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - EBKMovableCellTableViewDataSource
- (NSArray *)dataSourceArrayInTableView:(EBKMovableCellTableView *)tableView {
    return self.bikelist.copy;
}

- (void)tableView:(EBKMovableCellTableView *)tableView newDataSourceArrayAfterMove:(NSArray *)newDataSourceArray {
    self.bikelist = newDataSourceArray.mutableCopy;
    
    NSMutableArray *sortResult = [[NSMutableArray alloc] initWithCapacity:self.bikelist.count];
    // 更新数据库信息
    for (NSInteger i = 0; i < self.bikelist.count; i++) {
        G100BikeDomain *bike = [[self.bikelist safe_objectAtIndex:i] firstObject];
        
        /** 通过刷新车辆列表 确定排序结果
        [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeInfoWithUser_id:[self.userid integerValue]
                                                                      bike_id:bike.bike_id
                                                                      infokey:@"seq"
                                                                    infovalue:[NSNumber numberWithInteger:i]];
         */
        
        NSDictionary *sortParams = @{ @"bike_id" : [NSNumber numberWithInteger:bike.bike_id],
                                      @"bike_seq" : [NSNumber numberWithInteger:i] };
        [sortResult addObject:sortParams];
    }
    
    __weak typeof(self) weakSelf = self;
    [[G100BikeApi sharedInstance] updateBikeSeqWithUserid:self.userid bike_seq:sortResult.copy callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                // 更新列表顺序
                [weakSelf setupData];
            }];
        } else {
            // 更新列表顺序
            [weakSelf setupData];
            [weakSelf showHint:response.errDesc];
        }
    }];
}

- (void)tableView:(EBKMovableCellTableView *)tableView willMoveCellAtIndexPath:(NSIndexPath *)indexPath {
    self.addBikeBtn.hidden = YES;
}

- (void)tableView:(EBKMovableCellTableView *)tableView endMoveCellAtIndexPath:(NSIndexPath *)indexPath {
    self.addBikeBtn.hidden = NO;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    
    [self setupData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [weakSelf setupData];
        } else {
            [weakSelf showHint:response.errDesc];
        }
    }];
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:@"我的车库"];
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
