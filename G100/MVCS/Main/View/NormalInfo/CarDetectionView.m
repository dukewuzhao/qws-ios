//
//  CarDetectionView.m
//  G100
//
//  Created by sunjingjing on 16/6/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "CarDetectionView.h"
@implementation CarDetectionView

+ (instancetype)showView
{
    
    return [[[NSBundle mainBundle] loadNibNamed:@"CarDetectionView" owner:nil options:nil] firstObject];

}


-(void)awakeFromNib
{
    [super awakeFromNib];
    [self createGradeView];
}

-(void)createGradeView
{
//    CGRect newFrame = CGRectMake(0, 0, self.gradeView.frame.size.height, self.gradeView.frame.size.height);
    self.graView = [G100GradeView sharedWithFrame:self.gradeView.bounds option:nil];
    [self.gradeView addSubview:self.graView];
    [self.graView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(@0);

    }];
    if (ISIPHONE_4 || ISIPHONE_5) {
        self.carState.font = [UIFont systemFontOfSize:11];
    }
}


-(void)setBackgroundWithGrade:(NSInteger)grade
{
    
    [self.bgImageView.layer removeAnimationForKey:@"bgTrans"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.bgImageView.layer addAnimation:transition forKey:@"bgTrans"];
    if (grade < 20) {
        
        [self.bgImageView setImage:[UIImage imageNamed:@"icon_detection_terrible"]];
    }else if (grade >= 20 && grade < 60)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"icon_detection_bad"]];
        
    }else if (grade >= 60 && grade < 80)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"icon_detection_better"]];
    }else if (grade >= 80 && grade < 100)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"icon_detection_better"]];
        
    }else if (grade == 100)
    {
        [self.bgImageView setImage:[UIImage imageNamed:@"icon_detection_best"]];
        
    }
    
}

-(void)beginAnimateWithParameter:(G100TestResultDomain *)tesultDomain isAnimate:(BOOL)isAnimate
{
    if (!tesultDomain) {
        
        [self setBackgroundWithGrade:100];
        self.detectionDate.hidden = YES;
        [self.graView setGradeViewWithGrade:-1 isAnimation:NO];
        self.carState.text = @"点击立即检测";
        return;
    }
    self.detectionDate.hidden = NO;
    NSInteger rand = tesultDomain.score;
    [self.graView setGradeViewWithGrade:rand isAnimation:isAnimate];
    
    if (isAnimate) {
        [UIView animateWithDuration:1 animations:^{
            self.detectionDate.alpha = 0;
            self.carState.alpha = 0;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:1 animations:^{
                self.detectionDate.alpha = 1;
                self.carState.alpha = 1;
                self.detectionDate.text = [tesultDomain.lastTestTime substringToIndex:10];
                self.carState.text = tesultDomain.testResultHint;
                
            } completion:^(BOOL finished) {
                
                [self setBackgroundWithGrade:rand];
            }];
        }];
    }else
    {
        self.detectionDate.text = [tesultDomain.lastTestTime substringToIndex:10];
        self.carState.text = tesultDomain.testResultHint;
        [self setBackgroundWithGrade:rand];
    }
    
}

@end
