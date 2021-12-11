//
//  G100DevFindInspirationViewController.m
//  G100
//
//  Created by yuhanle on 16/4/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevFindInspirationViewController.h"
#import "G100DevUnderFindingViewController.h"
#import "G100DevLostListDomain.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

#import "G100UMSocialHelper.h"
#import "G100DevLostInfoViewController.h"
#import "G100WebViewController.h"
#import "G100BikeApi.h"
#import "G100UrlManager.h"

@interface G100DevFindInspirationViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate> {
    IBOutlet NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *webTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (nonatomic, strong) UIView *bottomView; // 底部按钮 告诉亲朋 开始寻车
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationViewConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subStanceViewConstraintBottom;

@property (nonatomic, strong) G100DevLostDomain *lostDomain;
@property (nonatomic, assign) NSInteger shareid;

@end

@implementation G100DevFindInspirationViewController

#pragma mark - 跳转
- (void)tl_bottomButtonClick:(UIButton *)button {
    switch (button.tag) {
        case 100:
        {
            // 分享并寻车
            __weak G100DevFindInspirationViewController *wself = self;
            // 调用网页提供的分享数据
            NSString *shareJSONStr = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"share\")[0].content"];
            if (!shareJSONStr || !shareJSONStr.length) {
                return;
            }
            
            NSData *jsonData = [shareJSONStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&err];
            UMShareModel *umShareModel = nil;
            if(err) {
                DLog(@"json解析失败：%@", err);
            }else {
                for (NSDictionary *dict in result) {
                    umShareModel = [[UMShareModel alloc] initWithDictionary:dict];
                    break;
                }
            }
            
            [[G100UMSocialHelper shareInstance] showShareWithShareJSONStr:shareJSONStr onViewController:self selected:^(NSInteger shareto) {
                [wself jumpToTheUnderFindingCarViewController];
                [[G100BikeApi sharedInstance] shareBikeLostWithLostid:wself.lostid bikeid:wself.bikeid shareurl:umShareModel.shareJumpUrl callback:nil];
            } complete:nil];
        }
            break;
        case 200:
        {
            [self jumpToTheUnderFindingCarViewController];
        }
            break;
        default:
            break;
    }
}

- (void)jumpToTheUnderFindingCarViewController {
    NSArray *vcs = [self.navigationController viewControllers];
    G100DevUnderFindingViewController * underFinding = [[G100DevUnderFindingViewController alloc] init];
    underFinding.userid = self.userid;
    underFinding.bikeid = self.bikeid;
    underFinding.devid  = self.devid;
    underFinding.lostid = self.lostid;
    NSMutableArray *newVcs = [[NSMutableArray alloc] init];
    for (UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[G100DevUnderFindingViewController class]] ||
            [vc isKindOfClass:[G100DevLostInfoViewController class]] ||
            [vc isKindOfClass:[self class]]) {
            break;
        }
        [newVcs addObject:vc];
    }
    [newVcs addObject:underFinding];
    
    // 判断是否是首次开始寻车 是的话先跳转到寻车提示
    if ([[G100InfoHelper shareInstance] leftRemainderTimesWithKey:@"tipstofind_car"]) {
        G100WebViewController * webVc = [[G100WebViewController alloc] initWithNibName:@"G100WebViewController" bundle:nil];
        webVc.httpUrl = [[G100UrlManager sharedInstance] getFindCarTipsUrlWithUserid:self.userid bikeid:nil devid:self.devid];
        [self.navigationController pushViewController:webVc animated:YES];
        [newVcs addObject:webVc];
    }
    
    [self.navigationController setViewControllers:newVcs animated:YES];
}

