//
//  G100TrackingFunctionView.m
//  G100
//
//  Created by William on 16/7/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100TrackingFunctionView.h"
#import "G100DevInfoView.h"
#import "G100TFCollectionViewCell.h"
#import "G100FlowServiceCell.h"
#import "G100BikeDomain.h"
#import "G100DeviceDomain.h"
#import "G100BikesRuntimeDomain.h"
#import "G100ToastLabel.h"

NSString * TFDuiMaTongxinFaultToast = @"车辆设备通信故障，请立即检查。";
NSString * TFDuiMaDuiMaFaultToast   = @"车辆控制器验证失败，请立即检查。";

NSString * TFDuiMaSuodingToast      = @"车辆处于断电状态，无法启动。";
NSString * TFDuiMaUnSuodingToast    = @"已开启供电，车辆恢复正常启动状态。";
NSString * TFDuiMaSuodingIngToast   = @"正在远程断电，受车辆网络环境影响，该过程可能需要几分钟，请耐心等待。";
NSString * TFDuiMaUnSuodingIngToast = @"正在恢复供电，受车辆网络环境影响，该过程可能需要几分钟，请耐心等待。";

NSString * TFCaseSolvingNoticeToast     = @"保险车辆的整车盗抢险已进入破案流程，如在此期间找回被盗车辆可点击\"恢复供电\"";
NSString * TFCaseClaimingNoticeToast    = @"保险车辆的整车盗抢险已进入理赔流程，如找回被盗车辆联系保险公司进行消案处理，再联系骑卫士客服执行\"恢复供电\"程序";
NSString * TFCaseCompensatedNoticeToast = @"保险车辆的整车盗抢险赔款已经支付到您的银行帐户中，系统默认启动了“远程断电”程序。如找回被盗车辆请联系保险公司或理赔专员处理相关事宜";

NSString * TFDuiMaSuodingText   = @"远程断电";
NSString * TFDuiMaUnSuodingText = @"开启供电";

#define kFunctionViewBGColor  [UIColor whiteColor]
#define kFunctionViewLineColor  [UIColor colorWithHexString:@"#cecece"]
#define kFunctionViewCollectionBackgroudColor  [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]

@interface G100TrackingFunctionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, G100TFCollectionViewCellDelegate, G100FlowServieCellDelegate>

@property (strong, nonatomic) UICollectionView * functionCollectionView;

@property (strong, nonatomic) G100DevInfoView * devInfoView;

@property (strong, nonatomic) UIButton * moveBtn;

@property (strong, nonatomic) NSMutableArray * functionArray;

@property (strong, nonatomic) UIView * backgroundView;

@property (assign, nonatomic) NSInteger left_days;

@property (strong, nonatomic) G100ToastLabel * toastLabel;

@property (strong, nonatomic) MASConstraint * functionViewMasHeight;

@property (strong, nonatomic) MASConstraint * contrainerViewMasHeight;

@property (assign, nonatomic) NSInteger rowCount;

@property (strong, nonatomic) NSMutableDictionary *cellIdentifierDict;

@end

@implementation G100TrackingFunctionView

#pragma mark - lazy loading
- (UIButton *)moveBtn {
    if (!_moveBtn) {
        _moveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moveBtn setBackgroundColor:[UIColor whiteColor]];
        [_moveBtn setImage:[UIImage imageNamed:@"ic_gps_uparrow"] forState:UIControlStateNormal];
        [_moveBtn addTarget:self action:@selector(flexViewAction:) forControlEvents:UIControlEventTouchUpInside];
        _moveBtn.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _moveBtn.layer.shadowOffset = CGSizeMake(0, -3);
        _moveBtn.layer.shadowOpacity = 0.6;
        _moveBtn.layer.shadowRadius = 3;
        _moveBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
       
    }
    return _moveBtn;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:self.superview.bounds];
        _backgroundView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(collectFunctionView:)];
        [_backgroundView addGestureRecognizer:tap];
    }
    return _backgroundView;
}

