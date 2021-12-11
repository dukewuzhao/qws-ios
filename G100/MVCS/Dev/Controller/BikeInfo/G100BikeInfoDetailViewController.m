//
//  G100BikeInfoDetailViewController.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoDetailViewController.h"

#import "G100BikeInfoCardManager.h"
#import "G100BikeInfoCardModel.h"
#import "G100BikeDomain.h"
#import "G100DevApi.h"

#import "G10BikeInfoCardViewCell.h"
#import "G100ScrollView.h"

#import "G100BikeEditFeatureViewController.h"
#import "G100BikeInfoUserViewController.h"

#import "BikeQRCodeView.h"
#import "G100BikeInfoNavigationView.h"

#define kNavigationBarHeight (ISIPHONEX ? 88 : 64)

@interface G100BikeInfoDetailViewController () <UITableViewDelegate, UITableViewDataSource, G100ScrollViewDelegate, G100BikeInfoUserViewControllerDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) G100BikeInfoCardManager *cardManager;

@property (nonatomic, strong) G100ScrollView *headerView;

@property (nonatomic, strong) G100BikeInfoNavigationView *navigationView;

@property (nonatomic, strong) G100BikeInfoCardModel *bikeModel;

@property (nonatomic, strong) G100BikeDomain *bikeDomain;

@end

@implementation G100BikeInfoDetailViewController

- (void)dealloc {
    DLog(@"车辆资料页面已释放");
}

#pragma mark - Lazy Load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
        _tableView.contentOffset = CGPointMake(0, 0);
    }
    return _tableView;
}
- (G100ScrollView *)headerView{
    if (!_headerView) {
        _headerView = [G100ScrollView createScrollViewWithFrame:CGRectMake(0, 0, WIDTH, (WIDTH / 414.00)*160) imagesArr:nil];
        _headerView.delegate = self;
    }
    return _headerView;
}
- (G100BikeInfoNavigationView *)navigationView{
    if (!_navigationView) {
        _navigationView = [G100BikeInfoNavigationView loadXibView];
    }
    return _navigationView;
}

#pragma mark - Setter
- (void)setBikeDomain:(G100BikeDomain *)bikeDomain {
    _bikeDomain = bikeDomain;
    
    [self.navigationView setBikeDoamin:bikeDomain];
}

#pragma mark - 布局
- (void)setupView {
    self.navigationBarView.hidden = YES;
    
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(0);
    }];
    
    [self.view addSubview:self.navigationView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(0);
        make.height.equalTo(kNavigationBarHeight);
    }];
    
    __weak  typeof(self) weakSelf = self;

    self.navigationView.tapAction = ^(NSInteger index){
        if (index == 1) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [weakSelf qrBtnClicked];
        }
    };
}

- (void)setTableHeaderView {
    NSMutableArray *headerViewArr = [NSMutableArray array];
    NSString *image = nil;
    if ([self.bikeDomain isMOTOBike]) {
        image = @"icon_motor";
    }else{
        image = @"ic_bike_defaultnew";
    }
    
    [headerViewArr addObject:image];
    
    if (self.bikeDomain.feature.pictures.count == 0) {
        self.headerView.imageUrlArr = headerViewArr;
    }else {
        self.headerView.imageUrlArr = self.bikeDomain.feature.pictures;
    }
    
    self.tableView.tableHeaderView = self.headerView;
}
#pragma mark - 获取车辆特征信息
- (void)getBikeInfo {
    __weak G100BikeInfoDetailViewController * wself = self;
    if (kNetworkNotReachability) {
        return;
    }
    
    [[G100DevApi sharedInstance] getBikeFeatureWithBikeid:self.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [[G100InfoHelper shareInstance] updateMyBikeFeatureWithUserid:wself.userid bikeid:wself.bikeid feature:response.data];
            wself.bikeDomain =  [[G100InfoHelper shareInstance] findMyBikeWithUserid:wself.userid bikeid:wself.bikeid];
            wself.cardManager.bike = wself.bikeDomain;
            [wself setTableHeaderView];
            [wself.tableView reloadData];
        }
    }];
}

#pragma mark - 显示车辆二维码
- (void)qrBtnClicked{
    BikeQRCodeView *qrView = [BikeQRCodeView loadViewFromNibWithTitle:@"扫描车辆二维码绑定"
                                                               qrcode:[NSString stringWithFormat:@"%@", self.cardManager.bike.add_url]];
    [qrView showInVc:self view:self.view animation:YES];
}

#pragma mark - G100ScrollView delegate
- (void)selectedScrollViewAtIndex:(NSInteger)index OnScrollView:(G100ScrollView *)scrollView{
    G100BikeEditFeatureViewController *bikeFeatureEditVC = [[G100BikeEditFeatureViewController alloc]init];
    bikeFeatureEditVC.userid = self.userid;
    bikeFeatureEditVC.bikeid = self.bikeid;
    [self.navigationController pushViewController:bikeFeatureEditVC animated:YES];
}

#pragma mark - G100BikeInfoUserViewControllerDelegate
- (void)featchUserListFinished {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cardManager.dataArray safe_objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.cardManager numberOfRows];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100BikeInfoCardModel *cardModel = [[self.cardManager.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    G10BikeInfoCardViewCell *cardViewCell = (G10BikeInfoCardViewCell *)[tableView dequeueReusableCellWithIdentifier:cardModel.identifier];
    if (!cardViewCell) {
        cardViewCell = [[G10BikeInfoCardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cardModel.identifier];
    }
    if (!cardViewCell.cardVc) {
        UIViewController *baseCardVC = [self.cardManager cardViewWithItem:cardModel];
        cardViewCell.cardVc = baseCardVC;
    }
    if (cardViewCell.cardVc && ![cardViewCell.cardVc.view superview]) {
        [cardViewCell.containerView removeAllSubviews];
        [self addChildViewController:cardViewCell.cardVc toView:cardViewCell.containerView];
    }
    
    if ([cardViewCell.cardVc isKindOfClass:[G100BikeInfoUserViewController class]]) {
        G100BikeInfoUserViewController *card = (G100BikeInfoUserViewController *)cardViewCell.cardVc;
        card.delegate = self;
    }
    
    [cardViewCell.cardVc setValue:cardModel forKey:@"bikeInfoModel"];

    return cardViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    G100BikeInfoCardModel *cardModel = [[self.cardManager.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    return [self.cardManager heightForCardViewWithItem:cardModel width:WIDTH];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.01;
    }
    return 10;
}

#pragma mark - Private Method
- (void)addChildViewController:(UIViewController *)childController toView:(UIView *)view
{
    [self addChildViewController:childController];
    
    [view addSubview:childController.view];
    
    [childController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top);
        make.bottom.equalTo(view.mas_bottom);
        make.left.equalTo(view.mas_left);
        make.right.equalTo(view.mas_right);
    }];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    self.cardManager = [G100BikeInfoCardManager cardManagerWithUserid:self.userid bikeid:self.bikeid];
    self.cardManager.bike = self.bikeDomain;
    
    [self setupView];
    [self setTableHeaderView];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // iOS 11 UI 显示bug 修复
    if ([self.tableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.tableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    self.cardManager.bike = self.bikeDomain;
    
    [self getBikeInfo];
    [self setTableHeaderView];
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
