//
//  G100DevUnderFindingViewController.m
//  G100
//
//  Created by William on 16/4/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevUnderFindingViewController.h"
#import "G100FindingSectionHeaderView.h"
#import "G100DevLostListDomain.h"
#import "G100BikeDomain.h"

#import "G100DevLostNewTagViewController.h"
#import "G100DevFindingCell.h"
#import "G100DevFindLostListDomain.h"
#import "G100DevFindingSectionHeaderView.h"
#import "G100RollingPlayingView.h"
#import "G100WebViewController.h"

#import "G100DevLostFindResultViewController.h"
#import "G100DevLostInfoViewController.h"

#import "G100HoledView.h"
#import "G100UMSocialHelper.h"
#import "G100BikeApi.h"
#import "G100UrlManager.h"

#define kSearchPageSize 20
#define kMapEdgeInset UIEdgeInsetsMake(120, 20, 40, 20)

@interface G100DevUnderFindingViewController () <UITableViewDelegate, UITableViewDataSource, SectionModeChangedDelegate, G100HoledViewDelegate> {
    NSInteger _kSearchPageNum;
    BOOL _viewDidAppear;
}

@property (nonatomic, strong) UIView * findingContentView;
@property (nonatomic, strong) UITableView * findingTableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) UIView *customBottomView; // 底部按钮 告诉亲朋 开始寻车
@property (nonatomic, strong) UIView *customShareButtonView;// 底部分享按钮
@property (nonatomic, strong) NSMutableArray * timeArray;

@property (nonatomic, strong) G100DevFindLostListDomain * lostListDomain;
@property (nonatomic, strong) G100DevLostDomain *lostDomain;
@property (nonatomic, strong) G100FindingSectionHeaderView * sectionHeaderView;
@property (nonatomic, strong) CustomMAPointAnnotation * lostPositionAnnotation;
@property (nonatomic, strong) CustomMAPointAnnotation * findPositionAnnotation;
@property (nonatomic, strong) G100RollingPlayingView * rollingView;

@property (strong, nonatomic) G100HoledView           * holedView;

@property (strong, nonatomic) MASConstraint           * findingContentViewTop;

@property (assign, nonatomic) NSInteger shareid;
@property (assign, nonatomic) NSInteger kSearchPageNum;

@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIButton *leftEndFindcarButton;
@property (strong, nonatomic) UIButton *middleReReportButton;
@property (strong, nonatomic) UIButton *rightMarkButton;

@property (assign, nonatomic) BOOL hasFitMapViewAllAnnotation;
@property (assign, nonatomic) BOOL hasFitMapViewFindLostAnnotation;
@property (assign, nonatomic) BOOL hasGetDevinfo;

@end

@implementation G100DevUnderFindingViewController

- (G100RollingPlayingView *)rollingView {
    if (!_rollingView) {
        _rollingView = [[G100RollingPlayingView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 24)];
    }
    return _rollingView;
}

