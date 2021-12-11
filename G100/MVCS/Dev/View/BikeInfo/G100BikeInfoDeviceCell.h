//
//  G100BikeInfoDeviceCell.h
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100DeviceDomain.h"

typedef void(^rechargeBtnClickedBlock)();

@protocol BikeInfoDeviceCellDelegate <NSObject>

- (void)showDevDetailInfoPageActionWithDeviceDomain:(G100DeviceDomain *)deviceDomain;

- (void)rechargeBtnClickedWithDeviceDomain:(G100DeviceDomain *)deviceDomain;
@end

@interface G100BikeInfoDeviceCell : UITableViewCell

+ (NSString *)cellID;
+ (void)registerToTabelView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UILabel *devTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *devNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *warrantyTimeLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabel;


@property (nonatomic, strong) G100DeviceDomain *deviceDomain;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy)rechargeBtnClickedBlock rechargeBtnClickedBlock;


@property (nonatomic, weak)id <BikeInfoDeviceCellDelegate> delegate;
@end
