//
//  G100BaseArrowItem.h
//  G100
//
//  Created by 温世波 on 15/12/3.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseItem.h"

typedef enum {
    G100BaseArrowItemVcShowTypePush,
    G100BaseArrowItemVcShowTypeModal
} G100BaseArrowItemVcShowType;

@interface G100BaseArrowItem : G100BaseItem

/**
 *  点击这行cell需要跳转的控制器
 */
@property (nonatomic, assign) Class destVcClass;

@property (nonatomic, assign)  G100BaseArrowItemVcShowType  vcShowType;

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title destVcClass:(Class)destVcClass;
+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass;

@end