- (G100DevInfoView *)devInfoView {
    if (!_devInfoView) {
        _devInfoView = [G100DevInfoView loadDevInfoView];
    }
    return _devInfoView;
}

- (UICollectionView *)functionCollectionView {
    if (!_functionCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _functionCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _functionCollectionView.delegate = self;
        _functionCollectionView.dataSource = self;
        _functionCollectionView.bounces = NO;
        _functionCollectionView.scrollEnabled = NO;
        _functionCollectionView.showsVerticalScrollIndicator = NO;
        _functionCollectionView.showsHorizontalScrollIndicator = NO;
        _functionCollectionView.backgroundColor = kFunctionViewCollectionBackgroudColor;
        
        [_functionCollectionView registerClass:[G100FlowServiceCell class]
                    forCellWithReuseIdentifier:@"flowservice"];
    }
    return _functionCollectionView;
}

- (NSMutableArray *)functionArray {
    if (!_functionArray) {
        _functionArray = [[NSMutableArray alloc] init];
    }
    return _functionArray;
}

- (void)setBattery:(CGFloat)battery {
    _battery = battery;
    [self.devInfoView setBattery:battery];
}

- (void)setDistance:(CGFloat)distance {
    _distance = distance;
    [self.devInfoView setDistance:distance];
}

- (void)setAccState:(BOOL)accState {
    _accState = accState;
    [self.devInfoView setAccState:accState];
}

- (void)setSuoDingStyle:(MyCarSuoDingStyle)suoDingStyle {
    _suoDingStyle = suoDingStyle;
    [self updateSuodingStatusLabelWithSuodingStyle:suoDingStyle];
}

- (void)updateSuodingStatusLabelWithSuodingStyle:(MyCarSuoDingStyle)suoDingStyle {
    if (!_toastLabel) {
        self.toastLabel = [[G100ToastLabel alloc]init];
        _toastLabel.userInteractionEnabled = YES;
        _toastLabel.numberOfLines = 0;
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.textColor = [UIColor whiteColor];
        _toastLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _toastLabel.layer.cornerRadius = 8.0f;
        _toastLabel.layer.masksToBounds = YES;
        _toastLabel.textInsets = UIEdgeInsetsMake(14, 16, 14, 16);
        
        [self.superview insertSubview:_toastLabel aboveSubview:self];
        [self.toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.right.equalTo(@-20);
            make.bottom.equalTo(self.mas_top).with.offset(@-12);
        }];
    }
    switch (suoDingStyle) {
        case DuiMaUnSuoDingMyCarStyle:
        {
            self.toastLabel.text = TFDuiMaUnSuodingToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"2db500"];/* 绿色 */
            [UIView animateWithDuration:5.0f animations:^{
                self.toastLabel.alpha = 0;
            }];
        }
            break;
        case DuiMaSuoDingMyCaringStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFDuiMaSuodingIngToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ff7200"];/* 橙色 */
        }
            break;
        case DuiMaSuoDingMyCarStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFDuiMaSuodingToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ee1515"];/* 红色 */
        }
            break;
        case DuiMaUnSuoDingMyCaringStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFDuiMaUnSuodingIngToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ff7200"];
        }
            break;
        case DuiMaTongxinFaultStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFDuiMaTongxinFaultToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ee1515"];
        }
            break;
        case DuiMaDuiMaFaultStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFDuiMaDuiMaFaultToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ee1515"];
        }
            break;
        case caseSolvingNoticeStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFCaseSolvingNoticeToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ff7200"];
        }
            break;
        case caseClaimingNoticeStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFCaseClaimingNoticeToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ff7200"];
        }
            break;
        case caseCompensatedNoticeStyle:
        {
            self.toastLabel.alpha = 1.0f;
            self.toastLabel.text = TFCaseCompensatedNoticeToast;
            self.toastLabel.backgroundColor = [UIColor colorWithHexString:@"ff7200"];
        }
            break;
        default:
            break;
    }
    
    CGSize labelSize = [self.toastLabel.text calculateSize:CGSizeMake(WIDTH-2*20-2*16, 999) font:self.toastLabel.font];
    CGFloat height = labelSize.height + 28;
    [self.toastLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(height);
    }];
}

