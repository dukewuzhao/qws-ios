//
//  MenuItem.m
//  G100
//
//  Created by 曹晓雨 on 2018/1/23.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "MenuItem.h"

typedef void(^selectedCallback)();

@implementation MenuItem

+ (instancetype)itemWithName:(NSString *)name iconName:(NSString *)iconName selectedCallback:(selectedCallback)selectedCallback {
    return [MenuItem itemWithName:name desc:nil iconName:iconName  selectedCallback:selectedCallback];
}
+ (instancetype)itemWithName:(NSString *)name desc:(NSString *)desc iconName:(NSString *)iconName selectedCallback:(selectedCallback)selectedCallback {
    return [MenuItem itemWithName:name desc:desc iconName:iconName needNoticeDot:NO selectedCallback:selectedCallback];
}

+ (instancetype)itemWithName:(NSString *)name desc:(NSString *)desc iconName:(NSString *)iconName needNoticeDot:(BOOL)needNoticeDot selectedCallback:(selectedCallback)selectedCallback {
    MenuItem *item = [[MenuItem alloc] init];
    item.itemName = name;
    item.itemDesc = desc;
    item.itemIconName = iconName;
    item.needNoticeDot = needNoticeDot;
    item.selectedCallback = selectedCallback;
    return item;
}

@end
