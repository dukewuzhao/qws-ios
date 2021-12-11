//
//  G100MainViewController.m
//  G100
//
//  Created by William on 16/6/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MainViewController.h"
#import "G100PageControl.h"
#import "G100MenuView.h"
#import "G100CarouselViewLayout.h"
#import "G100MainDetailViewController.h"
#import "G100RedDotButton.h"
#import "G100MenuPopView.h"
#import "G100BikeViewCell.h"

#import "G100Mediator+Login.h"
#import "G100Mediator+Register.h"
#import "G100Mediator+PersonProfile.h"
#import "G100Mediator+MsgCenter.h"
#import "G100Mediator+Insurance.h"
#import "G100Mediator+Order.h"
#import "G100Mediator+OfflineMap.h"
#import "G100Mediator+FeedBack.h"
#import "G100Mediator+Settings.h"
#import "G100Mediator+AddBike.h"
#import "G100Mediator+ScanCode.h"
#import "G100Mediator+CSBBatteryDetail.h"
#import "G100Mediator+SecuritySetting.h"
#import "G100Mediator+MyGarage.h"
#import "G100MallViewController.h"

#import "ThirdAccountViewController.h"
#import "G100WebViewController.h"

#import "G100CardViewCell.h"
#import "G100SampleMarking.h"
#import "G100MainNavigationView.h"
#import "G100PushAlarmTestView.h"
#import "G100WeatherGuideView.h"
#import "EventEntryView.h"
#import "G100NetworkHintView.h"

#import "G100PopBoxHelper.h"
#import "G100ABManager.h"
#import "G100UrlManager.h"
#import "G100Mediator+MapService.h"
#import "InsuranceCheckService.h"
#import "G100MenuViewHelper.h"
#import "G100BikeApi.h"
#import "NotificationHelper.h"
#import "G100ABHelper.h"
#import "MsgCenterHelper.h"

#define kNavigationBarHeight (ISIPHONEX ? 88 : 64)

@interface G100MainViewController () <G100MenuViewDelegate, G100PagerControlDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, G100MainDetailViewControllerDelegate, G100MenuPopViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate> {
    int _newPage; //!< 跳转目的页面
    int _transitionPage; //!< 跳转过程中页面
    int _currentPage; //!< 当前显示的页面
    int _lastPosition; //!< 记录容器最后的offset.x
    BOOL _bikeScrollViewScrolling; //!< 滚动过程中的判断值 YES 执行即将出现
}

@property (nonatomic, strong) G100MenuPopView * menuPopView;
@property (nonatomic, strong) G100MenuView * menuView;
@property (nonatomic, strong) G100PageControl * pagerView;
@property (nonatomic, strong) UICollectionView * cardBaseCollectionView;
@property (nonatomic, strong) NSArray * dropMenuOptions;
// 用来存放Cell的唯一标示符
@property (nonatomic, strong) NSMutableDictionary * cellIdentifierDict;
@property (nonatomic, strong) NSMutableArray * tableOffsetArr;

@property (nonatomic, strong) NSMutableArray *bikesArray;
@property (nonatomic, strong) NSMutableArray *indexPaths;

@property (nonatomic, strong) G100RedDotButton * leftButton;
@property (nonatomic, strong) G100RedDotButton * rightButton;
/** 按照索引储存详情页面*/
@property (nonatomic, strong) NSMutableArray * detailVcArray;

@property (nonatomic, strong) G100MainNavigationView *mainNavigationView;
@property (nonatomic, strong) G100ReactivePopingView *pushPopupBox;
@property (nonatomic, strong) G100WeatherGuideView *weatherGuideView;
@property (nonatomic, strong) EventEntryView *eventEntryView;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePan;
@property (nonatomic, strong) G100NetworkHintView *netview;

@property (nonatomic, strong) G100ReactivePopingView *dueBoxView;
@property (nonatomic, strong) G100ReactivePopingView *autoClosePhoneBoxView;
@property (nonatomic, strong) G100MenuViewHelper *menuViewHelper;
@property (strong, nonatomic) G100ReactivePopingView *popView;

@end

@implementation G100MainViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNShowNewMsgSignal object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNAppLoginOrLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperUserInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperBikeListDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperBikeInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperDeviceListDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CDDDataHelperDeviceInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}
    
#pragma mark - lazy loading
- (G100MainNavigationView *)mainNavigationView {
    if (!_mainNavigationView) {
        _mainNavigationView = [G100MainNavigationView loadXibView];
    }
    return _mainNavigationView;
}

- (EventEntryView *)eventEntryView {
    if (!_eventEntryView) {
        _eventEntryView = [[EventEntryView alloc] init];
        
        __weak typeof(self) wself = self;
        _eventEntryView.getEventDetailBlock = ^(G100EventDetailDomain *detailDomain){
            NSString *url = detailDomain.poster_url.length ? detailDomain.poster_url : detailDomain.page;
            if ([url hasPrefix:@"http"]) {
                G100WebViewController * webVc = [G100WebViewController loadNibWebViewController];
                webVc.httpUrl = url;
                [wself.navigationController pushViewController:webVc animated:YES];
                
                if ([UIApplication sharedApplication].statusBarHidden) {
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                }
            }else {
                if ([G100Router canOpenURL:url]) {
                    [G100Router openURL:url];
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }
            }
        };
    }
    return _eventEntryView;
}

- (UICollectionView *)cardBaseCollectionView {
    if (!_cardBaseCollectionView) {
        G100CarouselViewLayout * flowLayout = [[G100CarouselViewLayout alloc] init];
        _cardBaseCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                     collectionViewLayout:flowLayout];
        _cardBaseCollectionView.scrollsToTop = NO;
        _cardBaseCollectionView.pagingEnabled = YES;
        _cardBaseCollectionView.showsVerticalScrollIndicator = NO;
        _cardBaseCollectionView.showsHorizontalScrollIndicator = NO;
        _cardBaseCollectionView.delegate = self;
        _cardBaseCollectionView.dataSource = self;
        _cardBaseCollectionView.emptyDataSetDelegate = self;
        _cardBaseCollectionView.emptyDataSetSource = self;
        _cardBaseCollectionView.bounces = NO;
    }
    return _cardBaseCollectionView;
}
- (G100PageControl *)pagerView {
    if (!_pagerView) {
        _pagerView = [[G100PageControl alloc] initWithFrame:CGRectMake(42, 54, self.view.frame.size.width-84, 16)];
        _pagerView.page = 0;
        [_pagerView setImage:[UIImage imageNamed:@"ic_main_index"]
            highlightedImage:[UIImage imageNamed:@"ic_main_index_sel"]
                      forKey:@"1"];
        NSMutableString * pattern = @"".mutableCopy;
        for (NSInteger i = 0; i < [self numberOfRowsInCollectionView]; i++) {
            [pattern appendString:@"1"];
        }
        
        [self.pagerView setPattern:pattern];
        _pagerView.delegate = self;
    }
    return _pagerView;
}
- (NSArray *)dropMenuOptions {
    if (!_dropMenuOptions) {
        _dropMenuOptions = @[[[G100MenuPopModel alloc] initWithTitle:@"添加车辆" imageName:nil],
                             [[G100MenuPopModel alloc] initWithTitle:@"添加设备" imageName:nil],
                             [[G100MenuPopModel alloc] initWithTitle:@"扫一扫" imageName:nil]/*,
                             [[G100MenuPopModel alloc] initWithTitle:@"锂电池" imageName:nil]*/];
    }
    return _dropMenuOptions;
}

- (G100MenuPopView *)menuPopView {
    if (!_menuPopView) {
        _menuPopView = [[G100MenuPopView alloc]initWithDataArray:self.dropMenuOptions origin:CGPointMake(WIDTH-8, self.navigationBarView.v_bottom) width:100 height:44 direction:G100MenuPopViewDirectionRight];
        _menuPopView.delegate = self;
        _menuPopView.dismissOperation = ^(){
            _menuPopView = nil;
        };
    }
    return _menuPopView;
}

