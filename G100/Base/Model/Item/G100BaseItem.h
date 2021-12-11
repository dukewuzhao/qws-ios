//
//  G100BaseItem.h
//  G100
//
//  Created by 温世波 on 15/12/3.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^G100BaseItemOption)();

@interface G100BaseItem : NSObject
/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  子标题
 */
@property (nonatomic, copy) NSString *subtitle;
/**
 *  右侧图片url
 */
@property (nonatomic, copy) NSString *rightImageUrl;

/**
 *  存储数据用的key
 */
@property (nonatomic, copy) NSString *itemkey;

/**
 *  是否为必填项 Default is NO
 */
@property (nonatomic, assign) BOOL isRequired;

/**
 *  点击那个cell需要做什么事情
 */
@property (nonatomic, copy) G100BaseItemOption option;

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title;

@end
