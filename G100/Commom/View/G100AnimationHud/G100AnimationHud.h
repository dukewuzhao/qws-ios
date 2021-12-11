//
//  G100AnimationHud.h
//  G100
//
//  Created by 温世波 on 15/11/19.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100AnimationHud : UIView

@property (copy, nonatomic) NSString * hintText;

+ (instancetype)animationHud;

- (void)showInView:(UIView *)view animation:(BOOL)animation;

- (void)dismissWithAnimation:(BOOL)animation;

- (void)startAnimation;
- (void)stopAnimation;

@end
