//
//  G100DevFeatureInfoViewController.m
//  G100
//
//  Created by yuhanle on 16/3/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeEditFeatureViewController.h"
#import "G100ProgressView.h"

#import "G100BaseItem.h"
#import "G100BaseCell.h"
#import "G100BaseArrowItem.h"
#import "G100BaseLabelItem.h"
#import "G100BaseImageItem.h"
#import "G100BaseTextFieldItem.h"
#import "G100BaseContextItem.h"

#import "G100PhotoShowModel.h"

#import "G100MultiImageView.h"
#import "G100PickActionSheet.h"

#import "G100BikeTypePickViewController.h"
#import "G100DeleteBikeViewController.h"
#import "G100BikeEditBikeNameViewController.h"
#import "G100BikeEditBrandPhoneNumViewController.h"

#import "G100DevApi.h"
#import "G100BikeApi.h"

#import "G100ThemeManager.h"
#import "NSString+CalHeight.h"

#import "TZImagePickerController.h"
#import "BabyImageCompressor.h"

static NSString * const kBaseItemKeyDevName         = @"dev_name";
static NSString * const kBaseItemKeyDevPhone        = @"dev_phone";
static NSString * const kBaseItemKeyDevColor        = @"dev_color";
static NSString * const kBaseItemKeyDevModel        = @"dev_model";
static NSString * const kBaseItemKeyDevBrand        = @"dev_brand";
static NSString * const kBaseItemKeyDevPlatenumber  = @"dev_platenumber";
static NSString * const kBaseItemKeyDevOtherFeature = @"other_feature";
static NSString * const kBaseItemKeyDevMotornumber  = @"dev_motornumber";
static NSString * const kBaseItemKeyDevVin          = @"dev_vin";
static NSString * const kBaseItemKeyUnbind          = @"dev_unbind";
static NSString * const kBaseItemKeyDelete          = @"dev_delete";

static NSString *const kHintDeleteBikeIsMaster  = @"所有设备都将解绑，所有副用户也将会解绑";
static NSString *const kHintDeleteBikeNotMaster = @"删除后将解绑该车辆";

static NSString * cellIdentifier = @"devPhotoCell";

@interface G100BikeEditFeatureViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, G100MultiImageViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TZImagePickerControllerDelegate> {
    NSInteger _devType;
    NSInteger _changeIndex; //!< 更换照片的下标
    BOOL _previousInteractivePopEnable;
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) G100BikeDomain * bikeDomain;
@property (nonatomic, strong) G100ProgressView *topProgressView;

@property (nonatomic, strong) UIView *sectionHeader0;
@property (nonatomic, strong) UIView *sectionHeader1;
@property (nonatomic, strong) UIView *sectionFooter2;
@property (nonatomic, strong) UILabel *sectionHintLabel2;
@property (nonatomic, strong) UIView *pushAlertView;

@property (nonatomic, strong) G100BaseTextFieldItem * dev_name;
@property (nonatomic, strong) G100BaseArrowItem * dev_phone;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_color;
@property (nonatomic, strong) G100BaseArrowItem * dev_model;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_brand;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_platenumber;
@property (nonatomic, strong) G100BaseContextItem * other_feature;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_motornumber;
@property (nonatomic, strong) G100BaseTextFieldItem * dev_vin;
@property (nonatomic, strong) G100BaseArrowItem *itemUnbindAndDelete;
@property (nonatomic, strong) G100BaseArrowItem *itemDelete;

@property (nonatomic, strong) NSArray * urlImgArray;

@property (nonatomic, strong) G100BikeFeatureDomain * featureDomain;
@property (strong, nonatomic) G100BikeUpdateInfoDomain *bikeUpdateInfo;

@property (nonatomic, strong) NSMutableArray * photoArray;
@property (nonatomic, strong) NSMutableArray * photoAddArray;
@property (nonatomic, strong) NSMutableArray * photoDelArray;
@property (strong, nonatomic) NSMutableArray * updatePicArray;
@property (nonatomic, assign) BOOL isEnableEdit;

@property (nonatomic, assign) CGFloat pushAlertViewTextHeight;

@property (strong, nonatomic) UIButton *rightPayButton;

@property (strong, nonatomic) G100MultiImageView *multiImageView;
@property (strong, nonatomic) NSArray *devModelArray;

@end

