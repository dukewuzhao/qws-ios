//
//  G100PhotoPickerView.h
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100PhotoPickerView;

static NSString *kPhotoCellIdentifier = @"kPhotoCellIdentifier";
static NSString *kPickCellIdentifier = @"kPickCellIdentifier";

@protocol G100PhotoPickerDelegate <NSObject>

@optional

- (void)pickerView:(G100PhotoPickerView*)pickerView hasChangedPhotos:(NSArray*)photos;
- (void)pickerView:(G100PhotoPickerView *)pickerView hasDeletedPhotoName:(NSString*)name;
- (void)pickerView:(G100PhotoPickerView *)pickerView coverUrl:(NSString *)coverUrl;
@end

@interface G100PhotoPickerView : UIView

@property (nonatomic, strong) NSMutableArray * dataArray;/* G100PhotoShowModel */

@property (nonatomic, strong) NSArray *imageAsset;

// 是否允许编辑  add / delete
@property (nonatomic, assign) BOOL isAllowEdit;

@property (nonatomic, assign)BOOL isShowCoverBtn;

/** 最多允许选择的照片数量 默认为5*/
@property (nonatomic, assign) NSInteger maxSeletedNumber;

@property (nonatomic, weak) id <G100PhotoPickerDelegate> delegate;

- (id)initWithPoint:(CGPoint)point;

- (void)setPickerData:(NSArray*)array /* G100PhotoShowModel */;

@end
