//
//  G100ThemeInfoDoamin.m
//  G100
//
//  Created by 温世波 on 15/12/8.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100ThemeInfoDoamin.h"

@implementation G100ThemeInfoChannelInfo

@end

@implementation G100ThemeInfoBikeModel

@end

@implementation G100ThemeInfoDoamin

- (void)setChannel_info:(NSDictionary *)channel_info {
    _channel_info = channel_info.copy;
    
    _theme_channel_info = [[G100ThemeInfoChannelInfo alloc] initWithDictionary:channel_info];
}

- (G100ThemeInfoChannelInfo *)theme_channel_info {
    if (!_theme_channel_info) {
        _theme_channel_info = [[G100ThemeInfoChannelInfo alloc] init];
    }
    
    return _theme_channel_info;
}

- (void)setBike_info:(NSArray *)bike_info {
    _bike_info = bike_info.copy;
    
    NSMutableArray * tmp = [[NSMutableArray alloc] initWithCapacity:bike_info.count];
    [bike_info enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (INSTANCE_OF(obj, NSDictionary)) {
            G100ThemeInfoBikeModel * model = [[G100ThemeInfoBikeModel alloc] initWithDictionary:obj];
            [tmp addObject:model];
        }
    }];
    
    _theme_bike_model = tmp.copy;
}

- (NSArray *)theme_bike_model {
    if (!_theme_bike_model) {
        _theme_bike_model = [[NSArray alloc] init];
    }
    
    return _theme_bike_model;
}

- (G100ThemeInfoBikeModel *)findThemeInfoBikeModelWithModelid:(NSInteger)modelid {
    __block G100ThemeInfoBikeModel * model = nil;
    
    [_theme_bike_model enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (INSTANCE_OF(obj, G100ThemeInfoBikeModel)) {
            G100ThemeInfoBikeModel * tmp = (G100ThemeInfoBikeModel *)obj;
            if (tmp.modelid == modelid) {
                model = tmp;
            }
        }
    }];
    
    return model;
}

@end
