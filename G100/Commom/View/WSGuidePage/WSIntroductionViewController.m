//
//  WSIntroductionViewController.m
//
//  Created by 温世波 on 15/11/4.
//  Copyright © 2015年 温世波. All rights reserved.
//

#import "WSIntroductionViewController.h"
#import "WSPagerView.h"

@interface WSIntroductionViewController () <UIScrollViewDelegate, WSPagerViewDelegate>

@property (nonatomic, strong) NSArray *backgroundViews;
@property (nonatomic, strong) NSArray *scrollViewPages;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger centerPageIndex;
@property (nonatomic, strong) WSPagerView *pageView;
@property (nonatomic, strong) UIImageView *pageIndexView;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlitedImage;
@property (nonatomic, assign) BOOL isCustomPageControl;
@property (nonatomic, assign) BOOL isCustomImagePageControl;

@property (nonatomic, assign) CGFloat lastContentOffsetx;

@end

@implementation WSIntroductionViewController

- (id)initWithCoverImageNames:(NSArray *)coverNames backgroundImageNames:(NSArray *)bgNames
{
    if (self = [super init]) {
        self.isCustomPageControl = NO;
        [self initSelfWithCoverNames:coverNames backgroundImageNames:bgNames];
    }
    return self;
}

- (id)initWithCoverImageNames:(NSArray *)coverNames backgroundImageNames:(NSArray *)bgNames button:(UIButton *)button
{
    if (self = [super init]) {
        [self initSelfWithCoverNames:coverNames backgroundImageNames:bgNames];
        self.enterButton = button;
    }
    return self;
}

- (void)initSelfWithCoverNames:(NSArray *)coverNames backgroundImageNames:(NSArray *)bgNames
{
    self.coverImageNames = coverNames;
    self.backgroundImageNames = bgNames;
}

-(void)setImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage dotRadius:(CGFloat)dotRadius {
    self.normalImage = normalImage;
    self.highlitedImage = highlightedImage;
    self.dotRadius = dotRadius;
    self.isCustomPageControl = YES;
}

- (void)setIndexImageNames:(NSArray *)indexImageNames {
    _indexImageNames = indexImageNames;
    self.isCustomImagePageControl = YES;
    self.isCustomPageControl = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackgroundViews];
    
    self.pagingScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.pagingScrollView.delegate = self;
    self.pagingScrollView.pagingEnabled = YES;
    self.pagingScrollView.bounces = NO;
    self.pagingScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:self.pagingScrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:[self frameOfPageControl]];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];

    [self.view addSubview:self.pageControl];
    
    if (_isCustomPageControl) {
        [self.pageControl removeFromSuperview];
        
        self.pageView = [[WSPagerView alloc]initWithFrame:[self frameOfPageControl]];
        self.pageView.dotRadius = _dotRadius;
        [self.pageView setImage:_normalImage ? _normalImage : [UIImage imageNamed:@"index"]
               highlightedImage:_highlitedImage ? _highlitedImage : [UIImage imageNamed:@"index_sel"]
                         forKey:@"1"];
        NSMutableString * pattern = @"".mutableCopy;
        for (NSInteger i = 0; i < [self.coverImageNames count]; i++) {
            [pattern appendString:@"1"];
        }
        
        [self.pageView setPattern:pattern];
        
        self.pageView.delegate = self;
        [self.view addSubview:self.pageView];
    }
    
    if (_isCustomImagePageControl) {
        [self.pageControl removeFromSuperview];
        self.pageIndexView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.pageIndexView.image = [UIImage imageNamed:_indexImageNames[0]];
        [self.view addSubview:self.pageIndexView];
        
        [self.pageIndexView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@-20);
            make.centerX.equalTo(self.view);
            make.height.equalTo(@8);
            make.width.equalTo(@57);
        }];
    }
    
    if (!self.enterButton) {
        self.enterButton = [UIButton new];
//        [self.enterButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
        self.enterButton.layer.borderWidth = 0.5;
        self.enterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    [self.enterButton addTarget:self action:@selector(enter:) forControlEvents:UIControlEventTouchUpInside];
    //self.enterButton.frame = [self frameOfEnterButton];
    self.enterButton.alpha = 0;
    [self.view addSubview:self.enterButton];
    
    [self.enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-70);
        make.leading.equalTo(@70);
        make.trailing.equalTo(@-70);
        make.height.equalTo(@40);
    }];
    
    [self reloadPages];
}

- (void)addBackgroundViews
{
    CGRect frame = self.view.bounds;
    NSMutableArray *tmpArray = [NSMutableArray new];
    [[[[self backgroundImageNames] reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:obj]];
        imageView.frame = frame;
        imageView.tag = idx + 1;
        [tmpArray addObject:imageView];
        [self.view addSubview:imageView];
    }];

    self.backgroundViews = [[tmpArray reverseObjectEnumerator] allObjects];
}

- (void)reloadPages
{
    self.pageControl.numberOfPages = [[self coverImageNames] count];
    self.pagingScrollView.contentSize = [self contentSizeOfScrollView];
    
    __block CGFloat x = 0;
    [[self scrollViewPages] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.frame = CGRectOffset(obj.frame, x, 0);
        [self.pagingScrollView addSubview:obj];
        
        x += obj.frame.size.width;
    }];

    // fix enterButton can not presenting if ScrollView have only one page
    if (self.pageControl.numberOfPages == 1) {
        self.enterButton.alpha = 1;
        self.pageControl.alpha = 0;
    }
    
    // fix ScrollView can not scrolling if it have only one page
    if (self.pagingScrollView.contentSize.width == self.pagingScrollView.frame.size.width) {
        self.pagingScrollView.contentSize = CGSizeMake(self.pagingScrollView.contentSize.width + 1, self.pagingScrollView.contentSize.height);
    }
}

