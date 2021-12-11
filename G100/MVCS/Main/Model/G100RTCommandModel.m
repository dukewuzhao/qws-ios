//
//  G100RTCommandModel.m
//  G100
//
//  Created by yuhanle on 2017/4/18.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100RTCommandModel.h"

@implementation G100RTCommandModel

+ (instancetype)rt_commandEmpty {
    G100RTCommandModel *model = [[G100RTCommandModel alloc] init];
    model.rt_empty = YES;
    return model;
}
+ (instancetype)rt_commandModelWithTitle:(NSString *)rt_Title image:(NSString *)rt_Image command:(int)rt_Command {
    G100RTCommandModel *model = [[G100RTCommandModel alloc] init];
    model.rt_title = rt_Title;
    model.rt_image = rt_Image;
    model.rt_command = rt_Command;
    model.rt_empty = NO;
    model.rt_dots = NO;
    model.rt_status = 2;
    model.rt_type = 1;
    model.rt_enable = YES;
    return model;
}

@end