@implementation G100BikeEditFeatureViewController

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid entranceFrom:(BikeEditFeatureEntrance)entranceFrom {
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

-(G100BikeUpdateInfoDomain *)bikeUpdateInfo {
    if (!_bikeUpdateInfo) {
        _bikeUpdateInfo = self.bikeDomain.bikeUpdateInfo;
    }
    
    if (!_bikeUpdateInfo) {
        _bikeUpdateInfo = [[G100BikeUpdateInfoDomain alloc] init];
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

- (G100BaseTextFieldItem *)dev_name {
    if (!_dev_name) {
        _dev_name          = [G100BaseTextFieldItem itemWithTitle:@"车辆名称"];
        _dev_name.subtitle = self.bikeDomain.name;
        _dev_name.itemkey  = kBaseItemKeyDevName;
    }
    return _dev_name;
}

- (G100BaseArrowItem *)dev_phone {
    if (!_dev_phone) {
        _dev_phone          = [G100BaseArrowItem itemWithTitle:@"厂商电话"];
        _dev_phone.subtitle = @"";
        _dev_phone.itemkey  = kBaseItemKeyDevPhone;
    }
    return _dev_phone;
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
        _dev_brand          = [G100BaseTextFieldItem itemWithTitle:@"车辆品牌"];
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
        _dev_motornumber          = [G100BaseTextFieldItem itemWithTitle:@"电机/发动机号"];
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


- (G100BaseArrowItem *)itemUnbindAndDelete {
    if (!_itemUnbindAndDelete) {
        _itemUnbindAndDelete = [[G100BaseArrowItem alloc] init];
        _itemUnbindAndDelete.title = @"删除车辆";
        _itemUnbindAndDelete.subtitle = @"";
        _itemUnbindAndDelete.itemkey = kBaseItemKeyUnbind;
    }
    return _itemUnbindAndDelete;
}

- (G100BaseArrowItem *)itemDelete {
    if (!_itemDelete) {
        _itemDelete = [[G100BaseArrowItem alloc] init];
        _itemDelete.title = @"删除车辆";
        _itemDelete.subtitle = @"";
        _itemDelete.itemkey = kBaseItemKeyDelete;
    }
    return _itemDelete;
}

- (UIView *)pushAlertView {
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

- (G100MultiImageView *)multiImageView {
    if (!_multiImageView) {
        _multiImageView = [[G100MultiImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (WIDTH - 4.0*3)/4.0)];
        _multiImageView.backgroundColor = [UIColor whiteColor];
        _multiImageView.gap = 4.0f;
        _multiImageView.maxItem = 5;
        _multiImageView.lineCount = 4;
        _multiImageView.itemWidth = (WIDTH - 4.0*3)/4.0;
        _multiImageView.delegate = self;
    }
    return _multiImageView;
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1 || section == 2) {
        return 30;
    }
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 30;
    }
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    return [_dataArray[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    if ([item.itemkey isEqualToString:kBaseItemKeyDevBrand] ||
        [item.itemkey isEqualToString:kBaseItemKeyDevColor] ||
        [item.itemkey isEqualToString:kBaseItemKeyDevPlatenumber] ||
        [item.itemkey isEqualToString:kBaseItemKeyDevName]) {
        
        if (self.isEnableEdit) {
            baseCell.rightTextField.placeholder = @"点击输入";
        }
        
        if ([item.itemkey isEqualToString:kBaseItemKeyDevBrand]) {
            // 限制品牌输入字数
            baseCell.maxAllowCount = 10;
        }
        
        if ([item.itemkey isEqualToString:kBaseItemKeyDevName]) {
            // 限制品牌输入字数
            baseCell.maxAllowCount = 10;
        }
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
        if (self.isEnableEdit) baseCell.rightTextField.placeholder = @"请查看说明书或合格证";
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
    
    if ([item.itemkey isEqualToString:kBaseItemKeyDevPhone]) {
        if (!self.isEnableEdit) [baseCell setAccessoryType:UITableViewCellAccessoryNone];
    }

    if ([item.itemkey isEqualToString:kBaseItemKeyDelete] ||
        [item.itemkey isEqualToString:kBaseItemKeyUnbind]) {
        baseCell.textLabel.textColor = [UIColor redColor];
        [baseCell setAccessoryType:UITableViewCellAccessoryNone];
    }

    return baseCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.sectionHeader0;
    }
    
    if (section == 1) {
        return self.sectionHeader1;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        [self sectionFooter2];
        
        if (self.bikeDomain.isMaster) {
            self.sectionHintLabel2.text = kHintDeleteBikeIsMaster;
        } else {
            self.sectionHintLabel2.text = kHintDeleteBikeNotMaster;
        }
        
        return self.sectionFooter2;
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
        __weak typeof(self) wself = self;
        G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc]initWithTitle:nil clickedAtIndex:^(NSInteger index) {
            if (index!= 0) {
                item.subtitle = [self.devModelArray safe_objectAtIndex:index - 1];
                [self changeDevTypeWithSlectIndex:index - 1];
                [wself.tableView reloadRowsAtIndexPaths:@[indexPath]
                                       withRowAnimation:UITableViewRowAnimationNone];
            }
        } cancelButtonTitle:@"取消" otherButtonTitlesArray:self.devModelArray];
        [actionSheet show];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUnbind]) {
        // 解绑所有设备并删除车辆 仅限主用户操作
        G100DeleteBikeViewController * deleteBike = [[G100DeleteBikeViewController alloc] initWithNibName:@"G100DeleteBikeViewController"
                                                                                                   bundle:nil];
        deleteBike.userid = self.userid;
        deleteBike.bikeid = self.bikeid;
        deleteBike.bikeDomain = self.bikeDomain;
        [self.navigationController pushViewController:deleteBike animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyDelete]) {
        // 删除车辆 仅限副用户操作
        __weak typeof(self) weakSelf = self;
        G100ReactivePopingView * pop = [G100ReactivePopingView popingViewWithReactiveView];
        pop.contentAlignment = PopContentAlignmentLeft;
        [pop showPopingViewWithTitle:@"删除车辆" content:kHintDeleteBikeNotMaster noticeType:ClickEventBlockCancel otherTitle:@"取消" confirmTitle:@"确定" clickEvent:^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (index == 2) {
                [[G100BikeApi sharedInstance] deleteBikeWithUserid:strongSelf.userid bikeid:strongSelf.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                    if (requestSuccess) {
                        [[UserManager shareManager] updateBikeListWithUserid:strongSelf.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                            if (requestSuccess) {
                                [strongSelf showHint:@"删除成功"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:kGNDeleteBikeSuccess
                                                                                    object:response
                                                                                  userInfo:@{@"userid" : EMPTY_IF_NIL(strongSelf.userid),
                                                                                             @"bikeid" : EMPTY_IF_NIL(strongSelf.bikeid)}];
                                [strongSelf.navigationController popToRootViewControllerAnimated:YES];
                            }else {
                                [strongSelf showHint:response.errDesc];
                            }
                            
                            [[G100InfoHelper shareInstance] clearRelevantDataWithUserid:strongSelf.userid bikeid:strongSelf.bikeid];
                        }];
                    }else {
                        [strongSelf showHint:response.errDesc];
                    }
                }];
            }
            [pop dismissWithVc:strongSelf animation:YES];
        } onViewController:self onBaseView:self.view];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyDevPhone]) {
        if (_entranceFrom == BikeEditFeatureEntranceFromAddBike) {
            // 电话
            G100BikeEditBrandPhoneNumViewController *bikePhoneNumVC = [[G100BikeEditBrandPhoneNumViewController alloc] initWithUserid:self.userid
                                                                                                                               bikeid:self.bikeid
                                                                                                                            oldNumber:self.dev_phone.subtitle];
            bikePhoneNumVC.sureBlock = ^(NSString *result){
                self.dev_phone.subtitle = result;
                [self.tableView reloadData];
            };
            bikePhoneNumVC.brand_id = 0;
            bikePhoneNumVC.oldNumber = self.dev_phone.subtitle;
            [self.navigationController pushViewController:bikePhoneNumVC animated:YES];
            
            return;
        }
        
        if (!self.bikeDomain.isMaster) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", item.subtitle]]];
            return;
        }
        
        
        if (self.dev_phone.subtitle.length == 0) {
            // 电话
            G100BikeEditBrandPhoneNumViewController *bikePhoneNumVC = [[G100BikeEditBrandPhoneNumViewController alloc] initWithUserid:self.userid
                                                                                                                               bikeid:self.bikeid
                                                                                                                            oldNumber:self.bikeDomain.brand.service_num];
            bikePhoneNumVC.sureBlock = ^(NSString *result){
                self.dev_phone.subtitle = result;
                self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid
                                                                                bikeid:self.bikeid];
                [self.tableView reloadData];
            };
            bikePhoneNumVC.brand_id = self.bikeDomain.brand.brand_id;
            // 判断车辆品牌是否是预置品牌
            if (self.bikeDomain.brand.brand_id == 0) {
                bikePhoneNumVC.defaultNumber = nil;
            }else if (self.bikeDomain.brand.brand_id > 0) {
                if (!self.bikeDomain.brand.service_num.length) {
                    bikePhoneNumVC.defaultNumber = nil;
                }else {
                    // 预置品牌 需要从本地加载数据
                    [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                        if (success) {
                            bikePhoneNumVC.defaultNumber = theme.theme_channel_info.servicenum;
                        }
                    }];
                }
            }
            
            bikePhoneNumVC.oldNumber = self.dev_phone.subtitle;
            [self.navigationController pushViewController:bikePhoneNumVC animated:YES];
            return;
        }
        
        G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc] initWithTitle:nil clickedAtIndex:^(NSInteger index) {
            if (index == 2) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", item.subtitle]]];
            } else if (index == 1) {
                // 电话
                G100BikeEditBrandPhoneNumViewController *bikePhoneNumVC = [[G100BikeEditBrandPhoneNumViewController alloc] initWithUserid:self.userid
                                                                                                                                   bikeid:self.bikeid
                                                                                                                                oldNumber:self.bikeDomain.brand.service_num];
                bikePhoneNumVC.sureBlock = ^(NSString *result){
                    self.dev_phone.subtitle = result;
                    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid
                                                                                    bikeid:self.bikeid];
                    [self.tableView reloadData];
                };
                bikePhoneNumVC.brand_id = self.bikeDomain.brand.brand_id;
                // 判断车辆品牌是否是预置品牌
                if (self.bikeDomain.brand.brand_id == 0) {
                    bikePhoneNumVC.defaultNumber = nil;
                }else if (self.bikeDomain.brand.brand_id > 0) {
                    if (!self.bikeDomain.brand.service_num.length) {
                        bikePhoneNumVC.defaultNumber = nil;
                    }else {
                        // 预置品牌 需要从本地加载数据
                        [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                            if (success) {
                                bikePhoneNumVC.defaultNumber = theme.theme_channel_info.servicenum;
                            }
                        }];
                    }
                }
                
                bikePhoneNumVC.oldNumber = self.dev_phone.subtitle;
                [self.navigationController pushViewController:bikePhoneNumVC animated:YES];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"编辑", @"拨打电话", nil];
        [actionSheet show];
    }
}

