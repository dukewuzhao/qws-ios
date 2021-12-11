//
//  G100CardUserCarlViewController.m
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardUserCarlViewController.h"
#import "G100UserCarView.h"
#import "G100NoCarView.h"
#import "G100BikeManager.h"
#import "G100DevApi.h"
#import "G100Mediator+BikeDetail.h"
#import "G100Mediator+AddBike.h"
#import "G100DeviceDomain.h"
#import "BikeQRCodeView.h"
#import "G100DevDataHandler.h"
#import "G100BikesRuntimeDomain.h"
#import "CDDDataHelper.h"

@interface G100CardUserCarlViewController () <G100AddCarDelegate, G100TapAnimationDelegate, G100ScaleQRCodeDelegate, G100DevDataHandlerDelegate>

@property (nonatomic, strong) G100UserCarView *userCarView;
@property (strong, nonatomic) G100NoCarView   *noCarView;

@property (strong, nonatomic) G100BikeManager *bikeManager;
@property (strong, nonatomic) G100DeviceDomain *deviceDomin;

@property (strong, nonatomic) G100DevDataHandler *dataHandler;
@property (strong, nonatomic) G100BikesRuntimeDomain *bikesRuntimeDomain;

@property (assign, nonatomic) BOOL isBike;
@property (assign, nonatomic) BOOL isDevice;

@end

@implementation G100CardUserCarlViewController

- (void)dealloc {
    DLog(@"UserCar 已经销毁");
    
    _dataHandler.delegate = nil;
    _dataHandler = nil;
}

- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    self.bikeDomain = cardModel.bike;
    
    [self differIsBikeAndisDevice];
}

#pragma mark - Private method
- (void)differIsBikeAndisDevice {
    if ([self.bikeid isEqualToString:@"0"] || self.bikeid == nil) {
        self.isBike = NO;
        self.isDevice = NO;
    }else {
        self.isBike = YES;
        self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
        if (!self.bikeDomain) {
            if (self.dataHandler) {
                [self.dataHandler removeConcern];
                self.dataHandler.delegate = nil;
            }
            self.bikeid = nil;
            self.isBike = NO;
            self.isDevice = NO;
            return;
        }else {
            self.bikeid = [NSString stringWithFormat:@"%ld",(long)self.bikeDomain.bike_id];
        }
        if (self.bikeDomain.gps_devices.count > 0) {
            self.isDevice = YES;
        }else {
            self.isDevice = NO;
        }
    }
    
    if (!self.isBike) {
        self.noCarView.delegate = self;
        
        if (![self.noCarView superview]) {
            [self.view addSubview:self.noCarView];
            [self.noCarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
        }
        
        if (_userCarView && [_userCarView superview]) {
            [_userCarView removeFromSuperview];
            _userCarView = nil;
        }
    }else {
        if (![self.userCarView superview]) {
            [self.view addSubview:self.userCarView];
            [self.userCarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
        }
        
        if (_noCarView && [_noCarView superview]) {
            [_noCarView removeFromSuperview];
            _noCarView = nil;
        }
        
        if (!self.isDevice) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.userCarView updateViewOfNoDevice];
            });
        }else {
            [self.userCarView updateViewOfAddedDevice];
        }
        
        [self initBikeData];
    }
}

- (void)getRuntimeDataNowIsAnimate:(BOOL)isAnimate {
    __weak G100CardUserCarlViewController * wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.dataHandler concernNow:nil];
    });
}

- (void)initBikeData {
    [self.bikeManager getBikeModelWithData:self.bikeDomain compete:^(G100BikeModel *bikeModel) {
        _userCarView.bikeModel = bikeModel;
    }];
    
    if (self.bikeDomain) {
        self.bikeid = [NSString stringWithFormat:@"%ld",(long)self.bikeDomain.bike_id];
    }
}

#pragma mark - Lazy load
- (G100UserCarView *)userCarView {
    if (!_userCarView) {
        _userCarView = [G100UserCarView showView];
        _userCarView.leftClickedView.delegate = self;
        _userCarView.clickedAniView.delegate = self;
        _userCarView.delegate = self;
    }
    return _userCarView;
}

