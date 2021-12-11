//
//  G100ToastView.m
//  G100
//
//  Created by William on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ToastView.h"
#import "G100ToastLabel.h"

#define TOAST_DURATION      3.0f    /** toast显示总时长 */
#define ANIMATION_DURANTION 0.3f    /** toast显示消失动画时长 */
#define MIN_HEIGHT          36.0f   /** label最小高度 */
#define MIN_WIDTH           200.0f  /** label最小宽度 */
#define MIN_OFFSET          40.0f   /** label距离底部最小的偏移量 */
#define kWidthPadding       12.0f   /** label左右边距 */
#define kMinHeightPadding   14.0f   /** label最小上下边距 */
#define kMaxHeightPadding   20.0f   /** label最大上下边距 */
#define MIN_MARGIN          20.0f   /** label最小页边距 */

@interface G100ToastView ()

@property (nonatomic, strong) NSTimer * hideTimer;

@end

@implementation G100ToastView

#pragma mark - life cycle
+ (instancetype)showToastAddedTo:(UIView *)view {
    G100ToastView * toast = [[self alloc] initWithView:view];
    [view addSubview:toast];
    [toast show];
    return toast;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
        self.backgroundColor = [UIColor clearColor];
        [self setupLabel];
        [self initial];
    }
    return self;
}

#pragma mark - init & setup
- (void)initial {
    self.type = ToastShowTypeNotification;
    self.yOffset = MIN_OFFSET;
}

- (void)setupLabel {
    self.label = [[G100ToastLabel alloc] initWithFrame:self.bounds];
    self.label.font = [UIFont boldSystemFontOfSize:17.0f];
    self.label.textColor = [UIColor whiteColor];
    self.label.numberOfLines = 0;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.layer.masksToBounds = YES;
    self.label.layer.cornerRadius = MIN_HEIGHT/2;
    [self addSubview:self.label];
}

#pragma mark - setter
- (void)setType:(ToastShowType)type {
    _type = type;
    switch (type) {
        case ToastShowTypeNotification:
            self.label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75f];
            break;
        case ToastShowTypeWarning:
            self.label.backgroundColor = [UIColor colorWithHexString:@"ee1515" alpha:0.75f];
            break;
        default:
            break;
    }
}

- (void)setLabelText:(NSString *)labelText {
    _labelText = labelText;
    self.label.text = labelText;
    [self setNeedsDisplay];
}

- (void)setYOffset:(CGFloat)yOffset {
    _yOffset = yOffset;
    [self setNeedsDisplay];
}

#pragma mark - actions
- (void)show {
    [UIView animateWithDuration:ANIMATION_DURANTION animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideDelay {
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:TOAST_DURATION-2*ANIMATION_DURANTION target:self selector:@selector(handleHideTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.hideTimer forMode:NSRunLoopCommonModes];
}

- (void)handleHideTimer:(NSTimer *)timer {
    [UIView animateWithDuration:ANIMATION_DURANTION animations:^{
        self.alpha = .0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }];
}

- (void)hideNow {
    [self removeFromSuperview];
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

#pragma mark - view
- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIView *parent = self.superview;
    if (parent) {
        self.frame = parent.bounds;
    }
    CGRect bounds = self.bounds;
    
    CGSize smallSize = [self.labelText calculateSize:CGSizeMake(170, 999) font:[UIFont boldSystemFontOfSize:17.0f]];
    if (smallSize.height == 21) {
        [self.label setV_size:CGSizeMake(MIN_WIDTH, MIN_HEIGHT)];
    }else if (smallSize.height > 21) {
        CGSize largeSize = [self.labelText calculateSize:CGSizeMake(bounds.size.width-2*MIN_MARGIN-2*kWidthPadding, 999) font:[UIFont boldSystemFontOfSize:17.0f]];
        if (largeSize.height == 21) {
            [self.label setV_size:CGSizeMake(largeSize.width+2*kWidthPadding, MIN_HEIGHT)];
        }else if (largeSize.height > 21) {
            [self.label setV_size:CGSizeMake(bounds.size.width-2*MIN_MARGIN, largeSize.height+2*kWidthPadding)];
            self.label.textInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        }
    }
    [self.label setCenter:CGPointMake(self.v_centerX, bounds.size.height-self.yOffset-self.label.v_height/2)];
}


@end
