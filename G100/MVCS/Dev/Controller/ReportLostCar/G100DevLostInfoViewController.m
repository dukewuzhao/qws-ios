//
//  G100DevLostInfoViewController.m
//  G100
//
//  Created by yuhanle on 16/4/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevLostInfoViewController.h"
#import "G100BaseItem.h"
#import "G100BaseCell.h"
#import "G100BaseArrowItem.h"
#import "G100BaseLabelItem.h"
#import "G100BaseImageItem.h"
#import "G100BaseTextFieldItem.h"

#import "UUDatePicker.h"

#import "G100BikeDomain.h"
#import "G100DevLostListDomain.h"

#import "G100DevLocationConfirmViewController.h"
#import "G100DevFindInspirationViewController.h"
#import "G100DevLostNewTagViewController.h"

#import "G100BikeEditFeatureViewController.h"

#import "G100ThemeManager.h"

#import "G100DeviceDomain.h"
#import "G100BikeApi.h"
static NSString * const kBaseItemKeyLostCarLocation  = @"lostcarlocation";
static NSString * const kBaseItemKeyLostCarTime      = @"lostcartime";
static NSString * const kBaseItemKeyLostCarFeature   = @"lostcarfeature";
static NSString * const kBaseItemKeyLostCarUserName  = @"lostcarusername";
static NSString * const kBaseItemKeyLostCarUserPhone = @"lostcaruserphone";

@interface G100DevLostInfoViewController () <UITableViewDelegate, UITableViewDataSource, UUDatePickerDelegate, AMapLocationManagerDelegate>

@property (nonatomic, strong) UILabel *topHintLabel;

@property (nonatomic, strong) G100UserDomain *userDomain;
@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@property (nonatomic, strong) G100DeviceDomain *devDomain;
@property (nonatomic, strong) G100BikeFeatureDomain *featureDomain;
@property (nonatomic, strong) G100DevLostDomain *lostDomain;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) UIButton *publishedButton;

@property (nonatomic, strong) G100BaseItem *lostCarLocation;
@property (nonatomic, strong) G100BaseTextFieldItem *lostCarTime;
@property (nonatomic, strong) G100BaseArrowItem *lostCarFeature;
@property (nonatomic, strong) G100BaseTextFieldItem *lostCarUserName;
@property (nonatomic, strong) G100BaseTextFieldItem *lostCarUserPhone;

@property (nonatomic, strong) UIView *locationInfoButtonView;
@property (nonatomic, strong) UITextField *locationInfoTextField;

@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, assign) CLLocationCoordinate2D lostDevLocationCoordinate;

@property (nonatomic, assign) BOOL userHasSelectedLocation;
// 记录当前时间
@property (nonatomic, strong) NSDate *nowDate;

@end

@implementation G100DevLostInfoViewController

#pragma mark - 定位数据信息
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)locationInformation {
    __weak G100DevLostInfoViewController *wself = self;
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        // 如果此时用户已经选定了丢车位置 则丢弃这条定位结果信息
        if (wself.userHasSelectedLocation) {
            return;
        }
        
        if (error) {
            wself.lostCarLocation.subtitle = @"定位失败";
        }
        
        if (location && regeocode) {
            // 定位成功
            wself.lostDevLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            wself.lostCarLocation.subtitle = [NSString stringWithFormat:@"%@", regeocode.formattedAddress];
            wself.locationInfoTextField.text = [NSString stringWithFormat:@"%@", regeocode.formattedAddress];
        }
        
        wself.publishedButton.enabled = [wself publishIsEnable];
        [wself.tableView reloadData];
    }];
}