#pragma mark - G100MultiImageView Delegate
- (void)addButtonDidTap
{
    [self.view endEditing:YES];
    
    if (!self.isEnableEdit) {
        // 不允许编辑的
        return;
    }
    
    _changeIndex = -1;
    [self showAddPictureActionSheet];
}

- (void)multiImageBtn:(NSInteger)index withImage:(UIImage *)image
{
    [self.view endEditing:YES];
    
    if (!self.isEnableEdit) {
        // 不允许编辑的
        return;
    }
    
    __weak typeof(self) wself = self;
    // 图片放大显示，或删除等操作
    G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc] initWithTitle:nil clickedAtIndex:^(NSInteger btnIndex) {
        if (btnIndex) {
            if (btnIndex == 1) {
                // 删除照片
                NSMutableArray *arr = [NSMutableArray arrayWithArray:wself.multiImageView.images_MARR];
                G100PhotoShowModel *oldModel = [arr safe_objectAtIndex:index];
                if (oldModel.url.length) {
                    [wself.photoDelArray addObject:oldModel.url];
                }
                
                [wself.multiImageView strikeOutItemAtIndex:index animated:YES];
                
                [wself.tableView setTableHeaderView:wself.multiImageView];
                
                [wself.tableView reloadData];
                
            } else if (btnIndex == 2) {
                // 更换照片
                _changeIndex = index;
                [wself showAddPictureActionSheet];
            }
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"删除照片", @"更换照片", nil];
    [actionSheet show];
}

