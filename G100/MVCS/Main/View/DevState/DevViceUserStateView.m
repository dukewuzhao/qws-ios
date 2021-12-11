//
//  DevViceUserStateView.m
//  G100
//
//  Created by William on 16/8/10.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "DevViceUserStateView.h"

@implementation DevViceUserStateView

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak DevViceUserStateView * wself = self;
    self.gprsServiceView.tapAction = ^(){
        wself.functionTap();
    };
    
    self.serviceView.functionType = GPSStateFunctionTypeService;
    self.serviceView.tapAction = ^(){
        wself.functionTap();
    };
}

+ (instancetype)loadDevViceUserStateView {
    return [[[NSBundle mainBundle] loadNibNamed:@"DevViceUserStateView" owner:self options:nil]lastObject];
}


@end
