//
//  G100DevFeatureInfoViewController.m
//  G100
//
//  Created by yuhanle on 16/3/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeFeatureInfoViewController.h"
#import "DevFeatureSaveView.h"
#import "G100ProgressView.h"

#import "G100BaseItem.h"
#import "G100BaseCell.h"
#import "G100BaseArrowItem.h"
#import "G100BaseLabelItem.h"
#import "G100BaseImageItem.h"
#import "G100BaseTextFieldItem.h"
#import "G100BaseContextItem.h"

#import "G100DevPhotoCell.h"
#import "G100PhotoPickerView.h"
#import "G100PhotoShowModel.h"
#import "G100BikeTypePickViewController.h"
#import "G100PickActionSheet.h"

#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "G100PhotoShowModel.h"

#import "G100ThemeManager.h"
#import "G100BikeDomain.h"
#import "G100BikeUpdateInfoDomain.h"
#import "NSString+CalHeight.h"

static NSString * const kBaseItemKeyDevColor        = @"dev_color";
static NSString * const kBaseItemKeyDevModel        = @"dev_model";
static NSString * const kBaseItemKeyDevBrand        = @"dev_brand";
static NSString * const kBaseItemKeyDevPlatenumber  = @"dev_platenumber";
static NSString * const kBaseItemKeyDevOtherFeature = @"other_feature";
static NSString * const kBaseItemKeyDevMotornumber  = @"dev_motornumber";
static NSString * const kBaseItemKeyDevVin          = @"dev_vin";

static NSString * cellIdentifier = @"devPhotoCell";

@interface G100BikeFeatureInfoViewController () <UITableViewDelegate, UITableViewDataSource, DevFeatureSaveViewDelegate, G100PhotoPickerDelegate, UITextFieldDelegate> {
    NSInteger _devType;
    
    BOOL _previousInteractivePopEnable;
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) G100BikeDomain * bikeDomain;
@property (nonatomic, strong) DevFeatureSaveView * saveView;
@property (nonatomic, strong) G100ProgressView *topProgressView;
@property (nonatomic, strong) UIView *sectionHeader1;
@property (nonatomic, strong) UIView *sectionFooter1;
@property (nonatomic, strong) UIView *pushAlertView;

@property (nonatomic, strong) G100BaseTextFieldItem * dev_color;
@property (nonatomic, strong) G100BaseArrowItem * dev_model;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_brand;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_platenumber;
@property (nonatomic, strong) G100BaseContextItem * other_feature;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_motornumber;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_vin;

@property (nonatomic, strong) NSArray * urlImgArray;

@property (nonatomic, strong) G100BikeFeatureDomain * featureDomain;
@property (strong, nonatomic) G100BikeUpdateInfoDomain *bikeUpdateInfo;

@property (nonatomic, strong) NSMutableArray * photoArray;
@property (nonatomic, strong) NSMutableArray * photoAddArray;
@property (nonatomic, strong) NSMutableArray * photoDelArray;
@property (nonatomic, strong) NSMutableArray * photoNameArray;
@property (strong, nonatomic) NSMutableArray * updatePicArray;
@property (nonatomic, assign) BOOL isEnableEdit;

@property (nonatomic, assign) CGFloat pushAlertViewTextHeight;
@property (nonatomic, assign) CGFloat saveViewHeight;

@property (nonatomic, strong) NSString *coverUrl;

@end

@implementation G100BikeFeatureInfoViewController

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid entranceFrom:(BikeFeatureInfoEntrance)entranceFrom {
    if (self = [super init]) {
        self.userid = userid;
        self.bikeid = bikeid;
        self.entranceFrom = entranceFrom;
    }
    return self;
}

#pragma mark - lazy method
-(G100BikeDomain *)bikeDomain {
    _bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    return _bikeDomain;
}

-(G100BikeUpdateInfoDomain *)bikeUpdateInfo
{
    if (!_bikeUpdateInfo) {
        _bikeUpdateInfo = self.bikeDomain.bikeUpdateInfo;
    }
    return _bikeUpdateInfo;
}
- (NSMutableArray *)photoArray {
    if (!_photoArray) {
        _photoArray = [NSMutableArray array];
    }
    return _photoArray;
}

- (NSMutableArray *)photoAddArray {
    if (!_photoAddArray) {
        _photoAddArray = [NSMutableArray array];
    }
    return _photoAddArray;
}

- (NSMutableArray *)photoDelArray {
    if (!_photoDelArray) {
        _photoDelArray = [NSMutableArray array];
    }
    return _photoDelArray;
}

