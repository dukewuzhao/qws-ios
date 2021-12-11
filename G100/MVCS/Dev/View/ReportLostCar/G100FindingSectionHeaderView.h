//
//  G100FindingSectionHeaderView.h
//  G100
//
//  Created by William on 16/4/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100FindingSectionHeaderView;
@protocol SectionModeChangedDelegate <NSObject>

- (void)findingSectionHearder:(G100FindingSectionHeaderView *)headerView changeModeBtn:(UIButton *)changeModeBtn;

@end

@interface G100FindingSectionHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UIButton *changeModeBtn;

@property (nonatomic, weak) id <SectionModeChangedDelegate> delegate;

+ (instancetype)findingSectionHeaderView;

- (void)setLostMinute:(NSInteger)minute;

@end
