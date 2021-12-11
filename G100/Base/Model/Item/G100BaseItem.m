//
//  G100BaseItem.m
//  G100
//
//  Created by 温世波 on 15/12/3.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseItem.h"

@implementation G100BaseItem

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title
{
    G100BaseItem *item = [[self alloc] init];
    item.icon = icon;
    item.title = title;
    item.isRequired = NO;
    item.itemkey = NSStringFromClass([self class]);
    return item;
}


+ (instancetype)itemWithTitle:(NSString *)title
{
    return [self itemWithIcon:nil title:title];
}

@end