- (NSMutableArray *)photoNameArray {
    if (!_photoNameArray) {
        _photoNameArray = [NSMutableArray array];
    }
    return _photoNameArray;
}

-(NSMutableArray *)updatePicArray
{
    if (!_updatePicArray) {
        _updatePicArray = [NSMutableArray arrayWithArray:self.bikeUpdateInfo.feature.pictures];
    }
    return _updatePicArray;
}

- (G100BaseTextFieldItem *)dev_color {
    if (!_dev_color) {
        _dev_color          = [G100BaseTextFieldItem itemWithTitle:@"车身颜色"];
        _dev_color.subtitle = @"";
        _dev_color.itemkey  = kBaseItemKeyDevColor;
    }
    return _dev_color;
}

- (G100BaseArrowItem *)dev_model {
    if (!_dev_model) {
        _dev_model          = [G100BaseArrowItem itemWithTitle:@"车型"];
        _dev_model.subtitle = @"";
        _dev_model.itemkey  = kBaseItemKeyDevModel;
    }
    return _dev_model;
}

- (G100BaseTextFieldItem *)dev_brand {
    if (!_dev_brand) {
        _dev_brand          = [G100BaseTextFieldItem itemWithTitle:@"品牌"];
        _dev_brand.subtitle = self.bikeDomain.brand.name;
        _dev_brand.itemkey  = kBaseItemKeyDevBrand;
    }
    return _dev_brand;
}

- (G100BaseTextFieldItem *)dev_platenumber {
    if (!_dev_platenumber) {
        _dev_platenumber          = [G100BaseTextFieldItem itemWithTitle:@"车牌号"];
        _dev_platenumber.subtitle = @"";
        _dev_platenumber.itemkey  = kBaseItemKeyDevPlatenumber;
    }
    return _dev_platenumber;
}

- (G100BaseContextItem *)other_feature {
    if (!_other_feature) {
        _other_feature          = [G100BaseContextItem itemWithTitle:@"其他特征"];
        _other_feature.subtitle = @"";
        _other_feature.itemkey  = kBaseItemKeyDevOtherFeature;
    }
    return _other_feature;
}

- (G100BaseTextFieldItem *)dev_motornumber {
    if (!_dev_motornumber) {
        _dev_motornumber          = [G100BaseTextFieldItem itemWithTitle:@"电机号或发动机号"];
        _dev_motornumber.subtitle = @"";
        _dev_motornumber.itemkey  = kBaseItemKeyDevMotornumber;
    }
    return _dev_motornumber;
}

- (G100BaseTextFieldItem *)dev_vin {
    if (!_dev_vin) {
        _dev_vin          = [G100BaseTextFieldItem itemWithTitle:@"车架号"];
        _dev_vin.subtitle = @"";
        _dev_vin.itemkey  = kBaseItemKeyDevVin;
    }
    return _dev_vin;
}

- (UIView *)pushAlertView
{
    if (!_pushAlertView) {
        _pushAlertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
        _pushAlertView.backgroundColor =  [UIColor colorWithHexString:@"FD6207"];
        UILabel *textLable = [[UILabel alloc]init];
        textLable.backgroundColor = [UIColor colorWithHexString:@"FD6207"];
        textLable.textColor = [UIColor whiteColor];
        textLable.font = [UIFont systemFontOfSize:15];
        textLable.numberOfLines = 0;
        if (self.bikeDomain.isMaster) {
            textLable.text = @"填写详细的信息，可以帮你在丢车时更快找回车辆";
        }else{
            textLable.text = @"抱歉，你没有权限操作，如要更改请通知主用户更改";

        }
      
        [_pushAlertView addSubview:textLable];
        
        [textLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@15);
            make.top.equalTo(@5);
            make.center.equalTo(@0);
        }];

        _pushAlertViewTextHeight = [NSString heightWithText:textLable.text fontSize:textLable.font Width:WIDTH - 30] + 10;
    }
    return _pushAlertView;
}
#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - G100PhotoPickerDelegate
- (void)pickerView:(G100PhotoPickerView*)pickerView hasChangedPhotos:(NSArray*)photos/* G100PhotoShowModel */ {
    [self.photoArray removeAllObjects];
    [self.photoArray addObjectsFromArray:photos];
    
    if (self.urlImgArray.count > 0 && self.entranceFrom != BikeFeatureInfoEntranceFromAddBike) {
        for (G100PhotoShowModel * model in self.urlImgArray) {
            if ([self.photoArray containsObject:model]) { //去除服务器上的图片
                [self.photoArray removeObject:model];
            }
        }
    }
    [self.photoAddArray removeAllObjects];
    if (self.photoArray.count > 0) {
        for (G100PhotoShowModel * model in self.photoArray) {
            if (model.data) {
                [self.photoAddArray addObject:model.data];
            }
            
            if (model.photoName) {
                [self.photoNameArray addObject:model.photoName];
            }

        }
    }
}