-(G100NoCarView *)noCarView
{
    if (!_noCarView) {
        _noCarView = [G100NoCarView showView];
    }
    return _noCarView;
}
-(G100BikeManager *)bikeManager
{
    if (!_bikeManager) {
        _bikeManager = [[G100BikeManager alloc] init];
    }
    return _bikeManager;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册光观察者
    _dataHandler = [[G100DevDataHandler alloc] initWithUserid:self.userid bikeid:self.bikeid];
    _dataHandler.delegate = self;
    
    // 布局
    [self differIsBikeAndisDevice];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self differIsBikeAndisDevice];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 出现/消失
- (void)mdv_viewDidAppear:(BOOL)animated {
    [super mdv_viewDidAppear:animated];
    
}

- (void)mdv_viewDidDisappear:(BOOL)animated {
    [super mdv_viewDidDisappear:animated];
    
}

#pragma mark - G100DevDataHandlerDelegate
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    if (response.errCode == 0) {
        self.bikesRuntimeDomain = [[G100BikesRuntimeDomain alloc] initWithDictionary:response.data];
        for (G100BikeRuntimeDomain *runtime in self.bikesRuntimeDomain.runtime) {
            if (self.bikeid.integerValue == runtime.bike_id) {
                //刷新UI
                self.userCarView.bikeModel.soc = runtime.batt_soc * 100;
                self.userCarView.bikeModel.expecteddistance = runtime.expected_distance;
                self.userCarView.bikeModel.eleDoorState = runtime.acc == 1 ? YES : NO;
                if (!self.hasAppear) {
                    [self.userCarView beginAnimateWithIsAnimate:YES];
                    self.hasAppear = YES;
                }else {
                    [self.userCarView beginAnimateWithIsAnimate:NO];
                }
            }
        }
    }
}

#pragma mark - G100AddCarDelegate
-(void)buttonClickedToAddCar:(UIButton *)button {
    [[G100Mediator sharedInstance] G100Mediator_viewControllerForAddBike:self.userid loginHandler:^(UIViewController *viewController, BOOL loginSuccess) {
        if (viewController && loginSuccess) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

#pragma mark - G100TapAnimationDelegate
-(void)viewTouchedEndWithView:(UIView *)touchedView touchPoint:(CGPoint)point {
    CGPoint clickPoint = [touchedView convertPoint:point toView:self.userCarView.clickedAniView];
    if ([touchedView isKindOfClass:[G100UserCarView class]]) {
        if (CGRectContainsPoint(self.userCarView.clickedAniView.bounds, clickPoint) && !self.userCarView.clickedAniView.hidden) {
            [self getRuntimeDataNowIsAnimate:YES];
        }
        return;
    }
}

- (void)viewTouchedToPushWithView:(UIView *)touchedView touchPoint:(CGPoint)point {
    CGPoint clickPoint = [touchedView convertPoint:point toView:self.userCarView.clickedAniView];
    if ([touchedView isKindOfClass:[G100UserCarView class]]) {
        if (CGRectContainsPoint(self.userCarView.clickedAniView.bounds, clickPoint) && !self.userCarView.clickedAniView.hidden) {
            dispatch_async(dispatch_get_main_queue(), ^{
                return;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *bikeDetail = [[G100Mediator sharedInstance] G100Mediator_viewControllerForBikeDetail:self.userid
                                                                                                                bikeid:self.bikeid];
                [self.navigationController pushViewController:bikeDetail animated:YES];
            });
        }
    }
}

- (void)buttonClickedToScaleQRCode:(UIButton *)button {
    BikeQRCodeView *qrView = [BikeQRCodeView loadViewFromNibWithTitle:@"扫描车辆二维码绑定"
                                                               qrcode:[NSString stringWithFormat:@"%@", self.bikeDomain.add_url]];
    [qrView showInVc:self view:self.view.window animation:YES];
}

@end