- (CGRect)frameOfPageControl
{
    return CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 20);
}

- (CGRect)frameOfEnterButton
{
    /*
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat w2h = 511 / 156.0;
    CGFloat x = 369 / 1242.0 * screenSize.width;
    CGFloat y = 949 / 2208.0 * screenSize.height;
    CGFloat w = 511 / 1242.0 * screenSize.width;
    CGFloat h = w / w2h;
    
    return CGRectMake(x, y, w, h);
     */
    return [[UIScreen mainScreen] bounds];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.view.frame.size.width;
    CGFloat alpha = 1 - ((scrollView.contentOffset.x - index * self.view.frame.size.width) / self.view.frame.size.width);
    
    if (scrollView.contentOffset.x > self.lastContentOffsetx) {
        // 左滑
        if ([self isLast:self.pageControl] ||
            scrollView.contentOffset.x < 0) {
            
        }else {
            if ([self.backgroundViews count] > index) {
                UIView *v = [self.backgroundViews objectAtIndex:index];
                if (v) {
                    [v setAlpha:alpha];
                }
            }
        }
    }else {
        // 右滑
        if ([self isFirst:self.pageControl] ||
            scrollView.contentOffset.x > ((self.pageControl.numberOfPages - 1) * self.view.frame.size.width)) {
            
        }else {
            if ([self.backgroundViews count] > index) {
                UIView *v = [self.backgroundViews objectAtIndex:index];
                if (v) {
                    [v setAlpha:alpha];
                }
            }
        }
    }
    
    self.lastContentOffsetx = scrollView.contentOffset.x;
    
    NSInteger currentIndex = scrollView.contentOffset.x / (scrollView.contentSize.width / [self numberOfPagesInPagingScrollView]);
    self.pageControl.currentPage = currentIndex;
    
    if (_isCustomImagePageControl) {
        self.pageIndexView.image = [UIImage imageNamed:_indexImageNames[currentIndex]];
    }
    
    [self pagingScrollViewDidChangePages:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        if (![self hasNext:self.pageControl]) {
//            [self enter:nil];
        }
    }
}

#pragma mark - UIScrollView & UIPageControl DataSource

- (BOOL)hasNext:(UIPageControl*)pageControl
{
    return pageControl.numberOfPages > pageControl.currentPage + 1;
}

- (BOOL)isFirst:(UIPageControl*)pageControl
{
    return pageControl.numberOfPages == 0;
}

- (BOOL)isLast:(UIPageControl*)pageControl
{
    return pageControl.numberOfPages == pageControl.currentPage + 1;
}

- (NSInteger)numberOfPagesInPagingScrollView
{
    return [[self coverImageNames] count];
}

- (void)pagingScrollViewDidChangePages:(UIScrollView *)pagingScrollView
{
    if ([self isLast:self.pageControl]) {
        if (self.pageControl.alpha == 1) {
            self.enterButton.alpha = 0;
            
            [UIView animateWithDuration:0.6 animations:^{
                self.enterButton.alpha = 1;
                self.pageControl.alpha = 0;
                self.pageView.alpha = 0;
            }];
        }
    } else {
        if (self.pageControl.alpha == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.enterButton.alpha = 0;
                self.pageControl.alpha = 1;
                self.pageView.alpha = 1;
            }];
        }
    }
}

- (BOOL)hasEnterButtonInView:(UIView*)page
{
    __block BOOL result = NO;
    [page.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj && obj == self.enterButton) {
            result = YES;
        }
    }];
    return result;
}

- (UIImageView*)scrollViewPage:(NSString*)imageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    CGSize size = {[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height};
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, size.width, size.height);
    return imageView;
}

- (NSArray*)scrollViewPages
{
    if ([self numberOfPagesInPagingScrollView] == 0) {
        return nil;
    }
    
    if (_scrollViewPages) {
        return _scrollViewPages;
    }
    
    NSMutableArray *tmpArray = [NSMutableArray new];
    [self.coverImageNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIImageView *v = [self scrollViewPage:obj];
        [tmpArray addObject:v];
        
    }];
    
    _scrollViewPages = tmpArray;
    
    return _scrollViewPages;
}

- (CGSize)contentSizeOfScrollView
{
    UIView *view = [[self scrollViewPages] firstObject];
    return CGSizeMake(view.frame.size.width * self.scrollViewPages.count, view.frame.size.height);
}

- (void)updatePager
{
    _pageView.page = floorf(_pagingScrollView.contentOffset.x / _pagingScrollView.frame.size.width);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePager];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updatePager];
    }
}

- (void)pageView:(WSPagerView *)pageView didUpdateToPage:(NSInteger)newPage
{
    CGPoint offset = CGPointMake(_pagingScrollView.frame.size.width * _pageView.page, 0);
    [_pagingScrollView setContentOffset:offset animated:YES];
}

#pragma mark - Action

- (void)enter:(id)object
{
    if (self.didSelectedEnter) {
        self.didSelectedEnter();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