- (UIView *)customBottomView {
    if (!_customBottomView) {
        _customBottomView = [[UIView alloc] init];
        _customBottomView.backgroundColor = self.view.backgroundColor;
        // 结束寻车
        UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
        button0.tag = 100;
        button0.titleLabel.font = [UIFont systemFontOfSize:FontInBiggest(17)];
        [button0 setTitle:@"已找到车" forState:UIControlStateNormal];
        
        UIEdgeInsets insets  = UIEdgeInsetsMake(9, 9, 9, 9);
        UIImage *normalImage = [[UIImage imageNamed:@"ic_alarm_option_yes_up"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        UIImage *highlitedImage = [[UIImage imageNamed:@"ic_alarm_option_yes_down"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        [button0 addTarget:self action:@selector(tl_bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button0 setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button0 setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        // 重发启事
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.tag = 200;
        button1.titleLabel.font = [UIFont systemFontOfSize:FontInBiggest(17)];
        [button1 setTitle:@"重发启事" forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(tl_bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button1 setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button1 setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        // 自己记一条
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.tag = 300;
        button2.titleLabel.font = [UIFont systemFontOfSize:FontInBiggest(17)];
        [button2 setTitle:@"自己记一条" forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(tl_bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button2 setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button2 setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        [_customBottomView addSubview:button0];
        [_customBottomView addSubview:button1];
        [_customBottomView addSubview:button2];
        
        CGFloat ew = (WIDTH-20*4)/3.0;
        [button0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@5);
            make.leading.equalTo(@20);
            make.height.equalTo(@36);
            make.width.equalTo(ew);
            make.size.equalTo(button1);
            make.size.equalTo(button2);
            make.centerY.equalTo(button1);
            make.centerY.equalTo(button2);
        }];
        
        [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_customBottomView);
        }];
        
        [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(@-20);
        }];
        
        [self.contentView addSubview:_customBottomView];
        
        self.leftEndFindcarButton = button0;
        self.middleReReportButton = button1;
        self.rightMarkButton = button2;
    }
    return _customBottomView;
}

- (UIView *)customShareButtonView {
    if (!_customShareButtonView) {
        _customShareButtonView = [[UIView alloc] init];
        _customShareButtonView.backgroundColor = self.view.backgroundColor;
        // 结束寻车
        UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
        button0.tag = 400;
        button0.titleLabel.font = [UIFont systemFontOfSize:FontInBiggest(17)];
        [button0 setTitle:@"分  享" forState:UIControlStateNormal];
        
        UIEdgeInsets insets  = UIEdgeInsetsMake(9, 9, 9, 9);
        UIImage *normalImage = [[UIImage imageNamed:@"ic_alarm_option_yes_up"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        UIImage *highlitedImage = [[UIImage imageNamed:@"ic_alarm_option_yes_down"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        [button0 addTarget:self action:@selector(tl_bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button0 setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button0 setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        [_customShareButtonView addSubview:button0];
        
        [button0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@5);
            make.leading.equalTo(@20);
            make.trailing.equalTo(@-20);
        }];
    }
    return _customShareButtonView;
}

- (UIView *)findingContentView {
    if (!_findingContentView) {
        _findingContentView = [[UIView alloc]init];
        _findingContentView.backgroundColor = [UIColor clearColor];
    }
    return _findingContentView;
}

- (G100FindingSectionHeaderView *)sectionHeaderView {
    if (!_sectionHeaderView) {
        _sectionHeaderView = [G100FindingSectionHeaderView findingSectionHeaderView];
        _sectionHeaderView.delegate = self;
    }
    return _sectionHeaderView;
}

- (UITableView *)findingTableView {
    if (!_findingTableView) {
        _findingTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _findingTableView.delegate = self;
        _findingTableView.dataSource = self;
        _findingContentView.backgroundColor = [UIColor clearColor];
        _findingTableView.contentInset = UIEdgeInsetsMake(0, 0, (HEIGHT-kNavigationBarHeight)*0.4+50, 0);
        _findingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_findingTableView registerNib:[UINib nibWithNibName:@"G100DevFindingNormalCell" bundle:nil] forCellReuseIdentifier:kNibNameDevFindingNormalCell];
        [_findingTableView registerNib:[UINib nibWithNibName:@"G100DevFindingCustomCell" bundle:nil] forCellReuseIdentifier:kNibNameDevFindingCustomCell];
    }
    return _findingTableView;
}

- (CustomMAPointAnnotation *)lostPositionAnnotation {
    if (!_lostPositionAnnotation) {
        _lostPositionAnnotation = [[CustomMAPointAnnotation alloc] init];
    }
    return _lostPositionAnnotation;
}

- (CustomMAPointAnnotation *)findPositionAnnotation {
    if (!_findPositionAnnotation) {
        _findPositionAnnotation = [[CustomMAPointAnnotation alloc] init];
    }
    return _findPositionAnnotation;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lostBikeAlarmCome:)
                                                 name:kGNLostBikeAlarmComeFromServer
                                               object:nil];
    
    _viewDidAppear = NO;
    self.hasGetDevinfo = NO;
    self.hasFitMapViewAllAnnotation = NO;
    self.hasFitMapViewFindLostAnnotation = NO;
    
    self.userLocationViewHidden = NO;
    self.userLocationServiceEnabled = YES;
    self.userLocationAnnotationHidden = YES;
    
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    
    [self setupData];
 
    [self setupView];
    
    [self configLostData:YES];

    __weak G100DevUnderFindingViewController * wself = self;
    
    self.findingTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        wself.kSearchPageNum = 1;
        [wself tl_startReloadMapData];
        [wself configLostData:NO];
        [wself configFindingDataWithRefreshType:YES isShowHud:NO];
    }];
    self.findingTableView.mj_header.lastUpdatedTimeKey = NSStringFromClass([self class]);
    
    self.findingTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        wself.kSearchPageNum++;
        [wself configFindingDataWithRefreshType:NO isShowHud:NO];
    }];
    self.findingTableView.mj_footer.automaticallyHidden = YES;
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // iOS 11 UI 显示bug 修复
    if ([self.findingTableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.findingTableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hasAppear) {
        [self configLostData:NO];
        if (self.lostid)
            [self configFindingDataWithRefreshType:YES isShowHud:NO];
    }else {
        if (self.lostid)
            [self configFindingDataWithRefreshType:YES isShowHud:NO];
    }
    self.hasAppear = YES;
    
    [[UserManager shareManager] updateBikeInfoWithUserid:self.userid bikeid:self.bikeid complete:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_viewDidAppear) {
        if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"tipstofind_car"]) {
            [self addHoledView];
            [[G100InfoHelper shareInstance] updateRemainderTimesWithKey:@"tipstofind_car" leftTimes:0];
        }
        
        [self showAllAnnotationsWithEdgeInset:kMapEdgeInset animated:YES];
    }
    _viewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 防止其他情况导致 引导提示无法消除
    if (_holedView || _holedView.superview) {
        [self.holedView removeHoles];
        [self.holedView removeFromSuperview];
    }
}

- (void)dealloc {
    DLog(@"寻车记录页面已销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNLostBikeAlarmComeFromServer object:nil];
}

#pragma mark - 添加引导提示
- (void)addHoledView {
    //添加遮罩指示
    self.holedView = [[G100HoledView alloc] initWithFrame:self.view.frame];
    self.holedView.holeViewDelegate = self;
    [self.view addSubview:_holedView];
    
    CGRect buttonFrame = self.rightButton.frame;
    [self.holedView addHoleRoundedRectOnRect:CGRectMake(buttonFrame.origin.x - 2,
                                                        buttonFrame.origin.y - 2,
                                                        buttonFrame.size.width + 4,
                                                        buttonFrame.size.height + 4)
                            withCornerRadius:6.0f];
    
    CGRect buttonFrame1 = self.leftEndFindcarButton.frame;
    buttonFrame1.origin.y = HEIGHT - 45 - kBottomPadding;
    [self.holedView addHoleRoundedRectOnRect:CGRectMake(buttonFrame1.origin.x,
                                                        buttonFrame1.origin.y,
                                                        buttonFrame1.size.width,
                                                        buttonFrame1.size.height)
                            withCornerRadius:10.0f];
    
    CGRect buttonFrame2 = self.middleReReportButton.frame;
    buttonFrame2.origin.y = HEIGHT - 45 - kBottomPadding;
    [self.holedView addHoleRoundedRectOnRect:CGRectMake(buttonFrame2.origin.x,
                                                        buttonFrame2.origin.y,
                                                        buttonFrame2.size.width,
                                                        buttonFrame2.size.height)
                            withCornerRadius:10.0f];
    
    CGRect buttonFrame3 = self.rightMarkButton.frame;
    buttonFrame3.origin.y = HEIGHT - 45 - kBottomPadding;
    [self.holedView addHoleRoundedRectOnRect:CGRectMake(buttonFrame3.origin.x,
                                                        buttonFrame3.origin.y,
                                                        buttonFrame3.size.width,
                                                        buttonFrame3.size.height)
                            withCornerRadius:10.0f];
    //[self.holedView addFocusView:self.rightButton];
    
    // 图文说明 寻车贴士
    UIImageView *hintImageView = [[UIImageView alloc] init];
    hintImageView.frame = CGRectMake(WIDTH - 30 - 225, kNavigationBarHeight, 225, 71);
    hintImageView.image = [UIImage imageNamed:@"ic_tips_findtips"];
    
    [self.holedView addHCustomView:hintImageView onRect:hintImageView.frame];
    
    // 图文说明 已找到车
    UIImageView *hintImageView1 = [[UIImageView alloc] init];
    hintImageView1.frame = CGRectMake(15, HEIGHT - 50 - 106 - kBottomPadding, 142, 106);
    hintImageView1.image = [UIImage imageNamed:@"ic_tips_finded"];
    
    [self.holedView addHCustomView:hintImageView1 onRect:hintImageView1.frame];
    
    // 图文说明 重发启事
    UIImageView *hintImageView2 = [[UIImageView alloc] init];
    hintImageView2.frame = CGRectMake((WIDTH - 121)/2.0, HEIGHT - 50 - 285 - kBottomPadding, 121, 285);
    hintImageView2.image = [UIImage imageNamed:@"ic_tips_rereport"];
    
    [self.holedView addHCustomView:hintImageView2 onRect:hintImageView2.frame];
    
    // 图文说明 记一条
    UIImageView *hintImageView3 = [[UIImageView alloc] init];
    hintImageView3.frame = CGRectMake(WIDTH - 15 - 191, HEIGHT - 50 - 169 - kBottomPadding, 191, 169);
    hintImageView3.image = [UIImage imageNamed:@"ic_tips_markbyself"];
    
    [self.holedView addHCustomView:hintImageView3 onRect:hintImageView3.frame];
}

- (void)holedView:(G100HoledView *)holedView didSelectHoleAtIndex:(NSUInteger)index {
    [UIView animateWithDuration:0.3f animations:^{
        self.holedView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.holedView removeHoles];
            [self.holedView removeFromSuperview];
        }
    }];
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:@"寻车记录"];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightButton.frame = CGRectMake(WIDTH - 90, kNavigationBarHeight - 44 + 8, 80, 28);
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_rightButton setTitle:@"寻车贴士" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(getFindingTips) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:_rightButton];
}

