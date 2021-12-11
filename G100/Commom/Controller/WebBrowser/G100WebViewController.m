//
//  G100WebViewController.m
//  G100
//
//  Created by 温世波 on 15/12/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100WebViewController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

#import "ExtString.h"
#import "G100UMSocialHelper.h"
#import "G100InsuranceApi.h"

#import "G100Router.h"
#import "G100JSNativeService.h"
#import <WebKit/WebKit.h>
NSString *kGNWebRebindNotification = @"web_rebind_notification";

@interface G100WebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate> {
    IBOutlet NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    dispatch_queue_t queue;
    dispatch_source_t _timer;
}

@property (nonatomic, weak) IBOutlet UIView *refreshHintView;
@property (nonatomic, weak) IBOutlet UILabel *errorHintLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightConstraint;

@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSURLRequest *currentLoadingUrlRequest;

/**
 *  当网页有弹窗时 盖住导航栏 避免再次点击操作
 */
@property (nonatomic, strong) UIView *hitView;

@end

@implementation G100WebViewController

+ (instancetype)loadNibWebViewController {
    G100WebViewController *webBrowser = [[G100WebViewController alloc] initWithNibName:@"G100WebViewController" bundle:nil];
    webBrowser.isAllowInpourJS = YES;
    webBrowser.isAllowBackSlip = YES;
    return webBrowser;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.isAllowInpourJS = YES;
        self.isAllowBackSlip = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidCreateContextNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 监听可以注入js 方法的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateJSContext:) name:@"DidCreateContextNotification" object:nil];
    self.navigationBarView.hidden = YES;
    self.hitView = [[UIView alloc] init];
    [self.view addSubview:self.hitView];
    self.navigationHeightConstraint.constant = kNavigationBarHeight;
    
    [self.hitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.navigationBarView);
    }];
    
    self.hitView.hidden = YES;
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 判断是否需要全屏显示
    if ([_httpUrl hasContainString:@"fullscreen=1"]) {
        self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight - 44;
        [self.view bringSubviewToFront:self.substanceView];
        self.navigationBarView.backgroundColor = [UIColor whiteColor];
    }else {
        self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight;
    }
    
    self.substanceViewtoBottomConstraint.constant = 0;
    // iOS 11 UI 显示bug 修复
    if ([self.webView.scrollView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.webView.scrollView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    _previousInteractivePopGestureEnabled = self.navigationController.interactivePopGestureRecognizer.enabled;
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    if (![self.filename length] && [self.httpUrl length]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.httpUrl]]];
        IDLog(IDLogTypeInfo, @"webView Request Url = %@", self.httpUrl);
    }else {
        NSString *path = [[NSBundle mainBundle] pathForResource:self.filename ofType:nil];
        
        if (path) {
            // 判断是否是消息模板
            if (self.msg_title || self.msg_desc) {
                [self.webView loadHTMLString:[self loadHTMLByStringFormat:self.msg_title desc:self.msg_desc] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
            }else {
                NSURL *url = [NSURL fileURLWithPath:path];
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
            }
        }else {
            self.webTitleLabel.text = @"出错啦";
            [self showHint:@"出错啦"];
        }
        
        IDLog(IDLogTypeInfo, @"webView Request FileName = %@", self.filename);
    }

}

- (NSString *)loadHTMLByStringFormat:(NSString *)title desc:(NSString *)desc {
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:self.filename ofType:nil];
    NSMutableString *html = [[NSMutableString alloc] initWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    [html replaceOccurrencesOfString:@"{title}" withString:title options:NSCaseInsensitiveSearch range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"{desc}" withString:desc options:NSCaseInsensitiveSearch range:NSMakeRange(0, html.length)];
    return html;
}

