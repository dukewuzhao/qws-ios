//
//  G100RollingPlayingView.m
//  G100
//
//  Created by William on 16/4/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100RollingPlayingView.h"

@interface G100RollingPlayingView () <CAAnimationDelegate>

@property (nonatomic, strong) NSString * text;
@property (nonatomic, assign) CGSize labelSize;
@property (assign, nonatomic) CGRect frame;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation G100RollingPlayingView
@synthesize frame = _frame;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (UILabel *)rollingLabel {
    if (!_rollingLabel) {
        _rollingLabel = [[UILabel alloc]init];
        _rollingLabel.textColor = [UIColor whiteColor];
        _rollingLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_rollingLabel];
    }
    return _rollingLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = [UIColor colorWithHexString:@"FD6207"];
        self.isPlaying = NO;
        self.hidden = YES;
        
        [self setupNotificationObserver];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _frame = frame;
}

- (void)setRollingText:(NSString*)text {
    if (![_text isEqualToString:text]) {
        self.isPlaying = NO;
    }
    
    _text = text;
    if (0 == text.length) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    
    _labelSize = [text calculateSize:CGSizeMake(999, _frame.size.height) font:self.rollingLabel.font];
    
    [self.rollingLabel setFrame:CGRectMake(5, 0, _labelSize.width, _frame.size.height)];
    self.rollingLabel.text = text;
    
    self.contentSize = CGSizeMake(_labelSize.width+_frame.size.width, _labelSize.height);
    
    if (_labelSize.width+10 <= self.frame.size.width) {
        return;
    }
    
    if (!self.isPlaying) {
        [self.rollingLabel.layer removeAllAnimations];
        
        [self startRolling];
        self.isPlaying = YES;
    }
}

- (void)startRolling {
    CGFloat duration = self.text.length*0.5;
    
    CABasicAnimation *translation;
    translation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    translation.fromValue = @(self.frame.size.width);
    translation.toValue = @(-self.rollingLabel.frame.size.width);
    translation.duration = duration;
    translation.repeatCount = INT_MAX;
    translation.removedOnCompletion = NO;
    translation.fillMode = kCAFillModeForwards;
    translation.delegate = self;
    
    [self.rollingLabel.layer addAnimation:translation forKey:@"translationAnimation"];
}

#pragma mark - CAAnimationDelegate Method
- (void)animationDidStart:(CAAnimation *)theAnimation {
    NSLog(@"animationDidStart");
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    NSLog(@"animationDidStop finished %d",flag);
}

#pragma mark - Pravite Method
- (void)startRunloop {
    [self resumeLayer:self.rollingLabel.layer];
}
- (void)stopRunloop {
    [self pauseLayer:self.rollingLabel.layer];
}

-(void)pauseLayer:(CALayer*)layer //暂停动画
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer //恢复动画
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)setupNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(grp_applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(grp_applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

#pragma mark - Notification Callback
- (void)grp_applicationDidBecomeActive:(UIApplication *)application {
    [self startRunloop];
}

- (void)grp_applicationDidEnterBackground:(UIApplication *)application {
    [self stopRunloop];
}

@end
