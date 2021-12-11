//
//  DevLogsHeaderView.h
//  G100
//
//  Created by Tilink on 15/2/27.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DevLogsHeaderView;
@protocol DevLogsHeaderViewDelegate <NSObject>

@optional

-(void)headerView:(DevLogsHeaderView *)headerView section:(NSInteger)section expanded:(BOOL)expanded;

@end
@class G100DevUsageSummaryDomain;
@interface DevLogsHeaderView : UIView

@property (weak, nonatomic) id <DevLogsHeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSeperatorTopMargin;
@property (assign, nonatomic) NSInteger section;
@property (assign, nonatomic) BOOL expanded;
@property (weak, nonatomic) IBOutlet UIView * mainView;
@property (weak, nonatomic) IBOutlet UILabel * topSeperator;
@property (weak, nonatomic) IBOutlet UIButton * selectButton;
@property (weak, nonatomic) IBOutlet UIImageView *blackSm;
@property (weak, nonatomic) IBOutlet UILabel *sectionHeaderDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *seperateLine;
@property (weak, nonatomic) IBOutlet UILabel *sectionHeaderMonthLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *warnCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (copy, nonatomic) NSString * timeStr;

-(void)showSectionHeaderWithModel:(G100DevUsageSummaryDomain *)model section:(NSInteger)section expanded:(BOOL)expanded;

@end
