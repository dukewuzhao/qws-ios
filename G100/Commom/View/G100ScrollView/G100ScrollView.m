//
//  G100MyInsurancesHeaderView.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ScrollView.h"
#import "G100ScrollViewCell.h"
#import <SDWebImageManager.h>

@interface G100ScrollView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) UIView *selectedMaskView;

/** 轮播图总数量*/
@property (nonatomic, assign) NSInteger totalItemsCount;

@end

@implementation G100ScrollView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
        [self setUpView];
    }
    return self;
}

+ (instancetype)createScrollViewWithFrame:(CGRect)frame imagesArr:(NSArray *)imageArr
{
    G100ScrollView *headerView = [[G100ScrollView alloc] initWithFrame:frame];
    headerView.imageUrlArr = [imageArr mutableCopy];
    return headerView;
}

+ (instancetype)createScrollViewWithFrame:(CGRect)frame imageUrlArr:(NSArray *)imageUrl
{
    G100ScrollView *headerView = [[G100ScrollView alloc] initWithFrame:frame];
    headerView.imageUrlArr = [imageUrl mutableCopy];
    return headerView;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.flowLayout.itemSize = self.frame.size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
    if (_collectionView.contentOffset.x == 0 && _totalItemsCount) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_totalItemsCount * 0.5 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    }
    
    if (!_pageControlHidden) {
        CGSize size = [self.pageControl sizeForNumberOfPages:self.imageUrlArr.count];
        CGFloat x = (self.bounds.size.width - size.width)/2;
        if (self.pageControlAlignment == PageControlAlignmentRight) {
            x = self.bounds.size.width - size.width - 20;
        }
        self.pageControl.frame = CGRectMake(x,self.bounds.size.height - size.height, size.width, size.height);
        self.pageControl.hidesForSinglePage = YES;
    }
}

#pragma mark - 初始化数据
- (void)setupData {
    self.autoScrollInterval = 3.0;
    self.pageControlHidden = NO;
    self.pageControlAlignment = 0;
}

#pragma mark - 初始化视图
- (void)setUpView {
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.itemSize = self.frame.size;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    
    if ([self.collectionView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.collectionView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [G100ScrollViewCell registerToCollectionView:self.collectionView];
}

#pragma mark - 配置 PageControl
- (void)setUpPageControl {
    if (!self.pageControlHidden) {
        if (!_pageControl) {
            self.pageControl = [[UIPageControl alloc] init];
        }
        
        if (![_pageControl superview]) {
            [self addSubview:self.pageControl];
        }
        
        [self bringSubviewToFront:self.pageControl];
        self.pageControl.numberOfPages = self.imageUrlArr.count;
    }else {
        if ([_pageControl superview]) {
            [_pageControl removeFromSuperview];
        }
    }
}

#pragma mark - 设置定时器
- (void)setUpTimer {
    if (self.imageUrlArr.count < 2) {
        return;
    }
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollInterval
                                                  target:self
                                                selector:@selector(automaticScroll)
                                                userInfo:nil
                                                 repeats:YES];
    }
    [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)automaticScroll {
    if (self.totalItemsCount < 2) {
        return;
    }
    
    int currentIndex = self.collectionView.contentOffset.x / self.flowLayout.itemSize.width;
    int targetIndex = currentIndex + 1;
    if (targetIndex == self.totalItemsCount) {
        targetIndex =  self.totalItemsCount *0.5;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:YES];
}

#pragma mark - setter
- (void)setImageUrlArr:(NSArray *)imageUrlArr {
    _imageUrlArr = imageUrlArr;
    
    if (imageUrlArr.count == 1) {
        _totalItemsCount = 1;
    }else{
        _totalItemsCount = imageUrlArr.count *1000;
    }

    [self setUpPageControl];
    
    [self loadImageWithImageUrlsArr:imageUrlArr];
    [self.collectionView reloadData];
}

- (void)setAutoScrollInterval:(CGFloat)autoScrollInterval {
    _autoScrollInterval = autoScrollInterval;
    
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [self setUpTimer];
}
- (void)setPageControlHidden:(BOOL)pageControlHidden {
    _pageControlHidden = pageControlHidden;
    
    [self setUpPageControl];
}

#pragma mark - Downlaod remote images
- (void)loadImageWithImageUrlsArr:(NSArray *)imageUrlArr {
    for (NSString *url in imageUrlArr) {
        if ([url hasPrefix:@"http"]) {
            NSString *result = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:result] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
            }];
        }
    }
}
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _totalItemsCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    G100ScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[G100ScrollViewCell cellID] forIndexPath:indexPath];
    
    long itemIndex = indexPath.item % self.imageUrlArr.count;
    NSString *result = [self.imageUrlArr safe_objectAtIndex:itemIndex];
    
    if ([result hasPrefix:@"http"]) {
        result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView iph_setImageWithURL:[NSURL URLWithString:result] placeholderImage:nil];
    }else {
        cell.imageView.image = [UIImage imageNamed:result];
    }
    
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    G100ScrollViewCell *cell = (G100ScrollViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if (![self.selectedMaskView superview]) {
        [cell.contentView addSubview:self.selectedMaskView];
        [self.selectedMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    //G100ScrollViewCell *cell = (G100ScrollViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if ([self.selectedMaskView superview]) {
        [self.selectedMaskView removeFromSuperview];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectedScrollViewAtIndex:OnScrollView:)]) {
        [self.delegate selectedScrollViewAtIndex:indexPath.item % self.imageUrlArr.count OnScrollView:self];
    }
}

- (UIView *)selectedMaskView {
    if (!_selectedMaskView) {
        _selectedMaskView = [[UIView alloc] init];
        _selectedMaskView.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.1f];
    }
    return _selectedMaskView;
}
#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int itemIndex = (scrollView.contentOffset.x + self.collectionView.frame.size.width * 0.5) / self.collectionView.frame.size.width;
    int indexOnPageControl = itemIndex % self.imageUrlArr.count;
    self.pageControl.currentPage = indexOnPageControl;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setUpTimer];
}

@end
