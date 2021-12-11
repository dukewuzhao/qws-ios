//
//  G100InsuranceWebViewController.h
//  G100
//
//  Created by Tilink on 15/4/27.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"
#import "InsuranceWebModel.h"

@interface G100InsuranceWebViewController : G100BaseXibVC

@property (weak, nonatomic) IBOutlet UIWebView * webView;
@property (strong, nonatomic) InsuranceWebModel * model;

@property (copy, nonatomic) void (^paySuccessCallback)();

/**
 *  快速创建网页浏览视图控制器
 *
 *  @return 视图控制器实例
 */
+ (instancetype)loadNibWebViewController;

@end