- (G100MenuView *)menuView {
    if (!_menuView) {
        _menuView = [[G100MenuView alloc] init];
        _menuView.delegate = self;
        __weak G100MainViewController * wself = self;
        _menuView.userActionTap = ^(NSInteger index){
            if (index == 0) {
                //跳转注册页面
                [[G100Mediator sharedInstance] G100Mediator_presentRegisterViewController:nil completion:^{
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }];
            }else if (index == 1){
                //跳转登录页面
                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }];
            }
        };
        _menuView.getEventDetailBlock = ^(G100EventDetailDomain *detailDomain){
            NSString *url = detailDomain.poster_url.length ? detailDomain.poster_url : detailDomain.page;
            if ([url hasPrefix:@"http"]) {
                G100WebViewController * webVc = [G100WebViewController loadNibWebViewController];
                webVc.httpUrl = url;
                [wself.navigationController pushViewController:webVc animated:YES];
                
                if ([UIApplication sharedApplication].statusBarHidden) {
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                }
            }else {
                if ([G100Router canOpenURL:url]) {
                    [G100Router openURL:url];
                    if ([UIApplication sharedApplication].statusBarHidden) {
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                    }
                }
            }
        };
        [self.view addSubview:_menuView];
    }
    return _menuView;
}

- (G100ReactivePopingView *)autoClosePhoneBoxView {
    if (!_autoClosePhoneBoxView) {
        _autoClosePhoneBoxView = [G100ReactivePopingView popingViewWithReactiveView];
        _autoClosePhoneBoxView.backgorundTouchEnable = false;
    }
    return _autoClosePhoneBoxView;
}

- (G100MenuViewHelper *)menuViewHelper {
    if (!_menuViewHelper) {
        _menuViewHelper = [[G100MenuViewHelper alloc] init];
        _menuViewHelper.menuView = self.menuView;
    }
    return _menuViewHelper;
}

- (NSMutableDictionary *)cellIdentifierDict {
    if (!_cellIdentifierDict) {
        _cellIdentifierDict = [[NSMutableDictionary alloc] init];
    }
    return _cellIdentifierDict;
}
- (NSMutableArray *)bikesArray {
    if (!_bikesArray) {
        _bikesArray = [[[G100InfoHelper shareInstance] findMyBikeListWithUserid:self.userid] mutableCopy];
    }
    return _bikesArray;
}
- (NSMutableArray *)indexPaths {
    if (!_indexPaths) {
        _indexPaths = [[NSMutableArray alloc] init];
    }
    return _indexPaths;
}
- (NSMutableArray *)detailVcArray {
    if (!_detailVcArray) {
        _detailVcArray = [[NSMutableArray alloc] init];
    }
    return _detailVcArray;
}
- (NSMutableArray *)tableOffsetArr {
    if (!_tableOffsetArr) {
        _tableOffsetArr = [[NSMutableArray alloc] init];
    }
    return _tableOffsetArr;
}

#pragma mark - init & setup
- (void)initialData {
    self.userid = [[G100InfoHelper shareInstance] buserid];
    _transitionPage = 0;
    _currentPage = 0;
    
    for (int i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        if ([self.tableOffsetArr safe_objectAtIndex:i]) {
            
        }else {
            [self.tableOffsetArr addObject:[NSNumber numberWithFloat:-kNavigationBarHeight]];
        }
    }
    
    NSMutableString * pattern = @"".mutableCopy;
    for (NSInteger i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        [pattern appendString:@"1"];
    }
    
    [self.pagerView setPattern:pattern];
    
    if ([self numberOfRowsInCollectionView] <= 1) {
        [self.pagerView setHidden:YES];
    }else {
        [self.pagerView setHidden:NO];
    }
    
    [self setupBikeList];
}
- (void)setupBikeList {
    if (IsLogin() == NO) {
        G100BikeDomain *bikeDomain = [[G100BikeDomain alloc] initWithDictionary:@{ @"user_id" : @(-9999),
                                                                                   @"bike_id" : @(-9999),
                                                                                   @"name" : @"我的爱车" }];
        self.bikesArray = [NSMutableArray arrayWithObject:bikeDomain];
    }else {
        self.bikesArray = [[[G100InfoHelper shareInstance] findMyBikeListWithUserid:self.userid] mutableCopy];
        if (!self.bikesArray.count) {
            G100BikeDomain *bikeDomain = [[G100BikeDomain alloc] initWithDictionary:@{ @"user_id" : @(-9999),
                                                                                       @"bike_id" : @(-9999),
                                                                                       @"name" : @"我的爱车" }];
            self.bikesArray = [NSMutableArray arrayWithObject:bikeDomain];
        }
    }
    
    NSMutableArray *bikesid = [NSMutableArray arrayWithCapacity:self.bikesArray.count];
    for (G100BikeDomain *bike in self.bikesArray) {
        [bikesid addObject:[NSString stringWithFormat:@"%@", @(bike.bike_id)]];
    }
    
    // 移除: 删除过的车辆详情VC 不然不能释放这个VC 和里面的请求
    for (G100MainDetailViewController *childController in self.detailVcArray) {
        BOOL exist = NO;
        for (NSString *bikeid in bikesid) {
            if ([bikeid isEqualToString:childController.bikeid]) {
                exist = YES;
                break;
            }
        }
        
        if ([childController.view superview] && !exist) {
            [childController beginAppearanceTransition:NO animated:YES];
            [childController.view removeFromSuperview];
            [childController endAppearanceTransition];
            [childController removeFromParentViewController];
        }
    }
    
    [self.cardBaseCollectionView reloadData];
}
- (void)setupView {
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_bg_nodev"]];
    [self.view insertSubview:backgroundImageView belowSubview:self.navigationBarView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.cardBaseCollectionView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.cardBaseCollectionView belowSubview:self.navigationBarView];
    [self.cardBaseCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    
    UIScreenEdgePanGestureRecognizer * edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(edgePanAction:)];
    edgePan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePan];
    
    self.edgePan = edgePan;
    [self.cardBaseCollectionView.panGestureRecognizer requireGestureRecognizerToFail:edgePan];
    
    [self handleNavigationTitleWithOffset:-kNavigationBarHeight page:_currentPage];
}

- (void)setupNavigationBarView {
    [self.navigationBarView setHidden:YES];
    
    [self.view addSubview:self.mainNavigationView];
    [self.mainNavigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.leading.and.trailing.equalTo(@0);
        make.height.equalTo(kNavigationBarHeight);
    }];
    
    self.leftButton = self.mainNavigationView.menuBtn;
    self.rightButton = self.mainNavigationView.addBtn;
    
    [self.leftButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(dropDownAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加pager
    [self.mainNavigationView.indexView addSubview:self.pagerView];
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void)edgePanAction:(UIScreenEdgePanGestureRecognizer *)recognizer {
    // 如果顶部有弹窗 则禁止呼出侧边栏
    if (self.popViewCount) {
        return;
    }
    [self.menuView configViewWithGesture:recognizer];
}

- (void)menuAction:(UIButton *)sender {
    self.popViewCount = 0;
    [self.menuView showMenuWithPanAction:NO];
}

- (void)dropDownAction:(UIButton *)sender {
    if (![UserAccount sharedInfo].appfunction.mybikes_add.enable && IsLogin()) {
        return;
    };
    [self.menuPopView pop];
}

#pragma mark - G100MenuPopViewDelegate
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // 添加车辆
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForAddBike:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (viewController && loginSuccess) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }];
    }else if (indexPath.row == 1) {
        // 扫码GPS
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForScanCode:self.userid bindMode:1 operation:0 loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (viewController && loginSuccess) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }];
    }else if (indexPath.row == 2) {
        // 扫一扫
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForScanCode:self.userid bindMode:3 operation:2 loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (viewController && loginSuccess) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }];
    }else if (indexPath.row == 3) {
        // 锂电池项目入口 测试入口
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForCSBBatteryDetail:self.userid bikeid:self.bikeid batteryid:@"1" loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (viewController && loginSuccess) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }];
    }
}
#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"请点击右上角的“”图标";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#FFFFFF"]};
    NSMutableAttributedString *title1 = [[NSMutableAttributedString alloc]initWithString:text attributes:attributes];
    NSMutableAttributedString *addStr = [[NSMutableAttributedString alloc] initWithString:@"+" attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:24.0f],NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#FFFFFF"]}];
    [title1 insertAttributedString:addStr atIndex:8];
    return title1;
}

