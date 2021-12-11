//
//  G100CountDownView.m
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#define CIRCLE_WIDTH 6
#define PROGRESS_WIDTH 6
#define NUM_SIZE 50
#define TEXT_SIZE 24
#define TIMER_INTERVAL 1.0

#import "G100CountDownView.h"

@implementation G100CountDownView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initView];
    }
    return self;
}

- (void)initData {
    // 圆周为 2 * pi * R, 默认起始点于正右方向为 0 度， 改为正上为起始点
    startAngle = -0.5 * M_PI;
    endAngle = startAngle;
    
    totalTime = 0;
    
    numFont = [UIFont fontWithName:@"Helvetica Neue" size:NUM_SIZE];
    textFont = [UIFont fontWithName: @"Helvetica Neue" size: TEXT_SIZE];
    textColor = [UIColor blackColor];
    textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    
    b_timerRunning = NO;
    
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)drawRect:(CGRect)rect {
    if (totalTime == 0) {
        endAngle = startAngle;

    }else{
        if (b_timerRunning) {
            if (self.time_left>0) {
                endAngle = -(1 - self.time_left / totalTime) * 2 * M_PI + startAngle;
            }else{
                endAngle = startAngle;
            }
            
        }else{
            if (self.time_left != totalTime) {
                endAngle = -(1 - self.time_left / totalTime) * 2 * M_PI + startAngle;
            }else{
               endAngle = 1.5 * M_PI;
            }
        }

    }
    
    
    UIBezierPath *circle = [UIBezierPath bezierPath];
    [circle addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                      radius:rect.size.width/2-CIRCLE_WIDTH
                  startAngle:0
                    endAngle:2 * M_PI
                   clockwise:YES];
    circle.lineWidth = CIRCLE_WIDTH;
    [[UIColor lightGrayColor] setStroke];
    [circle stroke];
    
    
    UIBezierPath *progress = [UIBezierPath bezierPath];
    [progress addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                        radius:rect.size.width/2-PROGRESS_WIDTH
                    startAngle:startAngle
                      endAngle:endAngle
                     clockwise:YES];
    progress.lineWidth = PROGRESS_WIDTH;
    [MyNavColor set];
    [progress stroke];
    
    NSString *textContent = [self secondStrWithLeft_time:self.time_left];
    
    CGSize textSize = [textContent sizeWithAttributes:@{NSFontAttributeName:numFont}];
    
    CGRect textRect = CGRectMake(rect.size.width / 2 - textSize.width / 2 - 8,
                                 rect.size.height / 2 - textSize.height / 2,
                                 textSize.width , textSize.height);
    
    NSDictionary * attrs = @{NSFontAttributeName:numFont,
                             NSForegroundColorAttributeName:MyNavColor,
                             NSParagraphStyleAttributeName:textStyle};
    
    
    NSString * appStr = @"秒";
    
    CGSize appTextSize = [appStr sizeWithAttributes:@{NSFontAttributeName:textFont}];
    
    CGRect appStrRect = CGRectMake(textRect.origin.x + textRect.size.width + 8,
                                   textRect.origin.y + 8,
                                   appTextSize.width, appTextSize.height);
    
    NSDictionary * appAttrs = @{NSFontAttributeName:textFont,
                                NSForegroundColorAttributeName:textColor,
                                NSParagraphStyleAttributeName:textStyle};
    
    [textContent drawInRect:textRect withAttributes:attrs];
    [appStr drawInRect:appStrRect withAttributes:appAttrs];
}

- (NSString *)secondStrWithLeft_time:(CGFloat)left_time {
    int sec = (int)ceil(left_time);
    NSString *str = [NSString stringWithFormat:@"%d",sec];
    return str;
}

- (void)setTotalSecondTime:(CGFloat)time {
    totalTime = time;
    self.time_left = totalTime;
    b_timerRunning = NO;
    [self setNeedsDisplay];
}

- (void)setTotalSecondTime:(CGFloat)time left_time:(CGFloat)left_time {
    totalTime = time;
    self.time_left = left_time;
    b_timerRunning = NO;
    [self setNeedsDisplay];
}

- (void)startTimer {
    if (!b_timerRunning) {
        _m_timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                    target:self
                                                  selector:@selector(setProgress)
                                                  userInfo:nil
                                                   repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_m_timer forMode:NSRunLoopCommonModes];
        b_timerRunning = YES;
    }
}

- (void)pauseTimer {
    if (b_timerRunning) {
        [_m_timer invalidate];
        _m_timer = nil;
        b_timerRunning = NO;
    }
    
    if ([delegate respondsToSelector:@selector(didPauseCountDownOfView:)]) {
        [delegate didPauseCountDownOfView:self];
    }
}

- (void)setProgress {
    if (self.time_left > 0) {
        self.time_left -= TIMER_INTERVAL;
        
        [self setNeedsDisplay];
    } else {
        [self pauseTimer];
        
        if ([delegate respondsToSelector:@selector(didEndCountDownOfView:)]) {
            [delegate didEndCountDownOfView:self];
        }
    }
}

- (void)stopTimer {
    [self pauseTimer];
    
    startAngle = -0.5 * M_PI;
    endAngle = startAngle;
    self.time_left = totalTime;
    [self setNeedsDisplay];
    
    if ([delegate respondsToSelector:@selector(didStopCountDownOfView:)]) {
        [delegate didStopCountDownOfView:self];
    }
}

@end
