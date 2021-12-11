//
//  CSBBatteryDetailViewController.m
//  G100
//
//  Created by yuhanle on 2016/12/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "CSBBatteryDetailViewController.h"
#import "CSBSmartChargeViewController.h"
#import "CSBEffectiveElecViewController.h"
#import "CSBBatteryCycleViewController.h"

#import "G100BatteryApi.h"
#import "G100BatteryDomain.h"

@interface CSBBatteryDetailViewController () <UIScrollViewDelegate>

/** 选择器 */
@property (strong, nonatomic) UISegmentedControl *segControl;
/** 容器视图 */
@property (strong, nonatomic) UIScrollView *containerView;

@property (strong, nonatomic) CSBSmartChargeViewController *smartChargeVC;
@property (strong, nonatomic) CSBEffectiveElecViewController *effectiveElecVC;
@property (strong, nonatomic) CSBBatteryCycleViewController *batteryCycleVC;

@property (nonatomic, strong) G100BatteryDomain *batteryDomain;

@property (nonatomic, strong) NSTimer *quereyTimer;

@end

@implementation CSBBatteryDetailViewController

- (void)dealloc {
    DLog(@"锂电池主页面销毁");
    
    if ([_quereyTimer isValid]) {
        [_quereyTimer invalidate];
        _quereyTimer = nil;
    }
}

#pragma mark - 网络数据请求
- (void)quereyBatteryInfoWithBatteryid:(NSString *)batteryid callback:(API_CALLBACK)callback showHUD:(BOOL)showHUD animated:(BOOL)animated {
    __weak typeof(self) wself = self;
    __block ApiRequest *request = nil;
    API_CALLBACK resback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself api_removeApiRequest:request];
        
        [wself hideHud];
        if (requestSuccess) {
            G100BatteryDomain *batt = [[G100BatteryDomain alloc] initWithDictionary:response.data];
            
            wself.batteryDomain = batt;
            
            [wself.smartChargeVC setBatteryDomain:batt animated:animated];
            
            wself.effectiveElecVC.batteryDomain = batt;
            wself.batteryCycleVC.batteryDomain = batt;
            
        }else {
            [wself showHint:response.errDesc];
        }
        
        if (callback) {
            callback(statusCode, response, requestSuccess);
        }
    };
    
    request = [[G100BatteryApi sharedInstance] getBatteryInfoWithBatteryid:batteryid callback:resback];
    [self api_addApiRequest:request];
    
    if (showHUD) {
        [self showHudInView:self.view hint:@""];
    }
}