-(NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"添加车辆或设备";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#FFFFFF"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor clearColor];
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return ![self.bikesArray count];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfRowsInCollectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.indexPaths containsObject:indexPath]) {
        [self.indexPaths addObject:indexPath];
    }
    
    G100BikeDomain *bike = [self.bikesArray safe_objectAtIndex:indexPath.row];
    NSString *commonKey = [NSString stringWithFormat:@"%@-%@", self.userid, @(bike.bike_id)];
    NSString *identifier = [self.cellIdentifierDict objectForKey:commonKey];
    if (identifier == nil) {
        identifier = commonKey;
        [self.cellIdentifierDict setValue:identifier forKey:commonKey];
        [self.cardBaseCollectionView registerClass:[G100BikeViewCell class] forCellWithReuseIdentifier:identifier];
    }
    
    G100BikeViewCell *viewCell = (G100BikeViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!viewCell.bikeVc) {
        G100MainDetailViewController *mainDetail = [[G100MainDetailViewController alloc] init];
        viewCell.bikeVc = mainDetail;
    }
    
    G100MainDetailViewController *mainDetail = (G100MainDetailViewController *)viewCell.bikeVc;
    mainDetail.userid = self.userid;
    mainDetail.bikeid = [NSString stringWithFormat:@"%@", @(bike.bike_id)];
    mainDetail.delegate = self;
    mainDetail.bike = bike;
    
    if (mainDetail && ![mainDetail.view superview]) {
        [self addChildViewController:mainDetail toView:viewCell.contentView];
        // 保存到数组中
        if ([self.detailVcArray safe_objectAtIndex:indexPath.row]) {
            [self.detailVcArray replaceObjectAtIndex:indexPath.row withObject:mainDetail];
        }else {
            [self.detailVcArray addObject:mainDetail];
        }
    }
    
    return viewCell;
}

#pragma mark - G100MainDetailViewControllerDelegate
- (void)mainDetailViewDidScroll:(UIScrollView *)scrollView {
    self.tableOffsetArr[self.pagerView.page] = [NSString stringWithFormat:@"%@",@(scrollView.contentOffset.y)];
    [self handleNavigationTitleWithOffset:scrollView.contentOffset.y page:self.pagerView.page];
}

- (void)mainDetailViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.eventEntryView hide:YES animated:YES];
}

- (void)mainDetailViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.eventEntryView hide:NO animated:YES];
}

- (void)mainDetailViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self.eventEntryView hide:NO animated:YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.cardBaseCollectionView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePageView) object:self.pagerView];
        // 调整pageControl
        CGPoint contenOffset = self.cardBaseCollectionView.contentOffset;
        NSInteger newPage = contenOffset.x/self.view.frame.size.width;
        if (newPage != self.pagerView.page) {
            CGFloat offsetY = [self.tableOffsetArr[newPage] integerValue];
            [self handleNavigationTitleWithOffset:offsetY page:newPage];
        }
        [self.pagerView setPage:newPage];
        
        // 2秒后隐藏 page
        [self performSelector:@selector(hidePageView) withObject:self.pagerView afterDelay:2.0];
        
        for (NSInteger i = 0; i < [self.detailVcArray count]; i++) {
            G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:i];
            if (i == newPage) {
                [vc setScrollsToTop:YES];
                
                [vc mdv_viewDidAppear:YES];
            }else {
                [vc setScrollsToTop:NO];
                
                if (i == _currentPage) {
                    [vc mdv_viewDidDisappear:YES];
                }
            }
        }
        
        _bikeScrollViewScrolling = NO;
        _transitionPage = (int)newPage;
        _currentPage = (int)newPage;
        _newPage = -1;
        
        G100BikeDomain *bike = [self.bikesArray safe_objectAtIndex:_currentPage];
        [self.mainNavigationView setBikeDoamin:bike];
    }
}
- (void)hidePageView {
    //[self.pagerView dismissWithDuration:1.0 animation:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    /** 注意
     *  此处需要检测用户停止拖拽的时候 又开始新的拖拽
     *  将这个值设为NO DidScroll中会检测并刷新
     */
    if (scrollView == self.cardBaseCollectionView) {
        if (decelerate) {
            _bikeScrollViewScrolling = NO;
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.cardBaseCollectionView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePageView) object:self.pagerView];
        [self.pagerView appearWithDuration:0 animation:NO];
        
        // 调整pageControl
        CGPoint contenOffset = self.cardBaseCollectionView.contentOffset;
        NSInteger newPage = (contenOffset.x)/self.view.frame.size.width;
        
        int currentPostion = scrollView.contentOffset.x;
        if (currentPostion - _lastPosition > 25) {
            _lastPosition = currentPostion;
            newPage++;
            
            newPage = _newPage == -1 ? newPage : _newPage;
            
            if (((int)contenOffset.x)%((int)self.view.frame.size.width) > self.view.frame.size.width/2.0) {
                if (!_bikeScrollViewScrolling) {
                    int index = -1;
                    for (NSInteger i = 0; i < [self.detailVcArray count]; i++) {
                        G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:i];
                        if (i == newPage) {
                            [vc mdv_viewWillAppear:YES];
                            index = (int)newPage;
                        }else {
                            if (i == _transitionPage) {
                                [vc mdv_viewWillDisappear:YES];
                            }
                        }
                    }
                    
                    _transitionPage = (index == -1 ? _transitionPage : index);
                    _bikeScrollViewScrolling = YES;
                }
            }
        } else if (_lastPosition - currentPostion > 25) {
            _lastPosition = currentPostion;
            
            newPage = _newPage == -1 ? newPage : _newPage;
            
            if (((int)contenOffset.x)%((int)self.view.frame.size.width) > self.view.frame.size.width/2.0) {
                if (!_bikeScrollViewScrolling) {
                    int index = -1;
                    for (NSInteger i = 0; i < [self.detailVcArray count]; i++) {
                        G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:i];
                        if (i == newPage) {
                            [vc mdv_viewWillAppear:YES];
                            index = (int)newPage;
                        }else {
                            if (i == _transitionPage) {
                                [vc mdv_viewWillDisappear:YES];
                            }
                        }
                    }
                    
                    _transitionPage = (index == -1 ? _transitionPage : index);
                    _bikeScrollViewScrolling = YES;
                }
            }
        }
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.cardBaseCollectionView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePageView) object:self.pagerView];
        // 调整pageControl
        CGPoint contenOffset = self.cardBaseCollectionView.contentOffset;
        NSInteger newPage = contenOffset.x/self.view.frame.size.width;
        [self.pagerView setPage:newPage];
        
        // 2秒后隐藏 page
        [self performSelector:@selector(hidePageView) withObject:self.pagerView afterDelay:2.0];
        
        for (NSInteger i = 0; i < [self.detailVcArray count]; i++) {
            G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:i];
            if (i == newPage) {
                [vc setScrollsToTop:YES];
                
                [vc mdv_viewDidAppear:YES];
            }else {
                [vc setScrollsToTop:NO];
                
                if (i == _currentPage) {
                    [vc mdv_viewDidDisappear:YES];
                }
            }
        }
        
        _bikeScrollViewScrolling = NO;
        _transitionPage = (int)newPage;
        _currentPage = (int)newPage;
        _newPage = -1;
    }
}

