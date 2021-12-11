//
//  G100DevFindingSectionHeaderView.h
//  G100
//
//  Created by William on 16/4/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100DevFindingSectionHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

+ (instancetype)findingHeaderWithTime:(NSString *)time;

@end
