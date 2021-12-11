//
//  G100BaseImageItem.m
//  G100
//
//  Created by yuhanle on 16/3/22.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseImageItem.h"

@implementation G100BaseImageItem

+ (instancetype)itemWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl {
    return [self itemWithIcon:nil title:title imageUrl:imageUrl];
}

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title imageUrl:(NSString *)imageUrl {
    G100BaseImageItem * item = [self itemWithIcon:icon title:title];
    item.rightImageUrl = imageUrl;
    return item;
}

@end