- (void)pickerView:(G100PhotoPickerView *)pickerView hasDeletedPhotoName:(NSString*)name {
    [self.photoDelArray addObject:name];
    
    if (self.urlImgArray.count > 0  && self.entranceFrom != BikeFeatureInfoEntranceFromAddBike) {
        for (G100PhotoShowModel * model in self.urlImgArray) {
            if ([self.photoArray containsObject:model]) { //去除服务器上的图片
                [self.photoArray removeObject:model];
            }
        }
    }
    [self.photoAddArray removeAllObjects];
    if (self.photoArray.count > 0) {
        for (G100PhotoShowModel * model in self.photoArray) {
            if (model.data) {
                [self.photoAddArray addObject:model.data];
            }
            
            if (model.photoName) {
                [self.photoNameArray addObject:model.photoName];
            }

        }
    }
}

- (void)pickerView:(G100PhotoPickerView *)pickerView coverUrl:(NSString *)coverUrl
{
    __block typeof(self) wself = self;
    if (coverUrl) {
        [[G100BikeApi sharedInstance] setBikeCoverWithBikeid:self.bikeid coverPicture:coverUrl callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
            [wself hideHud];
            if (requestSuccess) {
                [[UserManager shareManager] updateBikeInfoWithUserid:self.userid bikeid:self.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                    if (requestSuccess) {
                        [CURRENTVIEWCONTROLLER showHint:@"设置成功"];
                    }
                }];
            }else{
                [wself showHint:response.errDesc];
            }
        }];
    }
}
#pragma mark - DevFeatureSaveViewDelegate
- (void)devFeatureSaveView:(DevFeatureSaveView *)saveView saveBtn:(UIButton *)saveBtn {
    [self saveInfo];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        if (self.bikeDomain.isMaster) {
            return 40;
        }else{
            return 0.001;
        }
     
    }
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.v_height;
    }
    
    G100BaseItem * item = _dataArray[indexPath.section][indexPath.row];
    if ([item isKindOfClass:[G100BaseContextItem class]]) {
        return [G100BaseContextEditCell heightForItem:item];
    }
    
    return 44;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [_dataArray[section] count];
    }
    return [_dataArray[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        G100DevPhotoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[G100DevPhotoCell alloc] initWithDelegate:self
                                                   identifier:cellIdentifier
                                                    dataArray:self.urlImgArray
                                                  isAllowEdit:self.isEnableEdit
                                               isShowCoverBtn:self.isEnableEdit];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        G100BaseItem * item = _dataArray[indexPath.section][indexPath.row];
        G100BaseCell * baseCell = nil;
        if ([item isKindOfClass:[G100BaseContextItem class]]) {
            baseCell = [G100BaseContextEditCell cellWithTableView:tableView item:item];
        }else {
            baseCell = [G100BaseCell cellWithTableView:tableView item:item];
        }
        
        if ( [item.itemkey isEqualToString:kBaseItemKeyDevMotornumber]) {
            [baseCell setItem:item rightTextfiledBound:CGRectMake(0, 0, WIDTH - 180, 30)];
        }else{
            [baseCell setItem:item];
        }
        
        if ([item.itemkey isEqualToString:kBaseItemKeyDevColor]) {
            // 限制颜色输入字数
            baseCell.maxAllowCount = 10;
        }
        if ([item.itemkey isEqualToString:kBaseItemKeyDevModel]) {
            baseCell.userInteractionEnabled = self.isEnableEdit;
            if (!self.isEnableEdit) [baseCell setAccessoryType:UITableViewCellAccessoryNone];
        }
        if ([item.itemkey isEqualToString:kBaseItemKeyDevBrand] || [item.itemkey isEqualToString:kBaseItemKeyDevColor] || [item.itemkey isEqualToString:kBaseItemKeyDevPlatenumber]) {
            if (self.isEnableEdit) baseCell.rightTextField.placeholder = @"点击输入";
            if ([item.itemkey isEqualToString:kBaseItemKeyDevBrand])
                // 限制品牌输入字数
                baseCell.maxAllowCount = 10;
        }
        if ([item.itemkey isEqualToString:kBaseItemKeyDevOtherFeature]) {
            // 限制其他特征输入字数
            baseCell.maxAllowCount = 30;
            baseCell.maxHint = @"特征不能超过30个字符";
            G100BaseContextEditCell * cell = (G100BaseContextEditCell *)baseCell;
            if (self.isEnableEdit) cell.contextDetailTextView.placeholder = @"如改装、成色、损坏情况(最多填写30个字符)";
            cell.contextDetailTextView.editable = cell.contextDetailTextView.selectable = self.isEnableEdit;
        }
        if ([item.itemkey isEqualToString:kBaseItemKeyDevVin] || [item.itemkey isEqualToString:kBaseItemKeyDevMotornumber]) {
            if ([item.itemkey isEqualToString:kBaseItemKeyDevVin]) {
                baseCell.maxHint = @"车架号不能超过20个字符";
                baseCell.maxAllowCount = 20;
            }
            if ([item.itemkey isEqualToString:kBaseItemKeyDevMotornumber]) {
                baseCell.maxHint = @"电机号不能超过40个字符";
                baseCell.maxAllowCount = 40;
            }
            baseCell.rightTextField.keyboardType = UIKeyboardTypeASCIICapable;
            if (self.isEnableEdit) baseCell.rightTextField.placeholder = @"此信息可在说明书或者合格证上查找";
        }
        
        baseCell.rightTextField.text = item.subtitle;
        baseCell.rightTextField.delegate = self;
        baseCell.rightTextField.returnKeyType = UIReturnKeyDone;

        if ([item.itemkey isEqualToString:kBaseItemKeyDevBrand]) {
            if (self.bikeDomain.brand.brand_id > 0) {
                baseCell.rightTextField.placeholder = nil;
                baseCell.rightTextField.userInteractionEnabled = NO;
            }else if (self.bikeDomain.brand.brand_id == 0) {
                baseCell.rightTextField.userInteractionEnabled = self.isEnableEdit;
            }
        }else {
            baseCell.rightTextField.userInteractionEnabled = self.isEnableEdit;
        }
        
        return baseCell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.sectionHeader1;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (self.bikeDomain.isMaster) {
            return self.sectionFooter1;
        }else{
            return nil;
        }
      
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    
    G100BaseItem * item = _dataArray[indexPath.section][indexPath.row];
    if ([item.itemkey isEqualToString:kBaseItemKeyDevModel]) {
        __weak G100BikeFeatureInfoViewController * wself = self;
        G100BikeTypePickViewController * viewController = [[G100BikeTypePickViewController alloc]init];
        viewController.devTypeStr = item.subtitle;
        viewController.bikeType = self.bikeDomain.bike_type;
        viewController.completePickBlock = ^(NSString * devTypeStr, NSInteger devType) {
            item.subtitle = devTypeStr;
            _devType = devType;
            [wself.tableView reloadRowsAtIndexPaths:@[indexPath]
                                   withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - 私有方法
- (void)saveInfo {
    /** 获取输入框中的内容
     *  cell不可见的时候不能取到输入框的内容，所以需要监听输入框的信息
     */
    if (self.dev_color.subtitle.length > 10) {
        [self showHint:@"颜色描述不能超过10个字"];
        return;
    }
    
    if (_entranceFrom == BikeFeatureInfoEntranceFromLostBike) {
        // 丢车信息 有几项是必填 颜色+车型+品牌
        if (self.dev_color.subtitle.length == 0) {
            [self showHint:@"请填写车辆的车身颜色"];
            return;
        }
        
        if ((self.dev_model.subtitle.length == 0)) {
            [self showHint:@"请填写车辆的车型"];
            return;
        }
        
        if (self.bikeDomain.brand.brand_id == 0) {
            if (self.dev_brand.subtitle.length == 0) {
                [self showHint:@"请填写车辆的品牌"];
                return;
            }
        }
    }
    
    if (self.urlImgArray.count > 0 && self.entranceFrom != BikeFeatureInfoEntranceFromAddBike) {
        for (G100PhotoShowModel * model in self.urlImgArray) {
            if ([self.photoArray containsObject:model]) { //去除服务器上的图片
                [self.photoArray removeObject:model];
            }
        }
    }
    [self.photoAddArray removeAllObjects];
    [self.photoNameArray removeAllObjects];
    if (self.photoArray.count > 0) {
        for (G100PhotoShowModel * model in self.photoArray) {
            [self.photoAddArray addObject:model.data ? : [NSData data]];
            [self.photoNameArray addObject:model.photoName ? : @""];
        }
    }
    for (NSString *urlDelImage  in self.photoDelArray) {
        if ([self.updatePicArray containsObject:urlDelImage]) {
                [self.updatePicArray removeObject:urlDelImage];
        }
    }
    for (NSData *imageData in self.photoAddArray) {
        NSString *base64Image = [imageData base64EncodedStringWithOptions:0];
        [self.updatePicArray addObject:base64Image ? : @""];
    }
    //@"cust_brand" : self.bikeDomain.brand.brand_id==0?EMPTY_IF_NIL(self.dev_brand.subtitle):@"",
    NSDictionary * featureDic = @{@"pictures" : self.updatePicArray,
                                  @"color" : EMPTY_IF_NIL(self.dev_color.subtitle),
                                  @"type" : [NSNumber numberWithInteger:_devType],
                                  @"plate_number" : EMPTY_IF_NIL(self.dev_platenumber.subtitle),
                                  @"other_feature" : EMPTY_IF_NIL(self.other_feature.subtitle),
                                  @"vin" : EMPTY_IF_NIL(self.dev_vin.subtitle),
                                  @"motor_number" : EMPTY_IF_NIL(self.dev_motornumber.subtitle),
                                  @"cust_brand" : EMPTY_IF_NIL(self.dev_brand.subtitle)};
    
    [self.bikeUpdateInfo.feature setValuesForKeysWith_MyDict:featureDic];
    self.bikeUpdateInfo.brand.name = self.bikeDomain.brand.brand_id==0?EMPTY_IF_NIL(self.dev_brand.subtitle):@"";
    /**
     *  判断是添加车辆还是更新特征信息
     */
    if (_entranceFrom == BikeFeatureInfoEntranceFromAddBike) {
        // TODO... 添加车辆回调
        if (_bikeFeatureBlock) {
            self.bikeFeatureBlock(self.updatePicArray, featureDic);
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }else {
        ;
    }
    
    __weak typeof(self) wself = self;
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }

    [self showProgressHudInView:self.view hint:@"保存中"];
    
    [[G100BikeApi sharedInstance] updateBikeProfileWithBikeid:self.bikeid bikeType:self.bikeDomain.bike_type profile:[self.bikeUpdateInfo mj_keyValues] progress:^(float progress) {
        [self setProgress:progress];
    } callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeInfoWithUserid:self.userid bikeid:self.bikeid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [wself showHint:@"保存成功"];
                    [wself.navigationController popViewControllerAnimated:YES];
                }
            }];
        }else{
            [wself showHint:response.errDesc];
        }
    }];
}

