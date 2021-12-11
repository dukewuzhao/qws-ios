//
//  G100DiscoveryShopDetailCell.h
//  G100
//
//  Created by 天奕 on 15/12/28.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100ShopDomain.h"

typedef enum : NSInteger {
    ClickTypeAddress = 100,
    ClickTypePhoneNum
}ClickType;

@interface G100DiscoveryShopDetailCell : UITableViewCell

@property (strong, nonatomic) G100ShopPlaceDomain *placeDomain;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopPhoneNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UIView *shopTypeView;

@property (copy, nonatomic) void (^buttonClick)(G100ShopPlaceDomain *domain, ClickType type);

- (void)setCellDataWithModel:(G100ShopPlaceDomain*)model;

+ (CGFloat)heightForModel:(G100ShopPlaceDomain *)domain;

@end