- (void)setupData {
    _kSearchPageNum = 1;
}

- (void)setupView {
    self.mapView.showsCompass = NO;
    self.scaleLabel.hidden = YES;
    self.rulerView.hidden = YES;
    self.locationDevBtn.hidden = YES;
    self.locationUserBtn.hidden = YES;
    self.scaleBg.hidden = YES;
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.trailing.leading.equalTo(@0);
        make.height.equalTo(@((HEIGHT-kNavigationBarHeight)*0.4));
    }];
    
    [self.contentView addSubview:self.rollingView];
    
    [self.contentView addSubview:self.findingContentView];
    [self.findingContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.findingContentViewTop = make.top.equalTo(@((HEIGHT-kNavigationBarHeight)*0.4));
        make.trailing.leading.equalTo(@0);
        make.height.equalTo(@(HEIGHT-kNavigationBarHeight));
    }];

    [self.findingContentView addSubview:self.sectionHeaderView];
    [self.sectionHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.trailing.leading.equalTo(@0);
        make.height.equalTo(@32);
    }];
    
    [self.findingContentView addSubview:self.findingTableView];
    [self.findingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@32);
        make.trailing.leading.equalTo(@0);
        make.bottom.equalTo(@-50);
    }];

    [self.customBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.height.equalTo(50+kBottomPadding);
        make.bottom.equalTo(@0);
    }];

    [self.contentView addSubview:self.customShareButtonView];
    [self.customShareButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.customBottomView);
    }];
    self.customShareButtonView.hidden = YES;
}