- (void)configDataWithBikeDomain:(G100BikeDomain *)bikeDomain devDomain:(G100DeviceDomain *)devDomain bikesRuntimeDomain:(G100BikesRuntimeDomain *)bikesRuntimeDomain {
    _bikeDomain = bikeDomain;
    _devDomain = devDomain;
    _bikesRuntimeDomain = bikesRuntimeDomain;
    
    // 配置提示文案
    BOOL isG500 = self.devDomain.isG500Device;
    BOOL isMotoBike = self.bikeDomain.isMOTOBike;
    
    TFDuiMaSuodingToast   = isMotoBike ? @"车辆处于远程断电状态，无法启动。" : isG500 ? @"当您的车辆停止骑行时，车辆将进入设防状态，直至远程解锁后恢复正常。" : @"车辆处于断电状态，无法启动。";
    TFDuiMaUnSuodingToast = isMotoBike ? @"车辆已开启供电，可以正常骑行。" : isG500 ? @"车辆已远程解锁，可以正常骑行。" : @"已开启供电，车辆恢复正常启动状态。";
    TFDuiMaSuodingIngToast   = isMotoBike ? @"正在远程断电，受网络环境影响，该过程可能需要几分钟，请耐心等待" : isG500 ? @"正在远程锁车，受车辆网络环境影响，该过程可能需要几分钟，请耐心等待。" : @"正在远程断电，受车辆网络环境影响，该过程可能需要几分钟，请耐心等待。";
    TFDuiMaUnSuodingIngToast = isMotoBike ? @"正在开启供电，受网络环境影响，该过程可能需要几分钟，请耐心等待" : isG500 ? @"正在远程解锁，受车辆网络环境影响，该过程可能需要几分钟，请耐心等待，可以尝试开关电门以加快进程" : @"正在恢复供电，受车辆网络环境影响，该过程可能需要几分钟，请耐心等待。";
    
    TFCaseSolvingNoticeToast     = isG500 ? @"保险车辆的整车盗抢险已进入破案流程，如在此期间找回被盗车辆可点击\"远程解锁\"。" : @"保险车辆的整车盗抢险已进入破案流程，如在此期间找回被盗车辆可点击\"恢复供电\"。";
    TFCaseClaimingNoticeToast    = isG500 ? @"保险车辆的整车盗抢险已进入理赔流程，如找回被盗车辆联系保险公司进行消案处理，再联系骑卫士客服执行\"远程解锁\"程序。" : @"保险车辆的整车盗抢险已进入理赔流程，如找回被盗车辆联系保险公司进行消案处理，再联系骑卫士客服执行\"恢复供电\"程序。";
    TFCaseCompensatedNoticeToast = isG500 ? @"保险车辆的整车盗抢险赔款已经支付到您的银行帐户中，系统默认启动了\"远程锁车\"程序。如找回被盗车辆请联系保险公司或理赔专员处理相关事宜。" : @"保险车辆的整车盗抢险赔款已经支付到您的银行帐户中，系统默认启动了\"远程断电\"程序。如找回被盗车辆请联系保险公司或理赔专员处理相关事宜。";
    
    TFDuiMaSuodingText   = isMotoBike ? @"远程断电" : isG500 ? @"远程锁车" : @"远程断电";
    TFDuiMaUnSuodingText = isMotoBike ? @"开启供电" : isG500 ? @"远程解锁" : @"开启供电";
    
    self.left_days = devDomain.service.left_days;
    
    [self.functionArray removeAllObjects];
    
    [_functionArray addObject:[G100RTCommandModel rt_commandModelWithTitle:@"用车报告" image:@"gps_bikereport" command:2]];
    
    // 远程供断电 仅支持主用户操作
    if (self.bikeDomain.isMaster) {
        for (G100DeviceDomain *devDomain in self.bikeDomain.gps_devices) {
            if (devDomain.func.remote_power == 1) {
                if (self.bikesRuntimeDomain) {
                    for (G100BikeRuntimeDomain * bikeRuntimeDomain in self.bikesRuntimeDomain.runtime) {
                        if (bikeRuntimeDomain.bike_id == bikeDomain.bike_id) {
                            BOOL hasFault = NO;
                            BOOL hasDuimaFault = NO;
                            //BOOL hasTongxinFault = NO;
                            
                            // 保险优先级最高 其次 故障 再然后车辆锁定状态
                            if ([bikeRuntimeDomain.fault_code hasContainString:@"194"]) {
                                hasFault = YES;
                                hasDuimaFault = YES;
                                self.suoDingStyle = DuiMaDuiMaFaultStyle;
                            }else if ([bikeRuntimeDomain.fault_code hasContainString:@"193"]) {
                                hasFault = YES;
                                //hasTongxinFault = YES;
                            }
                            
                            if (bikeRuntimeDomain.theft_insurance.integerValue != 4 &&
                                bikeRuntimeDomain.theft_insurance.integerValue != 5) {
                                if (!hasFault) {
                                    if (self.suoDingStyle != bikeRuntimeDomain.controller_status) {
                                        self.suoDingStyle = bikeRuntimeDomain.controller_status;
                                    }
                                }
                                
                                G100RTCommandModel * model = [[G100RTCommandModel alloc] init];
                                switch (bikeRuntimeDomain.controller_status) {
                                    case DuiMaUnSuoDingMyCarStyle:
                                    case DuiMaSuoDingMyCaringStyle:
                                    {
                                        NSString *iconName = @"gps_power_off";
                                        if (self.bikeDomain.isMOTOBike) {
                                            iconName = @"ic_moto_off";
                                        }
                                        
                                        model = [G100RTCommandModel rt_commandModelWithTitle:TFDuiMaSuodingText image:iconName command:5];
                                    }
                                        break;
                                    case DuiMaSuoDingMyCarStyle:
                                    case DuiMaUnSuoDingMyCaringStyle:
                                    {
                                        NSString *iconName = @"gps_power_on";
                                        if (self.bikeDomain.isMOTOBike) {
                                            iconName = @"ic_moto_on";
                                        }
                                        
                                        model = [G100RTCommandModel rt_commandModelWithTitle:TFDuiMaUnSuodingText image:iconName command:5];
                                    }
                                        break;
                                    default:
                                        break;
                                }
                                
                                model.rt_enable = !hasDuimaFault;
                                [_functionArray addObject:model];
                            }
                            
                            if (bikeRuntimeDomain.theft_insurance.integerValue == 3) {
                                self.suoDingStyle = caseSolvingNoticeStyle;
                            }else if (bikeRuntimeDomain.theft_insurance.integerValue == 4) {
                                self.suoDingStyle = caseClaimingNoticeStyle;
                            }else if (bikeRuntimeDomain.theft_insurance.integerValue == 5) {
                                self.suoDingStyle = caseCompensatedNoticeStyle;
                            }
                        }
                    }
                }
                break;
            }
        }
    }
    
    if (self.bikeDomain.isMaster) {
        for (G100DeviceDomain *devDomain in self.bikeDomain.gps_devices) {
            if (devDomain.func.alertor.remote_ctrl == 1) {
                [_functionArray addObject:[G100RTCommandModel rt_commandModelWithTitle:@"远程遥控" image:@"gps_remote_ctrl" command:3]];
                break;
            }
        }
    }
    
    [_functionArray addObject:[G100RTCommandModel rt_commandModelWithTitle:@"购买服务" image:@"gps_service" command:6]];
    [_functionArray addObject:[G100RTCommandModel rt_commandModelWithTitle:@"安防设置" image:devDomain.securityModeResourceImageName command:1]];
    [_functionArray addObject:[G100RTCommandModel rt_commandModelWithTitle:@"设备管理" image:@"gps_set" command:7]];
    
    if ([self.bikeDomain.is_master integerValue] == 1) {
        [_functionArray addObject:[G100RTCommandModel rt_commandModelWithTitle:@"帮我找车" image:@"ic_helpfind" command:4]];
    }
    
    NSInteger remaindCount = self.functionArray.count%4 == 0 ? 0 : 4 - self.functionArray.count%4;
    for (NSInteger i = 0; i < remaindCount; i++) {
        [_functionArray addObject:[G100RTCommandModel rt_commandEmpty]];
    }
    
    NSInteger rowCount = self.functionArray.count/4 + (self.functionArray.count%4 == 0 ? 0 : 1);
    self.rowCount = rowCount;
    
    if (self.flexState == FlexStateAjar) {
        [self.functionCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.functionViewMasHeight = make.height.equalTo(ITEM_HEIGHT * rowCount);
        }];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT+ITEM_HEIGHT);
        }];
        
        [self layoutIfNeeded];
    }else if (self.flexState == FlexStateOpen) {
        // 调整视图的高度
        [self.functionCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.functionViewMasHeight = make.height.equalTo(ITEM_HEIGHT * rowCount);
        }];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.isShowBikeInfo) {
                self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT+ITEM_HEIGHT*self.rowCount+INFO_HEIGHT);
            } else {
                self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT+ITEM_HEIGHT*self.rowCount);
            }
        }];
        
        [self layoutIfNeeded];
    }else if (self.flexState == FlexStateClose) {
        [self.functionCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.functionViewMasHeight = make.height.equalTo(ITEM_HEIGHT * rowCount);
        }];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT);
        }];
        
        [self layoutIfNeeded];
    }else {
        
    }
    
    [self.functionCollectionView reloadData];
}

