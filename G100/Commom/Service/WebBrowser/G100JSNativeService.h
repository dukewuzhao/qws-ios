//
//  G100JSNativeService.h
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class G100WebViewController;

@protocol JavaScriptObjectiveCDelegate <JSExport>

//TODO: 获取token功能

/**
 *  获取客户端的token
 *
 *  @param qwsKey 客户端生成的密码key
 *
 *  @return 返回值token
 */
- (NSString *)getToken:(NSString *)qwsKey;

/**
 *  H5 传递key 获取newToken 在调用其 callback 方法
 *
 *  @param key      qwskey
 *  @param callback 回调方法名
 *  @param property 方法参数
 */
- (void)getNewToken:(NSString *)key callback:(NSString *)callback property:(NSString *)property;

/**
 网页访问过程中 收到抢占登陆的问题
 */
- (void)occupyToken;

//TODO: 保险功能

/**
 H5 端在购买保险页面，服务端返回平安商城的支付url时，调用此方法，并传递服务端返回的所有数据
 
 @param data 服务端返回的所有数据（JSON）
 */
- (void)payPingAnInsurance:(NSString *)data;

//TODO: Toast/HUD功能

/**
 H5 端在发送异步请求时，需要展示等待HUD 视图
 
 @param hint HUD文案
 @param canOperate YES/NO （显示hud 时，页面是否可操作）
 */
- (void)qwsShowHudHint:(NSString *)hint canOperate:(BOOL)canOperate;
/**
 H5 端在异步请求完成后，隐藏HUD 视图
 */
- (void)qwsHideHud;
/**
 H5 端调用客户端的显示Toast 功能 （默认3s隐藏）
 
 @param hint Hint文案
 */
- (void)qwsShowHint:(NSString *)hint;
/**
 H5 端调用客户端的隐藏Toast 功能
 */
- (void)qwsHideHint;

//TODO: 配置功能

/**
 *  H5 在加载完成后 告诉客户端在返回的时候调用该方法
 *
 *  @param callback js 方法名
 */
- (void)getExitMsgCallback:(NSString *)callback;
/**
 H5 端在加载完成后，告诉客户端该页面是否可以关闭浏览器
 
 @param canClose YES/NO
 */
- (void)qwsWebViewCanClose:(BOOL)canClose;
/**
 H5 端在加载完成后，告诉客户端该页面是否可以操作
 
 @param canOperate YES/NO
 */
- (void)qwsWebViewCanOperate:(BOOL)canOperate;

/**
 设置导航栏标题
 
 @param title 标题
 */
- (void)setNavigationBarTitle:(NSString *)title;

/**
 设置导航栏颜色
 
 @param color 颜色
 */
- (void)setNavigationBarColor:(NSString *)color;

/**
 获取当前位置
 
 @param
 */
- (void)getCLIWithCallback:(NSString *)callback;
@end

// 此模型用于注入JS的模型，这样就可以通过模型来调用方法。
@interface QWSJsObjCModel : NSObject <JavaScriptObjectiveCDelegate>

@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) G100WebViewController * webVc;

@end

@interface G100JSNativeService : NSObject

@end
