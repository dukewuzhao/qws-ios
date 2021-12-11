//
//  G100PageControl.m
//  G100
//
//  Created by yuhanle on 16/7/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PageControl.h"

@interface G100PageControl ()

@property (nonatomic, strong) UIView *backView;

@end

@implementation G100PageControl {
    NSMutableDictionary *_images;
    NSMutableArray *_pageViews;
}

@synthesize page = _page;
@synthesize pattern = _pattern;
@synthesize delegate = _delegate;

- (void)commonInit
{
    _page = 0;
    _dotRadius = 0;
    _pattern = @"";
    _dotSpacing = 6;
    _dotSize = CGSizeMake(42, 2);
    _images = [NSMutableDictionary dictionary];
    _pageViews = [NSMutableArray array];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setPage:(NSInteger)page
{
    // Skip if delegate said "do not update"
    if ([_delegate respondsToSelector:@selector(pageView:shouldUpdateToPage:)] && ![_delegate pageView:self shouldUpdateToPage:page]) {
        return;
    }
    
    _page = page;
    [self setNeedsLayout];
}

- (void)setPattern:(NSString *)pattern {
    _pattern = pattern;
    
    [self setNeedsLayout];
}

- (NSInteger)numberOfPages
{
    return _pattern.length;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapGestureTappedPageControlView:)];
        [self addGestureRecognizer:tapGesture];
    }
    return _backView;
}

- (void)tapGestureTappedPageControlView:(UITapGestureRecognizer *)recognizer {
    if (self.backView.alpha == 0.0) {
        [self appearWithDuration:0.3 animation:YES];
    }
    
    // Inform delegate of the update
    if ([_delegate respondsToSelector:@selector(pageViewDidTapped:)]) {
        [_delegate pageViewDidTapped:self];
    }
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    self.page = [_pageViews indexOfObject:recognizer.view];
    
    // Inform delegate of the update
    if ([_delegate respondsToSelector:@selector(pageView:didUpdateToPage:)]) {
        [_delegate pageView:self didUpdateToPage:_page];
    }
    
    // Send update notification
    [[NSNotificationCenter defaultCenter] postNotificationName:G100PAGECONTROL_DID_UPDATE_NOTIFICATION object:self];
}

- (UIImageView *)imageViewForKey:(NSString *)key
{
    NSDictionary *imageData = [_images objectForKey:key];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[imageData objectForKey:@"normal"] highlightedImage:[imageData objectForKey:@"highlighted"]];
    return imageView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_pageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
    [_pageViews removeAllObjects];
    
    self.backView.frame = self.bounds;
    NSInteger pages = self.numberOfPages;
    if (_page < 0) _page = 0;
    
    CGFloat xOffset = (self.frame.size.width - (pages * _dotSize.width + (pages - 1) * _dotSpacing)) * 0.5f;
    for (int i = 0; i < pages; i++) {
        NSString *key = [_pattern substringWithRange:NSMakeRange(i, 1)];
        UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
        baseView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [self imageViewForKey:key];
        
        CGRect frame = baseView.frame;
        frame.origin.x = xOffset;
        
        if (i == self.page) {
            // 选中状态
            frame.size.width = _dotSize.width;
            frame.size.height = self.frame.size.height;
            baseView.frame = frame;
            
            imageView.frame = CGRectMake(0, (CGRectGetHeight(baseView.frame)-_dotSize.height)/2.0, _dotSize.width, _dotSize.height);
        }else {
            frame.size.width = _dotSize.width;
            frame.size.height = self.frame.size.height;
            baseView.frame = frame;
            
            imageView.frame = CGRectMake(0, (CGRectGetHeight(baseView.frame)-_dotSize.height)/2.0, _dotSize.width, _dotSize.height);
        }
        
        imageView.highlighted = (i == self.page);
        
        [baseView addSubview:imageView];
        [self.backView addSubview:baseView];
        [_pageViews addObject:baseView];
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [baseView addGestureRecognizer:tgr];
        
        xOffset = xOffset + _dotSize.width + _dotSpacing;
    }
}

#pragma mark - Public method
- (void)setImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage forKey:(NSString *)key
{
    NSDictionary *imageData = [NSDictionary dictionaryWithObjectsAndKeys:image, @"normal", highlightedImage, @"highlighted", nil];
    [_images setObject:imageData forKey:key];
    [self setNeedsLayout];
}

- (void)appearWithDuration:(NSTimeInterval)duration animation:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            self.backView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }else {
        self.backView.alpha = 1.0;
    }
}
- (void)dismissWithDuration:(NSTimeInterval)duration animation:(BOOL)animaited {
    if (animaited) {
        [UIView animateWithDuration:duration animations:^{
            self.backView.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }else {
        self.backView.alpha = 0.0;
    }
}

@end
