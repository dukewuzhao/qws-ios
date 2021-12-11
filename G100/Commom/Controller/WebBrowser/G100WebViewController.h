//
//  G100WebViewController.h
//  G100
//
//  Created by 温世波 on 15/12/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface G100WebViewController : G100BaseXibVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid; //!< 需要传递的设备id
@property (nonatomic, copy) NSString *httpUrl; //!< 需要load的网址
@property (nonatomic, copy) NSString *filename; //!< 加载本地html文件
@property (nonatomic, copy) NSString *webTitle; //!< 网页固定标题
@property (nonatomic, assign) BOOL isAllowInpourJS; //!< 是否允许注入JS代码
@property (nonatomic, assign) BOOL isAllowBackSlip; //!< 是否允许侧滑返回
@property (nonatomic, copy) NSString *qwsKey; //!< 绑定key 用于H5回调信息
@property (nonatomic, copy) NSString *exitJSCallback; //!< web在返回的时候调用JS 的方法名 如果为空就不用调用

@property (nonatomic, assign) BOOL previousInteractivePopGestureEnabled; //!< 记录当前页面是否允许侧滑返回

/** 消息模板参数*/
@property (nonatomic, copy) NSString *msg_title;
@property (nonatomic, copy) NSString *msg_desc;

@property (strong, nonatomic) JSContext *jsContext;
@property (weak, nonatomic) IBOutlet UIWebView * webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewtoLeadingConstraint;

@property (strong, nonatomic) IBOutlet UILabel *webTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

/** 告诉试图控制器 在网页要关掉页面时该做的事儿*/
@property (copy, nonatomic) void (^whenWebCloseTodoEventBlock)(void (^result)());

- (IBAction)getBack:(UIButton *)sender;
- (IBAction)closeWebPage:(UIButton *)sender;
- (IBAction)shareWebPage:(UIButton *)sender;

/**
 *  快速创建网页浏览视图控制器
 *
 *  @return 视图控制器实例
 */
+ (instancetype)loadNibWebViewController;

/**
 设置导航栏区域是否可点击

 @param enabled YES/NO
 */
- (void)setNavigationViewClickEnabled:(BOOL)enabled;

@end
