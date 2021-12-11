//
//  Target_OfflineMap.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "Target_OfflineMap.h"
#import "G100AMapOfflineMapViewController.h"

@implementation Target_OfflineMap

- (UIViewController *)Action_nativeFetchOfflineMapViewController:(NSDictionary *)params {
    G100AMapOfflineMapViewController *viewController = [[G100AMapOfflineMapViewController alloc]init];
    return viewController;
}

@end
