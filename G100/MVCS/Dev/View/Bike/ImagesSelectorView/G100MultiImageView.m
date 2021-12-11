//
//  G100MultiImageView.m
//  G100
//
//  Created by yuhanle on 14/11/11.
//  Copyright (c) 2014年 tilink. All rights reserved.
//

#import "G100MultiImageView.h"
#import "UIImageButton.h"
#import "G100PhotoShowModel.h"
#import <UIImageView+WebCache.h>

@interface G100MultiImageView ()

@property (nonatomic, strong) NSMutableArray *imageBtns_MARR;
@property (nonatomic, strong) UIImageView    *choosed_IV;
@property (nonatomic, assign) NSInteger      from;
@property (nonatomic, assign) NSInteger      to;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPG;

@end

@implementation G100MultiImageView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self shareInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self shareInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self shareInit];
}

- (void)shareInit
{
    if (self.lineCount == 0) self.lineCount = 4;
    if (self.itemWidth == 0) self.itemWidth = 68*(WIDTH/320.0);
    if (self.maxItem == 0) self.maxItem = 12;
    if (self.gap == 0) self.gap = fmodf(self.v_width, self.itemWidth)/(self.lineCount-1);
    
    _isDragged          = NO;
    self.clipsToBounds  = YES;
    self.images_MARR    = [NSMutableArray array];
    self.imageBtns_MARR = [NSMutableArray array];
    
    UILongPressGestureRecognizer *longPG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPG];
    self.longPG = longPG;
}

- (void)setImages_MARR:(NSMutableArray *)images_MARR
{
    _images_MARR = images_MARR;

    [self loadingImageView];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPG
{
    if (self.imageBtns_MARR.count) {
        
        CGPoint point = [longPG locationInView:self];
        
        switch ((int)longPG.state) {
            case UIGestureRecognizerStateBegan:
            {
                [self.imageBtns_MARR enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    UIImageButton *btn = obj;
                    if (CGRectContainsPoint(btn.frame, point)) {
                        btn.hidden                  = YES;
                        self.choosed_IV             = [[UIImageView alloc] initWithImage:btn.image];
                        self.choosed_IV.frame       = btn.frame;
                        self.choosed_IV.contentMode = UIViewContentModeScaleAspectFill;
                        self.choosed_IV.clipsToBounds = YES;
                        
                        [UIView animateWithDuration:0.2 animations:^{
                            if (idx == 0) {
                                self.choosed_IV.frame  = CGRectMake(0, 0, self.itemWidth, self.itemWidth);
                                self.choosed_IV.center = btn.center;
                                self.choosed_IV.transform = CGAffineTransformMakeScale(1.3, 1.3);
                            } else {
                                self.choosed_IV.transform = CGAffineTransformMakeScale(1.3, 1.3);
                            }
                        }];
                        [self addSubview:self.choosed_IV];
                        self.from = idx;
                    }
                }];
                
                if ([self.delegate respondsToSelector:@selector(multiImageDragBegin:)]) {
                    [self.delegate multiImageDragBegin:self.from];
                }
            }
                break;
                
            case UIGestureRecognizerStateChanged:
            {
                self.choosed_IV.center = point;
                [self.imageBtns_MARR enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    UIImageButton *btn = obj;
                    if (CGRectContainsPoint(btn.frame, point)) {
                        *stop = YES;
                        self.to = idx;
                        if (self.from != self.to) {
                            UIImageButton *anotherBtn = self.imageBtns_MARR[self.from];
                            
                            if (stop) {
                                [self.imageBtns_MARR removeObject:anotherBtn];
                                [self.imageBtns_MARR insertObject:anotherBtn atIndex:self.to];
                            }
                            ((UIView *)self.imageBtns_MARR[self.to]).hidden = YES;
                            
                            G100PhotoShowModel *anotherImage = self.images_MARR[self.from];
                            [self.images_MARR removeObjectAtIndex:self.from];
                            [self.images_MARR insertObject:anotherImage atIndex:self.to];
                            
                            [self updateUIWithAnimated:YES];
                            self.from = self.to;
                            
                            _isDragged = YES;
                        }
                    }
                }];
                
                if ([self.delegate respondsToSelector:@selector(multiImageDragEndedWithFrom:to:)]) {
                    [self.delegate multiImageDragEndedWithFrom:self.from to:self.to];
                }
            }
                break;
                
            case UIGestureRecognizerStateEnded:
            {
                [self.choosed_IV removeFromSuperview];
                ((UIView *)self.imageBtns_MARR[self.from]).hidden = NO;
            }
                break;
        }
    }
}

