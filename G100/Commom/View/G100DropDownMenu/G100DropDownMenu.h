//
//  G100DropDownMenu.h
//  G100DropDownMenuDemo
//
//  Created by  on 12/26/15.
//  Copyright (c) 2014 tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    G100DropDownMenuColomnStyleDefault = 0, // 默认
    G100DropDownMenuColomnStyleMultiple,    // 筛选
} G100DropDownMenuColomnStyle;

@interface G100IndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger item;
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
// default item = -1
+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row;
+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row item:(NSInteger)item;
@end

@interface G100BackgroundCellView : UIView

@end

#pragma mark - data source protocol
@class G100DropDownMenu;

@protocol G100DropDownMenuDataSource <NSObject>

@required

/**
 *  返回 menu 第column列有多少行
 */
- (NSInteger)menu:(G100DropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column;

/** 
 *  新增 menu 的title
 */
- (NSString *)menu:(G100DropDownMenu *)menu titleForColumn:(NSInteger)column;
/**
 *  返回 menu 第column列 每行title
 */
- (NSString *)menu:(G100DropDownMenu *)menu titleForRowAtIndexPath:(G100IndexPath *)indexPath;

/**
 *  返回 menu 第column列的展示形式
 */
- (G100DropDownMenuColomnStyle)menu:(G100DropDownMenu *)menu colomnStyleForColumn:(NSInteger)column;

@optional
/**
 *  返回 menu 有多少列 ，默认1列
 */
- (NSInteger)numberOfColumnsInMenu:(G100DropDownMenu *)menu;

// 新增 返回 menu 第column列 每行image
- (NSString *)menu:(G100DropDownMenu *)menu imageNameForRowAtIndexPath:(G100IndexPath *)indexPath;

// 新增 detailText ,right text
- (NSString *)menu:(G100DropDownMenu *)menu detailTextForRowAtIndexPath:(G100IndexPath *)indexPath;

- (BOOL)menu:(G100DropDownMenu *)menu detailButtonForRowAtIndexPath:(G100IndexPath *)indexPath;

/** 新增
 *  当有column列 row 行 返回有多少个item ，如果>0，说明有二级列表 ，=0 没有二级列表
 *  如果都没有可以不实现该协议
 */
- (NSInteger)menu:(G100DropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column;

/** 新增
 *  当有column列 row 行 item项 title
 *  如果都没有可以不实现该协议
 */
- (NSString *)menu:(G100DropDownMenu *)menu titleForItemsInRowAtIndexPath:(G100IndexPath *)indexPath;

// 新增 当有column列 row 行 item项 image
- (NSString *)menu:(G100DropDownMenu *)menu imageNameForItemsInRowAtIndexPath:(G100IndexPath *)indexPath;
// 新增
- (NSString *)menu:(G100DropDownMenu *)menu detailTextForItemsInRowAtIndexPath:(G100IndexPath *)indexPath;

@end

#pragma mark - delegate
@protocol G100DropDownMenuDelegate <NSObject>
@optional
/**
 *  点击代理，点击了第column 第row 或者item项，如果 item >=0
 */
- (void)menu:(G100DropDownMenu *)menu didSelectRowAtIndexPath:(G100IndexPath *)indexPath;

/** 新增
 *  return nil if you don't want to user select specified indexpath
 *  optional
 */
- (NSIndexPath *)menu:(G100DropDownMenu *)menu willSelectRowAtIndexPath:(G100IndexPath *)indexPath;

/**
 *  重置筛选条件
 */
- (void)menu:(G100DropDownMenu *)menu resetFilter:(NSArray *)filter;

/**
 *  确认筛选条件
 */
- (void)menu:(G100DropDownMenu *)menu confirmFilter:(NSArray *)fileter;

@end

#pragma mark - interface
@interface G100DropDownMenu : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <G100DropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <G100DropDownMenuDelegate> delegate;

@property (nonatomic, assign) UITableViewCellStyle cellStyle; // default value1
@property (nonatomic, strong) UIColor *indicatorColor;      // 三角指示器颜色
@property (nonatomic, strong) UIColor *textColor;           // 文字title颜色
@property (nonatomic, strong) UIColor *textSelectedColor;   // 文字title选中颜色
@property (nonatomic, strong) UIColor *detailTextColor;     // detailText文字颜色
@property (nonatomic, strong) UIFont *detailTextFont;       // font
@property (nonatomic, strong) UIColor *separatorColor;      // 分割线颜色
@property (nonatomic, assign) NSInteger fontSize;           // 字体大小
// 当有二级列表item时，点击row 是否调用点击代理方法
@property (nonatomic, assign) BOOL isClickHaveItemValid;

@property (nonatomic, copy) void (^openMenuBlock)();/* 打开下拉菜单 */
@property (nonatomic, copy) void (^menuCancelPick)();/* 取消选中选项 */

@property (nonatomic, getter=isRemainMenuTitle) BOOL remainMenuTitle; // 切换条件时是否更改menu title
@property (nonatomic, strong) NSMutableArray  *currentSelectRowArray; // 恢复默认选项用
/**
 *  the width of menu will be set to screen width defaultly
 *
 *  @param origin the origin of this view's frame
 *  @param height menu's height
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

// 获取title
- (NSString *)titleForRowAtIndexPath:(G100IndexPath *)indexPath;

// 重新加载数据
- (void)reloadData;

// 刷新数据
- (void)refreshData;

// 创建menu 第一次显示 不会调用点击代理，这个手动调用
- (void)selectDefalutIndexPath;

- (void)selectIndexPath:(G100IndexPath *)indexPath; // 默认trigger delegate

- (void)selectIndexPath:(G100IndexPath *)indexPath triggerDelegate:(BOOL)trigger; // 调用代理
@end

