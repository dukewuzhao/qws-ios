//
//  G100StartPageView.h
//  G100
//
//  Created by 温世波 on 15/12/15.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100StartPageDomain.h"

@interface G100StartPageView : UIView

@property (nonatomic, copy) void (^completeBlock)(void (^callback)());
@property (nonatomic, copy) void (^tappedBlock)(G100StartPageDomain * page);

@property (nonatomic, strong) G100StartPageDomain * page;

+ (BOOL)canShowStartPageView;

+ (instancetype)startPageView;

- (void)showInView:(UIView *)view animated:(BOOL)animated;

- (void)showInView:(UIView *)view animated:(BOOL)animated completeBlock:(void (^)(void (^callback)()))completeBlock;

- (void)showInView:(UIView *)view animated:(BOOL)animated completeBlock:(void (^)(void (^callback)()))completeBlock tappedBlock:(void (^)(G100StartPageDomain * page))tappedBlock;

- (void)dismissWithAnimated:(BOOL)animated;

@end