#pragma mark - G100PagerControlDelegate
- (BOOL)pageView:(G100PageControl *)pageView shouldUpdateToPage:(NSInteger)newPage {
    return YES;
}
- (void)pageView:(G100PageControl *)pageView didUpdateToPage:(NSInteger)newPage {
    _newPage = (int)newPage;
    
    G100BikeDomain *bike = [self.bikesArray safe_objectAtIndex:_newPage];
    [self.mainNavigationView setBikeDoamin:bike];
    
    CGFloat contenOffsetX = newPage*self.view.frame.size.width;
    [self.cardBaseCollectionView setContentOffset:CGPointMake(contenOffsetX, 0) animated:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePageView) object:self.pagerView];
    // 2秒后隐藏 page
    [self performSelector:@selector(hidePageView) withObject:self.pagerView afterDelay:2.0];
    
    CGFloat offsetY = [[self.tableOffsetArr safe_objectAtIndex:newPage] floatValue];
    [self handleNavigationTitleWithOffset:offsetY page:newPage];
    
    for (NSInteger i = 0; i < [self.detailVcArray count]; i++) {
        G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:i];
        if (i == newPage) {
            [vc setScrollsToTop:YES];
        }else {
            [vc setScrollsToTop:NO];
        }
    }
}
- (void)pageViewDidTapped:(G100PageControl *)pageView {
    // 先取消旧的隐藏事件
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePageView) object:self.pagerView];
    // 2秒后隐藏 page
    [self performSelector:@selector(hidePageView) withObject:self.pagerView afterDelay:2.0];
}

#pragma mark - G100MenuViewDelegate
- (void)menuView:(G100MenuView *)menuView didSelectRowAtIndexPath:(NSIndexPath *)indexPath menuItem:(MenuItem *)menuItem{
    //[menuView hideMenuWithPanAction:NO];
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    
    if (indexPath.row == 1000) {
        if (![UserAccount sharedInfo].appfunction.profile.enable && IsLogin()) {
            return;
        };
        [[G100Mediator sharedInstance] G100Mediator_viewControllerForPersonProfile:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
            if (loginSuccess && viewController) {
                [self.navigationController pushViewController:viewController animated:YES];
                if ([UIApplication sharedApplication].statusBarHidden) {
                    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                }
            }
        }];
    }else if (indexPath.row == 2000) {
        UIViewController * viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForSettings:self.userid];
        [self.navigationController pushViewController:viewController animated:YES];
    }else {
        menuItem.selectedCallback();
    }
}

- (void)addChildViewController:(UIViewController *)childController toView:(UIView *)view
{
    [self addChildViewController:childController];
    
    //add this
    //[childController beginAppearanceTransition:YES animated:YES];
    [view addSubview:childController.view];
    //[childController endAppearanceTransition];
    
    //[childController didMoveToParentViewController:self];
    
    [childController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top);
        make.bottom.equalTo(view.mas_bottom);
        make.left.equalTo(view.mas_left);
        make.right.equalTo(view.mas_right);
    }];
}

//- (void)removeChildViewController:(UIViewController *)childController
//{
//    [childController beginAppearanceTransition:NO animated:YES];
//    [childController.view removeFromSuperview];
//    [childController endAppearanceTransition];
//    [childController removeFromParentViewController];
//}

#pragma mark - 通知监听
- (void)setupNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNewMsgNotice)
                                                 name:kGNShowNewMsgSignal
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginOrlogoutNotification:)
                                                 name:kGNAppLoginOrLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_userinfoDidChange:)
                                                 name:CDDDataHelperUserInfoDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_bikeListDidChange:)
                                                 name:CDDDataHelperBikeListDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_bikeInfoDidChange:)
                                                 name:CDDDataHelperBikeInfoDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_deviceListDidChange:)
                                                 name:CDDDataHelperDeviceListDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_deviceInfoDidChange:)
                                                 name:CDDDataHelperDeviceInfoDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(securityViewControllerBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(monitorCurrentNetworkStatus:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    
    // 监听未读消息变化
    [self.KVOController observe:[MsgCenterHelper sharedInstace]
                        keyPath:@"unReadMsgCount"
                        options:NSKeyValueObservingOptionNew
                          block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        self.leftButton.hasRedDot = [MsgCenterHelper sharedInstace].unReadMsgCount ? YES : NO;
    }];
}

#pragma mark - private method
- (void)handleNavigationTitleWithOffset:(CGFloat)y page:(NSInteger)page {
    G100BikeDomain *bike = [self.bikesArray safe_objectAtIndex:page];
    
    [self.mainNavigationView setBikeDoamin:bike];
    [self.mainNavigationView setNavigationTitle:[NSString stringWithFormat:@"%@", bike.name ? : @"您还未绑定车辆"]];
    
    self.bikeid = [NSString stringWithFormat:@"%@", @(bike.bike_id)];
    // self.devid = [NSString stringWithFormat:@"%@". @([bike mainDevice].device_id)];
    if (y< 100 && y> -kNavigationBarHeight) {
        //self.mainNavigationView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5];
    }else{
        self.mainNavigationView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0];
    }
    
    /*
    if (y > -36) {
        G100BikeDomain *bike = [self.bikesArray safe_objectAtIndex:page];
        [self.mainNavigationView setNavigationTitle:[NSString stringWithFormat:@"%@", bike.name ? : @"添加车辆"]];
        if (y < 0) {
            [self.mainNavigationView setNavigationTitleAlpha:1.0 * (1 - y/-36)];
        }else{
            [self.mainNavigationView setNavigationTitleAlpha:1.0f];
        }
    }else{
        if (self.bikesArray.count) {
            [self.mainNavigationView setNavigationTitle:[NSString stringWithFormat:@"您已绑定了%@辆车", @(self.bikesArray.count)]];
        }else {
            [self.mainNavigationView setNavigationTitle:@"您还未绑定车辆"];
        }
        
        if (y > -kNavigationBarHeight) {
            [self.mainNavigationView setNavigationTitleAlpha:1.0 * (y/-kNavigationBarHeight)];
        }else{
            [self.mainNavigationView setNavigationTitleAlpha:1.0f];
        }
    }
     */
}

- (NSInteger)numberOfRowsInCollectionView {
   // return [self.bikesArray count] < 5 ? [self.bikesArray count]+1 : [self.bikesArray count];
    return [self.bikesArray count];
}

#pragma mark - 监听通知的操作
- (void)showNewMsgNotice {
    [[MsgCenterHelper sharedInstace] loadUnReadMsgStatusWithUserid:self.userid success:nil];
}

- (void)noti_userinfoDidChange:(NSNotification *)notification {
    NSString *userid = [[G100InfoHelper shareInstance] buserid];
    self.userid = userid;
    self.menuView.userid = userid;
    [self setUpMenuViewData];
}

- (void)noti_bikeListDidChange:(NSNotification *)notification {
    if ([notification.userInfo[@"user_id"] integerValue] != [self.userid integerValue]) {
        return;
    }
    
    [self updateBikeListlayout:[notification.userInfo[@"bike_update_type"] integerValue]];
    
    G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:_currentPage];
    [vc featchMainData];
}

- (void)updateBikeListlayout:(NSInteger)updateType {
    [self setupBikeList];
    
    for (int i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        if ([self.tableOffsetArr safe_objectAtIndex:i]) {
            
        }else {
            [self.tableOffsetArr addObject:[NSNumber numberWithFloat:-kNavigationBarHeight]];
        }
    }
    
    NSMutableString * pattern = @"".mutableCopy;
    for (NSInteger i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        [pattern appendString:@"1"];
    }
    
    [self.pagerView setPattern:pattern];
    if (self.bikesArray.count && updateType == BikeListAddType) {
        _currentPage = (int)self.bikesArray.count -1;
    }else if (self.bikesArray.count && _currentPage == self.bikesArray.count) {
        _currentPage = (int)self.bikesArray.count -1;
    }
    [self.pagerView setPage:_currentPage];
    
    if ([self numberOfRowsInCollectionView] <= 1) {
        [self.pagerView setHidden:YES];
    }else {
        [self.pagerView setHidden:NO];
    }
    
    CGFloat offset = [self.tableOffsetArr safe_objectAtIndex:_currentPage] ? [[self.tableOffsetArr safe_objectAtIndex:_currentPage] floatValue ]: -kNavigationBarHeight;
    [self handleNavigationTitleWithOffset:offset page:_currentPage];
    [self pageView:self.pagerView didUpdateToPage:_currentPage];
}

