//
//  G100PhotoPickerCell.h
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPickerCellDelegate <NSObject>

- (void)actionWithButtonIndex:(NSInteger)index;

@end

@interface G100PhotoPickerCell : UICollectionViewCell

@property (nonatomic, weak) id <PhotoPickerCellDelegate> delegate;

- (IBAction)addNewPhoto:(UIButton *)sender;

@end
