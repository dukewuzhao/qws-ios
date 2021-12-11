//
//  G100PhotoBrowserViewController.m
//  PhotoPicker
//
//  Created by William on 16/3/23.
//  Copyright © 2016年 William. All rights reserved.
//

#import "G100PhotoBrowserViewController.h"
#import "G100PhotoBrowserCell.h"
#import "G100PhotoShowModel.h"

@interface G100PhotoBrowserViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    BOOL _statusBarShouldBeHidden;
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _viewIsActive;
    BOOL _viewHasAppearedInitially;

    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarBarTintColor;
    UIColor *_previousNavBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
    
}

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UICollectionView *browserCollectionView;
@property (nonatomic, strong) UIButton *coverBtn;

@end

@implementation G100PhotoBrowserViewController

- (instancetype)initWithPhotos:(NSArray *)photosArray
                  currentIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray arrayWithArray:photosArray];
        _currentIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self updateNavigationBarAndToolBar];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
    _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers safe_objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    // Initial appearance
    if (!_viewHasAppearedInitially) {
        _viewHasAppearedInitially = YES;
    }
    
    //scroll to the current offset
    [self.browserCollectionView setContentOffset:CGPointMake(self.browserCollectionView.frame.size.width * self.currentIndex,0)];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers safe_objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        _viewIsActive = NO;
        [self restorePreviousNavBarAppearance:animated];
    }
    
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setControlsHidden:NO animated:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)setupView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    [self browserCollectionView];
    [self coverBtn];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.deleteButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    if (!_statusBarShouldBeHidden) {
        G100PhotoShowModel *model = [self.dataArray safe_objectAtIndex:self.currentIndex];
        [UIView animateWithDuration:0.3 animations:^{
            if (model.url) {
                self.coverBtn.alpha = 1.0;
            }else {
                self.coverBtn.alpha = 0.0;
            }
        }];
    }
}

- (void)updateNavigationBarAndToolBar {
    NSUInteger totalNumber = self.dataArray.count;
    self.title = [NSString stringWithFormat:@"%tu/%lu",self.currentIndex + 1,(unsigned long)totalNumber];
}

- (UICollectionView *)browserCollectionView
{
    if (nil == _browserCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _browserCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.bounds.size.width+20, self.view.bounds.size.height+1) collectionViewLayout:layout];
        _browserCollectionView.backgroundColor = [UIColor blackColor];
        [_browserCollectionView registerClass:[G100PhotoBrowserCell class] forCellWithReuseIdentifier:NSStringFromClass([G100PhotoBrowserCell class])];
        _browserCollectionView.delegate = self;
        _browserCollectionView.dataSource = self;
        _browserCollectionView.pagingEnabled = YES;
        _browserCollectionView.showsHorizontalScrollIndicator = NO;
        _browserCollectionView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_browserCollectionView];
    }
    return _browserCollectionView;
}