#pragma mark - SegmentControlAction
- (IBAction)segmentControlAction:(UISegmentedControl *)sender {
    NSInteger idx = sender.selectedSegmentIndex;
    CGFloat w = self.containerView.frame.size.width;
    
    if (idx == 0) {
        [self.containerView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (idx == 1) {
        [self.containerView setContentOffset:CGPointMake(w, 0) animated:YES];
    }
    else if (idx == 2) {
        [self.containerView setContentOffset:CGPointMake(w*2, 0) animated:YES];
    }
    
    [self switchToPage:self.segControl.selectedSegmentIndex];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    
    CGFloat w = self.containerView.frame.size.width;
    if (contentOffset.x < w) {
        self.segControl.selectedSegmentIndex = 0;
    }
    else if (contentOffset.x < w*2 && contentOffset.x >= w) {
        self.segControl.selectedSegmentIndex = 1;
    }
    else if (contentOffset.x < w*3 && contentOffset.x >= w*2) {
        self.segControl.selectedSegmentIndex = 2;
    }

    [self switchToPage:self.segControl.selectedSegmentIndex];
}

#pragma mark - Private Method
- (void)switchToPage:(NSInteger)index {
    if (index == 0) {
        [self.smartChargeVC becameActived];
    }else if (index == 1) {
        [self.effectiveElecVC becameActived];
    }else if (index == 2) {
        [self.batteryCycleVC becameActived];
    }
}
- (void)startQuereyBatteryInfo {
    if (!_quereyTimer) {
        _quereyTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                        target:self
                                                      selector:@selector(timerAction)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    
    [_quereyTimer setFireDate:[NSDate distantPast]];
}

- (void)timerAction {
    [self quereyBatteryInfoWithBatteryid:self.batteryid callback:nil showHUD:NO animated:NO];
}

- (void)stopQuereyBatteryInfo {
    if ([_quereyTimer isValid]) {
        [_quereyTimer invalidate];
        _quereyTimer = nil;
    }
}

#pragma mark - setupView
- (void)setupView {
    // 布局顶部选择器
    self.segControl = [[UISegmentedControl alloc] initWithItems:@[@"智能充电", @"有效电量", @"电池循环"]];
    self.segControl.frame = CGRectMake(64, 28, self.view.v_width - 128, 24);
    
    self.segControl.selectedSegmentIndex = 0;
    self.segControl.tintColor= [UIColor whiteColor];
    
    [self.segControl setTitleTextAttributes:@{
                                               NSForegroundColorAttributeName:[UIColor blackColor],
                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0f]
                                               } forState:UIControlStateSelected];
    
    [self.segControl setTitleTextAttributes:@{
                                               NSForegroundColorAttributeName:[UIColor whiteColor],
                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0f]
                                               } forState:UIControlStateNormal];
    
    [self.segControl addTarget:self action:@selector(segmentControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.navigationBarView addSubview:self.segControl];
    
    [self.segControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(kNavigationBarHeight);
        make.centerX.equalTo(self.navigationBarView);
        make.top.equalTo(28);
        make.height.equalTo(@24);
    }];
    
    // 布局容器
    self.containerView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    self.containerView.pagingEnabled = YES;
    self.containerView.delegate = self;
    self.containerView.bounces = NO;
    self.containerView.showsVerticalScrollIndicator = NO;
    self.containerView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    // 添加子控制器
    [self addChildViewController:self.smartChargeVC];
    [self addChildViewController:self.effectiveElecVC];
    [self addChildViewController:self.batteryCycleVC];
    self.smartChargeVC.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    self.smartChargeVC.userid = self.userid;
    self.smartChargeVC.bikeid = self.bikeid;
    self.smartChargeVC.devid = self.devid;
    self.smartChargeVC.batteryid = self.batteryid;
    [self.containerView addSubview:self.smartChargeVC.view];
    
    self.effectiveElecVC.view.frame = CGRectMake(self.containerView.frame.size.width, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    self.effectiveElecVC.userid = self.userid;
    self.effectiveElecVC.bikeid = self.bikeid;
    self.effectiveElecVC.devid = self.devid;
    self.effectiveElecVC.batteryid = self.batteryid;
    [self.containerView addSubview:self.effectiveElecVC.view];
    
    self.batteryCycleVC.view.frame = CGRectMake(self.containerView.frame.size.width*2, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    self.batteryCycleVC.userid = self.userid;
    self.batteryCycleVC.bikeid = self.bikeid;
    self.batteryCycleVC.devid = self.devid;
    self.batteryCycleVC.batteryid = self.batteryid;
    [self.containerView addSubview:self.batteryCycleVC.view];
    
    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width*3, self.containerView.frame.size.height);
}

#pragma mark - Lazy load
- (CSBSmartChargeViewController *)smartChargeVC {
    if (!_smartChargeVC) {
        _smartChargeVC = [[CSBSmartChargeViewController alloc] init];
    }
    return _smartChargeVC;
}

- (CSBEffectiveElecViewController *)effectiveElecVC {
    if (!_effectiveElecVC) {
        _effectiveElecVC = [[CSBEffectiveElecViewController alloc] init];
    }
    return _effectiveElecVC;
}

- (CSBBatteryCycleViewController *)batteryCycleVC {
    if (!_batteryCycleVC) {
        _batteryCycleVC = [[CSBBatteryCycleViewController alloc] init];
    }
    return _batteryCycleVC;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    
    [self quereyBatteryInfoWithBatteryid:self.batteryid callback:nil showHUD:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startQuereyBatteryInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopQuereyBatteryInfo];
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
