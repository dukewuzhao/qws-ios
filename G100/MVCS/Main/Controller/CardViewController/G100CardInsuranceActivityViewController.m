//
//  G100InsuranceActivityViewController.m
//  G100
//
//  Created by sunjingjing on 16/12/7.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardInsuranceActivityViewController.h"
#import "G100InsuranceActivity.h"
#import "G100InsuranceManager.h"
#import "G100Mediator+Login.h"

@interface G100CardInsuranceActivityViewController ()<G100ScrollViewDelegate>

@property (strong, nonatomic) G100InsuranceActivity *insuranceActivityView;
@property (strong, nonatomic) G100InsuranceManager *insuranceManager;
@property (strong, nonatomic) G100InsuranceCardModel *insuranceCardModel;
@end

@implementation G100CardInsuranceActivityViewController

- (void)dealloc {
    DLog(@"保险活动卡片已释放");
}

#pragma mark - Lazy load
- (G100InsuranceManager *)insuranceManager {
    if (!_insuranceManager) {
        _insuranceManager = [[G100InsuranceManager alloc] init];
    }
    return _insuranceManager;
}

#pragma mark - Public Method
- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    _insuranceCardModel = cardModel.insuranceModel;
    self.insuranceActivityView.insuranceCardModel = cardModel.insuranceModel;
}

#pragma mark - G100ScrollViewDelegate
-(void)selectedScrollViewAtIndex:(NSInteger)index OnScrollView:(G100ScrollView *)scrollView {
    if (IsLogin() == NO) {
        [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
            if ([UIApplication sharedApplication].statusBarHidden) {
                [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            }
        }];
        return;
    }
    G100InsuranceActivityDomain *activityDomain = [self.insuranceCardModel.activityList safe_objectAtIndex:index];
    if (activityDomain.url.length) {
        [G100Router openURL:activityDomain.url];
    }
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _insuranceActivityView = [[G100InsuranceActivity alloc] initWithFrame:self.view.bounds];
    _insuranceActivityView.backgroundColor = [UIColor clearColor];
    _insuranceActivityView.imageScrollView.delegate = self;
    __weak G100CardInsuranceActivityViewController *weakSelf = self;
    _insuranceActivityView.expireButtonTaped = ^(){
        if (weakSelf.insuranceCardModel.prompt.url.length) {
            [G100Router openURL:weakSelf.insuranceCardModel.prompt.url];
        }
    };
    
    [self.view addSubview:self.insuranceActivityView];
    [self.insuranceActivityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    self.insuranceActivityView.insuranceCardModel = self.insuranceCardModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
