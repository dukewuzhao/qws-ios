//
//  G100BikeInfoDeviceCell.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoDeviceCell.h"

#import "NSDate+TimeString.h"
#import "UILabeL+AjustFont.h"


@interface G100BikeInfoDeviceCell ()
@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (weak, nonatomic) IBOutlet UIButton *overdueBtn;
@property (weak, nonatomic) IBOutlet UIView *leftdaysView;

@end

@implementation G100BikeInfoDeviceCell

+ (NSString *)cellID
{
    return NSStringFromClass([self class]);
}
+ (void)registerToTabelView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:[self cellID] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[self cellID]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _rechargeBtn.layer.masksToBounds = YES;
    _rechargeBtn.layer.cornerRadius = 8;
    // Initialization code
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDevDetailPageAction)];
    [_topView addGestureRecognizer:tap];
    
    [UILabel adjustAllLabel:self multiple:0.5];
}
- (void)showDevDetailPageAction{
    if ([self.delegate respondsToSelector:@selector(showDevDetailInfoPageActionWithDeviceDomain:)]) {
        [self.delegate showDevDetailInfoPageActionWithDeviceDomain:self.deviceDomain];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (IBAction)rechargeAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(rechargeBtnClickedWithDeviceDomain:)]) {
        [self.delegate rechargeBtnClickedWithDeviceDomain:self.deviceDomain];
    }
}

- (void)setDeviceDomain:(G100DeviceDomain *)deviceDomain{
    _deviceDomain = deviceDomain;
    _devNameLabel.text = _deviceDomain.name;
    _warrantyTimeLimitLabel.text = _deviceDomain.warranty;
    
    if ([NSDate distanceInDaysToDate:_deviceDomain.warranty] <= 0) {
        _warrantyTimeLimitLabel.textColor = [UIColor redColor];
    }
    
    if (_deviceDomain.leftdays <= 0) {
        _remainTimeLabel.textColor = [UIColor redColor];
    }else if (_deviceDomain.leftdays <= 30) {
        _remainTimeLabel.textColor = [UIColor colorWithHexString:@"#ff6c00"];
    }
    
    if ([deviceDomain isMainDevice]) {
        _hintLabel.text = @"主设备";
    }else{
        _hintLabel.text = @"副设备";
    }
    
    if ( deviceDomain.isSpecialChinaMobileDevice) {
        _remainTimeLabel.text = @"移动特供机";
        self.overdueBtn.hidden = YES;
        return;
    }
    
    self.leftdaysView.hidden = NO;
    self.rechargeBtn.hidden = NO;
    self.overdueBtn.hidden = NO;
    
    if (![deviceDomain isOverdue]) {
        _remainTimeLabel.text = [NSString stringWithFormat:@"%@天", @(deviceDomain.service.left_days)];
    } else {
        _remainTimeLabel.text = @"已过期";
    }
    
    if (![deviceDomain canRecharge]) {
        self.leftdaysView.hidden = YES;
        self.overdueBtn.hidden = NO;
    } else {
        self.leftdaysView.hidden = NO;
        self.overdueBtn.hidden = YES;
    }
}
- (void)setIndexPath:(NSIndexPath *)indexPath {
    _devTagLabel.text = [NSString stringWithFormat:@"%@.", @(indexPath.section + 1)];
}

- (IBAction)callServiceNumberAction:(UIButton *)button {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://400-920-2890"]];
}

@end
