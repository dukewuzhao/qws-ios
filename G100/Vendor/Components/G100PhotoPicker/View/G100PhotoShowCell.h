//
//  G100PhotoShowCell.h
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100PhotoShowModel;

@interface G100PhotoShowCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;

@property (nonatomic, copy) void (^showPhotoBrowser)();

- (void)setImageViewWithModel:(G100PhotoShowModel*)model;



@end
