//
//  G100Mediator+InsuranceOrders.h
//  G100
//
//  Created by yuhanle on 2017/1/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (InsuranceOrders)

/**
 跳转保单列表

 @param userid 用户id
 @param params 其他参数 如listtype 或 selected
 @param loginHandler 登陆成功后的回调
 @return 控制器实例
 */
- (UIViewController *)G100Mediator_viewControllerForInsuranceOrdersWithUserid:(NSString *)userid params:(NSDictionary *)params loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

@end
