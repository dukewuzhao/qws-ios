//
//  Target_BikeTrack.m
//  G100
//
//  Created by yuhanle on 16/8/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_BikeTrack.h"
#import "G100AMapTrackViewController.h"

@implementation Target_BikeTrack

- (UIViewController *)Action_nativeFetchBikeTrackViewController:(NSDictionary *)params {
    G100AMapTrackViewController *viewController = [[G100AMapTrackViewController alloc] init];
    viewController.userid = params[@"userid"];
    viewController.bikeid = params[@"bikeid"];
    viewController.devid = params[@"devid"];
    viewController.dayStr = params[@"dayStr"];
    viewController.begintime = params[@"begintime"];
    viewController.endtime = params[@"endtime"];
    return viewController;
}

@end
