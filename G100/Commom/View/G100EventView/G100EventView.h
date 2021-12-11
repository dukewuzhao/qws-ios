//
//  G100EventView.h
//  G100
//
//  Created by William on 16/2/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"
#import "G100EventDomain.h"

@interface G100EventView : G100PopBoxBaseView

@property (nonatomic, copy) void (^getDetailBlock)(G100EventDetailDomain *event);

@property (nonatomic, copy) void (^dismissBlock)(G100EventDetailDomain *event);

@property (nonatomic, strong) G100EventDetailDomain *event;

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;


/**
 返回活动事件的视图

 @param event 默认返回Poster 海报活动
 @return 活动页面
 */
+ (instancetype)loadXibEventViewWithEventDetailModel:(G100EventDetailDomain *)event;

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation completion:(void (^)(BOOL finished))completion;

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation completion:(void (^)(BOOL finished))completion;

@end
