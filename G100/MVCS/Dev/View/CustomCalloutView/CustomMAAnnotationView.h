//
//  CustomMAAnnotationView.h
//  G100
//
//  Created by Tilink on 15/10/13.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "PositionDomain.h"
#import "PositionPaoPaoView.h"

@interface CustomMAAnnotationView : MAAnnotationView

@property (strong, nonatomic) PositionDomain * positionDomain;
@property (strong, nonatomic) PositionPaoPaoView * calloutView;
@property (strong, nonatomic) UIImageView *masterFlagView;
@property (assign, nonatomic) BOOL isMainDevice;

@end