- (void)multiImageDragBegin:(NSInteger)index {
    [self.view endEditing:YES];
}

#pragma mark - UIImagePickerControllerDelegate相关
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString * str = [info objectForKey:UIImagePickerControllerMediaType];
    if ([str isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage * originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage * image = [self thumbnailWithImageWithoutScale:originalImage size:CGSizeMake(240, 240)];
        
        NSData * data = UIImageJPEGRepresentation(image, 1.0f);
        if (!data) {
            data = UIImagePNGRepresentation(image);
        }
        
        if (_changeIndex == -1) {
            // 添加照片
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.multiImageView.images_MARR];
            
            G100PhotoShowModel *model = [[G100PhotoShowModel alloc] init];
            model.image = image;
            [arr addObject:model];
            [self.multiImageView.images_MARR removeAllObjects];
            self.multiImageView.images_MARR = arr;
            
            [self.photoAddArray addObject:model];
            
            [self.tableView setTableHeaderView:self.multiImageView];
            
            [self.tableView reloadData];
        }else {
            // 更换照片
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.multiImageView.images_MARR];
            
            G100PhotoShowModel *oldModel = [arr safe_objectAtIndex:_changeIndex];
            G100PhotoShowModel *model = [[G100PhotoShowModel alloc] init];
            model.image = image;
            [arr replaceObjectAtIndex:_changeIndex withObject:model];
            [self.multiImageView.images_MARR removeAllObjects];
            self.multiImageView.images_MARR = arr;
            
            if (oldModel.url.length) {
                [self.photoDelArray addObject:oldModel.url];
            }
            [self.photoAddArray addObject:model];
            
            [self.tableView setTableHeaderView:self.multiImageView];
            
            [self.tableView reloadData];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    } else {
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        } else {
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return newimage;
}

