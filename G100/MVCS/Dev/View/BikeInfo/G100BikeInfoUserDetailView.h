//
//  G100BikeInfoUserDetailView.h
//  G100
//
//  Created by 曹晓雨 on 2017/6/2.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"
#import "G100UserDomain.h"


typedef void(^BikeInfoUserDetailButtonClick)(NSInteger,BOOL,NSString *);

@interface G100BikeInfoUserDetailView : G100PopBoxBaseView

@property (copy, nonatomic) BikeInfoUserDetailButtonClick buttonClick;

- (void)showBindApplicationViewWithVc:(UIViewController *)vc
                                 view:(UIView *)view
                                 user:(G100UserDomain *)userDomain
                          buttonClick:(BikeInfoUserDetailButtonClick)buttonClick
                             animated:(BOOL)animated;

@end
