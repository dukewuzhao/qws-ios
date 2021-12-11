//
//  G100ScanViewController.m
//  G100
//
//  Created by Tilink on 15/3/1.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100ScanViewController.h"
#import "G100DevTestDomain.h"
#import "NewScanMainView.h"
#import "G100BikeApi.h"

@interface G100ScanViewController ()

@property (strong, nonatomic) NewScanMainView * mainView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (assign, nonatomic) BOOL isComplete;

@end

@implementation G100ScanViewController

-(void)dealloc {
    DLog(@"安全评分已释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:@"安全评分"];
    
    self.mainView = [[[NSBundle mainBundle] loadNibNamed:@"NewScanMainView" owner:self options:nil]lastObject];
    self.mainView.userid = self.userid;
    self.mainView.bikeid = self.bikeid;
    self.mainView.devid = self.devid;
    [self.mainView setupViewWithOwner:self];
    
    [self.view addSubview:self.mainView];
    [self.view sendSubviewToBack:_mainView];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.bottom.equalTo(-kBottomPadding);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
    
    // 确定取消按钮
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setExclusiveTouch:YES];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"ic_service_commit_btn_bg"] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取 消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [cancelBtn addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@60);
        make.bottom.equalTo(-12-kBottomPadding);
        make.left.equalTo(@15);
        make.right.equalTo(@-15);
    }];
    
    __weak G100ScanViewController * wself = self;
    self.mainView.testOverAction = ^(){
        [cancelBtn setTitle:@"完  成" forState:UIControlStateNormal];
        wself.isComplete = YES;
    };
    
    // 请求服务器最新评测数据 并开始检测
    [self sendRequestWithHasAppear:NO];
    
    [self.mainView inAnimation];
}
#pragma mark - 请求服务器最新评测数据
-(void)sendRequestWithHasAppear:(BOOL)hasAppear {
    __weak G100ScanViewController * wself = self;
    self.dataArray = [[NSMutableArray alloc] init];
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces) {
        if (requestSucces) {
            G100DevTestResultDomain * resultDomain = [[G100DevTestResultDomain alloc] initWithDictionary:response.data];
            if (resultDomain && resultDomain.security_scores.count) {
                wself.dataArray = resultDomain.security_scores.mutableCopy;
                
                wself.mainView.dataArray = wself.dataArray;
                wself.mainView.displayResult = resultDomain;
                
                if (!hasAppear) {
                    [wself.mainView startAnimation];
                } else {
                    [wself.mainView reloadResult];
                }
               
            }else {
                if (response) {
                    [wself showHint:response.errDesc];
                }
            }
        }else {
            if (response) {
                double delayInSeconds = 0.8f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [wself popViewWithMessage:response.errDesc];
                });
            } else {
                double delayInSeconds = 0.8f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [wself popViewWithMessage:@"无法进行检测，请连接无线网或打开蜂窝网络后重试"];
                });
            }
        }
    };
    
    [[G100BikeApi sharedInstance] evaluatingBikeSafetyScoreWithBikeid:self.bikeid callback:callback];
}

#pragma mark - 信息错误提醒
-(void)popViewWithMessage:(NSString *)message {
    __weak G100ScanViewController * wself = self;
    G100StatusPopingView * popview = [G100StatusPopingView popingViewWithStatusView];
    popview.backgorundTouchEnable = NO;
    [popview showPopingViewWithMessage:message confirmTitle:@"我知道了" clickEvent:^(NSInteger index) {
        if (index == 2) {
            [wself.navigationController popViewControllerAnimated:YES];
        }
    } onViewController:self onBaseView:self.view];
}

-(void)cancelButtonClick:(UIButton *)button {
    [self actionClickNavigationBarLeftButton];
}

#pragma mark - 重写返回事件
-(void)actionClickNavigationBarLeftButton {
    [self.mainView endAnimation];
    if (self.isComplete) {
        if (self.testOverAnimter) {
            self.testOverAnimter(self.mainView.testResult);
        }
        self.isComplete = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setIsPopAppear:(BOOL)isPopAppear {
    [super setIsPopAppear:isPopAppear];
    self.mainView.isPopAppear = isPopAppear;
}

#pragma mark - Life Cycle
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self.mainView viewDidDisappear];
    [self setNavigationBarViewColor:MyGreenColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self setNavigationBarViewColor:[UIColor clearColor]];
    
    if (self.hasAppear) {
        [self sendRequestWithHasAppear:YES];
    }
    self.hasAppear = YES;
   
    [self.mainView viewWillAppear];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self.mainView viewDidAppear];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.mainView viewWillDisappear];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