#pragma mark - 私有方法
- (void)showAddPictureActionSheet {
    UIImagePickerController * pc = [[UIImagePickerController alloc] init];
    pc.allowsEditing = YES;
    pc.delegate = self;

    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowCrop = YES;
    imagePickerVc.cancelBtnTitleStr = @"取消";
    imagePickerVc.doneBtnTitleStr = @"完成";
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.cropRect = CGRectMake(0, (HEIGHT / 2) -((WIDTH / 414.0 * 160) / 2), WIDTH, WIDTH / 414.0 * 160 );
    __weak typeof(self) wself = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto){
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:photos.count];
        for (NSInteger i = 0; i < photos.count; i++) {
            UIImage *image = [photos safe_objectAtIndex:i];
            image = [BabyImageCompressor OnlyCompressToImageWithImage:image FileSize:160 * 1024];
            [result addObject:image];
        }
        
        for (UIImage *image in result) {
            NSData * data = UIImageJPEGRepresentation(image, 1.0f);
            if (!data) {
                data = UIImagePNGRepresentation(image);
            }
            
            if (_changeIndex == -1) {
                // 添加照片
                NSMutableArray *arr = [NSMutableArray arrayWithArray:wself.multiImageView.images_MARR];
                
                G100PhotoShowModel *model = [[G100PhotoShowModel alloc] init];
                model.image = image;
                [arr addObject:model];
                [wself.multiImageView.images_MARR removeAllObjects];
                wself.multiImageView.images_MARR = arr;
                
                [wself.photoAddArray addObject:model];
                
                [wself.tableView setTableHeaderView:wself.multiImageView];
                
                [wself.tableView reloadData];
            }else {
                // 更换照片
                NSMutableArray *arr = [NSMutableArray arrayWithArray:wself.multiImageView.images_MARR];
                
                G100PhotoShowModel *oldModel = [arr safe_objectAtIndex:_changeIndex];
                G100PhotoShowModel *model = [[G100PhotoShowModel alloc] init];
                model.image = image;
                [arr replaceObjectAtIndex:_changeIndex withObject:model];
                [wself.multiImageView.images_MARR removeAllObjects];
                wself.multiImageView.images_MARR = arr;
                
                if (oldModel.url.length) {
                    [wself.photoDelArray addObject:oldModel.url];
                }
                [wself.photoAddArray addObject:model];
                
                [wself.tableView setTableHeaderView:wself.multiImageView];
                
                [wself.tableView reloadData];
            }
        }
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:^{
        
    }];
}

/**
 保存功能
 */
- (void)saveInfo {
    /** 获取输入框中的内容 
     *  cell不可见的时候不能取到输入框的内容，所以需要监听输入框的信息
     */
    if ([NSString checkBikeName:[self.dev_name.subtitle trim]]) {
        [self showHint:[NSString checkBikeName:[self.dev_name.subtitle trim]]];
        return;
    }
    
    /** 2.2.3 版本不再显示颜色
    if (self.dev_color.subtitle.length > 10) {
        [self showHint:@"颜色描述不能超过10个字"];
        return;
    }
     */
    
    if (_entranceFrom == BikeEditFeatureEntranceFromLostBike) {
        // 丢车信息 有几项是必填 颜色+车型+品牌
        /** 2.2.3 版本不再显示颜色
        if (self.dev_color.subtitle.length == 0) {
            [self showHint:@"请填写车辆的车身颜色"];
            return;
        }
         */
        
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
    
    [self saveTempInfo];
    
    // 添加车辆
    if (_entranceFrom == BikeEditFeatureEntranceFromAddBike) {
        [self addNewBike];
    }else {
        [self updateBikeInfo];
    }
}

/**
 添加新的车辆
 */
- (void)addNewBike {
    __weak typeof(self) wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        [wself hideHud];
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeListWithUserid:self.userid updateType:BikeListAddType complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [wself showHint:@"车辆添加成功"];
                    [wself.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }else {
            [wself showHint:response.errDesc];
        }
    };
    
    [self showHudInView:self.view hint:@"正在添加"];
    [[G100BikeApi sharedInstance] addBikeWithUserid:self.userid bikeInfo:[self.bikeUpdateInfo mj_keyValues] callback:callback];
}

/**
 更新车辆信息
 */
- (void)updateBikeInfo {
    __weak typeof(self) wself = self;
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    [self showHudInView:self.view hint:@"上传中"];
    [[G100BikeApi sharedInstance] updateBikeProfileWithBikeid:self.bikeid bikeType:self.bikeDomain.bike_type profile:[self.bikeUpdateInfo mj_keyValues] progress:^(float progress) {
        
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
        NSString *result = self.bikeDomain.brand.custbrand;
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
    
    BOOL hasChange8 = YES;
    if ([self.bikeDomain.name isEqualToString:_dev_name.subtitle] ||
        (self.bikeDomain.name == nil && _dev_name.subtitle.length == 0))
        hasChange8 = NO;
    
    BOOL hasChange9 = YES;
    
    // 判断车辆品牌是否是预置品牌
    __block NSString *oldPhoneNumber = nil;
    if (self.bikeDomain.brand.brand_id == 0) {
        oldPhoneNumber = self.bikeDomain.brand.service_num;
    }else if (self.bikeDomain.brand.brand_id > 0) {
        if (self.bikeDomain.brand.name.length) {
            
        }else {
            // 预置品牌 需要从本地加载数据
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    
                }
            }];
        }
        
        if (self.bikeDomain.brand.service_num.length) {
            oldPhoneNumber = self.bikeDomain.brand.service_num;
        }else {
            // 预置品牌 需要从本地加载数据
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    oldPhoneNumber = theme.theme_channel_info.servicenum;
                }
            }];
        }
    }
    
    if ([oldPhoneNumber isEqualToString:_dev_phone.subtitle] ||
        (oldPhoneNumber == nil && _dev_phone.subtitle.length == 0)) {
        hasChange9 = NO;
    }

    return (hasChange0 || hasChange1 || hasChange2 || hasChange3 || hasChange4 || hasChange5 || hasChange6 || hasChange7 || hasChange8 || hasChange9 || self.multiImageView.isDragged);
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
        [self.contentView layoutIfNeeded];
    }];
}