#pragma mark - UUDatePickerDelegate
-(void)uuDatePicker:(UUDatePicker *)datePicker year:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute weekDay:(NSString *)weekDay {
    NSString *result = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", year, month, day, hour, minute];
    _lostCarTime.subtitle = result;
    
    G100BaseCell *lostCarTimeCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    lostCarTimeCell.rightTextField.text = [NSString stringWithFormat:@"大约 %@", result];;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100BaseItem * item = [self.dataArray safe_objectAtIndex:indexPath.row];
    
    G100BaseCell * cell = nil;
    cell = [G100BaseCell cellWithTableView:tableView item:item];
    
    [cell setItem:item];
    
    __weak G100DevLostInfoViewController *wself = self;
    if ([item isKindOfClass:[G100BaseTextFieldItem class]]) {
        // 添加输入框的监听
        cell.textFieldChanged = ^(UITextField *textFiled){
            wself.publishedButton.enabled = [wself publishIsEnable];
        };
    }
    
    // 丢车位置
    if ([item.itemkey isEqualToString:kBaseItemKeyLostCarLocation]) {
        cell.accessoryView = [self locationInfoButtonWithFrame:CGRectMake(0, 0, WIDTH - 120, 44)];
        _locationInfoTextField.text = item.subtitle;
    }
    
    // 丢车时间
    if ([item.itemkey isEqualToString:kBaseItemKeyLostCarTime]) {
        NSDate *lostDate = nil;
        if (self.lostCarTime.subtitle.length) {
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            lostDate = [formatter dateFromString:self.lostCarTime.subtitle];
        }else if (self.lostDomain.losttime.length) {
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            lostDate = [formatter dateFromString:self.lostDomain.losttime];
        }else {
            lostDate = self.nowDate;
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            item.subtitle = [formatter stringFromDate:lostDate];
        }
        
        UUDatePicker *datePicker= [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, WIDTH, 200)
                                                            Delegate:self
                                                         PickerStyle:UUDateStyle_YearMonthDayHourMinute];
        datePicker.ScrollToDate = lostDate;
        datePicker.maxLimitDate = self.nowDate;
        //datePicker.minLimitDate = [lostDate dateByAddingTimeInterval:-111111111];
        cell.rightTextField.inputView = datePicker;
        cell.rightTextField.text = [NSString stringWithFormat:@"大约 %@", item.subtitle];
    }
    
    // 车辆特征
    if ([item.itemkey isEqualToString:kBaseItemKeyLostCarFeature]) {
        cell.labelView.text = item.subtitle;
    }
    
    // 联系人
    if ([item.itemkey isEqualToString:kBaseItemKeyLostCarUserName]) {
        cell.rightTextField.placeholder = @"点击输入";
        cell.rightTextField.text = item.subtitle;
    }
    
    // 手机号
    if ([item.itemkey isEqualToString:kBaseItemKeyLostCarUserPhone]) {
        cell.rightTextField.placeholder = @"点击输入";
        cell.rightTextField.text = item.subtitle;
        
        cell.maxAllowCount = 11;
        [cell.rightTextField setKeyboardType:UIKeyboardTypeNumberPad];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    G100BaseItem * item = [self.dataArray safe_objectAtIndex:indexPath.row];
    
    if (item.option) {
        item.option();
    }
    
    if ([item.itemkey isEqualToString:kBaseItemKeyLostCarFeature]) {
        G100BikeEditFeatureViewController * featureVc = [[G100BikeEditFeatureViewController alloc] init];
        featureVc.userid = self.userid;
        featureVc.bikeid = self.bikeid;
        featureVc.devid = self.devid;
        featureVc.entranceFrom = BikeEditFeatureEntranceFromLostBike;
        [self.navigationController pushViewController:featureVc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100BaseItem * item = [_dataArray safe_objectAtIndex:indexPath.row];
    return [G100BaseCell heightForItem:item];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

#pragma mark - 地图按钮跳转
- (void)tl_mapToGetLostCarLocation {
    G100DevLocationConfirmViewController *devLocationConfirmVC = [[G100DevLocationConfirmViewController alloc] init];
    devLocationConfirmVC.userid = self.userid;
    devLocationConfirmVC.bikeid = self.bikeid;
    devLocationConfirmVC.devid = self.devid;
    
    devLocationConfirmVC.locationCoordinate = self.lostDevLocationCoordinate;
    
    __weak G100DevLostInfoViewController *wself = self;
    devLocationConfirmVC.locatinCofirmFinished = ^(CLLocationCoordinate2D coordinate, AMapReGeocode *reGeocode){
        wself.userHasSelectedLocation = YES;
        
        wself.locationInfoTextField.text = reGeocode.formattedAddress;
        wself.lostCarLocation.subtitle  = reGeocode.formattedAddress;
        wself.lostDevLocationCoordinate = coordinate;
        
        [wself.tableView reloadData];
        wself.publishedButton.enabled = [self publishIsEnable];
    };
    
    [self.navigationController pushViewController:devLocationConfirmVC animated:YES];
}

#pragma mark - 私有方法
- (BOOL)publishIsEnable {
    BOOL enable0 = YES;
    if (self.locationInfoTextField.text.length == 0) {
        enable0 = NO;
    }
    
    BOOL enable1 = YES;
    if (self.lostCarFeature.subtitle.length == 0) {
        enable1 = NO;
    }
    
    BOOL enable2 = YES;
    if (self.lostCarUserPhone.subtitle.length == 0) {
        enable2 = NO;
    }
    
    __block BOOL enable3 = YES;
    if (self.bikeDomain.brand.brand_id == 0) {
        
    }else if (self.bikeDomain.brand.brand_id > 0) {
        // 判断车辆品牌是否是预置品牌
        if (self.bikeDomain.brand.brand_id == 0) {
            if (//self.featureDomain.color.length == 0 ||
                self.featureDomain.type == 0 ||
                self.bikeDomain.brand.name.length == 0) {
                enable3 = NO;
            }
        }else if (self.bikeDomain.brand.brand_id > 0) {
            // 预置品牌 需要从本地加载数据
            __weak G100DevLostInfoViewController *wself = self;
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    if (//wself.featureDomain.color.length == 0 ||
                        wself.featureDomain.type == 0 ||
                        theme.theme_channel_info.name.length == 0) {
                        enable3 = NO;
                    }
                }else enable3 = NO;
            }];
        }
    }
    
    BOOL enable4 = YES; // 丢车地点的坐标信息
    if (self.lostDevLocationCoordinate.longitude == 0 &&
        self.lostDevLocationCoordinate.latitude == 0) {
        enable4 = NO;
    }
    
    return enable0&&enable1&&enable2&&enable3&&enable4;
}

