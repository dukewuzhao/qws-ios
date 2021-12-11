//
//  G100TrackSpeedView.h
//  G100
//
//  Created by 曹晓雨 on 2017/8/22.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BikeHisTrackDomain.h"
#import "LineChart.h"

@interface G100TrackSpeedView : UIView

@property (nonatomic, strong) G100BikeHisTracksDomain *hisTracksDomain;

@property (nonatomic, strong) LineChart *lineChart;
@property (nonatomic, assign) CGFloat maxSpeed;

- (void)moveLineWithPoint:(CGPoint)point;

@end