- (void)saveTempInfo{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.multiImageView.images_MARR];
    [self.updatePicArray removeAllObjects];
    for (G100PhotoShowModel * showModel in arr) {
        if (showModel.url.length) {
            [self.updatePicArray addObject:showModel.url];
        } else if (showModel.image) {
            NSData *imageData = UIImagePNGRepresentation(showModel.image);
            NSString *base64Image = [imageData base64EncodedStringWithOptions:0];
            [self.updatePicArray addObject:base64Image ? : @""];
        } else if (showModel.data) {
            NSString *base64Image = [showModel.data base64EncodedStringWithOptions:0];
            [self.updatePicArray addObject:base64Image ? : @""];
        }
    }
    
    NSDictionary * featureDic = @{@"pictures" : self.updatePicArray,
                                  /*@"color" : EMPTY_IF_NIL(self.dev_color.subtitle),*/
                                  @"type" : [NSNumber numberWithInteger:_devType],
                                  @"plate_number" : EMPTY_IF_NIL(self.dev_platenumber.subtitle),
                                  @"other_feature" : EMPTY_IF_NIL(self.other_feature.subtitle),
                                  @"vin" : EMPTY_IF_NIL(self.dev_vin.subtitle),
                                  @"motor_number" : EMPTY_IF_NIL(self.dev_motornumber.subtitle),
                                  @"cust_brand" : EMPTY_IF_NIL(self.dev_brand.subtitle),
                                  @"name" : EMPTY_IF_NIL(self.dev_name.subtitle),
                                  @"custservicenum" : EMPTY_IF_NIL(self.dev_phone.subtitle)};
    
    [self.bikeUpdateInfo.feature setValuesForKeysWith_MyDict:featureDic];
    self.bikeUpdateInfo.brand.name = self.bikeDomain.brand.brand_id==0 ? EMPTY_IF_NIL(self.dev_brand.subtitle) : @"";
    self.bikeUpdateInfo.name = EMPTY_IF_NIL(self.dev_name.subtitle);
    self.bikeUpdateInfo.brand.service_num = EMPTY_IF_NIL(self.dev_phone.subtitle);
}

#pragma mark - 更改车型
- (void)changeDevTypeWithSlectIndex:(NSInteger)selectedIndex {
    NSInteger devType;
    
    if (_entranceFrom == BikeEditFeatureEntranceFromAddBike) {
        switch (selectedIndex) {
            case 0:
                devType = G100BikeTypeScooter;
                break;
            case 1:
                devType = G100BikeTypeTwoWheeled;
                break;
            case 2:
                devType = G100BikeTypeThreeWheeled;
                break;
            case 3:
                devType = G100BikeTypeFourWheeled;
                break;
            case 4:
                devType = G100BikeTypeElectric;
                break;
            case 5:
                devType = G100BikeTypeMotor;
                break;
            case 6:
                devType = G100BikeTypeOther;
                break;
            default:
                devType = G100BikeTypeOther;
                break;
        }
    } else {
        if (![self.bikeDomain isMOTOBike]) {
            switch (selectedIndex) {
                case 0:
                    devType = G100BikeTypeScooter;
                    break;
                case 1:
                    devType = G100BikeTypeTwoWheeled;
                    break;
                case 2:
                    devType = G100BikeTypeThreeWheeled;
                    break;
                case 3:
                    devType = G100BikeTypeFourWheeled;
                    break;
                case 4:
                    devType = G100BikeTypeElectric;
                    break;
                case 5:
                    devType = G100BikeTypeOther;
                    break;
                default:
                    devType = G100BikeTypeOther;
                    break;
            }
        } else {
            switch (selectedIndex) {
                case 0:
                    devType = G100BikeTypeMotor;
                    break;
                case 1:
                    devType = G100BikeTypeOther;
                    break;
                default:
                    devType = G100BikeTypeOther;
                    break;
            }
        }
    }
    
    if (devType == 6) {
        self.bikeUpdateInfo.bike_type = 1;
    } else {
        self.bikeUpdateInfo.bike_type = 0;
    }
    
    _devType = devType;
}

#pragma mark - 重写父类方法
- (void)actionClickNavigationBarLeftButton {
    // 添加车辆允许可以返回
    if (_entranceFrom == BikeEditFeatureEntranceFromAddBike) {
        [self saveTempInfo];
        
        if (_bikeFeatureBlock) {
            self.bikeFeatureBlock(self.bikeUpdateInfo);
        }
        
        [super actionClickNavigationBarLeftButton];
    } else {
        if ([self hasChangeInfo]) {
            // 有信息变动 提示用户保存
            [MyAlertView MyAlertWithTitle:@"修改未保存" message:@"您已经修改车辆资料，是否放弃保存？" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [super actionClickNavigationBarLeftButton];
                }else {
                    [self saveInfo];
                }
            } cancelButtonTitle:@"放弃保存返回" otherButtonTitles:@"保存并返回"];
        }else {
            [super actionClickNavigationBarLeftButton];
        }
    }
}

- (void)rightButtonClick {
    if (kNetworkNotReachability) {
        [self showWarningHint:kError_Network_NotReachable];
        return;
    }
    
    // save
    [self saveInfo];
}