- (BOOL)hasChangeInfo {
    BOOL hasChange0 = NO;
    if ([self.photoAddArray count] || [self.photoDelArray count])
        hasChange0 = YES;
    
    BOOL hasChange1 = YES;
    if ([self.featureDomain.color isEqualToString:_dev_color.subtitle] ||
        (self.featureDomain.color == nil && _dev_color.subtitle.length == 0))
        hasChange1 = NO;
    
    BOOL hasChange2 = YES;
    if (self.featureDomain.type == _devType)
        hasChange2 = NO;
    
    BOOL hasChange3 = YES;
    if (self.bikeDomain) {
        if (self.bikeDomain.brand.brand_id == 0) {
            if ([self.bikeDomain.brand.name isEqualToString:_dev_brand.subtitle] ||
                (self.bikeDomain.brand.name == nil && _dev_brand.subtitle.length == 0)) {
                hasChange3 = NO;
            }
        }else if (self.bikeDomain.brand.brand_id > 0) {
            hasChange3 = NO;
        }
    }else {
        NSString *result = [self.featureDict objectForKey:@"cust_brand"];
        if (result) {
            if ([result isEqualToString:_dev_brand.subtitle]) {
                hasChange3 = NO;
            }
        }else {
            if (_dev_brand.subtitle.length == 0) {
                hasChange3 = NO;
            }
        }
    }
    
    BOOL hasChange4 = YES;
    if ([self.featureDomain.plate_number isEqualToString:_dev_platenumber.subtitle] ||
        (self.featureDomain.plate_number == nil && _dev_platenumber.subtitle.length == 0))
        hasChange4 = NO;
    
    BOOL hasChange5 = YES;
    if ([self.featureDomain.other_feature isEqualToString:_other_feature.subtitle] ||
        (self.featureDomain.other_feature == nil && _other_feature.subtitle.length == 0))
        hasChange5 = NO;
    
    BOOL hasChange6 = YES;
    if ([self.featureDomain.motor_number isEqualToString:_dev_motornumber.subtitle] ||
        (self.featureDomain.motor_number == nil && _dev_motornumber.subtitle.length == 0))
        hasChange6 = NO;
    
    BOOL hasChange7 = YES;
    if ([self.featureDomain.vin isEqualToString:_dev_vin.subtitle] ||
        (self.featureDomain.vin == nil && _dev_vin.subtitle.length == 0))
        hasChange7 = NO;

    return (hasChange0 || hasChange1 || hasChange2 || hasChange3 || hasChange4 || hasChange5 || hasChange6 || hasChange7);
}

