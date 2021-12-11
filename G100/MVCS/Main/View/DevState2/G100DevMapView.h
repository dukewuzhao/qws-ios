//
//  G100DevMapView.h
//  G100
//
//  Created by sunjingjing on 16/10/25.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"

@protocol G100CardDevMapViewTapDelegate <NSObject>
@optional
/**
 *  点击push跳转
 *
 *  @param touchedView 被点击的View
 */
- (void)viewTapToPushCardDevMapDetailWithView:(UIView *)touchedView;
@end

@class MAMapView;
@class PositionDomain;
@interface G100DevMapView : G100CardBaseView
@property (strong, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *bindDevNumLabel;
@property(nonatomic,weak) id<G100CardDevMapViewTapDelegate> delegate;
@property (nonatomic, strong) NSArray <PositionDomain *> *positionsArray;
@property (nonatomic, assign) NSInteger deviceCount;
@property (assign, nonatomic) BOOL hasSmartDevice;

+ (CGFloat)heightForItem:(id)item width:(CGFloat)width;

+ (instancetype)loadDevStateView;

/**
 *  即将滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillAppear:(BOOL)animated;
/**
 *  已经滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidAppear:(BOOL)animated;
/**
 *  即将离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillDisappear:(BOOL)animated;
/**
 *  已经离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidDisappear:(BOOL)animated;

@end
