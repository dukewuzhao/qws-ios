//
//  G100MainDetailViewController.h
//  G100
//
//  Created by yuhanle on 16/7/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CardManager.h"

@class G100BikeDomain;
@protocol G100MainDetailViewControllerDelegate <NSObject>

@optional
- (void)mainDetailViewDidScroll:(UIScrollView *)scrollView;

- (void)mainDetailViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)mainDetailViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)mainDetailViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

@interface G100MainDetailViewController : UIViewController

/**
 *  用户id
 */
@property (nonatomic, copy) NSString *userid;
/**
 *  车辆id
 */
@property (nonatomic, copy) NSString *bikeid;
/**
 *  车辆模型
 */
@property (nonatomic, strong) G100BikeDomain *bike;
/** 卡片管理器*/
@property (nonatomic, strong) G100CardManager *cardManager;
@property (nonatomic, strong) NSMutableArray *indexPaths;
@property (nonatomic, strong) UITableView *cardTableView;
/**
 *  设置详情页的滑动代理
 */
@property (nonatomic, weak) id <G100MainDetailViewControllerDelegate> delegate;
/**
 *  设置table 点击顶部是否快速回到顶部 同时表示这个是当前页面
 */
@property (nonatomic, assign) BOOL scrollsToTop;
/**
 *  设置table 滚动偏移量
 */
@property (nonatomic, assign) CGPoint contentOffset;
/**
 控制器是否已经出现
 */
@property (nonatomic, assign) BOOL hasAppear;
/**
 *  刷新数据
 */
- (void)reloadData;
/**
 获取服务器数据
 */
- (void)featchMainData;
/**
 *  刷新某一组indexPath
 *
 *  @param indexPaths 索引数组
 *  @param animation  动画效果
 */
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
/**
 *  刷新某一个 cell
 *
 *  @param indexPath 索引
 *  @param animation 动画效果
 *  @param scrollPosition  是否滚动到这个位置
 *  @param animated 是否带动画
 */
- (void)reloadRowsAtIndexPaths:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

/**
 *  即将滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillAppear:(BOOL)animated;
/**
 *  已经滑到这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidAppear:(BOOL)animated;
/**
 *  即将离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewWillDisappear:(BOOL)animated;
/**
 *  已经离开这个页面
 *
 *  @param animated YES/NO
 */
- (void)mdv_viewDidDisappear:(BOOL)animated;

@end