#pragma mark - UIWebView相关协议
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_timer) {
        __weak G100WebViewController *wself = self;
        dispatch_source_cancel(_timer);
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置界面的按钮显示 根据自己需求设置
            wself.refreshHintView.hidden = YES;
        });
        _timer = nil;
    }
    
    if ([webView canGoBack]) {
        self.closeBtn.hidden = NO;
    }else{
        self.closeBtn.hidden = YES;
    }
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (![webView canGoBack]) {
        if (_webTitle && _webTitle.length) {
            title = _webTitle;
        }
    }
    
    if (!title.length) {
        title = @"详情";
    }
    self.webTitleLabel.text = title;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"webview didFailLoadWithError %@ , and err is %@", webView.debugDescription, error.debugDescription);
    
    NSString *url = error.userInfo[@"NSErrorFailingURLStringKey"];
    if ([url hasContainString:@"tmall"] || [url hasContainString:@"taobao"]) {
        return;
    }
    
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    __weak G100WebViewController *wself = self;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    __block int timeout = 100; //倒计时时间
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0), 0.03*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                wself.webTitleLabel.text = @"出错啦";
                wself.refreshHintView.hidden = NO;
                wself.errorHintLabel.text = error.userInfo[@"NSLocalizedDescription"];
                [_progressView setProgress:0.0f animated:NO];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_progressView setProgress:(100-timeout)/100.0f animated:YES];
            });
            timeout--;
        }
    }); 
    dispatch_resume(_timer);
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    self.hitView.hidden = YES;
    self.refreshHintView.hidden = YES;
    
    NSString * str = [request.URL absoluteString];
    [self fullScreenAccordingtoLoadingUrl:str];
    NSDictionary * dict = [str paramsFromURL];
    self.currentLoadingUrlRequest = request;
    
    NSString * protocal = [dict objectForKey:@"PROTOCOL"];
    NSString * host     = [dict objectForKey:@"HOST"];
    NSDictionary *paramDict = [dict objectForKey:@"PARAMS"];
    
    // 先判断是否是平安银行支付页面
    if ([protocal isEqualToString:@"qwsapp"] && [str hasContainString:@"insurance/pay"]) {
        [self payFinished];
        return NO;
    }
    
    // 如果是在加载网页 显示标题为 Loading
    if ([protocal isEqualToString:@"http"] ||
        [protocal isEqualToString:@"https"]) {
        self.webTitleLabel.text = @"加载中";
    }
    
    if ([protocal isEqualToString:@"qwsapp"]) {
        if ([host isEqualToString:@"tel"]) {
            NSString *teleStr = [paramDict objectForKey:@"pn"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", teleStr]]];
        }else if ([host isEqualToString:@"close"]) { //需要关闭当前webView后再打开新的页面
            NSString *typeStr = [paramDict objectForKey:@"goto"];
            if (!typeStr) {
                // 判断关闭的时候 是否需要做其他操作
                if (_whenWebCloseTodoEventBlock) {
                    __weak G100WebViewController *wself = self;
                    self.whenWebCloseTodoEventBlock(^(){[wself exitPopSelf];});
                }else {
                    [self exitPopSelf];
                }
            }else {
                NSString *pageName = [paramDict objectForKey:@"goto"];
                // 跳转制定页面
                NSString * appPageDefinitionPath = [[NSBundle mainBundle] pathForResource:@"PageDefinition" ofType:@"plist"];
                NSMutableDictionary * appPageDict = [[NSMutableDictionary alloc] initWithContentsOfFile:appPageDefinitionPath];
                
                // 找到对应的class
                NSArray * allkeys = [appPageDict allKeys];
                if ([allkeys containsObject:pageName]) {
                    
                    if ([pageName isEqualToString:@"my"] || [pageName isEqualToString:@"home"]) {
                        // 跳转到主页
                        if (self.navigationController.viewControllers.count > 1) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }else {
                            
                        }
                        
                        if ([pageName isEqualToString:@"my"]) {
                            
                        }else if ([pageName isEqualToString:@"home"]) {
                            
                        }
                    }else {
                        NSDictionary * pageInfo = [appPageDict objectForKey:pageName];
                        
                        NSString * pageclassName = pageInfo[@"pageclass"];
                        Class class = NSClassFromString(pageclassName);
                        
                        G100BaseVC *aPage = [[class alloc] init];
                        if ([aPage respondsToSelector:@selector(setDevid:)]) {
                            [aPage setValue:self.devid forKey:@"devid"];
                        }
                        
                        if ([aPage respondsToSelector:@selector(setUserid:)]) {
                            [aPage setValue:self.userid forKey:@"userid"];
                        }
                        
                        if ([pageclassName isEqualToString:@"G100BindDevViewController"]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kGNWebRebindNotification object:nil userInfo:nil];
                        }
                        
                        if ([self popToAnyViewController:pageclassName animated:YES]) {
                            
                        }else {
                            NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
                            [viewControllers removeLastObject];//删除当前页面
                            [viewControllers addObject:aPage];
                            [self.navigationController setViewControllers:viewControllers animated:YES];
                        }
                    }
                }else {
                    DLog(@"跳转制定的页面%@ 不存在！！！", pageName);
                }
            }
        }else if ([host isEqualToString:@"goto"]) {//直接跳转新的页面
            NSString *pageName = [paramDict objectForKey:@"page"];
            // 跳转制定页面
            NSString * appPageDefinitionPath = [[NSBundle mainBundle] pathForResource:@"PageDefinition" ofType:@"plist"];
            NSMutableDictionary * appPageDict = [[NSMutableDictionary alloc] initWithContentsOfFile:appPageDefinitionPath];
            
            // 找到对应的class
            NSArray * allkeys = [appPageDict allKeys];
            if ([allkeys containsObject:pageName]) {
                
                if ([pageName isEqualToString:@"my"] || [pageName isEqualToString:@"home"]) {
                    // 跳转到主页
                    if (self.navigationController.viewControllers.count > 1) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }else {
                        
                    }
                    
                    if ([pageName isEqualToString:@"my"]) {
                        
                    }else if ([pageName isEqualToString:@"home"]) {
                        
                    }
                }else {
                    NSDictionary * pageInfo = [appPageDict objectForKey:pageName];
                    
                    NSString * pageclassName = pageInfo[@"pageclass"];
                    Class class = NSClassFromString(pageclassName);
                    
                    G100BaseVC *aPage = [[class alloc] init];
                    if ([aPage respondsToSelector:@selector(setDevid:)]) {
                        [aPage setValue:EMPTY_IF_NIL(self.devid) forKey:@"devid"];
                    }
                    
                    if ([aPage respondsToSelector:@selector(setUserid:)]) {
                        [aPage setValue:[[G100InfoHelper shareInstance] buserid] forKey:@"userid"];
                    }
                    
                    if ([pageclassName isEqualToString:@"G100BindDevViewController"]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kGNWebRebindNotification object:nil userInfo:nil];
                    }
                    
                    [self.navigationController pushViewController:aPage animated:YES];
                }
            }else {
                DLog(@"跳转制定的页面%@ 不存在！！！", pageName);
            }
        }else if ([host isEqualToString:@"share"]) {
            // 分享
            [self shareWebPage:nil];
        }else{
            [G100Router openURL:str];
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma mark - 可以注入js 的监听
- (void)didCreateJSContext:(NSNotification *)notification {
    NSString *indentifier = [NSString stringWithFormat:@"indentifier%lud", (unsigned long)self.webView.hash];
    NSString *indentifierJS = [NSString stringWithFormat:@"var %@ = '%@'", indentifier, indentifier];
    [self.webView stringByEvaluatingJavaScriptFromString:indentifierJS];
    
    JSContext *context = notification.object;
    
    if (![context[indentifier].toString isEqualToString:indentifier]) return;
    
    // 判断是否允许注入JS代码
    if (_isAllowInpourJS) {
        self.jsContext = context;
        // 通过模型调用方法，这种方式更好些。
        QWSJsObjCModel *model  = [[QWSJsObjCModel alloc] init];
        self.jsContext[@"nativeObj"] = model;
        model.jsContext = self.jsContext;
        model.webView   = self.webView;
        model.webVc     = self;
        
        self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
            context.exception = exceptionValue;
            DLog(@"异常信息：%@", exceptionValue);
        };
    }
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 判断是否需要全屏显示
    if ([self.currentLoadingUrlRequest.URL.absoluteString hasContainString:@"fullscreen=1"]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else {
        self.navigationController.interactivePopGestureRecognizer.enabled = self.isAllowBackSlip;
    }
    
    if (!self.hasAppear) {
        _previousInteractivePopGestureEnabled = self.navigationController.interactivePopGestureRecognizer.enabled;
    }
    self.hasAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = _previousInteractivePopGestureEnabled;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 中文网址编码
- (void)setHttpUrl:(NSString *)httpUrl {
    NSAssert(httpUrl.length != 0, @"httpUrl can not be nil");
    
    NSMutableString *realHttpUrl = [NSMutableString stringWithString:httpUrl];
    NSString *mmQwskey = [[NSString stringWithFormat:@"%@%@", [G100InfoHelper shareInstance].token, httpUrl] stringFromMD5];
    self.qwsKey = mmQwskey;
    
    // 先匹配模板
    if ([realHttpUrl hasContainString:@"{token}"]) {
        // 需要token
        realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{token}" withString:[[G100InfoHelper shareInstance] token]] mutableCopy];
    }
    
    if ([realHttpUrl hasContainString:@"{qwskey}"]) {
        self.qwsKey = mmQwskey;
        realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{qwskey}" withString:mmQwskey] mutableCopy];
    }
    
    if ([realHttpUrl hasContainString:@"{version}"]) {
        // 需要版本号
        realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{version}" withString:[NSString stringWithFormat:@"V%@", [[G100InfoHelper shareInstance] appVersion]]] mutableCopy];
    }
    
    if ([realHttpUrl hasContainString:@"{platform}"]) {
        // 需要平台
        realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{platform}" withString:@"ios"] mutableCopy];
    }
    
    if ([realHttpUrl hasContainString:@"{userid}"]) {
        // 需要用户id
        self.userid = [[G100InfoHelper shareInstance] buserid];
        realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{userid}" withString:self.userid] mutableCopy];
    }
    
    // 匹配参数
    if ([realHttpUrl is360qwsHost]) {
        if (![realHttpUrl hasContainString:@"qwskey"]) {
            realHttpUrl = [[realHttpUrl appendUrlWithParamter:[NSString stringWithFormat:@"qwskey=%@", mmQwskey]] mutableCopy];
        }else {
            if ([realHttpUrl hasContainString:@"{qwskey}"]) {
                realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{qwskey}" withString:mmQwskey] mutableCopy];
            }
        }
    } else {
        if ([realHttpUrl hasContainString:@"{qwskey}"]) {
            realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{qwskey}" withString:mmQwskey] mutableCopy];
        }
    }
    
    if (![realHttpUrl hasContainString:@"qwskey"]) {
        if ([realHttpUrl is360qwsHost]) {
            realHttpUrl = [[realHttpUrl appendUrlWithParamter:[NSString stringWithFormat:@"qwskey=%@", mmQwskey]] mutableCopy];
        }
    }else {
        if ([realHttpUrl is360qwsHost]) {
            // 包含 qwskey 的话 赋值给webVC
        } else {
        }
    }
    
    if (![realHttpUrl hasContainString:@"userid"] && self.userid) {
        realHttpUrl = [[realHttpUrl appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@", self.userid]] mutableCopy];
    }else if (!self.userid.length) {
        self.userid = [[G100InfoHelper shareInstance] buserid];
        realHttpUrl = [[realHttpUrl appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@", self.userid]] mutableCopy];
    }
    
    if (![realHttpUrl hasContainString:@"bikeid"] && self.bikeid) {
        realHttpUrl = [[realHttpUrl appendUrlWithParamter:[NSString stringWithFormat:@"bikeid=%@", self.bikeid]] mutableCopy];
    }
    
    if (![realHttpUrl hasContainString:@"devid"] && self.devid) {
        realHttpUrl = [[realHttpUrl appendUrlWithParamter:[NSString stringWithFormat:@"devid=%@", self.devid]] mutableCopy];
    }
    
    if (![realHttpUrl hasContainString:@"appversion"]) {
        NSString *app_Version = [NSString stringWithFormat:@"V%@", [[G100InfoHelper shareInstance] appVersion]];
        realHttpUrl = [[realHttpUrl appendUrlWithParamter:[NSString stringWithFormat:@"appversion=%@", app_Version]] mutableCopy];
    }
    
    if (![realHttpUrl hasContainString:@"platform"]) {
        realHttpUrl = [[realHttpUrl appendUrlWithParamter:@"platform=ios"] mutableCopy];
    }
    NSMutableCharacterSet *mutableCharSet = [[NSMutableCharacterSet alloc] init];
    [mutableCharSet formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [mutableCharSet addCharactersInString:@"#"]; // 允许#不被转义
    NSCharacterSet *charSet = mutableCharSet.copy;
    _httpUrl = [realHttpUrl stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    // 如果有 则获取订单号
    NSDictionary *dict = [_httpUrl paramsFromURL];
    NSDictionary *params = dict[PARAMS];
    
    if (params[@"qws_order_id"]) {
        self.order_id = params[@"qws_order_id"];
    }
}

#pragma mark - 否需要全屏显示
- (void)fullScreenAccordingtoLoadingUrl:(NSString *)url {
    if (![url hasPrefix:@"http"]) {
        return;
    }
    
    // 判断是否需要全屏显示 全屏不允许侧滑返回
    if ([url hasContainString:@"fullscreen=1"]) {
        self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight - 44;
        [UIView animateWithDuration:0.3f animations:^{
            [self.substanceView layoutIfNeeded];
            [self.substanceView layoutSubviews];
        }];
        
        for (id subview in self.webView.subviews) {
            if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
                ((UIScrollView *)subview).bounces = NO;
            }
        }
    }else {
        self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight;
        [UIView animateWithDuration:0.3f animations:^{
            [self.substanceView layoutIfNeeded];
            [self.substanceView layoutSubviews];
        }];
        
        for (id subview in self.webView.subviews) {
            if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
                ((UIScrollView *)subview).bounces = YES;
            }
        }
    }
}

- (void)payFinished {
    // 请求之前先创建一个request
    __block ApiRequest *request;
    __weak G100WebViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        // 请求完成后 从容器中移除这个request
        [wself api_removeApiRequest:request];
        if (requestSuccess) {
            // 支付成功
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    request = [[G100InsuranceApi sharedInstance] insurancePayFinishedWithOrderid:[self.order_id integerValue] callback:callback];
    // 请求发出后 将request 添加到容器中
    [self api_addApiRequest:request];
}

#pragma mark - Private Method
- (void)exitPopSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)getBack:(UIButton *)sender {
    if ([_webView canGoBack]) {
        [self.webView goBack];
    }else {
        [self closeWebPage:nil];
    }
    
    self.hitView.hidden = YES;
}

- (IBAction)closeWebPage:(UIButton *)sender {
    if (self.exitJSCallback.length) {
        // 调用js 方法
        JSValue * function = self.jsContext[self.exitJSCallback];
        [function callWithArguments:nil];
        
        self.hitView.hidden = NO;
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)shareWebPage:(UIButton *)sender {
    // 调用网页提供的分享数据
    NSString *shareJSONStr = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"share\")[0].content"];
    NSLog(@"share = %@", shareJSONStr);
    [[G100UMSocialHelper shareInstance] showShareWithShareJSONStr:shareJSONStr onViewController:self selected:nil complete:nil];
}
- (IBAction)refreshCurrentWebPage:(UIButton *)sender {
    [self.webView loadRequest:self.currentLoadingUrlRequest];
}

- (void)setNavigationViewClickEnabled:(BOOL)enabled {
    self.hitView.hidden = enabled;
}

@end

@implementation NSObject (JSTest)

- (void)webView:(id)unuse didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)frame {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreateContextNotification" object:ctx];
}

@end