#pragma mark - 监听输入框的内容
- (void)textFieldDidChange:(UITextField *)textField {
    self.publishedButton.enabled = [self publishIsEnable];
}

#pragma mark - 发布启事
- (void)tl_publishInspiration {
    // 将用户填写的数据提交服务器 返回成功 就根据返回的shareurl 打开相应的webView
    if (!self.lostCarLocation.subtitle.length) {
        [self showHint:@"请输入丢车地点"];
        return;
    }
    if (self.bikeDomain.brand.brand_id == 0) {
        if (//self.featureDomain.color.length == 0 ||
            self.featureDomain.type == 0 ||
            self.bikeDomain.brand.name.length == 0) {
            [self showHint:@"请完善您的特征信息"];
            return;
        }
    }else if (self.bikeDomain.brand.brand_id > 0) {
        if (//self.featureDomain.color.length == 0 ||
            self.featureDomain.type == 0) {
            [self showHint:@"请完善您的特征信息"];
            return;
        }
    }
    
    if([NSString checkPhoneNum:self.lostCarUserPhone.subtitle]){
        [self showHint:[NSString checkPhoneNum:self.lostCarUserPhone.subtitle]];
        return;
    }
    
    __weak G100DevLostInfoViewController *wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            G100DevFindInspirationViewController *inspirationvc = [[G100DevFindInspirationViewController alloc] initWithNibName:@"G100DevFindInspirationViewController" bundle:nil];
            inspirationvc.userid = wself.userid;
            inspirationvc.bikeid = wself.bikeid;
            inspirationvc.devid = wself.devid;
            inspirationvc.lostid = [[response.data objectForKey:@"lostid"] integerValue];
            inspirationvc.httpUrl = [NSString stringWithFormat:@"%@&status=1", [response.data objectForKey:@"previewshareurl"]];
            self.lostid = inspirationvc.lostid;
            [wself.navigationController pushViewController:inspirationvc animated:YES];
        }else {
            if (response.errDesc.length) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    // 发布丢车启事 新发布
    [self showHudInView:self.view hint:@"请稍候"];
    [[G100BikeApi sharedInstance] reportBikeLostWithBikeid:self.bikeid
                                                lostid:self.lostid
                                             lostlongi:self.lostDevLocationCoordinate.longitude
                                              lostlati:self.lostDevLocationCoordinate.latitude
                                              losttime:self.lostCarTime.subtitle
                                           lostlocdesc:self.locationInfoTextField.text
                                               contact:self.lostCarUserName.subtitle
                                              phonenum:self.lostCarUserPhone.subtitle
                                              callback:callback];
}

