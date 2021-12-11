//
//  G100MyInsurancesHeaderCell.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMGPlaceholderView.h"

@interface G100ScrollViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet IMGPlaceholderView *imageView;

+ (void)registerToCollectionView:(UICollectionView *)collectionView;
+ (NSString *)cellID;

@end
