//
//  G100CardInsuranceViewController.m
//  G100
//
//  Created by sunjingjing on 16/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardInsuranceViewController.h"
#import "G100InsuranceCardView.h"
#import "G100InsuranceManager.h"

@interface G100CardInsuranceViewController () <G100InsuranceTapDelegate>

@property (strong, nonatomic) G100InsuranceCardView *insuranceCardView;
@property (strong, nonatomic) G100InsuranceManager *insuranceManager;
@property (strong, nonatomic) G100InsuranceBannerList *bannerList;

@end

@implementation G100CardInsuranceViewController

- (void)dealloc {
    DLog(@"保险卡片已释放");
}

#pragma mark - Lazy load
- (G100InsuranceCardView *)insuranceCardView {
    if (!_insuranceCardView) {
        _insuranceCardView = [G100InsuranceCardView showView];
        _insuranceCardView.delegate = self;
    }
    return _insuranceCardView;
}

-(G100InsuranceManager *)insuranceManager {
    if (!_insuranceManager) {
        _insuranceManager = [[G100InsuranceManager alloc] init];
    }
    return _insuranceManager;
}

#pragma mark - G100InsuranceTapDelegate
-(void)viewTapedToPushDetail:(UIView *)view{
    if (self.insuranceCardView.insuranceBanner.button.url.length) {
        [G100Router openURL:self.insuranceCardView.insuranceBanner.button.url];
    }
}

#pragma mark - Public Method
- (void)setCardModel:(G100CardModel *)cardModel {
    _cardModel = cardModel;
    self.insuranceCardView.insuranceBanner = cardModel.banner;
}

#pragma mark - setupView
- (void)setupView {
    [self.view addSubview:self.insuranceCardView];
    [self.insuranceCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
