//
//  DevNormalStateView.m
//  G100
//
//  Created by William on 16/6/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "DevNormalStateView.h"

@interface DevNormalStateView ()

@end

@implementation DevNormalStateView

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak DevNormalStateView *wself = self;
    
    self.securityView.functionType = GPSStateFunctionTypeSecuritySettings;
    self.securityView.securityModeType = GPSSecurityModeTypeStandard;
    self.securityView.tapAction = ^(){
        wself.functionTap(0);
    };
    
    self.bikeReportView.functionType = GPSStateFunctionTypeBikeReports;
    self.bikeReportView.tapAction = ^(){
        wself.functionTap(1);
    };
    
    self.helpFindView.functionType = GPSStateFunctionTypeHelpFinding;
    self.helpFindView.tapAction = ^(){
        wself.functionTap(3);
    };
    
    self.gprsServiceView.tapAction = ^(){
        wself.functionTap(2);
    };
    
    self.serviceView.functionType = GPSStateFunctionTypeService;
    self.serviceView.tapAction = ^(){
        wself.functionTap(2);
    };
}

+ (instancetype)loadDevNormalStateView {
    return [[[NSBundle mainBundle] loadNibNamed:@"DevNormalStateView" owner:self options:nil]lastObject];
}

- (void)setSecurityMode:(GPSSecurityModeType)securityMode {
    self.securityView.securityModeType = securityMode;
}

@end
