//
//  MenuItem.h
//  G100
//
//  Created by 曹晓雨 on 2018/1/23.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^selectedCallback)();

@interface MenuItem : NSObject

@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *itemIconName;
@property (nonatomic, strong) NSString *itemDesc;
@property (nonatomic, assign) BOOL needNoticeDot;

@property (nonatomic, copy) selectedCallback selectedCallback;

+ (instancetype)itemWithName:(NSString *)name  iconName:(NSString *)iconName selectedCallback:(selectedCallback)selectedCallback;
+ (instancetype)itemWithName:(NSString *)name desc:(NSString *)desc iconName:(NSString *)iconName selectedCallback:(selectedCallback)selectedCallback;
+ (instancetype)itemWithName:(NSString *)name desc:(NSString *)desc iconName:(NSString *)iconName needNoticeDot:(BOOL)needNoticeDot selectedCallback:(selectedCallback)selectedCallback;

@end
