//
//  G100CityPickViewController.h
//  G100
//
//  Created by 天奕 on 15/12/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@class G100ServiceCityDomain;
@interface G100CityPickViewController : G100BaseXibVC

@property (strong, nonatomic) NSArray *dataArray;
@property (nonatomic, copy) void (^pickCityComplete)(G100ServiceCityDomain * city, NSIndexPath *indexPath);

@end
