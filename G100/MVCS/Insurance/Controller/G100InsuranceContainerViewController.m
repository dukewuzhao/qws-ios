//
//  G100InsuranceContainerViewController.m
//  G100
//
//  Created by yuhanle on 2017/8/7.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100InsuranceContainerViewController.h"
#import "SGPageView.h"

@interface G100InsuranceContainerViewController () <SGPageTitleViewDelegate, UIScrollViewDelegate> {
    NSInteger _originalIndex;
}

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) UIScrollView *tableContainer;

@property (nonatomic, strong) NSArray *titlesArray;

@end

@implementation G100InsuranceContainerViewController

#pragma mark - SGPageTitleViewDelegate
- (void)SGPageTitleView:(SGPageTitleView *)SGPageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.tableContainer setContentOffset:CGPointMake(self.tableContainer.frame.size.width*selectedIndex, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = (self.tableContainer.contentOffset.x + 20) / self.tableContainer.frame.size.width;
    [self.pageTitleView setPageTitleViewWithProgress:1.0 originalIndex:_originalIndex targetIndex:index];
    
    _originalIndex = index;
}

- (void)setupView {
    [self setNavigationTitle:@"我的保单"];
    
    self.titlesArray = @[ @"全部", @"待支付", @"审核中", @"保障中", @"已过期" ];
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 40)
                                                        delegate:self
                                                      titleNames:self.titlesArray];
    self.pageTitleView.backgroundColor = [UIColor whiteColor];
    self.pageTitleView.titleColorStateNormal = [UIColor blackColor];
    self.pageTitleView.titleColorStateSelected = [UIColor colorWithHexString:@"#FF7200"];
    self.pageTitleView.indicatorColor = [UIColor colorWithHexString:@"#FF7200"];
    self.pageTitleView.isShowBottomSeparator = YES;
    self.pageTitleView.isNeedBounces = NO;
    self.pageTitleView.indicatorHeight = 3;
    self.pageTitleView.indicatorLengthStyle = SGIndicatorLengthTypeDefault;
    self.pageTitleView.isShowIndicator = YES;
    
    [self.contentView addSubview:_pageTitleView];
    
    self.tableContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.contentView.frame.size.width, self.contentView.frame.size.height - 40)];
    self.tableContainer.bounces = NO;
    self.tableContainer.pagingEnabled = YES;
    self.tableContainer.delegate = self;
    self.tableContainer.showsVerticalScrollIndicator = NO;
    self.tableContainer.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.tableContainer];
    
    for (NSInteger i = 0; i < self.titlesArray.count; i++) {
        G100InsuranceOrderListViewController *list = [[G100InsuranceOrderListViewController alloc] init];
        list.userid = self.userid;
        
        if (i == 0) {
            list.insuranceOrderType = InsuranceOrderAll;
        }
        else if (i == 1) {
            list.insuranceOrderType = InsuranceOrderWaitPay;
        }
        else if (i == 2) {
            list.insuranceOrderType = InsuranceOrderAuditting;
        }
        else if (i == 3) {
            list.insuranceOrderType = InsuranceOrderGuarantee;
        }
        else if (i == 4) {
            list.insuranceOrderType = InsuranceOrderExpired;
        }
        else {
            
            list.insuranceOrderType = InsuranceOrderAll;
        }
        
        list.view.frame = CGRectMake(self.tableContainer.frame.size.width * i,
                                     0,
                                     self.tableContainer.frame.size.width,
                                     self.tableContainer.frame.size.height);
        
        [self addChildViewController:list];
        [self.tableContainer addSubview:list.view];
    }
    
    self.tableContainer.contentSize = CGSizeMake(self.tableContainer.frame.size.width * self.titlesArray.count, self.tableContainer.frame.size.height);
    
    // 根据传入状态切换
    NSInteger targetIndex = 0;
    if (_insuranceOrderType == InsuranceOrderWaitPay) {
        targetIndex = 1;
    }
    else if (_insuranceOrderType == InsuranceOrderGuarantee) {
        targetIndex = 3;
    }
    else if (_insuranceOrderType == InsuranceOrderExpired) {
        targetIndex = 4;
    }
    else {
        
    }
    
    [self.tableContainer setContentOffset:CGPointMake(self.tableContainer.frame.size.width*targetIndex, 0) animated:NO];
    [self.pageTitleView setPageTitleViewWithProgress:1.0 originalIndex:targetIndex targetIndex:targetIndex];
    
    _originalIndex = targetIndex;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    
    // iOS 11 UI 显示bug 修复
    if ([self.tableContainer respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.tableContainer setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
}
- (void)dealloc{
    
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
