//
//  G100BaseArrowItem.m
//  G100
//
//  Created by 温世波 on 15/12/3.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseArrowItem.h"

@implementation G100BaseArrowItem

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title destVcClass:(Class)destVcClass
{
    G100BaseArrowItem *item = [self itemWithIcon:icon title:title];
    item.destVcClass = destVcClass;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass
{
    return [self itemWithIcon:nil title:title destVcClass:destVcClass];
}

@end
