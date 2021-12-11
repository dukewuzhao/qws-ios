//
//  PopViewLayer.h
//  G100
//
//  Created by Tilink on 15/5/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PopViewLayer : CALayer

@property (nonatomic, assign) CGFloat        radius;// default:60pt
@property (nonatomic, assign) NSTimeInterval animationDuration;// default:3s
@property (nonatomic, assign) NSTimeInterval pulseInterval;// default is 0s

@end
