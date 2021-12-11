//
//  G100MallViewController.m
//  G100
//
//  Created by yuhanle on 2017/7/10.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100MallViewController.h"
#import <AlibcTradeSDK/AlibcTradeSDK.h>

#define kNavigationBarHeight (ISIPHONEX ? 88 : 64)

@interface G100MallViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UILabel *webTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightConstaint;

@end

@implementation G100MallViewController

- (instancetype)init {
    if (self = [super init]) {
        [self initialData];
    }
    return self;
}

- (void)initialData {
    self.mallType = 0;
    self.pageUrl = @"https://qiweishiydhw.m.tmall.com/?spm=a222m.7628550.1998338747.2";
}

+ (instancetype)loadXibViewControllerWithType:(QWSMallType)mallType {
    G100MallViewController *vc = [[G100MallViewController alloc] initWithNibName:@"G100MallViewController" bundle:nil];
    vc.pageUrl = @"https://qiweishiydhw.m.tmall.com/?spm=a222m.7628550.1998338747.2";
    vc.mallType = mallType;

    return vc;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHud];
        
        self.closeBtn.hidden = !webView.canGoBack;
        
        NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (![webView canGoBack]) {
            if (_webTitle && _webTitle.length) {
                title = _webTitle;
            }
        }
        
        if (title.length) {
            self.webTitleLabel.text = title;
        }
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideHud];
    });
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
}

- (IBAction)closeWebPage:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 创建页面
- (id<AlibcTradePage>)alibcTradePageWithMallType:(QWSMallType)mallType {
    id <AlibcTradePage> page;
    
    if (mallType == QWSMallTypeOther) {
        page = [AlibcTradePageFactory page:self.pageUrl];
    } else if (mallType == QWSMallTypeCarts) {
        page = [AlibcTradePageFactory myCartsPage];
    } else if (mallType == QWSMallTypeOrder) {
        page = [AlibcTradePageFactory myOrdersPage:self.status isAllOrder:NO];
    } else {
        page = [AlibcTradePageFactory page:self.pageUrl];
    }
    
    return page;
}

#pragma mark - 初始化视图
- (void)setupView {
    self.navigationBarView.hidden = YES;
    self.navigationHeightConstaint.constant = kNavigationBarHeight;
    self.view.backgroundColor = [UIColor whiteColor];
    self.substanceViewtoBottomConstraint.constant = 0;
    
    if (self.mallType == QWSMallTypeOther) {
        self.webTitleLabel.text = @"骑卫士商城";
    } else if (self.mallType == QWSMallTypeCarts) {
        self.webTitle = @"购物车";
        self.webTitleLabel.text = @"购物车";
    } else if (self.mallType == QWSMallTypeOrder) {
        self.webTitle = @"淘宝订单";
        self.webTitleLabel.text = @"淘宝订单";
    } else {
        self.webTitleLabel.text = @"商城";
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // iOS 11 UI 显示bug 修复
    if ([self.webView.scrollView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.webView.scrollView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [self setupView];
    
    id <AlibcTradePage> page = [self alibcTradePageWithMallType:self.mallType];
    id <AlibcTradeService> service = [AlibcTradeSDK sharedInstance].tradeService;
    AlibcTradeShowParams *showParams = [[AlibcTradeShowParams alloc] init];
    showParams.openType = AlibcOpenTypeAuto;
    [service show:self webView:self.webView page:page showParams:showParams taoKeParams:nil trackParam:nil tradeProcessSuccessCallback:^(AlibcTradeResult * _Nullable result) {
        
    } tradeProcessFailedCallback:^(NSError * _Nullable error) {
        
    }];
    
    [self showHudInView:self.substanceView hint:@"正在加载"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
