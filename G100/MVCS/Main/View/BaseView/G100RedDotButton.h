//
//  G100RedDotButton.h
//  G100
//
//  Created by William on 16/7/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonTapAction)();

@interface G100RedDotButton : UIButton

@property (copy, nonatomic) ButtonTapAction tapAction;

@property (assign, nonatomic) BOOL hasRedDot;

@end
