//
//  G100BikeHisTrackDomain.h
//  G100
//
//  Created by yuhanle on 2017/8/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100BikeHisTrackDomain;
@class G100BikeHisSummaryDomain;
@interface G100BikeHisTracksDomain : G100BaseDomain

@property (nonatomic, strong) NSArray <G100BikeHisTrackDomain *> * loc;
@property (nonatomic, strong) G100BikeHisSummaryDomain *summary;
@end

@interface G100BikeHisTrackDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger gpssvs;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) CGFloat lati;
@property (nonatomic, copy) NSString* ts;
@property (nonatomic, assign) CGFloat longi;
@property (nonatomic, assign) NSInteger bssignal;
@property (nonatomic, assign) CGFloat heading;
@property (nonatomic, copy) NSString *desc;
@end

@interface G100BikeHisSummaryDomain : G100BaseDomain
@property (nonatomic, strong) NSString *addr_b;
@property (nonatomic, strong) NSString *addr_e;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) int  time;
@property (nonatomic, strong) NSString *end_time;
@property (nonatomic, assign) int max_speed;
@property (nonatomic, assign) int over_speed_dis;
@property (nonatomic, strong) NSString *begin_time;
@property (nonatomic, assign) int ride_speed;
@property (nonatomic, strong) NSString *remind_content;
@end