- (void)configLostData:(BOOL)showHUD {
    __weak G100DevUnderFindingViewController * wself = self;
    
    if (kNetworkNotReachability) {
        [wself showHint:kError_Network_NotReachable];
        return;
    }
    
    if (!self.lostid) {
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
        self.lostid = bikeDomain.lost_id;
    }
    if (showHUD) [self showHudInView:self.contentView hint:@"请稍候"];
    [[G100BikeApi sharedInstance] getBikeLostRecordWithBikeid:self.bikeid lostid:@[[NSNumber numberWithInteger:self.lostid]] callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (showHUD) [wself hideHud];
        if (requestSuccess) {
            G100DevLostListDomain *lostListDomain = [[G100DevLostListDomain alloc]initWithDictionary:response.data];
            if (lostListDomain.lost.count>0) {
                wself.lostDomain = [lostListDomain.lost firstObject];
                [wself.sectionHeaderView setLostMinute:wself.lostDomain.reportminute];
                [wself.rollingView setRollingText:wself.lostDomain.lostdesc];
                [wself.mapView removeAnnotation:wself.lostPositionAnnotation];
                wself.lostPositionAnnotation.coordinate = CLLocationCoordinate2DMake(wself.lostDomain.lostlati, wself.lostDomain.lostlongi);
                wself.lostPositionAnnotation.type = 5;
                
                PositionDomain *lostPosition = [[PositionDomain alloc] init];
                lostPosition.topTitle = [NSString stringWithFormat:@"丢车时间：%@", [NSDate tl_locationTimeParase:wself.lostDomain.losttime]];
                lostPosition.bottomContent = [NSString stringWithFormat:@"丢车位置：%@", wself.lostDomain.lostlocdesc];
                wself.lostPositionAnnotation.positionDomain = lostPosition;
                
                [wself.mapView addAnnotation:wself.lostPositionAnnotation];
                [wself.mapView removeAnnotation:wself.userAnnotation];
                
                wself.lostid = wself.lostDomain.lostid;
                wself.shareid = [wself.lostDomain shareid];
                
                G100BikeFeatureDomain *featureDomain = [[G100InfoHelper shareInstance] findMyBikeFeatureWithUserid:wself.userid bikeid:wself.bikeid];
                [[G100UMSocialHelper shareInstance] loadShareWithShareid:[wself.lostDomain shareid] shareUrl:wself.lostDomain.shareurl sharePic:featureDomain.pictures.firstObject complete:nil];
                
                if (wself.lostDomain.status != 1) {
                    wself.customBottomView.hidden = YES;
                    wself.customShareButtonView.hidden = NO;
                }else {
                    wself.customBottomView.hidden = NO;
                    wself.customShareButtonView.hidden = YES;
                }
                
                if (wself.lostDomain.status == 1) {
                    // 寻车中 显示车辆当前的位置
                    if (wself.devAnnotation == nil) {
                        wself.devAnnotation = [[CustomMAPointAnnotation alloc] init];
                        wself.devAnnotation.type = 3;
                    }
                }else if (wself.lostDomain.status == 2) {
                    // 已找回车辆 添加找回车辆的标注
                    [wself.mapView removeAnnotation:wself.findPositionAnnotation];
                    wself.findPositionAnnotation.coordinate = CLLocationCoordinate2DMake(wself.lostDomain.foundlati, wself.lostDomain.foundlongi);
                    wself.findPositionAnnotation.type = 6;
                    
                    PositionDomain *findPosition = [[PositionDomain alloc] init];
                    findPosition.topTitle = [NSString stringWithFormat:@"找回时间：%@", [NSDate tl_locationTimeParase:wself.lostDomain.foundtime]];
                    findPosition.bottomContent = [NSString stringWithFormat:@"找回位置：%@", wself.lostDomain.foundlocdesc];
                    wself.findPositionAnnotation.positionDomain = findPosition;
                    
                    [wself.mapView addAnnotation:wself.findPositionAnnotation];
                    [wself.mapView removeAnnotation:wself.userAnnotation];
                    [wself.mapView removeAnnotation:wself.devAnnotation];
                    wself.devAnnotation = nil;
                    
                    if (!_hasFitMapViewFindLostAnnotation) {
                        [wself showAllAnnotationsWithEdgeInset:kMapEdgeInset animated:YES];
                        _hasFitMapViewFindLostAnnotation = YES;
                    }
                }
                
                if (!_hasFitMapViewAllAnnotation) {
                    [wself showAllAnnotationsWithEdgeInset:kMapEdgeInset animated:YES];
                    _hasFitMapViewAllAnnotation = YES;
                }
            }
        } else {
            [wself showHint:response.errDesc];
        }
        
    }];
}

