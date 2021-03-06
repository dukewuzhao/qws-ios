//
//  G100ShopApi.m
//  G100
//
//  Created by 温世波 on 15/12/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100ShopApi.h"

@implementation G100ShopApi

+ (instancetype)sharedInstance {
    static G100ShopApi *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (ApiRequest *)getPlaceNearbyShopWithLocation:(NSArray *)location
                                  type:(G100ShopType)type
                                sortBy:(G100ShopSortbyMode)sortby
                              sorttype:(G100ShopSorttypeDirection)sorttype
                                radius:(NSInteger)radius
                                  page:(NSInteger)page
                                  size:(NSInteger)size
                              callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"longi" : location[0],
                                                           @"lati" : location[1],
                                                           @"type" : [NSNumber numberWithInteger:type],
                                                           @"sortby" : [NSNumber numberWithInteger:sortby],
                                                           @"sorttype" : [NSNumber numberWithInteger:sorttype],
                                                           @"radius" : [NSNumber numberWithInteger:radius],
                                                           @"page" : [NSNumber numberWithInteger:page],
                                                           @"size" : [NSNumber numberWithInteger:size]
                                                           }];
    return [G100ApiHelper postApi:@"app/placenearby" andRequest:request callback:callback];
}

- (ApiRequest *)getServiceCityWithListts:(NSString *)listts callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"listts" : EMPTY_IF_NIL(listts) }];
    return [G100ApiHelper postApi:@"app/servicecity" andRequest:request callback:callback];
}

- (ApiRequest *)getCityDistrictWithAdcode:(NSString *)adcode callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"adcode" : EMPTY_IF_NIL(adcode) }];
    return [G100ApiHelper postApi:@"app/citydistrict" andRequest:request callback:callback];
}

- (ApiRequest *)searchPlaceWithSearchtype:(G100ShopSearchMode)searchtype
                         searchwd:(NSString *)searchwd
                         location:(NSArray *)location
                           adcode:(NSString *)adcode
                             type:(NSArray *)type
                           sortby:(G100ShopSortbyMode)sortby
                         sorttype:(G100ShopSorttypeDirection)sorttype
                           radius:(NSInteger)radius
                             page:(NSInteger)page
                             size:(NSInteger)size
                         callback:(API_CALLBACK)callback {
    NSNumber *longi = location[0] ? location[0] : [NSNumber numberWithDouble:121.39098741];
    NSNumber *lati = location[1] ? location[1] : [NSNumber numberWithDouble:31.16866265];
    ApiRequest *requset = [ApiRequest requestWithBizData:@{
                                                           @"searchtype" : [NSNumber numberWithInteger:searchtype],
                                                           @"searchwd" : EMPTY_IF_NIL(searchwd),
                                                           @"longi" : longi,
                                                           @"lati" : lati,
                                                           @"adcode" : EMPTY_IF_NIL(adcode),
                                                           @"type" : type ? : @[],
                                                           @"sortby" : [NSNumber numberWithInteger:sortby],
                                                           @"sorttype" : [NSNumber numberWithInteger:sorttype],
                                                           @"radius" : [NSNumber numberWithInteger:radius],
                                                           @"page" : [NSNumber numberWithInteger:page],
                                                           @"size" : [NSNumber numberWithInteger:size]
                                                           }];
    return [G100ApiHelper postApi:@"app/searchplace" andRequest:requset callback:callback];
}

@end
