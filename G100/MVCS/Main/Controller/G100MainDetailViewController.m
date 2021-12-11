//
//  G100MainDetailViewController.m
//  G100
//
//  Created by yuhanle on 16/7/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MainDetailViewController.h"
#import "G100CardBaseViewController.h"
#import "G100CardViewCell.h"

#import "G100EventView.h"
#import "G100WebViewController.h"
#import "G100DevUpdateViewController.h"

#import "G100UserApi.h"
#import "G100BikeApi.h"
#import "G100UrlManager.h"
#import "G100InsuranceManager.h"
#import "G100WeatherManager.h"
#import "G100DevDataHandler.h"
#import "G100TopHintView.h"
#import "G100TopHintTableView.h"
#import "G100Mediator+BuyService.h"
#import "G100WeatherCardView.h"
#import "G100TopHintModel.h"

#define Line_Spacing 12.0
#define Side_Spacing 9.0

#define kNavigationBarHeight (ISIPHONEX ? 88 : 64)

@interface G100MainDetailViewController () <UITableViewDelegate, UITableViewDataSource, G100TopTableViewClickActionDelegate, G100DevDataHandlerDelegate> {
    BOOL _hasAppear;
    
    BOOL _beginDragged;
    CGPoint _tableContentOffset;
}

@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) G100EventView *eventView;
@property (nonatomic, strong) G100ReactivePopingView *dueBoxView;
@property (nonatomic, strong) G100TopHintTableView *topHintTableView;
@property (strong, nonatomic) G100WeatherCardView *weatherView;
@property (nonatomic, strong) G100TopHintModel *topHintModel;
@property (nonatomic, strong) G100DevDataHandler *dataHandler;
@property (nonatomic, strong) G100InsuranceManager *insuranceDataManager;

@end

@implementation G100MainDetailViewController

- (void)dealloc {
    DLog(@"车辆大卡片已释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

#pragma mark - lazy loading
- (G100CardManager *)cardManager {
    if (!_cardManager) {
        _cardManager = [[G100CardManager alloc] init];
        _cardManager.userid = self.userid;
        _cardManager.bikeid = self.bikeid;
        _cardManager.bike = self.bike;
    }
    return _cardManager;
}
- (UIImageView *)shadowImageView {
    if (!_shadowImageView) {
        _shadowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_bg_shadow"]];
        _shadowImageView.alpha = 0;
    }
    return _shadowImageView;
}
- (UITableView *)cardTableView {
    if (!_cardTableView) {
        _cardTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _cardTableView.delegate = self;
        _cardTableView.dataSource = self;
        _cardTableView.bounces = YES;
        _cardTableView.showsVerticalScrollIndicator = NO;
        _cardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _cardTableView.backgroundColor = [UIColor clearColor];
        _cardTableView.contentInset = UIEdgeInsetsMake(kNavigationBarHeight, 0, kBottomPadding, 0);
        _cardTableView.contentOffset = CGPointMake(0, -kNavigationBarHeight);
        _cardTableView.estimatedRowHeight = 0;
        _cardTableView.estimatedSectionHeaderHeight = 0;
        _cardTableView.estimatedSectionFooterHeight = 0;
    }
    return _cardTableView;
}
-(G100WeatherCardView *)weatherView {
    if (!_weatherView) {
        _weatherView = [G100WeatherCardView showView];
    }
    return _weatherView;
}
- (G100EventView *)eventView {
    if (!_eventView) {
        _eventView = [G100EventView loadXibEventViewWithEventDetailModel:nil];
    }
    return _eventView;
}
- (G100TopHintModel *)topHintModel {
    if (!_topHintModel) {
        _topHintModel = [[G100TopHintModel alloc]init];
    }
    return _topHintModel;
}
- (G100TopHintTableView *)topHintTableView {
    if (!_topHintTableView) {
        _topHintTableView = [[G100TopHintTableView alloc]init];
        _topHintTableView.delegate = self;
    }
    return _topHintTableView;
}
- (NSMutableArray *)indexPaths {
    if (!_indexPaths) {
        _indexPaths = [[NSMutableArray alloc] init];
    }
    return _indexPaths;
}
- (G100InsuranceManager *)insuranceDataManager {
    if (!_insuranceDataManager) {
        _insuranceDataManager = [[G100InsuranceManager alloc] init];
    }
    return _insuranceDataManager;
}

#pragma mark - Public Method
- (void)setBike:(G100BikeDomain *)bike {
    _bike = bike;
    
    self.cardManager.bike = bike;
    [self reloadData];
}

- (void)setScrollsToTop:(BOOL)scrollsToTop {
    _scrollsToTop = scrollsToTop;
    [self.cardTableView setScrollsToTop:scrollsToTop];
}

- (void)setContentOffset:(CGPoint)contentOffset {
    _contentOffset = contentOffset;
    [self.cardTableView setContentOffset:contentOffset animated:NO];
}

#pragma mark - init & setup
- (void)initialData {
    _hasAppear = NO;
}

#pragma mark - setupView
- (void)setupView {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect gframe = self.view.frame;
    gframe.size.height -= kNavigationBarHeight;
    gframe.origin.y = kNavigationBarHeight;
    
    CGFloat gheight = self.view.frame.size.width * 0.3;
    gradient.frame = gframe;
    gradient.colors = @[ (id)[UIColor blackColor].CGColor,
                         (id)[UIColor colorWithRed:69/255.0 green:69/255.0 blue:69/255.0 alpha:1.0].CGColor,
                         (id)[UIColor colorWithHexString:@"DCDCDC"].CGColor ];
    
    gradient.locations = @[ @(gheight / gframe.size.height / 2.0), @(gheight / gframe.size.height / 1.0), @0.64 ];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self.view addSubview:self.weatherView];
    [self.weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@kNavigationBarHeight);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(self.view.mas_width).multipliedBy(0.3);
    }];
    
    [self.view addSubview:self.cardTableView];
    [self.cardTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@(-kBottomHeight));
    }];
}