- (void)configFindingDataWithRefreshType:(BOOL)isDownPull isShowHud:(BOOL)showHud {
    __weak G100DevUnderFindingViewController * wself = self;
    
    if (kNetworkNotReachability) {
        [wself showHint:kError_Network_NotReachable];
        isDownPull?[self.findingTableView.mj_header endRefreshing]:[self.findingTableView.mj_footer endRefreshing];
        return;
    }
    if (showHud) {
        [self showHudInView:self.contentView hint:@"请稍候"];
    }
    [[G100BikeApi sharedInstance] getFindLostRecordWithBikeid:self.devid lostid:self.lostid page:_kSearchPageNum size:kSearchPageSize callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        isDownPull?[wself.findingTableView.mj_header endRefreshing]:[wself.findingTableView.mj_footer endRefreshing];
        if (requestSuccess) {
            if (!_dataArray) {
                wself.dataArray = [NSMutableArray array];
            }
            if (isDownPull) {
                [wself.dataArray removeAllObjects];
            }
            
            // 提取丢车详细信息
            wself.lostListDomain = [[G100DevFindLostListDomain alloc]initWithDictionary:response.data];
            if (wself.lostListDomain.lostdetail) {
                wself.lostDomain = wself.lostListDomain.lostdetail;
            }
            if (wself.lostListDomain.findlost.count) {
                 [[G100InfoHelper shareInstance] updateMyBikeLastFindRecordWithUserid:self.userid bikeid:self.bikeid lastFindRecord:[wself.lostListDomain.findlost.firstObject mj_keyValues]];
            }
            if (0 == response.total) {
                ((MJRefreshAutoStateFooter*)wself.findingTableView.mj_footer).stateLabel.hidden = YES;
                [wself.findingTableView.mj_footer endRefreshingWithNoMoreData];
                
                [wself.dataArray removeAllObjects];
                [wself.findingTableView reloadData];
            }else{
                if (0 != response.subtotal) {
                    if (response.subtotal == kSearchPageSize) {
                        ((MJRefreshAutoStateFooter*)wself.findingTableView.mj_footer).stateLabel.hidden = NO;
                        [wself.findingTableView.mj_footer resetNoMoreData];
                    }else{
                        [wself.findingTableView.mj_footer endRefreshingWithNoMoreData];
                    }
                    wself.lostListDomain = [[G100DevFindLostListDomain alloc]initWithDictionary:response.data];
                    for (G100DevFindLostDomain * lostDomain in wself.lostListDomain.findlost) {
                        [wself.dataArray addObject:lostDomain];
                    }
                    
                    if (!_timeArray) {
                        _timeArray = [NSMutableArray array];
                    }
                    [_timeArray removeAllObjects];
                    
                    NSString * timeStr;
                    NSMutableArray * eachDayArray = [NSMutableArray array];
                    
                    for (G100DevFindLostDomain * lostDomain in wself.dataArray) {
                        NSString * summaryStr = [lostDomain.time substringToIndex:10];
                        if (!timeStr) {
                            [eachDayArray addObject:lostDomain];
                        }else if ([timeStr isEqualToString:summaryStr]) {
                            [eachDayArray addObject:lostDomain];
                        }else{
                            [wself.timeArray addObject:eachDayArray.copy];
                            [eachDayArray removeAllObjects];
                            [eachDayArray addObject:lostDomain];
                        }
                        timeStr = summaryStr;
                        
                        if (lostDomain == [wself.dataArray lastObject]) {
                            [wself.timeArray addObject:eachDayArray.copy];
                        }
                    }
                    
                    [wself.findingTableView reloadData];
                    
                }else {
                    ((MJRefreshAutoStateFooter*)wself.findingTableView.mj_footer).stateLabel.hidden = YES;
                    [wself.findingTableView.mj_footer endRefreshingWithNoMoreData];
                }

            }
        }else{
            [wself showHint:response.errDesc];
        }
    }];
}

