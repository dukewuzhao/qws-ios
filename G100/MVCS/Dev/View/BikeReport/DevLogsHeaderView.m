//
//  DevLogsHeaderView.m
//  G100
//
//  Created by Tilink on 15/2/27.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "DevLogsHeaderView.h"
#import "G100DevUsageSummaryDomain.h"

@implementation DevLogsHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taptoOpenSection:)];
    [self.mainView addGestureRecognizer:gesture];
}

-(void)showSectionHeaderWithModel:(G100DevUsageSummaryDomain *)model section:(NSInteger)section expanded:(BOOL)expanded{
    self.section = section;
    self.expanded = expanded;
    self.timeStr = model.day;
    self.selectButton.selected = expanded;
    
    self.sectionHeaderDateLabel.text = [model.day substringWithRange:NSMakeRange(8, 2)];
    self.sectionHeaderMonthLabel.text = [NSString stringWithFormat:@"%@月", [NSString arabictoHanzi:[model.day substringWithRange:NSMakeRange(5, 2)]]];
    
    NSString * distance = [NSString stringWithFormat:@"%.1lf", model.distance];
    if ([distance hasContainString:@".0"]) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.lfkm\n里程", model.distance];
    }else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1lfkm\n里程", model.distance];
    }
   /*原版
    NSString * speed = [NSString stringWithFormat:@"%.1lf", model.speed];
    if ([speed hasContainString:@".0"]) {
        self.speedLabel.text = [NSString stringWithFormat:@"%.lfkm/h\n车速", model.speed];
    }else{
        self.speedLabel.text = [NSString stringWithFormat:@"%.1lfkm/h\n车速", model.speed];
    }
    */
    self.speedLabel.text = [NSString stringWithFormat:@"%ld次\n行驶次数", model.ride_count];
    self.warnCountLabel.text = [NSString stringWithFormat:@"%ld次\n警告", (long)model.alertcount];
}

-(void)taptoOpenSection:(UITapGestureRecognizer *)gesture {
    self.expanded = !self.expanded;
    if ([self.delegate respondsToSelector:@selector(headerView:section:expanded:)]) {
        [self.delegate headerView:self section:self.section expanded:self.expanded];
    }
}

@end
