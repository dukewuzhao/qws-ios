//
//  BindApplicationView.h
//  G100
//
//  Created by Tilink on 15/4/22.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

typedef void(^ButtonClick)(NSInteger index);

@class G100PushMsgDomain;
@interface BindApplicationView : G100PopBoxBaseView

@property (copy, nonatomic) ButtonClick buttonClick;
@property (strong, nonatomic) G100PushMsgDomain * pushDomain;

- (void)showBindApplicationViewWithVc:(UIViewController *)vc
                                 view:(UIView *)view
                                 user:(G100PushMsgDomain *)userinfo
                          buttonClick:(ButtonClick)buttonClick
                             animated:(BOOL)animated;

- (IBAction)buttonClick:(UIButton *)sender;

@end
