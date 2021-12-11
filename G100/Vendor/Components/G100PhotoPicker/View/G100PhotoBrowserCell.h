//
//  G100PhotoBrowserCell.h
//  PhotoPicker
//
//  Created by William on 16/3/23.
//  Copyright © 2016年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100PhotoShowModel;

@interface G100PhotoBrowserCell : UICollectionViewCell

@property (nonatomic, weak) id photoBrowserViewController;

@property (nonatomic, strong) G100PhotoShowModel * photoModel;

@end
