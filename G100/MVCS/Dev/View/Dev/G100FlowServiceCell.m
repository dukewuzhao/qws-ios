//
//  G100FlowServiceCell.m
//  G100
//
//  Created by yuhanle on 16/7/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100FlowServiceCell.h"

@implementation G100FlowServiceCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    __weak __typeof__(self) weakSelf = self;
    self.flowServiceView.tapAction = ^(){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(flowServieCellDidTapped:indexPath:)]) {
            [strongSelf.delegate flowServieCellDidTapped:strongSelf indexPath:strongSelf.indexPath];
        }
    };
    [self addSubview:self.flowServiceView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.flowServiceView.frame = self.bounds;
}

- (void)setLeft_days:(NSInteger)left_days {
    [self.flowServiceView setLeft_days:left_days];
}

- (StateFunctionCustomView *)flowServiceView {
    if (!_flowServiceView) {
        _flowServiceView = [StateFunctionCustomView loadStateFunctionCustomView];
        _flowServiceView.backgroundColor = [UIColor clearColor];
    }
    return _flowServiceView;
}

@end
