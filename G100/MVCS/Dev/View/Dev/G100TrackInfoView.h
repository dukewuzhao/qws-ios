//
//  G100TrackInfoView.h
//  G100
//
//  Created by 曹晓雨 on 2017/8/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BikeHisTrackDomain.h"

typedef void(^MaxSpeedBtnClicked)();
@interface G100TrackInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *maxSpeedBtn;
@property (weak, nonatomic) IBOutlet UILabel *overSpeedDistanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedHintLabel;
@property (nonatomic, strong) G100BikeHisSummaryDomain *summaryDomain;
@property (nonatomic, assign) CGFloat maxSpeed;

@property (nonatomic, copy) MaxSpeedBtnClicked maxSpeedBtnClicked;
@property (nonatomic, assign) BOOL overSpeedOpen;
+ (instancetype)loadXibView;

@end
