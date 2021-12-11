//
//  G100TopInteractionBaseView.m
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import "G100TopInteractionBaseView.h"

@interface G100TopInteractionBaseView ()

@property (nonatomic, strong) UIScrollView *baseScrollView;
@property (nonatomic, strong) NSMutableArray *hintViewArray;

@end

@implementation G100TopInteractionBaseView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self setMws_maxDisplayHeight:200];
    [self addSubview:self.baseScrollView];
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - lazzy load
- (NSMutableArray *)hintViewArray {
    if (!_hintViewArray) {
        self.hintViewArray = [[NSMutableArray alloc] init];
    }
    return _hintViewArray;
}
- (UIScrollView *)baseScrollView {
    if (!_baseScrollView) {
        self.baseScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.baseScrollView.bounces = NO;
        self.baseScrollView.contentSize = self.bounds.size;
        self.baseScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _baseScrollView;
}

- (void)mws_showHint:(NSString *)hint didSelected:(G100InteractionDidSelected)selectedBlock close:(G100InteractionClose)closeBlock animated:(BOOL)animated {
    G100TopInteractionHintView *newHintView = [[G100TopInteractionHintView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    __weak G100TopInteractionHintView *weakHintView = newHintView;
    newHintView.didSelectedHintBlock = ^(){
        [self.hintViewArray removeObject:weakHintView];
        [self updateLastFrame:YES];
        
        if (selectedBlock) {
            selectedBlock();
        }
    };
    newHintView.closeHintBlock = ^(){
        [self.hintViewArray removeObject:weakHintView];
        [self updateLastFrame:YES];
        
        if (closeBlock) {
            closeBlock();
        }
    };
    
    if (![newHintView superview]) {
        CGRect oldRect = newHintView.frame;
        CGFloat h = [newHintView mws_heightForHint:hint];
        oldRect.origin.y -= h;
        oldRect.size.height = h;
        newHintView.frame = oldRect;
        
        [self.baseScrollView addSubview:newHintView];
        [self.hintViewArray addObject:newHintView];
        
        CGRect oldSelfRect = self.frame;
        oldSelfRect.size.height = MIN(oldSelfRect.size.height+h+2, _mws_maxDisplayHeight);
        self.frame = oldSelfRect;
        self.baseScrollView.frame = self.bounds;
        
        [newHintView mws_showHint:hint animated:NO complete:^{
            [self updateLastFrame:YES];
        }];
    }
}

- (void)mws_dismissWithAnimated:(BOOL)animated {
    [self updateLastFrame:YES];
}

#pragma mark - Private Method
- (void)updateLastFrame:(BOOL)animated {
    __block CGFloat beginY = 0.0;
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            for (NSInteger i = self.hintViewArray.count - 1; i >= 0; i--) {
                G100TopInteractionHintView *oldHintView = self.hintViewArray[i];
                CGRect oldRect = oldHintView.frame;
                oldRect.origin.y = beginY;
                oldHintView.frame = oldRect;
                
                beginY += oldHintView.mws_height + 2;
            }
        } completion:^(BOOL finished) {
            CGRect oldRect = self.frame;
            oldRect.size.height = MIN(beginY, _mws_maxDisplayHeight);
            self.frame = oldRect;
            
            self.baseScrollView.frame = self.bounds;
            self.baseScrollView.contentSize = CGSizeMake(self.frame.size.width, beginY);
        }];
    }else {
        for (NSInteger i = self.hintViewArray.count - 1; i >= 0; i--) {
            G100TopInteractionHintView *oldHintView = self.hintViewArray[i];
            CGRect oldRect = oldHintView.frame;
            oldRect.origin.y = beginY;
            oldHintView.frame = oldRect;
            
            beginY += oldHintView.mws_height + 2;
        }
    
        CGRect oldRect = self.frame;
        oldRect.size.height = MIN(beginY, _mws_maxDisplayHeight);
        self.frame = oldRect;
        
        self.baseScrollView.frame = self.bounds;
        self.baseScrollView.contentSize = CGSizeMake(self.frame.size.width, beginY);
    }
}

@end
