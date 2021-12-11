//
//  G100PickActionSheet.h
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickedIndexBlock)(NSInteger index);

@interface G100PickActionSheet : UIView

@property (strong,nonatomic) NSString *titleText;
@property (strong,nonatomic) NSString *cancelText;

/**
 *  @brief 初始化PQActionSheet(Block回调结果)
 *
 *  @param title             ActionSheet标题
 *  @param block             Block回调选中的Index
 *  @param cancelButtonTitle 取消按钮标题
 *  @param otherButtonTitles 其他按钮标题
 *
 *  @return PQActionSheet
 */
- (instancetype)initWithTitle:(NSString *)title
               clickedAtIndex:(ClickedIndexBlock)block
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...;

/**
 *  @brief 初始化PQActionSheet(Block回调结果)
 *
 *  @param title             ActionSheet标题
 *  @param block             Block回调选中的Index
 *  @param cancelButtonTitle 取消按钮标题
 *  @param otherButtonTitlesArray 其他按钮标题数组
 *
 *  @return PQActionSheet
 */
- (instancetype)initWithTitle:(NSString *)title
               clickedAtIndex:(ClickedIndexBlock)block
            cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitlesArray:(NSArray *)otherButtonTitlesArray;
/**
 *  @brief 显示ActionSheet
 */
- (void)show;

/**
 *  @brief 添加按钮
 *
 *  @param title 按钮标题
 *
 *  @return 按钮的Index
 */
- (NSInteger)addButtonWithTitle:(NSString *)title;

@end
