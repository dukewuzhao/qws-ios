//
//  G100BaseVC.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

@interface G100BaseVC ()

@property (strong, nonatomic) UIBarButtonItem   * leftBarBtn;
@property (strong, nonatomic) UIBarButtonItem   * rightBarBtn;
@property (strong, nonatomic) UIButton          * leftButton;
@property (strong, nonatomic) UILabel           * middleTitleLabel;

@end

@implementation G100BaseVC

- (void)dealloc {
    
}

+ (instancetype)loadXibViewController {
    return [[self alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

#pragma mark 初始化方法
- (void)loadNavigationBar {
    self.navigationController.navigationBarHidden = YES;
    self.navigationBarView = [[Tilink_BaseNavigationBarView alloc] init];
    [self.view addSubview:self.navigationBarView];
    
    [_navigationBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(IOS_VERSION_CODE > 6 ? 0 : -20);
        make.height.equalTo(kNavigationBarHeight);
    }];
    
    [self setupNavigationBarView];
}
- (void)setupBaseSysNavigationBarView {
    [self loadNavigationBar];
    
    CGFloat containerX = 0;
    CGFloat containerY = kNavigationBarHeight;
    CGFloat containerW = CGRectGetWidth(self.view.frame);
    CGFloat containerH = CGRectGetHeight(self.view.frame) - kNavigationBarHeight - kBottomHeight;
    
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(containerX, containerY, containerW, containerH)];
    self.contentView.backgroundColor = MyBackColor;
    self.contentView.clipsToBounds = YES;
    [self.view addSubview:self.contentView];
    
    [self.navigationBarView.leftBarButton addTarget:self action:@selector(actionClickNavigationBarLeftButton) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.leftBarButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    
    [self.view sendSubviewToBack:self.contentView];
}
- (void)setLeftBarButtonHidden:(BOOL)leftBarButtonHidden {
    self.navigationBarView.leftBarButton.hidden = leftBarButtonHidden;
}
- (void)setRightNavgationButton:(UIButton *)rightNavgationButton {
    _rightNavgationButton = rightNavgationButton;
    [self.navigationBarView setRightBarButton:rightNavgationButton];
}

#pragma mark - 定制导航栏
- (void)setupNavigationBarView {
    
}
#pragma mark - 设置标题
- (void)setNavigationTitle:(NSString *)title {
    [self.navigationBarView setNavigationTitleLabelText:title];
}
- (void)setNavigationBarViewColor:(UIColor *)color {
    self.navigationBarView.backgroundColor = color;
}

- (void)setNavigationTitleAlpha:(CGFloat)alpha {
    [self.navigationBarView setNavigationTitleLabelAlpha:alpha];
}

#pragma mark - 返回事件
- (void)actionClickNavigationBarLeftButton {
    if (![self.navigationController.viewControllers[0] isKindOfClass:[self class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)popToAnyViewController:(NSString *)viewController animated:(BOOL)animated {
    G100BaseVC * tmpVC = nil;
    for (UIViewController * obj in self.navigationController.viewControllers) {
        if ([obj isKindOfClass:[NSClassFromString(viewController) class]]) {
            tmpVC = (G100BaseVC *)obj;
            break;
        }
    }
    if (tmpVC) {
        [self.navigationController popToViewController:tmpVC animated:animated];
        return YES;
    }
    
    return NO;
}

- (void)pushNextViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isPopAppear = YES;
    [self.navigationController pushViewController:viewController animated:animated];
}

#pragma mark - 弹框计数
- (void)addPopViewCount {
    self.popViewCount++;
}
- (void)reducePopViewCount {
    if (self.popViewCount > 0) {
        self.popViewCount--;
    }
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [IQKeyHelper setKeyboardDistanceFromTextField:12];
    self.view.backgroundColor = MyBackColor;
    
    // 导航栏布局
    [self setupBaseSysNavigationBarView];
    
    self.hasAppear = NO;
    self.isPopAppear = NO;
    self.schemeBlockExecuted = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (_popViewCount != 0) { // 判断当前vc的弹出框个数
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }else {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_schemeBlockExecuted) {
        _schemeBlockExecuted = YES;
        
        if (_schemeOverBlock) {
            self.schemeOverBlock();
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
