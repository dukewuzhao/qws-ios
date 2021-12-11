//
//  G100DevPhotoCell.h
//  G100
//
//  Created by William on 16/3/25.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100PhotoPickerView.h"

@interface G100DevPhotoCell : UITableViewCell

// 是否允许编辑  add / delete
@property (nonatomic, assign) BOOL isAllowEdit;

// 是否设置封面  add / delete
@property (nonatomic, assign) BOOL isShowCoverBtn;

- (instancetype)initWithDelegate:(id<G100PhotoPickerDelegate>)delegate identifier:(NSString *)identifier dataArray:(NSArray *)dataArray;

- (instancetype)initWithDelegate:(id<G100PhotoPickerDelegate>)delegate identifier:(NSString *)identifier dataArray:(NSArray *)dataArray isAllowEdit:(BOOL)isAllowEdit;

- (instancetype)initWithDelegate:(id<G100PhotoPickerDelegate>)delegate identifier:(NSString *)identifier dataArray:(NSArray *)dataArray isAllowEdit:(BOOL)isAllowEdit isShowCoverBtn:(BOOL)isShowCoverBtn;

@end