- (void)removePushAlertView
{
    [self.pushAlertView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBarView.mas_bottom).with.offset(-_pushAlertViewTextHeight);
    }];
    CGRect tableViewFrame = self.contentView.bounds;
    tableViewFrame.origin.y = 5;
    tableViewFrame.size.height -= 5;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.tableView.frame = tableViewFrame;
        self.saveView.v_height = self.saveViewHeight;
        [self.contentView layoutIfNeeded];
    }];
}

#pragma mark - 重写父类方法
- (void)actionClickNavigationBarLeftButton {
    if ([self hasChangeInfo]) {
        // 有信息变动 提示用户保存
        [MyAlertView MyAlertWithTitle:nil message:@"您已经修改了信息，是否保存" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [super actionClickNavigationBarLeftButton];
            }else {
                [self saveInfo];
            }
        } cancelButtonTitle:@"放弃保存" otherButtonTitles:@"保存并返回"];
    }else {
        [super actionClickNavigationBarLeftButton];
    }
}

#pragma mark - UI
- (void)setupNavigationBarView {
    [self setNavigationTitle:@"特征信息"];
}

- (void)setupView {
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.pushAlertView];
    [self.contentView addSubview:self.topProgressView];
 
    [self.pushAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBarView.mas_bottom).with.offset(-_pushAlertViewTextHeight);
        make.leading.trailing.equalTo(@0);
    }];
    [self.topProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushAlertView.mas_bottom);
        make.leading.trailing.equalTo(@0);
        make.height.equalTo(@5);
    }];
    
    CGRect frame = self.contentView.bounds;
    frame.size.height -= 5;
    frame.origin.y = 5;
    self.tableView.frame = frame;

    if (_entranceFrom == BikeFeatureInfoEntranceFromAddBike) {
        [self.saveView setDeviceDomain:nil];
    }else {
        [self.saveView setBikeDomain:self.bikeDomain];
        [self.saveView setDeviceDomain:self.bikeDomain.mainDevice];
    }
    
    if (_entranceFrom == BikeFeatureInfoEntranceFromLostBike) {
        self.saveView.v_height = 150;
        
        if (self.bikeDomain.isMaster) {
            if (!self.bikeDomain.mainDevice) {
                self.saveView.v_height = 80;
            }
        }else {
            self.saveView.v_height = 80;
        }
    }else if (_entranceFrom == BikeFeatureInfoEntranceFromBikeInfo) {
        self.saveView.v_height = 150;
        
        if (self.bikeDomain.isMaster) {
            if (!self.bikeDomain.mainDevice) {
                self.saveView.v_height = 80;
            }
        }else {
            self.saveView.v_height = 80;
        }
    }else if (_entranceFrom == BikeFeatureInfoEntranceFromAddBike) {
        self.saveView.v_height = 80;
    }else {
        self.saveView.v_height = 80;
    }
    
    self.saveView.v_width = self.tableView.v_width;
    [self.tableView setTableFooterView:self.saveView];
    
    self.saveViewHeight = self.saveView.v_height;
    // 设置车辆信息完整度
    [self.topProgressView setProgress:self.bikeDomain.feature.integrity/100.0];
    
    //如果车辆信息不完整 则弹出提示
    __weak typeof (self) weakSelf = self;
   // if (self.bikeDomain.isMaster) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.pushAlertView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(strongSelf.navigationBarView.mas_bottom);
            }];
            
            CGRect tableViewFrame = strongSelf.contentView.bounds;
            tableViewFrame.origin.y += (5+_pushAlertViewTextHeight);
            tableViewFrame.size.height -= (5+_pushAlertViewTextHeight);
            
            [UIView animateWithDuration:1.0 animations:^{
                strongSelf.tableView.frame = tableViewFrame;
                strongSelf.saveView.v_height = strongSelf.saveViewHeight;
                [strongSelf.contentView layoutIfNeeded];
            }];
        });
    //}
}

