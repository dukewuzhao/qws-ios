//
//  DevPositionPaoPaoView.h
//  G100
//
//  Created by Tilink on 15/6/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100ShopPlaceDomain;
@interface G100ShopInfoPaoPaoView : UIView

@property (copy, nonatomic) void (^navigationButtonBlock)();

-(void)showShopInfoViewWithDomain:(G100ShopPlaceDomain *)domain;

@end
