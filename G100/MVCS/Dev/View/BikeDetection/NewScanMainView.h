//
//  NewScanMainView.h
//  G100
//
//  Created by Tilink on 15/3/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100DevTestDomain.h"
#import "G100ScanViewController.h"

typedef enum {
    SecureScrParkLocation    = 1, //停车位置是否安全
    SecureScrTrinSured       = 2, //车辆是否购置盗抢
    SecureScrDisChgcurve     = 3, //行车过程中电瓶放电曲线是否正常
    SecureScrChgCurve        = 4, //电瓶状态充电曲线是否正常
    SecureScrBatteryPower    = 5, //电瓶低电量
    SecureScrTplinSured      = 6, //车辆是否购入第三方责任险
    SecureScrPainsSured      = 7, //车辆是否购人身意外险
    SecureScrControllerFault = 8, //控制器故障
    SecureScrMotorFault      = 9, //电机故障
    SecureScrHallFault       = 10, //霍尔故障
    SecureScrBrakeFault      = 11, //刹车故障
    SecureScrTurnFault       = 12, //转把故障
    SecureScrGPS             = 13, //GPS信号
    SecureScrServiceTerm     = 14, //服务是否即将到期或者已经到期
    SecureScrSecuritySetting = 15, //是否开启设防
    SecureScrRapidAcc        = 16, //驾驶行为\急加速次数
    SecureScrRapidDec        = 17, //驾驶行为\急减速次数
    SecureScrOverSpeed       = 18, //驾驶行为\超速次数
    SecureScrTirewear        = 19, //轮胎磨损程度
    SecureScrBattStatus      = 20, //电瓶健康状态
    SecureScrRideBehavior    = 21, //驾驶行为分析
    SecureScrCommFault       = 22, //控制器与GPS设备通信故障
    SecureScrCtrlVerifyFail  = 23, //控制器验证失败
    SecureScrBikeInfoAdd     = 24, //车辆资料完善
    SecureScrUserInfoAdd     = 25, //个人资料完善
    SecureScrDeviceAdd       = 26, //需要绑定设备
} SecurityScore;

typedef void(^TestOver)();

@interface NewScanMainView : UIView

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

@property (assign, nonatomic) BOOL isPopAppear;
@property (assign, nonatomic) NSInteger scoreNumber;
@property (strong, nonatomic) G100TestResultDomain *testResult;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIView *processView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIView *testAnimationView;
@property (weak, nonatomic) IBOutlet UILabel *currentTestLabel;

@property (copy, nonatomic) TestOver testOverAction;
@property (assign, nonatomic) BOOL isTesting;   // 判断是否正在测试
@property (assign, nonatomic) NSInteger currentIndex;

/** 安全评分结果*/
@property (strong, nonatomic) NSMutableArray *dataArray;

/** 服务器返回分数区间文案详情*/
@property (strong, nonatomic) G100DevTestResultDomain *displayResult;

- (void)setupViewWithOwner:(G100ScanViewController *)owner;

- (void)inAnimation;

- (void)startAnimation;
- (void)endAnimation;

- (void)viewWillAppear;
- (void)viewWillDisappear;
- (void)viewDidAppear;
- (void)viewDidDisappear;

- (void)reloadResult;

@end