#pragma mark - 通知监听
- (void)setupNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(securityViewControllerBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insepectNet)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
}

#pragma mark - G100TopTableViewClickActionDelegate
- (void)topTableViewClickedWithDevice:(G100DeviceDomain *)deviceDomain {
    if (deviceDomain.leftdays <= -15) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://400-920-2890"]];
    }else {
        // 购买服务
        UIViewController *viewController = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBuyService:self.userid
                                                                                                            bikeid:self.bikeid
                                                                                                             devid:[NSString stringWithFormat:@"%@", @(deviceDomain.device_id)] fromVc:@(1)];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)topTableViewClickedWithInsurance:(G100InsuranceBanner *)insuranceBanner {
    if (insuranceBanner.button.url.length) {
        [G100Router openURL:insuranceBanner.button.url];
    }
}

- (void)topTableViewClickedWithUpdateVersion:(G100UpdateVersionModel *)waitUpdateInfo {
    G100DevUpdateViewController *updateVC = [[G100DevUpdateViewController alloc] init];
    updateVC.devid = waitUpdateInfo.devid;
    updateVC.bikeid = waitUpdateInfo.bikeid;
    updateVC.userid = self.userid;
    [self.navigationController pushViewController:updateVC animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(mainDetailViewDidScroll:)] && _hasAppear) {
        [self.delegate mainDetailViewDidScroll:scrollView];
    }
    if (scrollView.contentOffset.y > -kNavigationBarHeight) {
        if (scrollView.contentOffset.y < 0) {
            self.shadowImageView.alpha = 1*(1-scrollView.contentOffset.y/-kNavigationBarHeight);
        }else{
            self.shadowImageView.alpha = 1;
        }
    }else{
        self.shadowImageView.alpha = 0;
    }
    
    _contentOffset = scrollView.contentOffset;
    
    // 判断是否需要刷新天气
    if (scrollView.contentOffset.y < _tableContentOffset.y) {
        // 下拉
        if (scrollView.contentOffset.y < -kNavigationBarHeight - self.weatherView.v_height) {
            if (_beginDragged) {
                [self loadWeatherInfo];
                _beginDragged = NO;
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _beginDragged = YES;
    _tableContentOffset = scrollView.contentOffset;
    
    if ([_delegate respondsToSelector:@selector(mainDetailViewWillBeginDragging:)]) {
        [self.delegate mainDetailViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(mainDetailViewDidEndDecelerating:)]) {
        [self.delegate mainDetailViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_delegate respondsToSelector:@selector(mainDetailViewDidEndDragging:willDecelerate:)]) {
        [self.delegate mainDetailViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)loadWeatherInfo {
    [self.weatherView loadForecastWeatherModeComplete:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cardManager.dataArray safe_objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.cardManager numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.indexPaths containsObject:indexPath]) {
        [self.indexPaths addObject:indexPath];
    }
    
    G100CardModel *cardModel = [[self.cardManager.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    
    G100CardViewCell *cardViewCell = (G100CardViewCell *)[tableView dequeueReusableCellWithIdentifier:cardModel.identifier];
    if (!cardViewCell) {
        cardViewCell = [[G100CardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cardModel.identifier];
    }
    if (!cardViewCell.cardVc) {
        UIViewController *baseCardVC = [self.cardManager cardViewControllerWithItem:cardModel
                                                                          indexPath:indexPath
                                                                          idetifier:cardModel.identifier];
        cardViewCell.cardVc = baseCardVC;
    }
    cardModel.indexPath = indexPath;
    [cardViewCell.cardVc setValue:self.userid forKey:@"userid"];
    [cardViewCell.cardVc setValue:self.bikeid forKey:@"bikeid"];
    [cardViewCell.cardVc setValue:cardModel.devid forKey:@"devid"];
    [cardViewCell.cardVc setValue:cardModel forKey:@"cardModel"];
    if (cardViewCell.cardVc && ![cardViewCell.cardVc.view superview]) {
        [cardViewCell.containerView removeAllSubviews];
        [self addChildViewController:cardViewCell.cardVc toView:cardViewCell.containerView];
        [self.cardManager addCardViewController:cardViewCell.cardVc indexPath:indexPath];
    }
    return cardViewCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    G100CardModel *cardModel = [[self.cardManager.dataArray safe_objectAtIndex:indexPath.section] safe_objectAtIndex:indexPath.row];
    return [self.cardManager heightForCardViewWithItem:cardModel
                                                 width:self.view.frame.size.width
                                             indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.topHintModel.allViewHints.count != 0) {
        return self.topHintModel.viewHeight;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.topHintModel.allViewHints.count != 0) {
        self.topHintTableView.topHintModel = self.topHintModel;
        return self.topHintTableView;
    }else {
        return nil;
    }
   
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section < [self.cardManager.dataArray count]-1) {
        UIView * footer = [[UIView alloc] init];
        footer.backgroundColor = [UIColor colorWithHexString:@"DCDCDC"];
        return footer;
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

#pragma mark - 添加子视图控制器
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

#pragma mark - Public Method
- (void)reloadData {
    [self.cardTableView reloadData];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self.cardTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    _bike = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    self.cardManager.bike = self.bike;
    self.cardManager.bikeid = self.bikeid;
    
    [self.cardTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    
    CGFloat h = [[self.cardTableView cellForRowAtIndexPath:indexPath] frame].size.height;
    UITableViewCell *cell = [self.cardTableView cellForRowAtIndexPath:indexPath];
    CGPoint p = [cell convertPoint:CGPointZero fromView:self.view];
    if((h - p.y) > self.view.frame.size.height) {
        [self.cardTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (void)securityViewControllerBecomeActive {
    if (self.hasAppear) {
        [self loadWeatherInfo];
    }
}

#pragma mark - Private method
- (void)featchMainData {
    // 刷新顶部提醒
    NSArray *allDevsArr = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:self.bikeid];
    NSMutableArray *tempDevServiceArr = [NSMutableArray array];
    for (G100DeviceDomain *deviceDomain in allDevsArr) {
        if (deviceDomain.service.left_days <= 30 && !deviceDomain.isSpecialChinaMobileDevice) {
            [tempDevServiceArr addObject:deviceDomain];
        }
    }
    
    [tempDevServiceArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[NSNumber numberWithInteger:[obj1 leftdays]] compare:[NSNumber numberWithInteger:[obj2 leftdays]]];
    }];
    
    self.topHintModel.devServiceOverdueArr = tempDevServiceArr;
    
    // 获取网络数据
    if (self.userid && self.bikeid && IsLogin()) {
        __weak typeof(self) wself = self;
        dispatch_queue_t performTasksQueue = dispatch_queue_create("hintModelPerformTasksQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        
        // 查询保险 是否有免费领取的盗抢险
        dispatch_group_enter(group);
        dispatch_async(performTasksQueue, ^{
            [wself.insuranceDataManager getInsuranceModelWithUserid:wself.userid bikeid:wself.bikeid compete:^(G100InsuranceCardModel *insuranceModel) {
                wself.cardManager.insurance = insuranceModel;
                if (insuranceModel.bannerList) {
                    wself.topHintModel.insuranceBannerArr = [insuranceModel.bannerList copy];
                }else {
                    wself.topHintModel.insuranceBannerArr = @[];
                }
                
                dispatch_group_leave(group);
            }];
        });
        
        // 查询设备更新提醒
        __block NSMutableArray <G100UpdateVersionModel *> *waitUpdateArray = [[NSMutableArray alloc] init];
        for (G100DeviceDomain *dv in allDevsArr) {
            dispatch_group_enter(group);
            dispatch_async(performTasksQueue, ^{
                [[G100BikeApi sharedInstance] checkDeviceFirmWithBikeid:self.bikeid
                                                               deviceid:[NSString stringWithFormat:@"%@", @(dv.device_id)]
                                                               callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                    if (requestSuccess) {
                        G100UpdateVersionModel *updateVersionModel = [[G100UpdateVersionModel alloc] initWithDictionary:response.data];
                        if (updateVersionModel.firm.state == 0) {
                            // 没有最新版本
                            
                        }else if (updateVersionModel.firm.state == 1) {
                            //有最新版本 有新版本 或者 升级失败成功
                            updateVersionModel.bikeid = wself.bikeid;
                            updateVersionModel.devid = [NSString stringWithFormat:@"%@", @(dv.device_id)];
                            [waitUpdateArray addObject:updateVersionModel];
                        }else {
                            //正在升级/下载
                            
                        }
                    }else {
                        
                    }
                    
                    dispatch_group_leave(group);
                }];
            });
        }
        
        //此方法会阻塞当前线程 不推荐
        //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_group_notify(group, dispatch_get_main_queue(),^{
            wself.topHintModel.waitUpdateArray = waitUpdateArray.copy;
            [wself.dataHandler concernNow:nil];
            [wself reloadData];
        });
    }else {
        G100InsuranceCardModel *insuranceCardModel = [[G100InsuranceCardModel alloc] init];
        G100InsuranceActivityDomain *insuranceAD = [[G100InsuranceActivityDomain alloc] init];
        NSMutableArray *insuADArray = [NSMutableArray arrayWithObject:insuranceAD];
        insuranceCardModel.activityList = [insuADArray copy];
        self.cardManager.insurance = insuranceCardModel;
        
        [self reloadData];
    }
}

#pragma mark - 更新活动信息
/**
 更新活动信息
 
 @param userid 用户id
 @param bikeid 车辆id
 */
- (void)updateEventWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    //防止未登录情况下一直检查更新
    if (!IsLogin() || !userid.length) {
        return;
    }
    if ([self.eventView superview]) {
        return;
    }
    __weak __typeof(self) wself = self;
    API_CALLBACK calllback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            G100EventDomain *eventDomain = [[G100EventDomain alloc] initWithDictionary:response.data];
            // 首先判断 是否存在活动海报信息
            G100EventDetailDomain *posterEvent = [eventDomain firstPosterEventDetail];
            if (posterEvent) {
                G100EventDetailDomain * localDetailEventDomain = [[G100InfoHelper shareInstance] getCurrentEventWithUserId:self.userid bikeid:self.bikeid eventId:posterEvent.eventid];
                if (!localDetailEventDomain) {
                    [wself.eventView setEvent:posterEvent];
                    wself.eventView.getDetailBlock = ^(G100EventDetailDomain *detailDomain){
                        if ([detailDomain.poster_url hasPrefix:@"http"]) {
                            G100WebViewController * webVc = [G100WebViewController loadNibWebViewController];
                            webVc.userid = wself.userid;
                            webVc.bikeid = wself.bikeid;
                            webVc.httpUrl = detailDomain.poster_url;
                            [wself.navigationController pushViewController:webVc animated:YES];
                        }else {
                            if ([G100Router canOpenURL:detailDomain.poster_url]) {
                                [G100Router openURL:detailDomain.poster_url];
                            }
                        }
                        
                        [[G100InfoHelper shareInstance] updateCurrentEventWithUserid:wself.userid bikeid:wself.bikeid detailEventDomain:detailDomain];
                        wself.eventView = nil;
                    };
                    wself.eventView.dismissBlock = ^(G100EventDetailDomain *detailDomain){
                        [[G100InfoHelper shareInstance] updateCurrentEventWithUserid:wself.userid bikeid:wself.bikeid detailEventDomain:detailDomain];
                        wself.eventView = nil;
                    };
                    
                    [wself.eventView showInVc:wself.topParentViewController
                                         view:wself.topParentViewController.view
                                    animation:YES
                                   completion:^(BOOL finished) {
                                      [wself shakeAnimationForView:wself.eventView.containerView];
                                  }];
                }else {
                    
                }
            }
        }else {
            
        }
    };
    
    [[G100UserApi sharedInstance] checkCurrentEventWithBikeid:self.bikeid callback:calllback];
}
/* 抖动动画 */
- (void)shakeAnimationForView:(UIView *)view {
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint fromPoint = CGPointMake(position.x + 2, position.y);
    CGPoint toPoint = CGPointMake(position.x - 2, position.y);
    [viewLayer addAnimation:[CABasicAnimation shakeAnimationWithDuration:.06
                                                                   count:3
                                                                    from:fromPoint
                                                                      to:toPoint]
                     forKey:nil];
}

- (void)pushBikeBatteryInfoNoticeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:userid bikeid:bikeid];
    
    if (!bikeDomain.isMaster) {
        return;
    }
    
    if (!bikeDomain.mainDevice) {
        return;
    }
    
    if ([bikeDomain isMOTOBike]) {
        return;
    }
    
    if ([self.eventView superview]) {
        return;
    }
    [[G100InfoHelper shareInstance] setLeftRemainderTimesWithKey:@"kBatteryInfoNoticeNum" times:3 userid:userid devid:bikeid dependOnVersion:NO];
    if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"kBatteryInfoNoticeNum" userid:userid devid:bikeid] > 0) {
        // 弹窗活动信息 提醒用户
        NSString *deviceid = [NSString stringWithFormat:@"%@", @(self.bike.mainDevice.device_id)];
        G100EventDetailDomain *detailDomain = [[G100EventDetailDomain alloc] init];
        detailDomain.poster = @"poster_bg_battery";
        detailDomain.localtype = 1;
        detailDomain.poster_url = [[G100UrlManager sharedInstance] getBatteryAndVoltageUrlWithUserid:userid
                                                                                              bikeid:bikeid
                                                                                            isMaster:self.bike.is_master
                                                                                               devid:deviceid
                                                                                            model_id:self.bike.mainDevice.model_id];
        
        [self.eventView setEvent:detailDomain];
        
        __weak __typeof(self) wself = self;
        self.eventView.getDetailBlock = ^(G100EventDetailDomain *detailDomain){
            if ([detailDomain.poster_url hasPrefix:@"http"]) {
                G100WebViewController * webVc = [G100WebViewController loadNibWebViewController];
                webVc.userid = wself.userid;
                webVc.bikeid = bikeid;
                webVc.devid = deviceid;
                webVc.httpUrl = detailDomain.poster_url;
                [wself.navigationController pushViewController:webVc animated:YES];
            }else {
                if ([G100Router canOpenURL:detailDomain.poster_url]) {
                    [G100Router openURL:detailDomain.poster_url];
                }
            }
            
            // 清空不再显示
            [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"kBatteryInfoNoticeNum"
                                                              leftTimes:0
                                                                 userid:userid
                                                                  devid:bikeid];
        };
        self.eventView.dismissBlock = ^(G100EventDetailDomain *detailDomain){
            // 清空不再显示
            [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"kBatteryInfoNoticeNum"
                                                              leftTimes:0
                                                                 userid:userid
                                                                  devid:bikeid];
        };
        
        [self.eventView showInVc:self.topParentViewController
                            view:self.topParentViewController.view
                       animation:YES
                      completion:^(BOOL finished) {
                          [wself shakeAnimationForView:wself.eventView.containerView];
                      }];
        
        NSInteger num = [[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"kBatteryInfoNoticeNum" userid:userid devid:bikeid];
        if (num > 0) {
            num--;
            [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"kBatteryInfoNoticeNum"
                                                              leftTimes:num
                                                                 userid:userid
                                                                  devid:bikeid];
        }
    }
}

