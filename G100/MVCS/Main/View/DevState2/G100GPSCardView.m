//
//  G100GPSCardView.m
//  G100
//
//  Created by sunjingjing on 16/10/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100GPSCardView.h"

@interface G100GPSCardView () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIGestureRecognizer *mapGesture;
@property (nonatomic, weak) IBOutlet UIGestureRecognizer *safeGesture;
@property (nonatomic, weak) IBOutlet UIGestureRecognizer *reportGesture;

@end

@implementation G100GPSCardView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.devMapView = [G100DevMapView loadDevStateView];
    [self.topView addSubview:self.devMapView];
    [self.devMapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.safeSetView = [G100SafeSetView showView];
    [self.middleView addSubview:self.safeSetView];
    [self.safeSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.bikeReportView = [G100BikeReportView showView];
    [self.bottomView addSubview:self.bikeReportView];
    [self.bikeReportView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark - Getter

#pragma mark - Setter
- (void)setPositionsArray:(NSArray<PositionDomain *> *)positionsArray {
    _positionsArray = positionsArray;
    
    [self.devMapView setPositionsArray:positionsArray];
}

- (void)setBikeDomain:(G100BikeDomain *)bikeDomain {
    _bikeDomain = bikeDomain;
    
    // 安防设置
    self.safeSetView.safeMode = bikeDomain.mainDevice.security.mode;
    
    // 用车报告
    
}

- (void)setUnreadMsgCount:(NSInteger)unreadMsgCount {
    _unreadMsgCount = unreadMsgCount;
    
    self.bikeReportView.unreadMsgCount = unreadMsgCount;
}

- (void)setDeviceCount:(NSInteger)deviceCount {
    _deviceCount = deviceCount;
    
    self.devMapView.deviceCount = deviceCount;
}

#pragma mark - Pravite Method
- (IBAction)tapGestureClick:(UIGestureRecognizer *)gesture {
    if (_functionTapAction) {
        if (gesture == self.mapGesture) {
            self.functionTapAction(0);
        }else if (gesture == self.safeGesture) {
            self.functionTapAction(1);
        }else if (gesture == self.reportGesture) {
            self.functionTapAction(2);
        }
    }
}

#pragma mark - Public Method
+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100GPSCardView" owner:nil options:nil] firstObject];
}

+ (CGFloat)heightWithWidth:(CGFloat)width{
    return 160*width/207;
}

@end
