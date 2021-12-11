//
//  G100GPSCardView.h
//  G100
//
//  Created by sunjingjing on 16/10/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100DevMapView.h"
#import "G100SafeSetView.h"
#import "G100BikeReportView.h"

@class PositionDomain;
@class G100BikeDomain;
@interface G100GPSCardView : G100CardBaseView

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *middleView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) G100DevMapView *devMapView;
@property (strong, nonatomic) G100SafeSetView *safeSetView;
@property (strong, nonatomic) G100BikeReportView *bikeReportView;

@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@property (nonatomic, strong) NSArray <PositionDomain *> *positionsArray;

@property (assign, nonatomic) NSInteger unreadMsgCount;
@property (assign, nonatomic) NSInteger deviceCount;

@property (copy, nonatomic) void (^functionTapAction)(NSInteger index);

/**
 *  从xib中加载View
 *
 *  @return self
 */
+ (instancetype)showView;
/**
 *  根据View的宽度算出View的高
 *
 *  @param width
 *
 *  @return View的高
 */
+ (CGFloat)heightWithWidth:(CGFloat)width;

@end