- (void)noti_bikeInfoDidChange:(NSNotification *)notification {
    [self setupBikeList];
    if ([notification.userInfo[@"user_id"] integerValue] != [self.userid integerValue]) {
        return;
    }
    
    BikeInfoUpdateType updateType = [notification.userInfo[@"bike_update_type"] integerValue];
    // 如果是添加车辆的消息 则自动切换到刚添加成功的这辆车
    if (updateType == BikeInfoAddType) {
        NSInteger update_bikeid = [notification.userInfo[@"bike_id"] integerValue];
        for (int i = 0; i< self.bikesArray.count; i++) {
            G100BikeDomain *bikeDomain = [self.bikesArray safe_objectAtIndex:i];
            if (bikeDomain.bike_id == update_bikeid) {
                _currentPage = i;
                break;
            }
        }
    }
    
    for (int i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        if ([self.tableOffsetArr safe_objectAtIndex:i]) {
            
        }else {
            [self.tableOffsetArr addObject:[NSNumber numberWithFloat:-kNavigationBarHeight]];
        }
    }
    
    NSMutableString * pattern = @"".mutableCopy;
    for (NSInteger i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        [pattern appendString:@"1"];
    }
    
    [self.pagerView setPattern:pattern];
    [self.pagerView setPage:_currentPage];
    
    if ([self numberOfRowsInCollectionView] <= 1) {
        [self.pagerView setHidden:YES];
    }else {
        [self.pagerView setHidden:NO];
    }
    CGFloat offset = [self.tableOffsetArr safe_objectAtIndex:_currentPage] ? [[self.tableOffsetArr safe_objectAtIndex:_currentPage] floatValue ]: -kNavigationBarHeight;
    [self handleNavigationTitleWithOffset:offset page:_currentPage];
    [self pageView:self.pagerView didUpdateToPage:_currentPage];
}

- (void)noti_deviceListDidChange:(NSNotification *)notification {
    [self setupBikeList];
}

- (void)noti_deviceInfoDidChange:(NSNotification *)notification {
    [self setupBikeList];
}

#pragma mark - 用户登录注销监听
- (void)loginOrlogoutNotification:(NSNotification *)notification {
    BOOL result = [notification.object boolValue];
    
    if (result && IsLogin()) {
        NSString *userid = [[G100InfoHelper shareInstance] buserid];
        self.userid = userid;
        self.menuView.userid = userid;
        [self updateEventWithUserid:userid];
        
        [self setupBikeList];
        
        [self.menuView hideMenuWithPanAction:NO];
        
        _transitionPage = 0;
        _currentPage = 0;
        
        for (int i = 0; i < [self numberOfRowsInCollectionView]; i++) {
            if ([self.tableOffsetArr safe_objectAtIndex:i]) {
                [self.tableOffsetArr replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:-kNavigationBarHeight]];
            }else {
                [self.tableOffsetArr addObject:[NSNumber numberWithFloat:-kNavigationBarHeight]];
            }
        }
        
        NSMutableString * pattern = @"".mutableCopy;
        for (NSInteger i = 0; i < [self numberOfRowsInCollectionView]; i++) {
            [pattern appendString:@"1"];
        }
        
        [self.pagerView setPattern:pattern];
        [self.pagerView setPage:0];
        
        if ([self numberOfRowsInCollectionView] <= 1) {
            [self.pagerView setHidden:YES];
        }else {
            [self.pagerView setHidden:NO];
        }
        
        // 查询通讯录是否有更新
        [[G100ABManager sharedInstance] ab_checkUpdate:^(BOOL update, id res, NSError *error) {
            DLog(@"%@", error.userInfo);
            [self handle_AutoClosePhoneAlarm:error];
        }];
    }else {
        [self refreshLogoutMainVC];
    }
    
    // 退出登录后 删除水印图案
    if ([[[UserAccount sharedInfo] appwatermarking] type]) {
        [[G100SampleMarking shareInstance] removeSampleMarkingView];
    }
    
    for (NSInteger i = 0; i < [self.detailVcArray count]; i++) {
        G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:i];
        [vc setContentOffset:CGPointMake(0, -kNavigationBarHeight)];
    }
    [self.detailVcArray removeAllObjects];
    [self handleNavigationTitleWithOffset:-kNavigationBarHeight page:0];
    [self.cardBaseCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // 移除所有推送的报警框
    [[G100PopBoxHelper sharedInstance] removeAllPopView];
}

- (void)refreshLogoutMainVC{
    // 首先从父控制器中 移除详情控制器
    for (NSInteger i = 0; i < [self.detailVcArray count]; i++) {
        G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:i];
        
        for (NSInteger i = 0; i < [vc.cardManager.cardViewControllersArray count]; i++) {
            UIViewController *viewController = [vc.cardManager.cardViewControllersArray safe_objectAtIndex:i];
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
            viewController = nil;
        }
        
        for (NSInteger i = 0; i < vc.indexPaths.count; i++) {
            NSIndexPath *indexPath = [vc.indexPaths safe_objectAtIndex:i];
            G100CardViewCell *bikeCell = [vc.cardTableView cellForRowAtIndexPath:indexPath];
            bikeCell.cardVc = nil;
        }
        
        [vc.cardManager removeAllCardViewController];
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        vc = nil;
    }
    
    for (NSIndexPath *indexPath in self.indexPaths) {
        G100BikeViewCell *bikeCell = (G100BikeViewCell *)[self.cardBaseCollectionView cellForItemAtIndexPath:indexPath];
        bikeCell.bikeVc = nil;
    }
    
    self.userid = nil;
    self.menuView.userid = nil;
    self.menuView.eventDomain = nil;
    
    [self setupBikeList];
    
    [self.menuView hideMenuWithPanAction:NO];
    
    _transitionPage = 0;
    _currentPage = 0;
    
    for (int i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        if ([self.tableOffsetArr safe_objectAtIndex:i]) {
            [self.tableOffsetArr replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:-kNavigationBarHeight]];
        }else {
            [self.tableOffsetArr addObject:[NSNumber numberWithFloat:-kNavigationBarHeight]];
        }
    }
    
    NSMutableString * pattern = @"".mutableCopy;
    for (NSInteger i = 0; i < [self numberOfRowsInCollectionView]; i++) {
        [pattern appendString:@"1"];
    }
    
    [self.pagerView setPattern:pattern];
    [self.pagerView setPage:0];
    
    if ([self numberOfRowsInCollectionView] <= 1) {
        [self.pagerView setHidden:YES];
    }else {
        [self.pagerView setHidden:NO];
    }
}

#pragma mark - 程序到前台的处理
- (void)securityViewControllerBecomeActive {
    if (!self.hasAppear) {
        return;
    }
    
    [self updateMainContinueEvent];
}