- (void)getShareContent:(BOOL)showHUD {
    if (kNetworkNotReachability) {
        return;
    }
    __weak G100DevFindInspirationViewController * wself = self;
    if (showHUD) [self showHudInView:self.contentView hint:@"请稍候"];
    [[G100BikeApi sharedInstance] getBikeLostRecordWithBikeid:self.bikeid lostid:@[[NSNumber numberWithInteger:self.lostid]] callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (showHUD) [wself hideHud];
        if (requestSuccess) {
            G100DevLostListDomain *lostListDomain = [[G100DevLostListDomain alloc]initWithDictionary:response.data];
            if (lostListDomain.lost.count > 0) {
                self.lostDomain = [lostListDomain.lost firstObject];
                self.lostid = self.lostDomain.lostid;
                self.shareid = [self.lostDomain shareid];
                
                G100BikeFeatureDomain *featureDomain = [[G100InfoHelper shareInstance] findMyBikeFeatureWithUserid:wself.userid bikeid:wself.bikeid];
                [[G100UMSocialHelper shareInstance] loadShareWithShareid:[self.lostDomain shareid]
                                                                shareUrl:self.lostDomain.shareurl
                                                                sharePic:featureDomain.pictures.firstObject
                                                                complete:nil];
            }
        }else{
            [self showHint:response.errDesc];
        }
    }];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([webView canGoBack]) {
        self.closeBtn.hidden = NO;
    }else{
        self.closeBtn.hidden = YES;
    }
    NSString * title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (!title.length) {
        title = @"详情";
    }
    
    self.webTitleLabel.text = title;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma mark - setupData
- (void)setupData {
    
}

- (void)setHttpUrl:(NSString *)httpUrl {
    _httpUrl = [httpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = RGBColor(20, 20, 20, 1.0f);
        
        // 告诉亲朋
        UIButton *button0 = [UIButton buttonWithType:UIButtonTypeCustom];
        button0.tag = 100;
        button0.titleLabel.font = [UIFont systemFontOfSize:18];
        [button0 setTitle:@"告诉亲朋" forState:UIControlStateNormal];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(9, 9, 9, 9);
        UIImage *normalImage    = [[UIImage imageNamed:@"ic_alarm_option_yes_up"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        UIImage *highlitedImage = [[UIImage imageNamed:@"ic_alarm_option_yes_down"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        [button0 addTarget:self action:@selector(tl_bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button0 setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button0 setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        // 开始寻车
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.tag = 200;
        button1.titleLabel.font = [UIFont systemFontOfSize:18];
        [button1 setTitle:@"开始寻车" forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(tl_bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button1 setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button1 setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        [_bottomView addSubview:button0];
        [_bottomView addSubview:button1];
        
        [button0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@5);
            make.width.equalTo(button1);
            make.leading.equalTo(@20);
            make.trailing.equalTo(button1.mas_leading).with.offset(@-20);
            make.height.equalTo(@40);
        }];
        
        [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(button0);
            make.trailing.equalTo(@-20);
        }];
    }
    return _bottomView;
}

- (void)setupView {
    self.navigationBarView.hidden = YES;
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(kBottomHeight);
        make.height.equalTo(50+kBottomPadding);
    }];
    
    self.subStanceViewConstraintBottom.constant = kBottomHeight + 50;
    self.navigationViewConstraintH.constant = kNavigationBarHeight;
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)setupNavigationBarView {
    [super setupNavigationBarView];
    
    [self setNavigationTitle:@"寻车启事"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupData];
    
    [self setupView];
    
    // iOS 11 UI 显示bug 修复
    if ([self.webView.scrollView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.webView.scrollView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    // 获取分享的 id
    [self getShareContent:NO];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.httpUrl]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getBack:(UIButton *)sender {
    if ([_webView canGoBack]) {
        [self.webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)closeWebPage:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareWebPage:(UIButton *)sender {
    __weak G100DevFindInspirationViewController *wself = self;
    // 调用网页提供的分享数据
    NSString *shareJSONStr = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"share\")[0].content"];
    [[G100UMSocialHelper shareInstance] showShareWithShareJSONStr:shareJSONStr onViewController:self selected:^(NSInteger shareto) {
        [wself jumpToTheUnderFindingCarViewController];
    } complete:nil];
}

@end
