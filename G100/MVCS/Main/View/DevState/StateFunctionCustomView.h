//
//  StateFunctionCustomView.h
//  G100
//
//  Created by William on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapAction)();

@interface StateFunctionCustomView : UIView

@property (nonatomic, assign) NSInteger left_days;

@property (copy, nonatomic) TapAction tapAction;

+ (instancetype)loadStateFunctionCustomView;

@end
