//
//  G100MultiImageView.h
//  G100
//
//  Created by yuhanle on 14/11/11.
//  Copyright (c) 2014年 tilink All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol G100MultiImageViewDelegate;

@interface G100MultiImageView : UIView

/**
 *  每个图片宽度
 */
@property (nonatomic, assign) CGFloat        itemWidth;

/**
 *  每行显示个数
 */
@property (nonatomic, assign) NSInteger      lineCount;

/**
 *  图片最多显示数
 */
@property (nonatomic, assign) NSUInteger     maxItem;
/**
 *  图片间距
 */
@property (nonatomic, assign) CGFloat        gap;
/**
 是否拖动 默认NO
 */
@property (nonatomic, assign, readonly) BOOL isDragged;
/**
 是否允许编辑
 */
@property (nonatomic, assign) BOOL isEnableEdit;

/**
 *  存放要显示的图片数组[G100PhotoShowModel 类型]
 */
@property (nonatomic, strong) NSMutableArray *images_MARR;

@property (nonatomic, weak) id <G100MultiImageViewDelegate> delegate;

/**
 删除某个下标对应的图片

 @param index 数组下标
 @param animated 是否带动画
 */
- (void)strikeOutItemAtIndex:(NSInteger)index animated:(BOOL)animated;

@end



@protocol G100MultiImageViewDelegate <NSObject>

/**
 *  添加新图片“+”点击回调
 */
- (void)addButtonDidTap;

/**
 *  每张图片点击回调
 *
 *  @param index 图片位置的下标[和数组保持一致]
 *  @param image 被点击的图片
 */
- (void)multiImageBtn:(NSInteger)index withImage:(UIImage *)image;

@optional

/**
 拖动开始

 @param index 拖动的下标
 */
- (void)multiImageDragBegin:(NSInteger)index;

/**
 拖动结束

 @param from 拖动的下标
 @param to 结束的下标
 */
- (void)multiImageDragEndedWithFrom:(NSInteger)from to:(NSInteger)to;

@end
