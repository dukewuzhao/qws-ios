//
//  G100RTCollectionViewCell.h
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/28.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100RTCommandModel.h"

@class G100RTCollectionViewCell;

@protocol G100RTCollectionViewCellDelegate <NSObject>

@optional

- (void)cellDidTapped:(G100RTCollectionViewCell *)viewCell indexPath:(NSIndexPath *)indexPath;

@end

@interface G100RTCollectionViewCell : UICollectionViewCell

/**
 *  viewCell 对应的indexPath
 */
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) G100RTCommandModel *rtCommand;
@property (nonatomic, weak) id <G100RTCollectionViewCellDelegate> delegate;
@property (nonatomic, assign) NSInteger totalCount;
/**
 *  当前选中的远程控制模式状态 0 无 1 蓝牙 2 GPS
 */
@property (nonatomic, assign) int status;
/**
 *  空键+20%蒙黑 覆盖空视图
 */
@property (nonatomic, strong) UIView *emptyView;
/**
 *  是否响应点击事件
 */
@property (nonatomic, assign) BOOL rtEnabled;

/**
 是否自定义背景图片
 */
@property (nonatomic, assign) BOOL rtCustomBgImage;

@end
