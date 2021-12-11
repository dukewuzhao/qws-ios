//
//  DevLogsOpenView.h
//  G100
//
//  Created by Tilink on 15/3/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevLogsOpenView : UIView

- (instancetype)initWithFrame:(CGRect)frame time:(NSString *)timeString title:(NSString *)title message:(NSString *)message;

@property (strong, nonatomic) UILabel * seperatorLine;

@end
