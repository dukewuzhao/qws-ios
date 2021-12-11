//
//  SetAlarmNotiSetCell.h
//  G100
//
//  Created by yuhanle on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    G100SetAlarmNotiSetCellTypeAppPush = 0,
    G100SetAlarmNotiSetCellTypeWxPush,
    G100SetAlarmNotiSetCellTypePnPush
} G100SetAlarmNotiSetCellType;

@interface SetAlarmNotiSetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *alarmSwitch;

@property (weak, nonatomic) IBOutlet UIButton *testAlarmButton;

@property (copy, nonatomic) void (^serviceAgreementClickBlock)();
@property (copy, nonatomic) void (^testButtonEventBlock)(UIButton *button);
@property (copy, nonatomic) void (^testAlarmSwitchChangedBlock)(UISwitch *us);

+ (instancetype)alarmNotiSetCellWithType:(NSInteger)type;

- (IBAction)testButtonEvent:(UIButton *)sender;

- (IBAction)alarmSwitchChanged:(UISwitch *)sender;

- (void)showUIWithDict:(NSDictionary *)dict;

+ (CGFloat)heightForDict:(NSDictionary *)dict;

@end
