//
//  G100BikeInfoCardManager.m
//  G100
//
//  Created by yuhanle on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoCardManager.h"

#import "G100BikeInfoViewController.h"
#import "G100BikeInfoBatteryViewController.h"
#import "G100BikeInfoDeviceViewController.h"
#import "G100BikeInfoUserViewController.h"

NSString * const BikeInfoCardViewId_bikeinfo    = @"bikeinfo";
NSString * const BikeInfoCardViewId_batteryinfo = @"batteryinfo";
NSString * const BikeInfoCardViewId_deviceinfo  = @"deviceinfo";
NSString * const BikeInfoCardViewId_bikeuser    = @"bikeuser";

@interface G100BikeInfoCardManager()

@property (nonatomic, strong) NSMutableDictionary *cardViewMap;

@end

@implementation G100BikeInfoCardManager

+ (instancetype)cardManagerWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    G100BikeInfoCardManager *manager = [[G100BikeInfoCardManager alloc] init];
    manager.userid = userid;
    manager.bikeid = bikeid;
    return manager;
}

- (NSMutableDictionary *)cardViewMap {
    if (!_cardViewMap) {
        _cardViewMap = [[NSMutableDictionary alloc] init];
    }
    
    return _cardViewMap;
}

#pragma mark - Public Method
- (NSInteger)numberOfRows {
    return self.dataArray.count;
}

- (NSArray *)dataArray {
    return [self dataArrayWithItem:self.bike];
}
- (NSArray *)dataArrayWithItem:(G100BikeDomain *)item {
    NSMutableArray *resultArr = [NSMutableArray array];
    NSMutableArray *bikeInfoModelArr = [NSMutableArray array];
    G100BikeInfoCardModel *model = [[G100BikeInfoCardModel alloc]init];
    model.identifier = BikeInfoCardViewId_bikeinfo;
    model.bike = item;
    model.userid = self.userid;
    model.bikeid = self.bikeid;
    [bikeInfoModelArr addObject:model];
    
    NSMutableArray *bikeBatteryInfoArr = [NSMutableArray array];
    if (![item isMOTOBike]) {
        // 移动特供机和无设备车辆不显示
        G100BikeInfoCardModel *battryModel = [[G100BikeInfoCardModel alloc]init];
        battryModel.identifier = BikeInfoCardViewId_batteryinfo;
        battryModel.bike = item;
        battryModel.userid = self.userid;
        battryModel.bikeid = self.bikeid;
        [bikeBatteryInfoArr addObject:battryModel];
    }
 
    NSMutableArray *deviceInfoArr= [ NSMutableArray array];
    G100BikeInfoCardModel *deviceModel = [[G100BikeInfoCardModel alloc]init];
    deviceModel.identifier = BikeInfoCardViewId_deviceinfo;
    deviceModel.bike = item;
    deviceModel.userid = self.userid;
    deviceModel.bikeid = self.bikeid;
    [deviceInfoArr addObject:deviceModel];
    
    NSMutableArray *userInfoArr = [NSMutableArray array];
    G100BikeInfoCardModel *userModel = [[G100BikeInfoCardModel alloc]init];
    userModel.identifier = BikeInfoCardViewId_bikeuser;
    userModel.bike = item;
    userModel.userid = self.userid;
    userModel.bikeid = self.bikeid;
    [userInfoArr addObject:userModel];
    
    [resultArr addObject:bikeInfoModelArr];
    [resultArr addObject:bikeBatteryInfoArr];
    [resultArr addObject:deviceInfoArr];
    [resultArr addObject:userInfoArr];
    return resultArr;
}

- (UIViewController *)cardViewWithItem:(G100BikeInfoCardModel *)item {
    NSString *identifier = item.identifier;
    UIViewController *cardVC = nil;
    if ([identifier isEqualToString:BikeInfoCardViewId_bikeinfo]) {
        G100BikeInfoViewController *bikeInforVC = [[G100BikeInfoViewController alloc]init];
        cardVC =  bikeInforVC;
    } else if ([identifier isEqualToString:BikeInfoCardViewId_batteryinfo]) {
        G100BikeInfoBatteryViewController *batteryVC = [[G100BikeInfoBatteryViewController alloc]init];
        cardVC = batteryVC;
    }else if ([identifier isEqualToString:BikeInfoCardViewId_deviceinfo]){
        G100BikeInfoDeviceViewController *deviceVC = [[G100BikeInfoDeviceViewController alloc]init];
        cardVC = deviceVC;
    }else if ([identifier isEqualToString:BikeInfoCardViewId_bikeuser]){
        G100BikeInfoUserViewController *userVC = [[G100BikeInfoUserViewController alloc]init];
        cardVC = userVC;
    }
    
    [cardVC setValue:item.userid forKey:@"userid"];
    [cardVC setValue:item.bikeid forKey:@"bikeid"];
    [cardVC setValue:item forKey:@"bikeInfoModel"];
    
    [self.cardViewMap removeObjectForKey:identifier];
    [self.cardViewMap setObject:cardVC forKey:identifier];
    
    return cardVC;
}

- (CGFloat)heightForCardViewWithItem:(G100BikeInfoCardModel *)item width:(CGFloat)width {
    CGFloat result = 200;
    G100BikeInfoCardModel *card = (G100BikeInfoCardModel *)item;
    if ([item isKindOfClass:[G100BikeInfoCardModel class]]) {
        if ([card.identifier isEqualToString:BikeInfoCardViewId_bikeinfo]) {
            result = [G100BikeInfoViewController heightWithWidth:width];
        }else if ([card.identifier isEqualToString:BikeInfoCardViewId_batteryinfo]){
            result = [G100BikeInfoBatteryViewController heightWithWidth:width];
        }else if ([card.identifier isEqualToString:BikeInfoCardViewId_deviceinfo]){
            result = [G100BikeInfoDeviceViewController heightForItem:item.bike width:width];
        }else if ([card.identifier isEqualToString:BikeInfoCardViewId_bikeuser]){
            G100BikeInfoUserViewController *uvc = [self.cardViewMap objectForKey:item.identifier];
            result = [uvc heightForItem:item width:width];
        }
    }
    
    return result;
}

@end
