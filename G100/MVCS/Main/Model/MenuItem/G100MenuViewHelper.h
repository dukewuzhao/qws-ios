//
//  G100MenuViewHelper.h
//  G100
//
//  Created by 曹晓雨 on 2018/1/23.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100MenuView.h"
#import "MenuItem.h"

@interface G100MenuViewHelper : NSObject

@property (nonatomic, strong) G100MenuView *menuView;

/**
 刷新侧边栏选项
 
 @param userid 用户id
 @return 选项数组
 */
- (void)reloadMenuItemsWithUserid:(NSString *)userid;

@end