#pragma mark - init & setup
- (instancetype)initWithShowBikeInfo:(BOOL)isShowBikeInfo {
    if (self = [super init]) {
        [self setupWithShowBikeInfo:isShowBikeInfo];
        [self configView];
    }
    
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8.0f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5f;
}

- (void)setupWithShowBikeInfo:(BOOL)isShowBikeInfo {
    self.rowCount = 2;
    self.flexState = FlexStateAjar;
    self.isShowBikeInfo = isShowBikeInfo;
    
    if (isShowBikeInfo) {
        [self addSubview:self.functionCollectionView];
        [self addSubview:self.devInfoView];
        [self addSubview:self.moveBtn];
        
        [self.functionCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(@0);
            self.functionViewMasHeight = make.height.equalTo(ITEM_HEIGHT * self.rowCount);
        }];
        [self.devInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.functionCollectionView.mas_bottom);
            make.left.right.equalTo(@0);
            make.height.equalTo(72);
        }];
        [self.moveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(BTN_HEIGHT);
        }];
    } else {
        [self addSubview:self.functionCollectionView];
        [self addSubview:self.moveBtn];
        
        [self.functionCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(@0);
            self.functionViewMasHeight = make.height.equalTo(ITEM_HEIGHT * self.rowCount);
        }];
        [self.moveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(BTN_HEIGHT);
        }];
    }
}

