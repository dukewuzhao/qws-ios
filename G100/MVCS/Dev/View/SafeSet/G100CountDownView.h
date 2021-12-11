//
//  G100CountDownView.h
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100CountDownView;
@protocol CountDownEndDelegate <NSObject>

/**
 *  倒计时结束
 *
 *  @param countDownView    countDownView
 */
- (void)didEndCountDownOfView:(G100CountDownView*)countDownView;
/**
 *  倒计时暂停
 *
 *  @param countDownView    countDownView
 */
- (void)didPauseCountDownOfView:(G100CountDownView*)countDownView;
/**
 *  倒计时停止
 *
 *  @param countDownView countDownView
 */
- (void)didStopCountDownOfView:(G100CountDownView*)countDownView;

@end

@interface G100CountDownView : UIView {
    CGFloat startAngle;
    CGFloat endAngle;
    int     totalTime;
    
    UIFont *numFont;
    UIFont *textFont;
    UIColor *textColor;
    NSMutableParagraphStyle *textStyle;
    
    
    bool b_timerRunning;
}

@property (nonatomic, assign) id<CountDownEndDelegate> delegate;
@property (nonatomic, assign) CGFloat time_left;

@property (nonatomic, strong) NSTimer *m_timer;

- (void)setTotalSecondTime:(CGFloat)time;

- (void)setTotalSecondTime:(CGFloat)time left_time:(CGFloat)left_time;

- (void)startTimer;
- (void)stopTimer;
- (void)pauseTimer;

@end