- (void)getBikeFeature {
    if (_entranceFrom == BikeFeatureInfoEntranceFromAddBike) {
        return;
    }else {
        ;
    }
    
    __weak typeof(self) wself = self;
    
    if (kNetworkNotReachability) {
        [wself showHint:kError_Network_NotReachable];
        return;
    }
    [self showHudInView:self.contentView hint:@"请稍后"];
    [[G100DevApi sharedInstance] getBikeFeatureWithBikeid:self.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [wself hideHud];
        self.urlImgArray = [NSArray array];
        if (requestSuccess) {
            self.featureDomain = [[G100BikeFeatureDomain alloc] initWithDictionary:response.data];
            [self configFeatureData];
            [[G100InfoHelper shareInstance] updateMyBikeFeatureWithUserid:wself.userid bikeid:wself.bikeid feature:response.data];
        }else{
            [self showHint:response.errDesc];
        }
    }];
 
}

- (void)configFeatureData {
    self.urlImgArray = [G100PhotoShowModel showModelWithUrlArray:self.featureDomain.pictures];
    
    self.dev_color.subtitle = self.featureDomain.color;
    self.dev_platenumber.subtitle = self.featureDomain.plate_number;
    self.other_feature.subtitle = self.featureDomain.other_feature;
    self.dev_vin.subtitle = self.featureDomain.vin;
    self.dev_motornumber.subtitle = self.featureDomain.motor_number;
    _devType = self.featureDomain.type;
    
    if (![self.bikeDomain isMOTOBike]) {
        switch (_devType) {
            case 0:
                self.dev_model.subtitle = @"";
                break;
            case 1:
                self.dev_model.subtitle = @"滑板车";
                break;
            case 2:
                self.dev_model.subtitle = @"两轮电动车";
                break;
            case 3:
                self.dev_model.subtitle = @"三轮电动车";
                break;
            case 4:
                self.dev_model.subtitle = @"四轮电动车";
                break;
            case 5:
                self.dev_model.subtitle = @"电动自行车";
                break;
            case 99:
                self.dev_model.subtitle = @"其他";
                break;
            default:
                break;
        }

    }else{
        switch (_devType) {
            case 6:
                self.dev_model.subtitle = @"摩托车";
                break;
            case 99:
                self.dev_model.subtitle = @"其他";
                break;
            default:
                break;
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - data
- (void)setEntranceFrom:(BikeFeatureInfoEntrance)entranceFrom {
    _entranceFrom = entranceFrom;
    if (entranceFrom == BikeFeatureInfoEntranceFromLostBike) {
        self.dev_color.title = @"车身颜色*";
        self.dev_model.title = @"车型*";
        self.dev_brand.title = @"品牌*";
        
        [self.tableView reloadData];
        [self.tableView setTableFooterView:self.saveView];
    }else if (entranceFrom == BikeFeatureInfoEntranceFromBikeInfo) {
        self.dev_color.title = @"车身颜色";
        self.dev_model.title = @"车型";
        self.dev_brand.title = @"品牌";
        
        [self.tableView reloadData];
        [self.tableView setTableFooterView:self.saveView];
    }else if (entranceFrom == BikeFeatureInfoEntranceFromAddBike) {
        [self.tableView setTableFooterView:self.saveView];
    }else {
        [self.tableView setTableFooterView:nil];
    }
}
- (void)setupData {

    NSArray *arr1 = @[ @"", self.dev_color, self.dev_model, self.dev_brand, self.dev_platenumber, self.other_feature ];
    NSArray *arr2 = @[ self.dev_motornumber, self.dev_vin ];
    
    [self.dataArray addObject:arr1];
    [self.dataArray addObject:arr2];
    
    if (_entranceFrom == BikeFeatureInfoEntranceFromAddBike) {
        if ([self.featureDict count]) {
            self.dev_color.subtitle = self.featureDict[@"color"];
            self.dev_brand.subtitle = self.featureDict[@"cust_brand"];
            self.dev_platenumber.subtitle = self.featureDict[@"plate_number"];
            self.other_feature.subtitle = self.featureDict[@"other_feature"];
            self.dev_motornumber.subtitle = self.featureDict[@"motor_number"];
            self.dev_vin.subtitle = self.featureDict[@"vin"];
            
            _devType = [self.featureDict[@"type"] integerValue];
            if (![self.bikeDomain isMOTOBike]) {
                switch (_devType) {
                    case 0:
                        self.dev_model.subtitle = @"";
                        break;
                    case 1:
                        self.dev_model.subtitle = @"滑板车";
                        break;
                    case 2:
                        self.dev_model.subtitle = @"两轮电动车";
                        break;
                    case 3:
                        self.dev_model.subtitle = @"三轮电动车";
                        break;
                    case 4:
                        self.dev_model.subtitle = @"四轮电动车";
                        break;
                    case 5:
                        self.dev_model.subtitle = @"电动自行车";
                        break;

                    case 99:
                        self.dev_model.subtitle = @"其他";
                        break;
                    default:
                        break;
                }
                

            }else{
                switch (_devType) {
                    case 6:
                        self.dev_model.subtitle = @"摩托车";
                        break;
                    case 99:
                        self.dev_model.subtitle = @"其他";
                        break;

                    default:
                        break;
                }
            }
                       NSMutableArray *result = [[NSMutableArray alloc] initWithArray:self.featureDict[@"pictures"]];
            self.urlImgArray = [G100PhotoShowModel showModelWithDataArray:result];
            self.photoArray = self.urlImgArray.mutableCopy;
            
            self.featureDomain = [[G100BikeFeatureDomain alloc] init];
            [G100BikeFeatureDomain mj_setupIgnoredPropertyNames:^NSArray *{
                return @[@"pictures"];
            }];
            [self.featureDomain mj_setKeyValues:self.featureDict];
            [G100BikeFeatureDomain mj_setupIgnoredPropertyNames:^NSArray *{
                return @[];
            }];
            
            [self.tableView reloadData];
        }
        return;
    }else {
        ;
    }
    
    // 判断车辆品牌是否是预置品牌
    if (self.bikeDomain.brand.brand_id == 0) {
        
    }else if (self.bikeDomain.brand.brand_id > 0) {
        // 预置品牌 需要从本地加载数据
        __weak typeof(self) wself = self;
        [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
            if (success) {
                self.dev_brand.subtitle = theme.theme_channel_info.name;
                [wself.tableView reloadData];
            }
        }];
    }
    
    
    self.bikeDomain = [[G100InfoHelper shareInstance]findMyBikeWithUserid:self.userid bikeid:self.bikeid];

}

#pragma mark - UI 懒加载
- (UIView *)sectionHeader1 {
    if (!_sectionHeader1) {
        _sectionHeader1 = [[UIView alloc] init];
        _sectionHeader1.frame = CGRectMake(0, 0, WIDTH, 40);
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"6E6E6E"];
        label.text = @"其他信息（以下信息不会对外公开）";
        [_sectionHeader1 addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@15);
            make.trailing.equalTo(@-8);
            make.centerY.equalTo(_sectionHeader1);
        }];
    }
    return _sectionHeader1;
}
- (UIView *)sectionFooter1{
    if (!_sectionFooter1) {
        _sectionFooter1 = [[UIView alloc]init];
        _sectionFooter1.frame = CGRectMake(0, 0, WIDTH, 40);
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"6E6E6E"];
        label.text = @"特征信息越多,丢车时找回车辆机率越大";
        label.textAlignment = NSTextAlignmentCenter;
        [_sectionFooter1 addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@15);
            make.trailing.equalTo(@-8);
            make.centerY.equalTo(_sectionFooter1);
        }];
        
    }
    return _sectionFooter1;
}
- (G100ProgressView *)topProgressView {
    if (!_topProgressView) {
        _topProgressView = [[G100ProgressView alloc] init];
    }
    return _topProgressView;
}

- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _tableView;
}

- (DevFeatureSaveView *)saveView {
    if (!_saveView) {
        _saveView = [[[NSBundle mainBundle] loadNibNamed:@"DevFeatureSaveView" owner:self options:nil] lastObject];
        _saveView.delegate = self;
    }
    return _saveView;
}

#pragma mark - data 懒加载
- (BOOL)isEnableEdit {
    return [self.bikeDomain.is_master integerValue] || (self.entranceFrom == BikeFeatureInfoEntranceFromAddBike);
}

- (NSMutableArray *)dataArray {
    if (nil == _dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}


#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _previousInteractivePopEnable = self.navigationController.interactivePopGestureRecognizer.enabled;
    
    [self setupData];
    
    [self setupView];
    
    G100BikeFeatureDomain * localDomain = self.bikeDomain.feature;
    if (localDomain) {
        self.featureDomain = localDomain;
        [self configFeatureData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    if (!self.hasAppear) {
        double delayInSeconds ;
        __weak typeof(self) weakSelf = self;

        if (self.bikeDomain.isMaster) {
            delayInSeconds = 10.0;
            
        }else{
            delayInSeconds = 3.0;
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf removePushAlertView];
        });
    }
    
    self.hasAppear = YES;
       [IQKeyHelper setEnableAutoToolbar:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = _previousInteractivePopEnable;
       [IQKeyHelper setEnableAutoToolbar:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DLog(@"我的车辆-特征信息页面已释放");
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