- (void)insepectNet {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [self.cardTableView setContentInset:UIEdgeInsetsMake(kNavigationBarHeight + 25, 0, kBottomPadding, 0)];
        
        CGPoint point = self.cardTableView.contentOffset;
        if (point.y == -kNavigationBarHeight) {
            point.y -= 25;
            [self.cardTableView setContentOffset:point];
        }
    }else {
        [self.cardTableView setContentInset:UIEdgeInsetsMake(kNavigationBarHeight, 0, kBottomPadding, 0)];
    }
}

#pragma mark - 出现/消失
- (void)mdv_viewWillAppear:(BOOL)animated {
    for (G100CardBaseViewController *vc in self.cardManager.cardViewControllersArray) {
        [vc mdv_viewWillAppear:animated];
    }
}
- (void)mdv_viewDidAppear:(BOOL)animated {
    for (G100CardBaseViewController *vc in self.cardManager.cardViewControllersArray) {
        [vc mdv_viewDidAppear:animated];
    }
    
    // 更新活动信息
    [self updateEventWithUserid:self.userid bikeid:self.bikeid];
    
    // 检查是否提示完善电池信息
    [self pushBikeBatteryInfoNoticeWithUserid:self.userid bikeid:self.bikeid];
    
    [self insepectNet];
    
    // 刷新车辆实时信息
    [self featchMainData];
}
- (void)mdv_viewWillDisappear:(BOOL)animated {
    for (G100CardBaseViewController *vc in self.cardManager.cardViewControllersArray) {
        [vc mdv_viewWillDisappear:animated];
    }
}
- (void)mdv_viewDidDisappear:(BOOL)animated {
    for (G100CardBaseViewController *vc in self.cardManager.cardViewControllersArray) {
        [vc mdv_viewDidDisappear:animated];
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册观察者
    _dataHandler = [[G100DevDataHandler alloc] initWithUserid:self.userid bikeid:self.bikeid];
    _dataHandler.delegate = self;
    
    [self setupNotificationObserver];
    [self setupView];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if ([self.cardTableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.cardTableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [self initialData];
    [self loadWeatherInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hasAppear) {
        //[self featchMainData];
    }
    _hasAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

@end
