//
//  G100MyInsurancesHeaderCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ScrollViewCell.h"


@implementation G100ScrollViewCell

+ (NSString *)cellID
{
    return NSStringFromClass([self class]);
}
+ (void)registerToCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[UINib nibWithNibName:[self cellID] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[self cellID]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
