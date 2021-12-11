//
//  G100InUseCityCollectionViewCell.h
//  G100
//
//  Created by 天奕 on 15/12/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100ServiceCityDomain;
@interface G100InUseCityCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *inUseCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *noUseCityFlag;

@property (strong, nonatomic) G100ServiceCityDomain *cityDomain;

@end
