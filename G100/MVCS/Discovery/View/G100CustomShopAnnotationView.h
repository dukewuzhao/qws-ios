//
//  CustomMAAnnotationView.h
//  G100
//
//  Created by Tilink on 15/10/13.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "G100ShopDomain.h"
#import "G100ShopInfoPaoPaoView.h"

@interface G100CustomShopAnnotationView : MAAnnotationView

@property (strong, nonatomic) G100ShopPlaceDomain * shopPlaceDomain;
@property (strong, nonatomic) G100ShopInfoPaoPaoView * calloutView;

@end
