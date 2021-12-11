//
//  G100MenuView.h
//  G100
//
//  Created by William on 16/6/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItem;
@class G100MenuView;
@class G100EventDomain;
@protocol G100MenuViewDelegate <NSObject>

/**
 *  选中某条菜单
 *
 *  @param menuView  菜单
 *  @param indexPath 选中菜单
 */
- (void)menuView:(G100MenuView *)menuView didSelectRowAtIndexPath:(NSIndexPath *)indexPath menuItem:(MenuItem *)menuItem;
@optional

/**
 *  开始打开菜单
 *
 *  @param G100MenuView 菜单
 */
- (void)menuViewShouldStartOpening:(G100MenuView *)G100MenuView;

/**
 *  已经打开菜单
 *
 *  @param G100MenuView 菜单
 */
- (void)menuViewDidOpened:(G100MenuView *)G100MenuView;

/**
 *  开始关闭菜单
 *
 *  @param G100MenuView 菜单
 */
- (void)menuViewShouldStartClosing:(G100MenuView *)G100MenuView;

/**
 *  已经关闭菜单
 *
 *  @param G100MenuView 菜单
 */
- (void)menuViewDidClosed:(G100MenuView *)G100MenuView;

@end

typedef void (^UserActionTap)(NSInteger index);
typedef void (^GetEventDetailBlock)(G100EventDetailDomain *eventDetail);

@interface G100MenuView : UIView

/**
 *  菜单是否打开
 */
@property (assign, nonatomic) BOOL isOpen;

@property (copy, nonatomic) NSString *userid;

@property (strong, nonatomic) G100EventDomain *eventDomain;

@property (weak, nonatomic) id <G100MenuViewDelegate> delegate;

@property (copy, nonatomic) UserActionTap userActionTap;

@property (copy, nonatomic) GetEventDetailBlock getEventDetailBlock;

@property (nonatomic, strong) NSArray <MenuItem *>* menuItemArr;
/**
 *  打开菜单
 *
 *  @param hideMenu 是否是手势操控
 */
- (void)showMenuWithPanAction:(BOOL)isPanAction;

/**
 *  隐藏菜单
 *
 *  @param isPanAction 是否是手势操控
 */
- (void)hideMenuWithPanAction:(BOOL)isPanAction;

/**
 *  通过手势改变菜单视图
 *
 *  @param recognizer 手势
 */
- (void)configViewWithGesture:(UIPanGestureRecognizer *)recognizer;

@end