- (void)loadingImageView
{
    // 每个item间隔
    CGFloat gap = self.gap;
    
    [self.imageBtns_MARR removeAllObjects];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }

    // 显示的图片，用来排序的
    [self.images_MARR enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIImageButton *image_BTN  = [[UIImageButton alloc] initWithFrame:CGRectMake(0, 0, self.itemWidth, self.itemWidth)];
        image_BTN.tag             = idx;
        image_BTN.backgroundColor = [UIColor lightGrayColor];
        image_BTN.contentMode     = UIViewContentModeScaleAspectFill;
        
        // 判断传入的数组数据类型
        G100PhotoShowModel *model = obj;
        if (model.url.length) {
            [image_BTN sd_setImageWithURL:[NSURL URLWithString:model.url]];
        } else if (model.image) {
            [image_BTN setImage:model.image];
        }
        
        [image_BTN addTarget:self action:@selector(imageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:image_BTN];
        [self.imageBtns_MARR addObject:image_BTN];
    }];
    
    // 继续添加按钮
    if (self.images_MARR.count < self.maxItem) {
        
        UIButton *plus_BTN = [UIButton buttonWithType:UIButtonTypeCustom];
        [plus_BTN setBackgroundImage:[UIImage imageNamed:@"ic_btn_picture_add"] forState:UIControlStateNormal];
        if (self.images_MARR.count == 0) {
            plus_BTN.frame = CGRectMake(self.images_MARR.count%self.lineCount * (self.itemWidth+gap), self.images_MARR.count/self.lineCount * (self.itemWidth+gap), self.itemWidth, self.itemWidth);
        } else {
            plus_BTN.frame = CGRectMake((self.images_MARR.count-1)%self.lineCount * (self.itemWidth+gap), (self.images_MARR.count-1)/self.lineCount * (self.itemWidth)+self.v_width/376.0 * 160 + gap, self.itemWidth, self.itemWidth);
        }
        [plus_BTN addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:plus_BTN];
        
        self.v_height = plus_BTN.v_bottom;
    }
    
    [self updateUIWithAnimated:NO];
}

/**
 *  更新图片显示顺序
 */
- (void)updateUIWithAnimated:(BOOL)animated
{
    // 每个item间隔
    CGFloat gap = self.gap;
    // 显示的图片，用来排序的
    [self.imageBtns_MARR enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageButton *image_BTN = obj;
        image_BTN.tag = idx;
        [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
            if (idx == 0) {
                image_BTN.frame = CGRectMake(0, 0, self.v_width, self.v_width/376.0 * 160);
            } else {
                image_BTN.frame = CGRectMake((idx-1)%self.lineCount * (self.itemWidth+gap), (idx-1)/self.lineCount * (self.itemWidth)+self.v_width/376.0 * 160 + gap, self.itemWidth, self.itemWidth);
            }
        } completion:^(BOOL finished) {
            for (id iv in image_BTN.subviews) {
                if ([iv isKindOfClass:[UIControl class]]) {
                    UIControl *control = (UIControl *)iv;
                    control.v_size = image_BTN.frame.size;
                }
            }
        }];
        if (idx >= self.maxItem-1) self.v_height = image_BTN.v_bottom;
    }];
}

/**
 删除某个下标对应的图片
 */
- (void)strikeOutItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.images_MARR removeObjectAtIndex:index];
    UIImageButton *image_BTN = [self.imageBtns_MARR objectAtIndex:index];
    [image_BTN removeFromSuperview];
    [self.imageBtns_MARR removeObjectAtIndex:index];
    
    // 每个item间隔
    CGFloat gap = self.gap;
    // 显示的图片，用来排序的
    [self.imageBtns_MARR enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageButton *image_BTN = obj;
        image_BTN.tag = idx;
        [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
            if (idx == 0) {
                image_BTN.frame = CGRectMake(0, 0, self.v_width, self.v_width/376.0 * 160);
            } else {
                image_BTN.frame = CGRectMake((idx-1)%self.lineCount * (self.itemWidth+gap), (idx-1)/self.lineCount * (self.itemWidth)+self.v_width/376.0 * 160 + gap, self.itemWidth, self.itemWidth);
            }
        } completion:^(BOOL finished) {
            for (id iv in image_BTN.subviews) {
                if ([iv isKindOfClass:[UIControl class]]) {
                    UIControl *control = (UIControl *)iv;
                    control.v_size = image_BTN.frame.size;
                }
            }
            
            [self loadingImageView];
        }];
        if (idx >= self.maxItem-1) self.v_height = image_BTN.v_bottom;
    }];
    
    if (self.images_MARR.count == 0) {
        // 恢复至初始状态
        [self loadingImageView];
    }
}

- (void)setIsEnableEdit:(BOOL)isEnableEdit {
    _isEnableEdit = isEnableEdit;
    
    self.longPG.enabled = isEnableEdit;
}

#pragma mark - Control Action

- (void)addBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(addButtonDidTap)]) {
        [self.delegate addButtonDidTap];
    }
}

- (void)imageBtnAction:(UIImageButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(multiImageBtn:withImage:)]) {
        [self.delegate multiImageBtn:sender.tag withImage:sender.image];
    }
}



#pragma mark -
#pragma mark - Logic




@end

