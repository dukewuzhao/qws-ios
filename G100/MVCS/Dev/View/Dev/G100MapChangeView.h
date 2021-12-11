//
//  G100MapChangeView.h
//  G100
//
//  Created by William on 16/8/23.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MapDisplayMode) {
    MapDisplayModeNormal,
    MapDisplayModeSatellite,
    MapDisplayMode3D
};

@class MAMapView;
@interface G100MapChangeView : UIView

@property (assign, nonatomic) CGPoint anchorPoint;
@property (assign, nonatomic) MapDisplayMode mapMode;

@property (copy, nonatomic) void (^viewHideCompletion)();

- (instancetype)initWithMapView:(MAMapView *)mapView position:(CGPoint)position;

- (void)show;

- (void)hide;

@end
