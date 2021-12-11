//
//  G100Mediator+ScanCode.h
//  G100
//
//  Created by yuhanle on 16/8/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Mediator.h"

@interface G100Mediator (ScanCode)
/**
 去扫码页面

 @param userid 用户id
 @return 控制器实例
 */
- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bindMode:(int)bindMode;

/**
 去扫码页面绑定车辆

 @param userid 用户id
 @param bikeid 车辆id
 @param bindMode 绑定方式 1 扫码 2 手动输入 3 扫一扫功能
 @param loginHandler 登陆后回到
 @return 控制器实例
 */
- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bikeid:(NSString *)bikeid bindMode:(int)bindMode loginHandler:(void (^)(UIViewController *, BOOL))loginHandler;

/**
 去扫码页面

 @param userid 用户id
 @param bindMode 绑定方式 1 扫码 2 手动输入 3 扫一扫功能
 @param loginHandler 登陆后回调
 @return 控制器实例
 */
- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bindMode:(int)bindMode loginHandler:(void (^)(UIViewController *viewController, BOOL loginSuccess))loginHandler;

/**
 去扫码页面绑定设备
 
 @param userid 用户id
 @param devid  设备id
 @param bindMode 绑定方式 1 扫码 2 手动输入 3 扫一扫功能
 @param loginHandler 登陆后回调
 @return 控制器实例
 */
- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid devid:(NSString *)devid bindMode:(int)bindMode loginHandler:(void (^)(UIViewController *, BOOL))loginHandler;

/**
 去扫码页面扫码

 @param userid 用户id
 @param bindMode 绑定方式 1 扫码 2 手动输入 3 扫一扫功能
 @param operation 操作方式 0 绑定设备 1 更换设备 2 扫一扫 默认是0
 @param loginHandler 登陆后回调
 @return 控制器实例
 */
- (UIViewController *)G100Mediator_viewControllerForScanCode:(NSString *)userid bindMode:(int)bindMode operation:(int)operation loginHandler:(void (^)(UIViewController *, BOOL))loginHandler;

@end
