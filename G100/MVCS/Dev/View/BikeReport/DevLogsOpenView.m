//
//  DevLogsOpenView.m
//  G100
//
//  Created by Tilink on 15/3/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "DevLogsOpenView.h"

@implementation DevLogsOpenView

-(instancetype)initWithFrame:(CGRect)frame time:(NSString *)timeString title:(NSString *)title message:(NSString *)message {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        // timelabel
        UILabel * timelabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, [timeString calculateSize:CGSizeMake(200, self.v_height) font:[UIFont systemFontOfSize:14]].width, self.v_height - 10)];
        timelabel.font = [UIFont systemFontOfSize:14];
        timelabel.textColor = [UIColor darkGrayColor];
        timelabel.text = timeString;
        
        [self addSubview:timelabel];
        
        // message
        NSString * result = [NSString stringWithFormat:@"车辆%@", message];
        UILabel * messagelabel = [[UILabel alloc]initWithFrame:CGRectMake(timelabel.v_right + 10, 5, [result calculateSize:CGSizeMake(200, self.v_height) font:[UIFont systemFontOfSize:14]].width, self.v_height - 10)];
        messagelabel.font = [UIFont systemFontOfSize:14];
        messagelabel.textColor = [UIColor darkGrayColor];
        messagelabel.text = result;
        [self addSubview:messagelabel];
        
        if ([message isEqualToString:@"严重震动"]) {
            timelabel.textColor = [UIColor redColor];
            messagelabel.textColor = [UIColor redColor];
        }
        
        // 增添下划线
        _seperatorLine = [[UILabel alloc]initWithFrame:CGRectMake(30, self.v_height - 1, self.v_width - 36, 1)];
        _seperatorLine.backgroundColor = MyBackColor;
        
        [self addSubview:_seperatorLine];
    }
    
    return self;
}

@end