#pragma mark - 获取相关数据
- (void)getBikeFeature {
    __weak G100DevLostInfoViewController * wself = self;
    [[G100DevApi sharedInstance] getBikeFeatureWithBikeid:self.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [[G100InfoHelper shareInstance] updateMyBikeFeatureWithUserid:self.userid bikeid:self.bikeid feature:response.data];
            wself.publishedButton.enabled = [wself publishIsEnable];
        }

    }];
}

- (void)getBikeLostRecord {
    if (!self.lostid) {
        return;
    }
    __weak G100DevLostInfoViewController *wself = self;
    [[G100BikeApi sharedInstance] getBikeLostRecordWithBikeid:self.bikeid lostid:@[[NSNumber numberWithInteger:self.lostid]] callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            G100DevLostListDomain *lostListDomain = [[G100DevLostListDomain alloc]initWithDictionary:response.data];
            if (lostListDomain.lost.count>0) {
                wself.userHasSelectedLocation = YES;
                self.lostDomain = [lostListDomain.lost firstObject];
                wself.locationInfoTextField.text = self.lostDomain.lostlocdesc;
                wself.lostCarLocation.subtitle = self.lostDomain.lostlocdesc;
                wself.lostCarUserName.subtitle = self.lostDomain.contact;
                wself.lostCarUserPhone.subtitle = self.lostDomain.phonenum;
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *lostDate = [formatter dateFromString:self.lostDomain.losttime];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                wself.lostCarTime.subtitle = [formatter stringFromDate:lostDate];
                
                wself.lostDevLocationCoordinate = CLLocationCoordinate2DMake(self.lostDomain.lostlati,
                                                                             self.lostDomain.lostlongi);
                
                [wself.tableView reloadData];
                
                wself.publishedButton.enabled = [wself publishIsEnable];
            }
        }
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tag = 1000;
        _tableView.backgroundColor = MyBackColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (UILabel *)topHintLabel {
    if (!_topHintLabel) {
        _topHintLabel = [[UILabel alloc] init];
        _topHintLabel.numberOfLines = 0;
        _topHintLabel.font = [UIFont systemFontOfSize:14];
        _topHintLabel.textAlignment = NSTextAlignmentCenter;
        _topHintLabel.textColor = [UIColor whiteColor];
        _topHintLabel.backgroundColor = [UIColor colorWithHexString:@"FD6207"];
    }
    return _topHintLabel;
}

- (UIView *)tableFooterView {
    if (!_tableFooterView) {
        _tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 64 - self.tableView.contentSize.height - 30)];
        _tableFooterView.backgroundColor = MyBackColor;
    }
    return _tableFooterView;
}