#pragma mark - setupUI
- (void)setupNavigationBarView {
    [self setNavigationTitle:@"编辑车辆资料"];
    
    _rightPayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightPayButton.frame = CGRectMake(0, 0, 80, 30);
    _rightPayButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_rightPayButton setTitle:@"保存" forState:UIControlStateNormal];
    [_rightPayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightPayButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self setRightNavgationButton:_rightPayButton];
    _rightPayButton.enabled = YES;;
}

- (void)setupView {
    [self.contentView addSubview:self.tableView];
    
    CGRect frame = self.contentView.bounds;
    if (_entranceFrom == BikeEditFeatureEntranceFromAddBike) {
        self.tableView.frame = frame;
        return;
    } else {
        frame.size.height -= 5;
        frame.origin.y = 5;
    }
    
    self.tableView.frame = frame;
    
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
    
    // 设置车辆信息完整度
    [self.topProgressView setProgress:self.bikeDomain.feature.integrity/100.0];
    
    //如果车辆信息不完整 则弹出提示
    __weak typeof (self) weakSelf = self;
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
            [strongSelf.contentView layoutIfNeeded];
        }];
    });
}

#pragma mark - setupData
- (void)setupFeatureData {
    self.urlImgArray = [G100PhotoShowModel showModelWithUrlArray:self.featureDomain.pictures];
    
    self.dev_color.subtitle = self.featureDomain.color;
    self.dev_platenumber.subtitle = self.featureDomain.plate_number;
    self.other_feature.subtitle = self.featureDomain.other_feature;
    self.dev_vin.subtitle = self.featureDomain.vin;
    self.dev_motornumber.subtitle = self.featureDomain.motor_number;
    
    _devType = self.featureDomain.type;
    
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
        case 6:
            self.dev_model.subtitle = @"摩托车";
            break;
        case 99:
            self.dev_model.subtitle = @"其他";
            break;
        default:
            self.dev_model.subtitle = @"";
            break;
    }

    
    [self.tableView reloadData];
}

- (void)setupBikeinfoData {
    if (self.bikeInfo) {
        self.dev_color.subtitle = self.bikeInfo.feature.color;
        self.dev_name.subtitle = self.bikeInfo.name;
        self.dev_phone.subtitle = self.bikeInfo.brand.service_num;
        self.dev_brand.subtitle = self.bikeInfo.feature.cust_brand;
        self.dev_platenumber.subtitle = self.bikeInfo.feature.plate_number;
        self.other_feature.subtitle = self.bikeInfo.feature.other_feature;
        self.dev_motornumber.subtitle = self.bikeInfo.feature.motor_number;
        self.dev_vin.subtitle = self.bikeInfo.feature.vin;
        
        _devType = self.bikeInfo.feature.type;
        
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
            case 6:
                self.dev_model.subtitle = @"摩托车";
                break;
            case 99:
                self.dev_model.subtitle = @"其他";
                break;
            default:
                self.dev_model.subtitle = @"";
                break;
        }
        
        NSMutableArray *result = [[NSMutableArray alloc] initWithArray:self.bikeInfo.feature.pictures];
        self.urlImgArray = [G100PhotoShowModel showModelWithBase64Array:result];
        self.photoArray = self.urlImgArray.mutableCopy;
        
        self.featureDomain = [[G100BikeFeatureDomain alloc] init];
        [G100BikeFeatureDomain mj_setupIgnoredPropertyNames:^NSArray *{
            return @[@"pictures"];
        }];
        [self.featureDomain mj_setKeyValues:[self.bikeInfo.feature mj_keyValues]];
        [G100BikeFeatureDomain mj_setupIgnoredPropertyNames:^NSArray *{
            return @[];
        }];
        
        [self.tableView reloadData];
    }
}

- (void)setEntranceFrom:(BikeEditFeatureEntrance)entranceFrom {
    _entranceFrom = entranceFrom;
    if (entranceFrom == BikeEditFeatureEntranceFromLostBike) {
        self.dev_color.title = @"车身颜色*";
        self.dev_model.title = @"车型*";
        self.dev_brand.title = @"车辆品牌*";
        
        [self.tableView reloadData];
    }else if (entranceFrom == BikeEditFeatureEntranceFromBikeInfo) {
        self.dev_color.title = @"车身颜色";
        self.dev_model.title = @"车型";
        self.dev_brand.title = @"车辆品牌";
        
        [self.tableView reloadData];
    }else if (entranceFrom == BikeEditFeatureEntranceFromAddBike) {
        
    }else {
        
    }
}