#pragma mark - 提醒用户开通微信推送消息
- (void)remindUserOpenWxpushMsgWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    if (!IsLogin() || !userid.length || !bikeid.length || !devid.length) {
        return;
    }
    // 首先判断是否绑定微信
    __weak typeof(self) wself = self;
    [[G100UserApi sharedInstance] sv_checkWxmpWithCallback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            // 跳转到安防设置
            G100NewPromptDefaultBox *box = [G100NewPromptDefaultBox promptAlertViewWithDefaultStyle];
            [box showPromptBoxWithTitle:@"您已成功绑定设备" content:@"您还可以设置\n通过微信等接收报警通知" confirmButtonTitle:@"去设置" cancelButtonTitle:@"忽略" event:^(NSInteger index) {
                if (index == 0) {
                    // 去绑定微信
                    UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForSecuritySetting:userid
                                                                                                                             bikeid:bikeid
                                                                                                                              devid:devid];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                [box dismissWithVc:wself animation:YES];
                
            } onViewController:wself onBaseView:wself.view];
        }else if (response.errCode == SERV_RESP_ERROR_NOBIND_WX) {
            // 没有绑定微信
            G100NewPromptDefaultBox *box = [G100NewPromptDefaultBox promptAlertViewWithDefaultStyle];
            [box showPromptBoxWithTitle:@"您已成功绑定设备" content:@"您还可以通过绑定微信\n开通微信报警服务" confirmButtonTitle:@"去开通" cancelButtonTitle:@"忽略" event:^(NSInteger index) {
                if (index == 0) {
                    // 去绑定微信
                    ThirdAccountViewController *funVC = [[ThirdAccountViewController alloc] init];
                    funVC.userid = userid;
                    funVC.bikeid = bikeid;
                    funVC.devid = devid;
                    [self.navigationController pushViewController:funVC animated:YES];
                }
                [box dismissWithVc:wself animation:YES];
                
            } onViewController:wself onBaseView:wself.view];
        }
    }];
}

/**
 更新活动信息
 
 @param userid 用户id
 @param bikeid 车辆id
 */