#pragma mark - action
- (void)flexViewAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self flexFunctionViewWithState:sender.selected];
}

- (void)collectFunctionView:(UITapGestureRecognizer *)recognizer {
    [self flexFunctionViewWithState:NO];
    self.moveBtn.selected = NO;
}

- (void)flexFunctionViewWithState:(BOOL)state {
    if (state) {
        _flexState = FlexStateOpen;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.isShowBikeInfo) {
                self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT+ITEM_HEIGHT*self.rowCount+INFO_HEIGHT);
            } else {
                self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT+ITEM_HEIGHT*self.rowCount);
            }
        }];
    }else{
        _flexState = FlexStateClose;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT);
        }];
    }
    
    [self.superview insertSubview:self.backgroundView belowSubview:self];
    
    [UIView animateWithDuration:DURATION animations:^{
        [self layoutIfNeeded];
        [self.toastLabel.superview layoutIfNeeded];
        self.backgroundView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:state?.7f:0];
        self.moveBtn.imageView.transform = CGAffineTransformRotate(self.moveBtn.imageView.transform, (state ? -180.1 : 180.1) * M_PI/180.0);
    } completion:^(BOOL finished) {
        if (!state) {
            [self.backgroundView removeFromSuperview];
        }else{
            [self.functionCollectionView reloadData];
        }
    }];
}