- (void)setupData {
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    
    NSArray *arr1 = @[ self.dev_name, /*self.dev_color, */self.dev_brand, self.dev_phone, self.dev_model, self.dev_platenumber, self.other_feature ];
    NSArray *arr2 = @[ self.dev_motornumber, self.dev_vin ];
    
    [self.dataArray addObject:arr1];
    [self.dataArray addObject:arr2];
    
    // 如果是从车辆详情中进入 则显示删除车辆的入口
    if (_entranceFrom == BikeEditFeatureEntranceFromBikeInfo) {
        NSArray *arr3 = @[ self.bikeDomain.isMaster ? self.itemUnbindAndDelete : self.itemDelete ];
        [self.dataArray addObject:arr3];
    }
    
    // 判断车辆品牌是否是预置品牌
    if (self.bikeDomain.brand.brand_id == 0) {
        self.dev_brand.subtitle = self.bikeDomain.brand.name;
        self.dev_phone.subtitle = self.bikeDomain.brand.service_num;
    }else if (self.bikeDomain.brand.brand_id > 0) {
        if (self.bikeDomain.brand.name.length) {
            self.dev_brand.subtitle = self.bikeDomain.brand.name;
        }else {
            // 预置品牌 需要从本地加载数据
            __weak typeof(self) wself = self;
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    wself.dev_brand.subtitle = theme.theme_channel_info.name;
                    [wself.tableView reloadData];
                }
            }];
        }
        
        if (self.bikeDomain.brand.service_num.length) {
            self.dev_phone.subtitle = self.bikeDomain.brand.service_num;
        }else {
            // 预置品牌 需要从本地加载数据
            __weak typeof(self) wself = self;
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:self.bikeDomain.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    wself.dev_phone.subtitle = theme.theme_channel_info.servicenum;
                    [wself.tableView reloadData];
                }
            }];
        }
    }
    
    // 如果是添加车辆 则取到之前的数据 刷新
    if (_entranceFrom == BikeEditFeatureEntranceFromAddBike) {
        [self setupBikeinfoData];
    }
}

#pragma mark - UI 懒加载
- (UIView *)sectionHeader1 {
    if (!_sectionHeader1) {
        _sectionHeader1 = [[UIView alloc] init];
        _sectionHeader1.frame = CGRectMake(0, 0, WIDTH, 30);
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
- (UIView *)sectionHeader0 {
    if (!_sectionHeader0) {
        _sectionHeader0 = [[UIView alloc]init];
        _sectionHeader0.frame = CGRectMake(0, 0, WIDTH, 30);
        _sectionHeader0.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"8B8B8B"];
        label.text = @"点击照片进行更换，长按照片可变换排列顺序";
        [_sectionHeader0 addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@15);
            make.trailing.equalTo(@-8);
            make.centerY.equalTo(_sectionHeader0);
        }];
    }
    return _sectionHeader0;
}
- (UIView *)sectionFooter2 {
    if (!_sectionFooter2) {
        _sectionFooter2 = [[UIView alloc]init];
        _sectionFooter2.frame = CGRectMake(0, 0, WIDTH, 30);
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"6E6E6E"];
        label.text = kHintDeleteBikeIsMaster;
        [_sectionFooter2 addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@15);
            make.trailing.equalTo(@-8);
            make.centerY.equalTo(_sectionFooter2);
        }];
        
        self.sectionHintLabel2 = label;
    }
    return _sectionFooter2;
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

- (NSArray *)devModelArray {
    if (!_devModelArray) {
        if (_entranceFrom == BikeEditFeatureEntranceFromAddBike) {
            _devModelArray = @[@"滑板车", @"两轮电动车", @"三轮电动车", @"四轮电动车", @"电动自行车",@"摩托车", @"其他"];
        } else {
            if (![self.bikeDomain isMOTOBike]) {
                _devModelArray = @[@"滑板车", @"两轮电动车", @"三轮电动车", @"四轮电动车", @"电动自行车", @"其他"];
            } else {
                _devModelArray = @[ @"摩托车", @"其他"];
            }
        }
    }
    
    return _devModelArray;
}

#pragma mark - data 懒加载
- (BOOL)isEnableEdit {
    return [self.bikeDomain.is_master integerValue] || (self.entranceFrom == BikeEditFeatureEntranceFromAddBike);
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
//    _previousInteractivePopEnable = self.navigationController.interactivePopGestureRecognizer.enabled;
    
    [self setupData];
    
    [self setupView];
    
    G100BikeFeatureDomain * localDomain = self.bikeDomain.feature;
    if (localDomain) {
        self.featureDomain = localDomain;
        [self setupFeatureData];
    }
    
    [self.multiImageView setImages_MARR:self.urlImgArray.mutableCopy];
    self.multiImageView.isEnableEdit = self.isEnableEdit;
    
    [self.tableView setTableHeaderView:self.multiImageView];
    
    // 控制右上角保存功能
    if (self.entranceFrom == BikeEditFeatureEntranceFromAddBike) {
        self.rightPayButton.hidden = NO;
    } else {
        self.rightPayButton.hidden = !self.isEnableEdit;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    if (_entranceFrom != BikeEditFeatureEntranceFromAddBike) {
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
    }
    
    self.hasAppear = YES;
    [IQKeyHelper setEnableAutoToolbar:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    self.navigationController.interactivePopGestureRecognizer.enabled = _previousInteractivePopEnable;
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
    DLog(@"编写车辆资料页面已释放");
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
