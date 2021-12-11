//
//  G100BaseImageItem.h
//  G100
//
//  Created by yuhanle on 16/3/22.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseItem.h"

@interface G100BaseImageItem : G100BaseItem

+ (instancetype)itemWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl;
+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title imageUrl:(NSString *)imageUrl;

@end
