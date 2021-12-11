//
//  G100InsuranceWebViewController.m
//  G100
//
//  Created by Tilink on 15/4/27.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100InsuranceWebViewController.h"
#import "ExtString.h"
#import "G100InsuranceApi.h"

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface G100InsuranceWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate> {
    IBOutlet NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

@property (strong, nonatomic) IBOutlet UILabel *webTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightConstraint;

@end

@implementation G100InsuranceWebViewController

+ (instancetype)loadNibWebViewController {
    G100InsuranceWebViewController *webBrowser = [[G100InsuranceWebViewController alloc] initWithNibName:@"G100InsuranceWebViewController"
                                                                                                  bundle:nil];
    return webBrowser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationBarView.hidden = YES;
    self.navigationHeightConstraint.constant = kNavigationBarHeight;
    self.substanceViewtoBottomConstraint.constant = 0;
    
    // iOS 11 UI 显示bug 修复
    if ([self.webView.scrollView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.webView.scrollView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    [self loadWebPageWithString:_model.pay_url];
    
    // 判断帐号是否可以支付平安订单
    BOOL insurance_pay = [UserAccount sharedInfo].appfunction.insurance_pay.enable && IsLogin();
    __weak typeof(self) wself = self;
    if (!insurance_pay) {
        UIView * noClickableView = [[UIView alloc] init];
        noClickableView.userInteractionEnabled = YES;
        //
        noClickableView.backgroundColor = RGBColor(170, 170, 170, 0.44);
        [wself.view addSubview:noClickableView];
        
        __weak G100InsuranceWebViewController * wself = self;
        [noClickableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wself.webView);
        }];
    }
}

- (void)loadWebPageWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

#pragma mark - UIWebView相关协议
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString * str = [request.URL absoluteString];
    
    NSDictionary * dict = [str paramsFromURL];
    
    NSString * protocal = [dict objectForKey:@"PROTOCOL"];
    if ([protocal isEqualToString:@"qwsapp"]) {
        
        [self payFinished];
        
        return NO;
    }
    
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([webView canGoBack]) {
        self.closeBtn.hidden = NO;
    }else{
        self.closeBtn.hidden = YES;
    }
    NSString * title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (!title.length) {
        title = @"平安商城";
    }
    self.webTitleLabel.text = title;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"平安商城加载失败 - %@", error.userInfo);
}

-(void)payFinished {
    // 请求之前先创建一个request
    __block ApiRequest *request;
    __weak G100InsuranceWebViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        // 请求完成后 从容器中移除这个request
        [wself api_removeApiRequest:request];
        if (requestSuccess) {
            // 支付成功     // 跳转到保险页面
            [[UserManager shareManager] updateUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid] complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    if (wself.paySuccessCallback) {
                        wself.paySuccessCallback();
                    }
                    
                    [wself.navigationController popToViewController:[wself.navigationController.viewControllers safe_objectAtIndex:1] animated:YES];
                }
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    request = [[G100InsuranceApi sharedInstance] insurancePayFinishedWithOrderid:self.model.order_id callback:callback];
    // 请求发出后 将request 添加到容器中
    [self api_addApiRequest:request];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

- (IBAction)insuranceWebGoBack:(UIButton *)sender {
    if ([_webView canGoBack]) {
        [self.webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)insuranceWebCloseWebPage:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)insuranceWebShareWebPage:(UIButton *)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