- (void)getFindingTips {
    // 防止其他情况导致 引导提示无法消除
    if (_holedView || _holedView.superview) {
        [self.holedView removeHoles];
        [self.holedView removeFromSuperview];
    }
    
    G100WebViewController * webVc = [[G100WebViewController alloc] initWithNibName:@"G100WebViewController" bundle:nil];
    webVc.httpUrl = [[G100UrlManager sharedInstance] getFindCarTipsUrlWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    [self.navigationController pushViewController:webVc animated:YES];
}

#pragma mark - SectionModeChangedDelegate
- (void)findingSectionHearder:(G100FindingSectionHeaderView *)headerView changeModeBtn:(UIButton *)changeModeBtn {
    if (changeModeBtn.selected) {
        CGRect result = self.findingContentView.bounds;
        result.origin.y = 0;
        result.size.height = HEIGHT - kNavigationBarHeight;
        
        __weak G100DevUnderFindingViewController * wself = self;
        [UIView animateWithDuration:0.6 animations:^{
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI);
            changeModeBtn.transform = rotationTransform;
            self.findingContentView.frame = result;
            if (!changeModeBtn.selected) {
                changeModeBtn.transform = CGAffineTransformIdentity;
                wself.mapView.transform = CGAffineTransformIdentity;
            }
            if (changeModeBtn.selected) {
                [self.findingContentView layoutIfNeeded];
                [self.findingContentView layoutSubviews];
                wself.mapView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                wself.contentView.backgroundColor = [UIColor grayColor];
            }else{
                [self.findingContentView layoutIfNeeded];
                [self.findingContentView layoutSubviews];
                wself.contentView.backgroundColor = [UIColor colorWithHexString:@"EBEBF1"];
            }
        } completion:^(BOOL finished) {
            if (changeModeBtn.selected) {
                wself.findingTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
            }else{
                wself.findingTableView.contentInset = UIEdgeInsetsMake(0, 0, (HEIGHT-kNavigationBarHeight)*0.4+50, 0);
            }
        }];
    }else {
        CGRect result = self.findingContentView.bounds;
        result.origin.y = (HEIGHT-kNavigationBarHeight)*0.4;
        result.size.height = HEIGHT - kNavigationBarHeight - (HEIGHT-kNavigationBarHeight)*0.4;
        
        __weak G100DevUnderFindingViewController * wself = self;
        [UIView animateWithDuration:0.6 animations:^{
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI);
            changeModeBtn.transform = rotationTransform;
            self.findingContentView.frame = result;
            if (!changeModeBtn.selected) {
                changeModeBtn.transform = CGAffineTransformIdentity;
                wself.mapView.transform = CGAffineTransformIdentity;
            }
            if (changeModeBtn.selected) {
                [self.findingContentView layoutIfNeeded];
                [self.findingContentView layoutSubviews];
                wself.mapView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                wself.contentView.backgroundColor = [UIColor grayColor];
            }else{
                [self.findingContentView layoutIfNeeded];
                [self.findingContentView layoutSubviews];
                wself.contentView.backgroundColor = [UIColor colorWithHexString:@"EBEBF1"];
            }
        } completion:^(BOOL finished) {
            if (changeModeBtn.selected) {
                wself.findingTableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
            }else{
                wself.findingTableView.contentInset = UIEdgeInsetsMake(0, 0, (HEIGHT-kNavigationBarHeight)*0.4+50, 0);
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.timeArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *eachDay = self.timeArray[section];
    return eachDay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100DevFindLostDomain * lostDomain = [_timeArray[indexPath.section] safe_objectAtIndex:indexPath.row];
    NSString * cellIdentifier = [G100DevFindingCell identifierForRow:lostDomain];
    G100DevFindingCell * findingCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    __weak G100DevUnderFindingViewController * wself = self;
    findingCell.deleteFindingRecordBlock = ^(NSInteger findlostid){
        [MyAlertView MyAlertWithTitle:@"提示" message:@"是否确认删除此信息？" delegate:wself withMyAlertBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (kNetworkNotReachability) {
                    [wself showHint:kError_Network_NotReachable];
                    return;
                }
                [wself showHudInView:wself.contentView hint:@"请稍候"];
                [[G100BikeApi sharedInstance] deleteFindLostRecordWithBikeid:wself.bikeid lostid:wself.lostid findlostid:findlostid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                    [wself hideHud];
                    if (requestSuccess) {
                        [wself showHint:@"已删除"];
                        NSMutableArray *eachDayArray = [NSMutableArray arrayWithArray:wself.timeArray[indexPath.section]];
                        [eachDayArray removeObjectAtIndex:indexPath.row];
                        [wself.timeArray replaceObjectAtIndex:indexPath.section withObject:eachDayArray.copy];
                        
                        [wself.findingTableView reloadData];
                    }else {
                        [wself showHint:response.errDesc];
                    }
                }];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
    };
    
    [findingCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [findingCell setCellDataWithModel:lostDomain];

    // 只有在寻车状态下 才允许删除自定义的按钮
    if (self.lostDomain.status == 1) {
        findingCell.delFindingBtn.hidden = NO;
    }else {
        findingCell.delFindingBtn.hidden = YES;
    }
    
    return findingCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray * eachDayArray = self.timeArray[section];
    G100DevFindLostDomain * lostDomain = [eachDayArray firstObject];
    return [G100DevFindingSectionHeaderView findingHeaderWithTime:lostDomain.time];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100DevFindLostDomain * lostDomain = [_timeArray[indexPath.section] safe_objectAtIndex:indexPath.row];
    return [G100DevFindingCell heightForRow:lostDomain];
}

#pragma mark - 自定义标签
- (void)tl_bottomButtonClick:(UIButton *)button {
    switch (button.tag) {
        case 100:
        {
            G100DevLostFindResultViewController *findResult = [[G100DevLostFindResultViewController alloc] init];
            findResult.userid = self.userid;
            findResult.bikeid = self.bikeid;
            findResult.devid  = self.devid;
            findResult.lostid = self.lostid;
            [self.navigationController pushViewController:findResult animated:YES];
        }
            break;
        case 200:
        {
            // 重发启事
            G100DevLostInfoViewController *lostInfo = [[G100DevLostInfoViewController alloc] init];
            lostInfo.userid = self.userid;
            lostInfo.bikeid = self.bikeid;
            lostInfo.devid  = self.devid;
            lostInfo.lostid = self.lostid;
            lostInfo.firstPublishTime = self.lostDomain.reporttime;
            [self.navigationController pushViewController:lostInfo animated:YES];
        }
            break;
        case 300:
        {
            G100DevLostNewTagViewController *newTagvc = [[G100DevLostNewTagViewController alloc] init];
            newTagvc.userid = self.userid;
            newTagvc.bikeid = self.bikeid;
            newTagvc.devid  = self.devid;
            newTagvc.lostid = self.lostid;
            [self.navigationController pushViewController:newTagvc animated:YES];
        }
            break;
        case  400:
        {
            /**
             *  需要判断设备状态
             *  如果是已找回，就分享已找回
             *  如果是已理赔，就分享已理赔
             */
            [[G100UMSocialHelper shareInstance] showShareWithShareid:self.shareid];
        }
            break;
        default:
            break;
    }
}

- (void)lostBikeAlarmCome:(NSNotification *)noti {
    [self tl_startReloadMapData];
}

#pragma mark - Over writre
- (void)tl_hasGetDevInfo:(G100DevPositionDomain *)positionDomain {
    if (positionDomain == nil) {
        return;
    }
    if (self.lostDomain.status != 1) {
        return;
    }
    if (!_hasGetDevinfo) {
        [self showAllAnnotationsWithEdgeInset:kMapEdgeInset animated:YES];
        _hasGetDevinfo = YES;
    }
}

- (void)tl_hasGetUserLocationInfo:(MAUserLocation *)userLocation {
    if (!self.userLocationViewHidden) {
        // 控制地图页面随用户方向变化
        // self.mapView.rotationDegree = userLocation.heading.trueHeading;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