- (void)hideFunctionView {
    if (self.v_height > BTN_HEIGHT) {
        _flexState = FlexStateClose;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            self.contrainerViewMasHeight = make.height.equalTo(BTN_HEIGHT);
        }];
        [UIView animateWithDuration:DURATION animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void)regulateLayout {
    if (!_toastLabel) {
        _toastLabel = [[G100ToastLabel alloc] init];
        _toastLabel.userInteractionEnabled = YES;
        _toastLabel.numberOfLines = 0;
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.textColor = [UIColor whiteColor];
        _toastLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _toastLabel.layer.cornerRadius = 8.0f;
        _toastLabel.layer.masksToBounds = YES;
        _toastLabel.textInsets = UIEdgeInsetsMake(14, 16, 14, 16);
        
        [self.superview insertSubview:_toastLabel aboveSubview:self];
        [self.toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@20);
            make.right.equalTo(@-20);
            make.bottom.equalTo(self.mas_top).with.offset(@-12);
        }];
    }
}

- (NSMutableDictionary *)cellIdentifierDict {
    if (!_cellIdentifierDict) {
        _cellIdentifierDict = [[NSMutableDictionary alloc] init];
    }
    return _cellIdentifierDict;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.functionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    G100RTCommandModel *model = [self.functionArray safe_objectAtIndex:indexPath.row];
    
    if ([model.rt_title isEqualToString:@"流量充值"]) {
        G100FlowServiceCell *viewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flowservice" forIndexPath:indexPath];
        [viewCell setLeft_days:self.left_days];
        viewCell.rtCommand = model;
        viewCell.indexPath = indexPath;
        viewCell.delegate = self;
        viewCell.backgroundColor = kFunctionViewBGColor;
        return viewCell;
    }else {
        NSString *commonKey = [NSString stringWithFormat:@"function-%@-%@", @(indexPath.section), @(indexPath.row)];
        NSString *identifier = [self.cellIdentifierDict objectForKey:commonKey];
        if (identifier == nil) {
            identifier = commonKey;
            [self.cellIdentifierDict setValue:identifier forKey:commonKey];
            [self.functionCollectionView registerClass:[G100TFCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        }
        
        G100TFCollectionViewCell *viewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if (!viewCell) {
            viewCell = [[G100TFCollectionViewCell alloc] init];
        }
        
        viewCell.rtCommand = model;
        viewCell.indexPath = indexPath;
        viewCell.delegate = self;
        viewCell.backgroundColor = kFunctionViewBGColor;
        
        return viewCell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if ([_delegate respondsToSelector:@selector(trackingFunctionView:didSelected:)]) {
        G100RTCommandModel *model = [self.functionArray safe_objectAtIndex:indexPath.row];
        [self.delegate trackingFunctionView:self didSelected:model];
    }
     */
}

#pragma mark - G100TFCollectionViewCellDelegate
- (void)cellDidTapped:(G100TFCollectionViewCell *)viewCell indexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(trackingFunctionView:didSelected:)]) {
        G100RTCommandModel *model = [self.functionArray safe_objectAtIndex:indexPath.row];
        [self.delegate trackingFunctionView:self didSelected:model];
    }
}
#pragma mark - G100FlowServiceCellDelegate
- (void)flowServieCellDidTapped:(G100FlowServiceCell *)viewCell indexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(trackingFunctionView:didSelected:)]) {
        G100RTCommandModel *model = [self.functionArray safe_objectAtIndex:indexPath.row];
        [self.delegate trackingFunctionView:self didSelected:model];
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

@end