- (UIButton *)coverBtn
{
    if (!_coverBtn) {
        _coverBtn = [[UIButton alloc]init];
        _coverBtn.frame = CGRectMake(0, HEIGHT - 50, WIDTH, 50);
        [_coverBtn setTitle:@"设为封面" forState:UIControlStateNormal];
        [_coverBtn setTintColor:[UIColor whiteColor]];
        [_coverBtn setBackgroundColor:[UIColor colorWithRed:0.14 green:0.14 blue:0.14 alpha:1.00]];
        [_coverBtn addTarget:self action:@selector(setCoverImage) forControlEvents:UIControlEventTouchUpInside];
        if (_isShowCoverBtn) {
            [self.view addSubview:_coverBtn];
        }
    }
    return _coverBtn;
    
}
- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, 24, 24);
        [_deleteButton setImage:[UIImage imageNamed:@"ic_btn_picture_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deletePhotoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}
- (void)setCoverImage
{
    G100PhotoShowModel *model = [self.dataArray safe_objectAtIndex:self.currentIndex];
    if ([self.delegate respondsToSelector:@selector(photoBrowserSetCoverImageUrl:)]) {
        NSString *photoUrl;
        if (model.url) {
            photoUrl = model.url;
            [self.delegate photoBrowserSetCoverImageUrl:photoUrl];
        }
    }
}
- (void)deletePhotoAction {
    [MyAlertView MyAlertWithTitle:@"提示" message:@"确定删除该张照片？" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            G100PhotoShowModel *model = [self.dataArray safe_objectAtIndex:self.currentIndex];
            if ([self.delegate respondsToSelector:@selector(photoBrowserViewController:deletedPhoto:newArray:)]) {
                NSString *photoUrl;
                if (model.url) {
                    photoUrl = model.url;
                }
                [self.dataArray removeObjectAtIndex:self.currentIndex];
                [self.delegate photoBrowserViewController:self deletedPhoto:photoUrl newArray:self.dataArray];
            }
            
            [self.browserCollectionView reloadData];
            
            if (self.deletedCompeletionBlock) {
                self.deletedCompeletionBlock(self.dataArray);
            }
            if (0 == self.dataArray.count) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            if (self.currentIndex == self.dataArray.count) {
                self.currentIndex --;
            }
            [self updateNavigationBarAndToolBar];
            
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
}

#pragma mark - Nav Bar Appearance
- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = nil;
        navBar.shadowImage = nil;
    }
    navBar.translucent = NO;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    self.extendedLayoutIncludesOpaqueBars = YES;/* 导航栏不透明时使用 */
}

- (void)storePreviousNavBarAppearance {
    _didSavePreviousStateOfNavBar = YES;
    if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
        _previousNavBarBarTintColor = self.navigationController.navigationBar.barTintColor;
    }
    _previousNavBarTranslucent = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
    _previousNavBarStyle = self.navigationController.navigationBar.barStyle;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        _previousNavigationBarBackgroundImageDefault = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    if (_didSavePreviousStateOfNavBar) {
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.tintColor = _previousNavBarTintColor;
        navBar.translucent = _previousNavBarTranslucent;
        if ([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]) {
            navBar.barTintColor = _previousNavBarBarTintColor;
        }
        navBar.barStyle = _previousNavBarStyle;
        if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
            [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
        }
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            UIViewController *previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    G100PhotoBrowserCell *cell = (G100PhotoBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([G100PhotoBrowserCell class]) forIndexPath:indexPath];
    
    cell.photoModel = [self.dataArray safe_objectAtIndex:indexPath.row];
    cell.photoBrowserViewController = self;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.view.bounds.size.width+21, self.view.bounds.size.height);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat itemWidth = CGRectGetWidth(self.browserCollectionView.frame);
    if (offsetX >= 0){
        NSInteger page = offsetX / itemWidth;
        [self didScrollToPage:page];
    }
}

- (void)didScrollToPage:(NSInteger)page {
    self.currentIndex = page;
    [self updateNavigationBarAndToolBar];
    
    if (!_statusBarShouldBeHidden) {
        G100PhotoShowModel *model = [self.dataArray safe_objectAtIndex:self.currentIndex];
        [UIView animateWithDuration:0.3 animations:^{
            if (model.url) {
                self.coverBtn.alpha = 1.0;
            }else {
                self.coverBtn.alpha = 0.0;
            }
        }];
    }
}

#pragma mark - Control Hiding / Showing
// Fades all controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated {
    
    // Force visible
    if (nil == self.dataArray || self.dataArray.count == 0)
        hidden = NO;
    // Animations & positions
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // Hide status bar
        _statusBarShouldBeHidden = hidden;
        
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationSlide];
        
        [UIView animateWithDuration:animationDuration animations:^(void) {
            [self setNeedsStatusBarAppearanceUpdate];
            [UIView animateWithDuration:animationDuration animations:^(void) {
                [self setNeedsStatusBarAppearanceUpdate];
                if (hidden) {
                    G100PhotoShowModel *model = [self.dataArray safe_objectAtIndex:self.currentIndex];
                    if (model.url) {
                        self.coverBtn.alpha = 0.0;
                    }
                } else {
                    G100PhotoShowModel *model = [self.dataArray safe_objectAtIndex:self.currentIndex];
                    if (model.url) {
                        self.coverBtn.alpha = 1.0;
                    }
                }
                
            } completion:^(BOOL finished) {}];

            
        } completion:^(BOOL finished) {}];
    }
    
    [UIView animateWithDuration:animationDuration animations:^(void) {
        CGFloat alpha = hidden ? 0 : 1;
        // Nav bar slides up on it's own on iOS 7
        [self.navigationController.navigationBar setAlpha:alpha];
        
    } completion:^(BOOL finished) {}];
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarShouldBeHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)areControlsHidden {
    return (self.navigationController.navigationBar.alpha == 0);
}
- (void)hideControls {
    [self setControlsHidden:YES animated:YES];
}
- (void)toggleControls {
    [self setControlsHidden:![self areControlsHidden] animated:YES];
}

- (void)setDelBtnHidden:(BOOL)hidden {
    self.deleteButton.hidden = hidden;
}

@end
