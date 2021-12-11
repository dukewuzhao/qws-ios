//
//  EventEntryView.m
//  G100
//
//  Created by yuhanle on 2017/7/13.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "EventEntryView.h"
#import "G100EventDomain.h"

#import <UIButton+WebCache.h>

static CGFloat itemH = 50.0;

@interface EventEntryView () {
    CGFloat _sRight;
    CGFloat _sHeight;
}

@end

@implementation EventEntryView

- (instancetype)init {
    if (self = [super init]) {
        _sRight = 100.0;
        _sHeight = itemH;
    }
    return self;
}

#pragma mark - 
- (void)setEventDomain:(G100EventDomain *)eventDomain {
    NSMutableArray *result = [NSMutableArray array];
    for (G100EventDetailDomain *detail in eventDomain.events) {
        if (detail.control.icon) {
            [result addObject:detail];
        }
    }
    
    eventDomain.events = result.copy;
    
    _eventDomain = eventDomain;
    
    [self updateUI];
}

- (void)updateUI {
    [self removeAllSubviews];
    
    // 根据活动内容更新子控件
    if (!self.eventDomain.events.count) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    
    CGFloat top = 0;
    for (NSInteger i = 0; i < self.eventDomain.events.count; i++) {
        G100EventDetailDomain *detail = [self.eventDomain.events safe_objectAtIndex:i];
        
        __block UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(eventDatailBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(itemH);
            make.width.equalTo(@51);
            make.top.equalTo(top);
            make.centerX.equalTo(@0);
            make.left.greaterThanOrEqualTo(@0);
        }];
        
        [btn sd_setImageWithURL:[NSURL URLWithString:detail.icon] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image && !error) {
                CGFloat w = image.size.width / 1.0 / image.size.height * itemH;
                [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(w);
                }];
            }
        }];
        
        top += itemH + 5;
    }
    
    _sHeight = top;
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(_sHeight);
    }];
}

#pragma mark - Public Method
- (void)showEventEntryViewWithEvent:(G100EventDomain *)domain onBaseView:(UIView *)baseView animated:(BOOL)animated {
    NSMutableArray *result = [NSMutableArray array];
    for (G100EventDetailDomain *detail in domain.events) {
        if (detail.control.icon) {
            [result addObject:detail];
        }
    }
    
    domain.events = result.copy;
    
    // 判断是否显示
    if (![self superview]) {
        // 添加
        [baseView addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_sRight);
            make.bottom.equalTo(@-40);
            make.height.equalTo(_sHeight);
        }];
    }
    
    self.eventDomain = domain;
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_sRight);
    }];
    
    [self.superview layoutIfNeeded];
    
    [self hide:NO animated:animated];
}

- (void)hide:(BOOL)hide animated:(BOOL)animated {
    // 如果没有添加到父视图 则不执行
    if (![self superview]) {
        return;
    }
    
    CGFloat right = hide ? _sRight : -20;
    CGFloat alpha = hide ? 0.0 : 1.0;
    
    if (animated) {
        __weak typeof(self) wself = self;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(right);
        }];
        [UIView animateWithDuration:0.3 animations:^{
            wself.alpha = alpha;
            [wself.superview layoutIfNeeded];
        }];
    } else {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(right);
        }];
    }
}

- (void)eventDatailBtnAction:(UIButton *)sender {
    G100EventDetailDomain *detail = [self.eventDomain.events safe_objectAtIndex:sender.tag - 100];
    
    if (_getEventDetailBlock) {
        self.getEventDetailBlock(detail);
    }
}

@end