- (UIButton *)publishedButton {
    if (!_publishedButton) {
        _publishedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishedButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_publishedButton setTitle:@"发布启事" forState:UIControlStateNormal];
        
        UIEdgeInsets insets = UIEdgeInsetsMake(9, 9, 9, 9);
        UIImage *normalImage    = [[UIImage imageNamed:@"ic_alarm_option_yes_up"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        UIImage *highlitedImage = [[UIImage imageNamed:@"ic_alarm_option_yes_down"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        [_publishedButton addTarget:self action:@selector(tl_publishInspiration) forControlEvents:UIControlEventTouchUpInside];
        
        [_publishedButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_publishedButton setBackgroundImage:highlitedImage forState:UIControlStateHighlighted];
        
        [self.tableFooterView addSubview:_publishedButton];
        
        [_publishedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@20);
            make.width.equalTo(WIDTH-40);
            make.bottom.equalTo(@-20);
            make.height.equalTo(@40);
        }];
    }
    return _publishedButton;
}

- (UIView *)locationInfoButtonWithFrame:(CGRect)rect {
    if (!_locationInfoButtonView) {
        _locationInfoButtonView = [[UIView alloc] initWithFrame:rect];
        
        _locationInfoTextField = [[UITextField alloc] init];
        _locationInfoTextField.text = @"定位中...";
        _locationInfoTextField.textColor = RGBColor(125, 125, 125, 1.0);
        _locationInfoTextField.font = [UIFont systemFontOfSize:14];
        _locationInfoTextField.textAlignment = NSTextAlignmentRight;
        [_locationInfoTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_locationInfoButtonView addSubview:_locationInfoTextField];
        
        UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [mapButton setTitle:@"地图" forState:UIControlStateNormal];
        [mapButton setTitleColor:MyGreenColor forState:UIControlStateNormal];
        [mapButton addTarget:self action:@selector(tl_mapToGetLostCarLocation) forControlEvents:UIControlEventTouchUpInside];
        [mapButton.layer setMasksToBounds:YES];
        [mapButton.layer setCornerRadius:5.0];
        [mapButton.layer setBorderWidth:1.0f];
        [mapButton.layer setBorderColor:MyGreenColor.CGColor];
        
        [_locationInfoButtonView addSubview:mapButton];
        
        [mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@25);
            make.width.equalTo(kNavigationBarHeight);
            make.centerY.equalTo(_locationInfoButtonView);
            make.trailing.equalTo(@0);
        }];
        
        [_locationInfoTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.height.equalTo(@20);
            make.centerY.equalTo(mapButton);
            make.trailing.equalTo(mapButton.mas_leading).with.offset(@-5);
        }];
    }
    return _locationInfoButtonView;
}

