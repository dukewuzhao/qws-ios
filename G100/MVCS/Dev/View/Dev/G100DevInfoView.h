//
//  G100DevInfoView.h
//  G100
//
//  Created by William on 16/7/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100DevInfoView : UIView

@property (assign, nonatomic) CGFloat battery;

@property (assign, nonatomic) CGFloat distance;

@property (assign, nonatomic) BOOL accState;

+ (instancetype)loadDevInfoView;

@end
