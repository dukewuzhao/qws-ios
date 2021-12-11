//
//  G100TwoSwitchView.h
//  G100
//
//  Created by yuhanle on 16/3/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "UIColor+G100Color.h"

@class G100TwoSwitchView;
@protocol G100TwoSwitchDelegate <NSObject>
@optional
- (void)switchView:(G100TwoSwitchView *)switchView didSwitchButtonFrom:(NSInteger)from to:(NSInteger)to;

@end

@interface G100TwoSwitchView : UIView

@property (nonatomic, weak) id <G100TwoSwitchDelegate> delegate;
@property (nonatomic, assign) NSInteger switchCount; //!< switch的个数

- (instancetype)initWithTitleArray:(NSArray *)titleArray unreadCount:(NSArray *)unreadCountArray;

/**
 *  设置index的title
 *
 *  @param title title
 *  @param index index
 */
- (void)setTitle:(NSString *)title forIndex:(NSInteger)index;
/**
 *  设置index的count
 *
 *  @param unreadCount 未读个数
 *  @param index       index
 */
- (void)setUnreadCount:(NSInteger)unreadCount forIndex:(NSInteger)index;
/**
 *  设置index的title&count
 *
 *  @param title       title
 *  @param unreadCount 未读个数
 *  @param index       index
 */
- (void)setTitle:(NSString *)title unreadCount:(NSInteger)unreadCount forIndex:(NSInteger)index;

/**
 *  设置titles
 *
 *  @param titleArray title数组
 */
- (void)setTitleArray:(NSArray *)titleArray;
/**
 *  设置titles&unread
 *
 *  @param titleArray       title数组
 *  @param unreadCountArray unread个数
 */
- (void)setTitleArray:(NSArray *)titleArray unreadCount:(NSArray *)unreadCountArray;

// 提供外部一个可以跳转button的方法
- (void)switchToIndex:(NSInteger)index;

@end