#pragma mark - setter / getter
- (void)setFirstPublishTime:(NSString *)firstPublishTime {
    _firstPublishTime = firstPublishTime;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.nowDate = [formatter dateFromString:firstPublishTime];
}
#pragma mark - 模型懒加载
- (G100BaseTextFieldItem *)lostCarTime {
    if (!_lostCarTime) {
        _lostCarTime          = [G100BaseTextFieldItem itemWithTitle:@"丢车时间"];
        _lostCarTime.subtitle = @"";
        _lostCarTime.itemkey  = kBaseItemKeyLostCarTime;
    }
    return _lostCarTime;
}
- (G100BaseItem *)lostCarLocation {
    if (!_lostCarLocation) {
        _lostCarLocation          = [G100BaseLabelItem itemWithTitle:@"丢车地点*"];
        _lostCarLocation.subtitle = @"定位中...";
        _lostCarLocation.itemkey  = kBaseItemKeyLostCarLocation;
    }
    return _lostCarLocation;
}
- (G100BaseArrowItem *)lostCarFeature {
    if (!_lostCarFeature) {
        _lostCarFeature          = [G100BaseArrowItem itemWithTitle:@"车辆特征*"];
        _lostCarFeature.subtitle = [NSString stringWithFormat:@"%@%%", @(self.featureDomain.integrity)];
        _lostCarFeature.itemkey  = kBaseItemKeyLostCarFeature;
    }
    return _lostCarFeature;
}
- (G100BaseTextFieldItem *)lostCarUserName {
    if (!_lostCarUserName) {
        _lostCarUserName          = [G100BaseTextFieldItem itemWithTitle:@"联系人"];
        _lostCarUserName.subtitle = self.userDomain.real_name;
        _lostCarUserName.itemkey  = kBaseItemKeyLostCarUserName;
    }
    return _lostCarUserName;
}
- (G100BaseTextFieldItem *)lostCarUserPhone {
    if (!_lostCarUserPhone) {
        _lostCarUserPhone          = [G100BaseTextFieldItem itemWithTitle:@"手机*"];
        _lostCarUserPhone.subtitle = self.userDomain.phonenum;
        _lostCarUserPhone.itemkey  = kBaseItemKeyLostCarUserPhone;
    }
    return _lostCarUserPhone;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[ self.lostCarLocation,
                        self.lostCarTime,
                        self.lostCarFeature,
                        self.lostCarUserName,
                        self.lostCarUserPhone ].mutableCopy;
    }
    return _dataArray;
}

- (G100BikeFeatureDomain *)featureDomain {
    if (!_featureDomain) {
        _featureDomain = [[G100BikeFeatureDomain alloc] init];
    }
    _featureDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid].feature;
    return _featureDomain;
}

- (G100UserDomain *)userDomain {
    if (!_userDomain) {
        _userDomain = [[G100UserDomain alloc] init];
    }
    _userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:self.userid];
    return _userDomain;
}

- (G100DeviceDomain *)devDomain {
    if (!_devDomain) {
        _devDomain = [[G100DeviceDomain alloc] init];
    }
    _devDomain = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
    return _devDomain;
}

- (G100BikeDomain *)bikeDomain {
    if (!_bikeDomain) {
        _bikeDomain = [[G100BikeDomain alloc] init];
    }
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    return _bikeDomain;
}

- (void)setupData {
    
    [self userDomain];
    [self devDomain];
    [self featureDomain];
    
    [self dataArray];
    
    self.lostCarFeature.subtitle = [NSString stringWithFormat:@"完整度%@%%",@(self.featureDomain.integrity)];
    
    [self.tableView reloadData];
}

- (void)setupView {
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.topHintLabel];
    
    [self.topHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.trailing.equalTo(@0);
        make.height.greaterThanOrEqualTo(@30);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topHintLabel.mas_bottom);
        make.leading.trailing.bottom.equalTo(@0);
    }];
    
    [self.tableView setTableFooterView:self.tableFooterView];
    
    [self.topHintLabel setText:@"提供越多信息，越容易找回车辆"];
    
    self.publishedButton.enabled = [self publishIsEnable];
}

- (void)setupNavigationBarView {
    [self setNavigationTitle:@"丢车信息"];
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 如果没有定义最晚发布时间 则定义为当前时间
    if (!_nowDate) self.nowDate = [NSDate date];
    
    [self setupData];
    
    [self setupView];
    
    [self locationInformation];
    
    self.userHasSelectedLocation = NO;
    
    // 每次进来请求一次 刷新特征信息
    [self getBikeFeature];
    // 每次进来请求一次丢车记录
    [self getBikeLostRecord];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    __weak G100DevLostInfoViewController * wself = self;
    [[UserManager shareManager] updateBikeInfoWithUserid:self.userid bikeid:self.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [wself setupData];
        }
    }];
    
    self.publishedButton.enabled = [self publishIsEnable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
