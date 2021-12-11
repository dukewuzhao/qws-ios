//
//  G100TapAnimationView.h
//  G100
//
//  Created by William on 16/7/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnimationCompletion)();

@interface G100TapAnimationView : UIView

@property (copy, nonatomic) AnimationCompletion completion;

- (void)showCircleLayerWithPoint:(CGPoint)position comletion:(AnimationCompletion)completion;

@end
