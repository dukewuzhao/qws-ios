//
//  DevFeatureSaveView.h
//  G100
//
//  Created by yuhanle on 16/3/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100BikeDomain;
@class G100DeviceDomain;
@class DevFeatureSaveView;
@protocol DevFeatureSaveViewDelegate <NSObject>

- (void)devFeatureSaveView:(DevFeatureSaveView *)saveView saveBtn:(UIButton *)saveBtn;

@end

@interface DevFeatureSaveView : UIView

@property (weak, nonatomic) IBOutlet UILabel *devBindTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *devVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *devAlertorVersionLabel;

@property (weak, nonatomic) IBOutlet UIButton *devInfoSaveBtn;

@property (nonatomic, strong) G100BikeDomain * bikeDomain;
@property (nonatomic, strong) G100DeviceDomain * deviceDomain;

@property (nonatomic, weak) id <DevFeatureSaveViewDelegate> delegate;

@end