- (void)updateEventWithUserid:(NSString *)userid {
    if (!IsLogin() || !userid.length) {
        if ([self.eventEntryView superview]) {
            [self.eventEntryView removeFromSuperview];
        }
        return;
    }
    __weak __typeof__(self) wself = self;
    API_CALLBACK calllback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            G100EventDomain *eventDomain = [[G100EventDomain alloc] initWithDictionary:response.data];
            //[wself.menuView setEventDomain:eventDomain];
            [wself.eventEntryView showEventEntryViewWithEvent:eventDomain onBaseView:self.view animated:NO];
            [wself.view insertSubview:wself.eventEntryView aboveSubview:self.cardBaseCollectionView];
        }else {
            
        }
    };
    
    [[G100UserApi sharedInstance] checkCurrentEventWithCallback:calllback];
}
#pragma mark - 监测网络变化
-(void)monitorCurrentNetworkStatus:(NSNotification *)notification {
    AFNetworkReachabilityStatus status = [[notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if ([self.netview superview]) {
        [self.netview removeFromSuperview];
    }
    
    if (status == AFNetworkReachabilityStatusNotReachable) {
        self.netview = [[G100NetworkHintView alloc] initWithFrame:CGRectMake(0, 0, WIDTH ,25)
                                                            title:@"网络无法链接请检查您的网络。"
                                                            color:[UIColor redColor]];
        [self.view insertSubview:self.netview belowSubview:self.menuView];
        [self.netview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@25);
            make.top.equalTo(@kNavigationBarHeight);
        }];

        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    } else {
        if (IsLogin()) {
            [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:nil];
            [self updateEventWithUserid:self.userid];
        }
        
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - 检查车辆设备是否存在过期
- (void)checkServiceDue {
    if (!IsLogin()) {
        return;
    }
    
    if (!self.bikesArray.count) {
        return;
    }
    
    for (NSInteger i = 0; i < self.bikesArray.count; i++) {
        G100BikeDomain *bike = self.bikesArray[i];
        NSString *bikeid = [NSString stringWithFormat:@"%@", @(bike.bike_id)];
        NSArray *allDevsArr = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:bikeid];
        
        BOOL hasDue = NO;
        for (G100DeviceDomain *deviceDomain in allDevsArr) {
            // 检查是否存在即将过期设备
            if (!deviceDomain.isSpecialChinaMobileDevice) {
                NSString *userid = self.userid;
                NSString *leftKey = [NSString stringWithFormat:@"due-%@_%@_%@", userid, bikeid, @(deviceDomain.device_id)];
                NSString *devid = [NSString stringWithFormat:@"%@", @(deviceDomain.device_id)];
                NSInteger leftdays = deviceDomain.leftdays;
                if ((leftdays <= 30 && leftdays > 20 && !deviceDomain.left30remainder) ||
                    (leftdays <= 20 && leftdays > 15 && !deviceDomain.left20remainder) ||
                    (leftdays <= 15 && leftdays > 10 && !deviceDomain.left15remainder) ||
                    (leftdays <= 10 && leftdays > 7 && !deviceDomain.left10remainder) ||
                    (leftdays <= 7 && [[G100InfoHelper shareInstance].statusMap[leftKey] boolValue] == NO)) {
                    hasDue = YES;
                }
                
                if (leftdays > 30) {
                    [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left30remainder" : @(NO)}];
                    [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left20remainder" : @(NO)}];
                    [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left15remainder" : @(NO)}];
                    [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left10remainder" : @(NO)}];
                    [G100InfoHelper shareInstance].statusMap[leftKey] = @(NO);
                }
            }
        }
        
        if (hasDue) {
            [self checkServiceDueWithUserid:self.userid bikeid:bikeid index:i];
            break;
        }
    }
}

- (void)checkServiceDueWithUserid:(NSString *)userid bikeid:(NSString *)bikeid index:(NSInteger)targetIndex {
    if (!IsLogin()) {
        return;
    }
    
    G100BikeDomain *bike = [[G100InfoHelper shareInstance] findMyBikeWithUserid:userid bikeid:bikeid];
    NSArray *allDevsArr = [[G100InfoHelper shareInstance] findMyDevListWithUserid:userid bikeid:bikeid];
    if (allDevsArr.count == 0) {
        return;
    }
    
    if ([self.dueBoxView superview]) {
        return;
    }
    
    NSMutableArray *tempDevServiceArr = [NSMutableArray array];
    for (G100DeviceDomain *deviceDomain in allDevsArr) {
        if (deviceDomain.service.left_days <= 30 && !deviceDomain.isSpecialChinaMobileDevice) {
            G100DeviceDomain *tempDomain = [[G100DeviceDomain alloc] init];
            tempDomain = deviceDomain;
            [tempDevServiceArr addObject:tempDomain];
        }
    }
    
    if (tempDevServiceArr.count) {
        [tempDevServiceArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[NSNumber numberWithInteger:[obj1 leftdays]] compare:[NSNumber numberWithInteger:[obj2 leftdays]]];
        }];
    }
    
    G100DeviceDomain *domain = nil;
    for (G100DeviceDomain *deviceDomain in tempDevServiceArr) {
        NSString *leftKey = [NSString stringWithFormat:@"due-%@_%@_%@", userid, bikeid, @(deviceDomain.device_id)];
        NSInteger leftdays = deviceDomain.leftdays;
        if ((leftdays <= 30 && leftdays > 20 && !deviceDomain.left30remainder) ||
            (leftdays <= 20 && leftdays > 15 && !deviceDomain.left20remainder) ||
            (leftdays <= 15 && leftdays > 10 && !deviceDomain.left15remainder) ||
            (leftdays <= 10 && leftdays > 7 && !deviceDomain.left10remainder) ||
            (leftdays <= 7 && [[G100InfoHelper shareInstance].statusMap[leftKey] boolValue] == NO)) {
            domain = deviceDomain;
        }
    }
    
    NSString *devid = [NSString stringWithFormat:@"%@", @(domain.device_id)];
    
    if (domain) {
        // 取出第一个过期设备 符合以下条件的弹框提醒
        G100ReactivePopingView *boxView = [G100ReactivePopingView popingViewWithReactiveView];
        boxView.backgorundTouchEnable = NO;
        
        NSString *boxTitle = @"";
        NSString *boxDesc = @"";
        NSString *boxSure = @"";
        if (![domain isOverdue]) {
            boxTitle = @"安全服务即将过期";
            boxDesc = [NSString stringWithFormat:@"车辆【%@】的服务将在%@天后过期，过期后无法使用定位及报警相关服务，安全保护怎能不在，马上续费>>", bike.name, @(domain.leftdays)];
            boxSure = @"立即续费";
        }else if ([domain canRechargeAndOverdue]) {
            boxTitle = @"安全服务已经过期";
            boxDesc = [NSString stringWithFormat:@"车辆【%@】服务已过期，定位及报警服务均已过期，安全保护怎能不在，马上续费>>", bike.name];
            boxSure = @"马上续费";
        }else if (![domain canRecharge]) {
            // 已过期15天
            boxTitle = @"安全服务已经过期";
            boxDesc = [NSString stringWithFormat:@"车辆【%@】服务已过期，定位及报警服务均已过期，请致电客服重新开通服务>>", bike.name];
            boxSure = @"致电客服";
        }
        
        [boxView showPopingViewWithTitle:boxTitle content:boxDesc noticeType:ClickEventBlockCancel otherTitle:@"收起" confirmTitle:boxSure clickEvent:^(NSInteger index) {
            NSString *leftKey = [NSString stringWithFormat:@"due-%@_%@_%@", userid, bikeid, @(domain.device_id)];
            NSInteger leftdays = domain.leftdays;
            if (leftdays <= 30 && leftdays > 20) {
                [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left30remainder" : @(YES)}];
            }else if (leftdays <= 20 && leftdays > 15) {
                [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left20remainder" : @(YES)}];
            }else if (leftdays <= 15 && leftdays > 10) {
                [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left15remainder" : @(YES)}];
            }else if (leftdays <= 10 && leftdays > 7) {
                [[G100InfoHelper shareInstance] updateMyDevListWithUserid:userid bikeid:bikeid devid:devid devInfo:@{@"left10remainder" : @(YES)}];
            }else if (domain.leftdays <= 7) {
                // 保存弹出框状态
                [G100InfoHelper shareInstance].statusMap[leftKey] = @(YES);
            }
            
            if (index == 2) {
                [boxView dismissWithVc:self animation:YES];
                self.dueBoxView = nil;
                
                // 致电客服
                if (![domain canRecharge]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://400-920-2890"]];
                }else {
                    // 立即续费
                    [G100Router openURL:[[G100UrlManager sharedInstance] getServicePayWithUserid:self.userid
                                                                                          bikeid:self.bikeid
                                                                                           devid:[NSString stringWithFormat:@"%@", @(domain.device_id)]
                                                                                            type:1
                                                                                       productid:nil]];
                }
            }else {
                CGFloat boxW = 5 * self.dueBoxView.popingView.frame.size.width/self.dueBoxView.popingView.frame.size.height;
                [UIView animateWithDuration:0.3 animations:^{
                    self.dueBoxView.popingView.frame = CGRectMake(WIDTH - boxW, kNavigationBarHeight, boxW, 5);
                    self.dueBoxView.alpha = 0.1;
                } completion:^(BOOL finished) {
                    [boxView dismissWithVc:self animation:YES];
                    self.dueBoxView = nil;
                    
                    [self checkServiceDue];
                    
                    [self.cardBaseCollectionView setContentOffset:CGPointMake(WIDTH * targetIndex, 0) animated:YES];
                }];
            }
        } onViewController:self onBaseView:self.view];
        
        self.dueBoxView = boxView;
    }
}

-(void)checkPrivacyVersion{
    if (IsLogin()){
        dispatch_async(dispatch_get_main_queue(), ^{
            AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
            __weak typeof(self) wSelf = self;
            [sessionManager GET:@"https://www.qiweishi.com/data/qws_version.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSString *newV = [responseObject objectForKey:@"version"];
                NSString *oldV = [[G100InfoHelper shareInstance] getPrivacyVersionWithUserid:[G100InfoHelper shareInstance].username];
                if (![newV isEqualToString:oldV]) {
                    if (!wSelf.popView || ![wSelf.popView superview]){
                        wSelf.popView = [G100ReactivePopingView popingViewWithReactiveView];
                        [wSelf.popView showRichTextPopingViewWithTitle:@"隐私策略" content:@"亲爱的用户，骑卫士依照相关法律要求进行信息及风险防范管理。为了您可以正常使用我们的服务，您的车辆及定位信息需要被依法收集并使用。\n骑卫士将严格保护您的个人信息，确保信息安全，具体详见骑卫士隐私权政策，点击“同意”，即表示您同意上述内容并确认您已阅读 《骑卫士隐私权政策》" richText:@"《骑卫士隐私权政策》" noticeType:ClickEventBlockCancel otherTitle:@"不同意" confirmTitle:@"同意" clickEvent:^(NSInteger index) {
                            if (index == 2) {
                                [[G100InfoHelper shareInstance] updatePrivacyWithUserid:[G100InfoHelper shareInstance].username version:newV];
                                [wSelf.popView dismissWithVc:wSelf animation:YES];
                                wSelf.popView = nil;
                            }else{
                                [[UserManager shareManager] logoff];
                                [wSelf.popView dismissWithVc:wSelf animation:YES];
                                wSelf.popView = nil;
                                [wSelf refreshLogoutMainVC];
                                [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                                    [wSelf.navigationController popToRootViewControllerAnimated:NO];
                                }];
                            }
                        } ClickRichTextlBlock:^(NSInteger index) {
                            G100WebViewController * agreement = [G100WebViewController loadNibWebViewController];
                            agreement.httpUrl = @"https://www.qiweishi.com/privacy_policy.html";
                            agreement.webTitle = @"隐私政策";
                            [self.navigationController pushViewController:agreement animated:YES];
                        } onViewController:wSelf onBaseView:wSelf.view];
                        [wSelf.popView configConfirmViewTitleColorWithConfirmColor:@"000000" otherColor:@"000000"];
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                DLog(@"请求失败--%@",error);
            }];
        });
        
    }
}

#pragma mark - 检查网络
- (void)insepectNet {
    if ([self.netview superview]) {
        [self.netview removeFromSuperview];
    }
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        self.netview = [[G100NetworkHintView alloc] initWithFrame:CGRectMake(0, 0, WIDTH ,25)
                                                            title:@"网络无法链接请检查您的网络。"
                                                            color:[UIColor redColor]];
        [self.view insertSubview:self.netview belowSubview:self.menuView];
        [self.netview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@25);
            make.top.equalTo(@kNavigationBarHeight);
        }];

        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }else {
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }
}

- (void)setUpMenuViewData {
    [self.menuViewHelper reloadMenuItemsWithUserid:self.userid];
}

#pragma mark - 处理通讯录权限
- (void)handle_AutoClosePhoneAlarm:(NSError *)error {
    if (error.code == 110) {
        // 没有通讯录权限 -> 弹框提示自动关闭电话报警
        G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:self.userid];
        if ([userDomain isOpenPhoneAlarm] && ![self.autoClosePhoneBoxView superview]) {
            __weak __typeof__(self) wself = self;
            [self.autoClosePhoneBoxView showPopingViewWithTitle:@"无法使用通讯录"
                                                        content:@"当前电话号码有更新，为了更好识别我们的服务，请到“设置-隐私-通讯录”开启权限"
                                                     noticeType:ClickEventBlockCancel
                                                     otherTitle:@"取消"
                                                   confirmTitle:@"立即开启"
                                                     clickEvent:^(NSInteger index) {
                                                         if (index == 1) {
                                                             NSArray *bikes = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:wself.userid];
                                                             for (G100BikeDomain *bike in bikes) {
                                                                 for (G100DeviceDomain *device in bike.gps_devices) {
                                                                     if (device.security.phone_notify.switch_on) {
                                                                         [[G100BikeApi sharedInstance] setPhoneNotifyWithBikeid:[NSString stringWithFormat:@"%@", @(bike.bike_id)] notify:NO callback:nil];
                                                                     }
                                                                 }
                                                             }
                                                             
                                                             [CURRENTVIEWCONTROLLER showHint:@"电话报警已关闭"];
                                                         }else {
                                                             [G100ABHelper openSystemAppSettingPage];
                                                         }
                                                         
                                                         [wself.autoClosePhoneBoxView dismissWithVc:wself animation:YES];
                                                     }
                                               onViewController:self
                                                     onBaseView:self.view];
        }
    }
}

- (void)updateMainContinueEvent {
    if ([self.pushPopupBox superview] && [[NotificationHelper shareInstance] notificationServicesEnabled]) {
        [self.pushPopupBox dismissWithVc:self animation:YES];
    }
    
    // 首先判断 用户是否打开系统推送
    if (![[NotificationHelper shareInstance] notificationServicesEnabled]) {
        if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"user-push-custom"]) {
            if ([NotificationHelper canOpenSystemNotificationSettingPage]) {
                G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
                [box showPopingViewWithTitle:@"提示"
                                     content:@"您的手机禁止了App通知，\n这将导致无法接收App消息\n请前往设置"
                                  noticeType:ClickEventBlockCancel
                                  otherTitle:@"取消"
                                confirmTitle:@"去设置"
                                  clickEvent:^(NSInteger index) {
                                      if (index == 2) {
                                          [NotificationHelper openSystemNotificationSettingPage];
                                      }
                                      [box dismissWithVc:self animation:YES];
                                  }
                            onViewController:self
                                  onBaseView:self.view];
                
                self.pushPopupBox = box;
            }else {
                G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
                [box showPopingViewWithTitle:@"提示"
                                     content:@"您的手机禁止了App通知，\n这将导致无法接收App消息\n请前往设置"
                                  noticeType:ClickEventBlockCancel
                                  otherTitle:nil
                                confirmTitle:@"我知道了"
                                  clickEvent:^(NSInteger index) {
                                      [box dismissWithVc:self animation:YES];
                                  }
                            onViewController:self
                                  onBaseView:self.view];
                self.pushPopupBox = box;
            }
            
            [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"user-push-custom" leftTimes:0];
        }
    }else {
        [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"user-push-custom" leftTimes:1];
        //判断是否提醒长时间未收到报警
        if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"noti_overtime_warning"]) {
            
            NSDate *lastesd_date = [[G100InfoHelper shareInstance] findLastestNotificationTime];
            if (lastesd_date) {
                NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastesd_date];
                int days = ((int)interval)%(3600*24*30*12)%(3600*24*30)/(3600*24);
                if (days >= 5) { //超过五天提醒
                    __weak typeof (self) wself = self;
                    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
                    [box showPopingViewWithTitle:@"提示"
                                         content:@"您很久没有收到App通知了，\n是否需要测试一下\nApp推送是否正常"
                                      noticeType:ClickEventBlockCancel
                                      otherTitle:@"取消"
                                    confirmTitle:@"去测试"
                                      clickEvent:^(NSInteger index) {
                                          if (index == 2) {
                                              //跳转App报警测试
                                              G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:wself.userid bikeid:wself.bikeid];
                                              G100PushAlarmTestView *testView = [[G100PushAlarmTestView alloc] init];
                                              testView.userid = wself.userid;
                                              testView.bikeid = wself.bikeid;
                                              testView.devid = wself.devid;
                                              testView.phoneNum = bikeDomain.mainDevice.security.phone_notify.callee_num;
                                              testView.isTrainTest = NO;
                                              testView.entrance = 1;
                                              
                                              [testView showInVc:wself view:wself.view animation:YES];
                                          }
                                          [box dismissWithVc:wself animation:YES];
                                      }
                                onViewController:self
                                      onBaseView:self.view];
                    
                    [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"noti_overtime_warning" leftTimes:0];
                }
            }else {
                [[G100InfoHelper shareInstance] updateLastestNotificationTime:[NSDate date]];
            }
        }
    }
    
    // 判断是否存在未完成的测试项目
    NSDictionary *testResultInfo = [[G100InfoHelper shareInstance] findThereisPushTestResultWithUserid:self.userid];
    if (testResultInfo && [[testResultInfo allKeys] containsObject:@"testStartTime"] &&
        ![[self.navigationController.viewControllers lastObject] isKindOfClass:NSClassFromString(@"G100TestConfirmViewController")]) {
        // 存在未完成的测试项目 且当前页面不是测试结果等待页面的时候 跳转到结果页面让用户手动确认测试结果
        NSMutableArray *navs = [[self.navigationController viewControllers] mutableCopy];
        BOOL hasOldVC = NO;
        UIViewController *oldVC = nil;
        for (UIViewController *vc in navs) {
            if ([vc isKindOfClass:NSClassFromString(@"G100TestConfirmViewController")]) {
                hasOldVC = YES;
                oldVC    = vc;
                break;
            }
        }
        
        if (!hasOldVC) {
            G100PushAlarmTestView *pushTestView = [[G100PushAlarmTestView alloc] init];
            pushTestView.params = testResultInfo.mutableCopy;
            [pushTestView showInVc:self view:self.view animation:NO];
        }
    }
    
    if (IsLogin()) {
        // 更新车辆列表
        [[UserManager shareManager] updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            if (!requestSuccess) {
                // 若请求失败 -> 使用本地缓存数据
                G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:_currentPage];
                [vc featchMainData];
            }
        }];
        // 更新活动信息
        [self updateEventWithUserid:self.userid];
        // 查询通讯录是否有更新
        [[G100ABManager sharedInstance] ab_checkUpdate:^(BOOL update, id res, NSError *error) {
            DLog(@"%@", error.userInfo);
            [self handle_AutoClosePhoneAlarm:error];
        }];
        
        [[InsuranceCheckService sharedService] checkInsurancePacksWithUserid:self.userid complete:nil];
    }
    
    // 刷新侧边栏选项
    [self setUpMenuViewData];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialData];
    [self setupView];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // iOS 11 UI 显示bug 修复
    if ([self.cardBaseCollectionView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.cardBaseCollectionView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [self setupNotificationObserver];
    [self setUpMenuViewData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.pushPopupBox superview] && [[NotificationHelper shareInstance] notificationServicesEnabled]) {
        [self.pushPopupBox dismissWithVc:self animation:YES];
    }
    
    G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:_currentPage];
    [vc mdv_viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasAppear) {
        // 通知主页面已经加载完成
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNDIDShowMainView object:nil];
        self.hasAppear = YES;
        
        [[UserManager shareManager] updateUserInfoWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            self.menuView.userid = self.userid;
            [self updateMainContinueEvent];
        }];
    }else {
        if (self.menuView.isOpen) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
        
        [self setUpMenuViewData];
    }
    
    G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:_currentPage];
    [vc mdv_viewDidAppear:animated];
    
    // 判断是否属于样机 是的话 加上样机水印
    if ([[[UserAccount sharedInfo] appwatermarking] type]) {
        [[G100SampleMarking shareInstance] addSampleMarkingView];
    }
    
    // 判断是否有新绑定的设备需要弹窗提醒
    NSArray *result = [[G100InfoHelper shareInstance] findThereisNewDevBindSuccessWithUserid:self.userid];
    if (result) {
        // 有 则判断用户是否绑定微信
        NSString *userid = [result safe_objectAtIndex:0];
        NSString *bikeid = [result safe_objectAtIndex:1];
        NSString *devid = [result safe_objectAtIndex:2];
        [self remindUserOpenWxpushMsgWithUserid:userid bikeid:bikeid devid:devid];
    }
    
    // 判断是否需要展示天气功能引导
    if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"guide_weather_newfeature"]) {
        if (![_weatherGuideView superview]) {
            G100WeatherGuideView *weatherGuideView = [G100WeatherGuideView loadXibView];
            weatherGuideView.iKnowBlock = ^(){
                [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"guide_weather_newfeature" leftTimes:0];
                self.edgePan.enabled = YES;
            };
            
            [self.view addSubview:weatherGuideView];
            [weatherGuideView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
            
            self.edgePan.enabled = NO;
            self.weatherGuideView = weatherGuideView;
        }
    }
    
    // 检查是否存在服务过期
    [self checkServiceDue];
    [self insepectNet];
    if (IsLogin()) {
        [self checkPrivacyVersion];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:_currentPage];
    [vc mdv_viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    G100MainDetailViewController *vc = [self.detailVcArray safe_objectAtIndex:_currentPage];
    [vc mdv_viewDidDisappear:animated];
}

@end
