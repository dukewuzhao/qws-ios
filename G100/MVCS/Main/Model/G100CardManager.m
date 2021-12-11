//
//  G100CardManager.m
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardManager.h"
#import "G100CardBaseViewController.h"
#import "G100CardUserCarlViewController.h"
#import "G100CardWeatherViewController.h"
#import "G100CardDevStateViewController.h"
#import "G100CardRemoteCtrlViewController.h"
#import "G100CardUserCarViewController2.h"
#import "G100CardDevStateViewController2.h"
#import "G100CardCommonViewController.h"
#import "G100DevStateView.h"
#import "G100CardRemoteCtrlView.h"
#import "G100UserCarView.h"
#import "G100BikeInfoView.h"
#import "G100BattInfoView.h"
#import "G100WeatherAndCarView.h"
#import "G100BikeCardView.h"
#import "G100DevMapView.h"
#import "G100SafeSetView.h"
#import "G100BikeReportView.h"
#import "G100BikeDomain.h"
#import "G100DeviceDomain.h"
#import "G100InsuranceCardView.h"
#import "G100CardInsuranceViewController.h"
#import "G100CardInsuranceActivityViewController.h"
#import "G100InsuranceActivity.h"
#import "G100BattGPSView.h"
#import "G100CardBatteryViewController.h"
#import "G100InsuranceManager.h"
#import "G100MapServiceView.h"
#import "G100SafeAndReportView.h"
#import "G100BikeTestView.h"
#import "G100FindBikeView.h"

#define Line_Spacing 12.0
#define Side_Spacing 6.0

@implementation G100CardModel

@end

@interface G100CardManager ()

@property (nonatomic, strong) NSMutableDictionary *cardViewControllerMap;

@end

@implementation G100CardManager

#pragma mark - Lazy load
- (NSMutableDictionary *)cardViewControllerMap {
    if (!_cardViewControllerMap) {
        _cardViewControllerMap = [[NSMutableDictionary alloc] init];
    }
    return _cardViewControllerMap;
}

- (NSMutableArray *)cardViewControllersArray {
    if (!_cardViewControllersArray) {
        _cardViewControllersArray = [[NSMutableArray alloc] init];
    }
    
    [_cardViewControllersArray removeAllObjects];
    for (id key in [self.cardViewControllerMap allKeys]) {
        UIViewController *viewController = [self.cardViewControllerMap objectForKey:key];
        if (viewController) {
            [_cardViewControllersArray addObject:viewController];
        }
    }
    
    return _cardViewControllersArray;
}

#pragma mark - Public Method
- (void)setBike:(G100BikeDomain *)bike {
    _bike = bike;
    _dataArray = [self dataArrayWithBike:bike insurance:self.insurance];
}

- (void)setInsurance:(G100InsuranceCardModel *)insurance {
    _insurance = insurance;
    _dataArray = [self dataArrayWithBike:self.bike insurance:insurance];
}

- (NSInteger)numberOfRows {
    return [self.dataArray count];
}

- (void)addCardViewController:(UIViewController *)cardVC indexPath:(NSIndexPath *)indexPath {
    if (cardVC) {
        // 防止nil 造成崩溃
        [self.cardViewControllerMap setObject:cardVC forKey:indexPath];
    }
}

- (void)removeAllCardViewController {
    for (UIViewController *childController in self.cardViewControllersArray) {
        if ([childController.view superview]) {
            [childController beginAppearanceTransition:NO animated:YES];
            [childController.view removeFromSuperview];
            [childController endAppearanceTransition];
            [childController removeFromParentViewController];
        }
    }
    
    [self.cardViewControllersArray removeAllObjects];
    [self.cardViewControllerMap removeAllObjects];
}

#pragma mark - 正在使用
- (NSArray *)dataArrayWithItem:(id)item {
    if (!item) {
        return nil;
    }
    if ([item isKindOfClass:[G100BikeDomain class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSMutableArray *result0 = [[NSMutableArray alloc] init];
        NSMutableArray *result1 = [[NSMutableArray alloc] init];
        NSMutableArray *result2 = [[NSMutableArray alloc] init];
        NSMutableArray *result3 = [[NSMutableArray alloc] init];
        G100BikeDomain *bike = (G100BikeDomain *)item;
        G100CardModel *cardModel00 = [[G100CardModel alloc] init];
        cardModel00.bike = bike;
        cardModel00.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
        cardModel00.identifier = @"bike_info";
        [result0 addObject:cardModel00];
        
        if ([bike.devices count]) {
            if ([bike.battery_devices count]) {
                [result addObject:result0];
                for (G100DeviceDomain *deviceDomain in bike.battery_devices) {
                    NSMutableArray *tempResult = [NSMutableArray array];
                    G100CardModel *cardModel01 = [[G100CardModel alloc] init];
                    cardModel01.bike = bike;
                    cardModel01.devid = [NSString stringWithFormat:@"%@", @(deviceDomain.device_id)];
                    cardModel01.identifier = @"battery_info";
                    [tempResult addObject:cardModel01];
                    [result addObject:tempResult];
                }
            }else{
                G100CardModel *cardModel01 = [[G100CardModel alloc] init];
                cardModel01.bike = bike;
                cardModel01.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
                cardModel01.identifier = @"batt_info";
                [result0 addObject:cardModel01];
                [result addObject:result0];
            }
            G100CardModel *cardModel10 = [[G100CardModel alloc] init];
            cardModel10.bike = bike;
            cardModel10.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel10.identifier = @"device_info";
            [result1 addObject:cardModel10];
            
            G100CardModel *cardModel11 = [[G100CardModel alloc] init];
            cardModel11.bike = bike;
            cardModel11.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel11.identifier = @"safe_set_info";
            [result1 addObject:cardModel11];
            
            G100CardModel *cardModel12 = [[G100CardModel alloc] init];
            cardModel12.bike = bike;
            cardModel12.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel12.identifier = @"report_info";
            [result1 addObject:cardModel12];
            [result addObject:result1];
            if (bike.isMaster) { // 主用户才拥有远程遥控功能
                for (G100DeviceDomain *device in bike.devices) { // 必须存在远程控制的设备 才显示此卡片
                    if (device.func.alertor.remote_ctrl == 1) {
                        G100CardModel *cardModel2 = [[G100CardModel alloc] init];
                        cardModel2.bike = bike;
                        cardModel2.device = device;
                        cardModel2.devid = [NSString stringWithFormat:@"%@", @(device.device_id)];
                        cardModel2.identifier = @"remote_ctrl_info";
                        [result2 addObject:cardModel2];
                        [result addObject:result2];
                        break;
                    }
                }
            }else {
                ;
            }
            G100CardModel *cardModel30 = [[G100CardModel alloc] init];
            cardModel30.bike = bike;
            cardModel30.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel30.identifier = @"insurance_active";
            [result3 addObject:cardModel30];
            
            G100CardModel *cardModel31 = [[G100CardModel alloc] init];
            cardModel31.bike = bike;
            cardModel31.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel31.identifier = @"insurance_info";
            [result3 addObject:cardModel31];
            [result addObject:result3];
        }else{
            [result addObject:result0];
        }
        return result;
    }
    
    return nil;
}
- (NSArray *)dataArrayWithBike:(G100BikeDomain *)bikeDomain insurance:(G100InsuranceCardModel *)insurance {
    if (!bikeDomain) {
        return nil;
    }
    if ([bikeDomain isKindOfClass:[G100BikeDomain class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSMutableArray *result0 = [[NSMutableArray alloc] init];
        NSMutableArray *result1 = [[NSMutableArray alloc] init];
        NSMutableArray *result2 = [[NSMutableArray alloc] init];
        //NSMutableArray *result3 = [[NSMutableArray alloc] init];
        NSMutableArray *result4 = [[NSMutableArray alloc] init];
        
        G100BikeDomain *bike = (G100BikeDomain *)bikeDomain;
        G100CardModel *cardModel00 = [[G100CardModel alloc] init];
        cardModel00.bike = bike;
        cardModel00.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
        cardModel00.identifier = @"bike_info";
        [result0 addObject:cardModel00];
        
        if ([bike.devices count] && bike.mainDevice.security.mode == 8) {
            G100CardModel *cardModel01 = [[G100CardModel alloc] init];
            cardModel01.bike = bike;
            cardModel01.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel01.identifier = @"find_record_info";
            [result0 addObject:cardModel01];
        }else {
            G100CardModel *cardModel01 = [[G100CardModel alloc] init];
            cardModel01.bike = bike;
            cardModel01.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel01.identifier = @"test_info";
            [result0 addObject:cardModel01];
        }
        
        [result addObject:result0];
        
        if ([bike.devices count]) {
            // 智能电池设备 需要显示智能电池卡片
            if ([bike.battery_devices count]) {
                for (G100DeviceDomain *deviceDomain in bike.battery_devices) {
                    NSMutableArray *tempResult = [NSMutableArray array];
                    G100CardModel *cardModel01 = [[G100CardModel alloc] init];
                    cardModel01.bike = bike;
                    cardModel01.devid = [NSString stringWithFormat:@"%@", @(deviceDomain.device_id)];
                    cardModel01.identifier = @"battery_info";
                    [tempResult addObject:cardModel01];
                    [result addObject:tempResult];
                }
            }
            
            G100CardModel *cardModel10 = [[G100CardModel alloc] init];
            cardModel10.bike = bike;
            cardModel10.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel10.identifier = @"device_info";
            [result1 addObject:cardModel10];
            
            G100CardModel *cardModel11 = [[G100CardModel alloc] init];
            cardModel11.bike = bike;
            cardModel11.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel11.identifier = @"safeAndReport_info";
            [result1 addObject:cardModel11];
            [result addObject:result1];
            if (bike.isMaster) { // 主用户才拥有远程遥控功能
                for (G100DeviceDomain *device in bike.devices) { // 必须存在远程控制的设备 才显示此卡片
                    if (device.func.alertor.remote_ctrl == 1) {
                        G100CardModel *cardModel2 = [[G100CardModel alloc] init];
                        cardModel2.bike = bike;
                        cardModel2.device = device;
                        cardModel2.devid = [NSString stringWithFormat:@"%@", @(device.device_id)];
                        cardModel2.identifier = @"remote_ctrl_info";
                        [result2 addObject:cardModel2];
                        [result addObject:result2];
                        break;
                    }
                }
            }else {
                ;
            }
           
        }else {
            
            G100CardModel *cardModel10 = [[G100CardModel alloc] init];
            cardModel10.bike = bike;
            cardModel10.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel10.identifier = @"device_info";
            [result1 addObject:cardModel10];
            [result addObject:result1];

        }
        
        if (insurance && (!bike.battery_devices.count || bike.gps_devices.count)) {
            /** 2.2.3 版本不再显示轮播图 改成累积
            G100CardModel *cardModel30 = [[G100CardModel alloc] init];
            cardModel30.bike = bike;
            cardModel30.insuranceModel = insurance;
            cardModel30.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
            cardModel30.identifier = @"insurance_active";
            if (insurance.activityList.count) {
                [result3 addObject:cardModel30];
            }
             */
            
            /** 2.2.1 本不再显示活动入口
            for (G100InsuranceBanner *banner in insurance.bannerList) {
                G100CardModel *cardModel31 = [[G100CardModel alloc] init];
                cardModel31.bike = bike;
                cardModel31.insuranceModel = insurance;
                cardModel31.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
                cardModel31.identifier = @"insurance_info";
                cardModel31.banner = banner;
                [result3 addObject:cardModel31];
            }
             */
            
            // 累积显示活动列表
            NSMutableArray *activityList = [insurance.activityList mutableCopy];
            
            for (G100InsuranceActivityDomain *activity in activityList) {
                G100CardModel *cardModel30 = [[G100CardModel alloc] init];
                cardModel30.bike = bike;
                
                G100InsuranceCardModel *activityCard = [[G100InsuranceCardModel alloc] initWithDictionary:[insurance mj_keyValues]];
                activityCard.activityList = @[ activity ];
                cardModel30.insuranceModel = activityCard;
                cardModel30.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
                cardModel30.identifier = @"insurance_active";
                
                if (activityCard.activityList.count) {
                    [result addObject: @[ cardModel30 ] ];
                }
            }
        }
        
        G100CardModel *cardModel40 = [[G100CardModel alloc] init];
        cardModel40.bike = bike;
        cardModel40.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
        cardModel40.identifier = @"mapService_info";
        [result4 addObject:cardModel40];
        [result addObject:result4];
        return result;
    }
    
    return nil;
}

- (UIViewController *)cardViewControllerWithItem:(id)item indexPath:(NSIndexPath *)indexPath idetifier:(NSString *)identifier {
    if ([item isKindOfClass:[G100CardModel class]]) {
        UIViewController *cardVC = nil;
        G100CardModel *card = (G100CardModel *)item;
        if ([card.identifier isEqualToString:@"bike_info"]) {
            cardVC = [[G100CardUserCarViewController2 alloc] init];
        }else if ([card.identifier isEqualToString:@"test_info"]) {
            cardVC = [[G100CardCommonViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"find_record_info"]) {
            cardVC = [[G100CardCommonViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"battery_info"]) {
            cardVC = [[G100CardBatteryViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"device_info"]) {
            cardVC = [[G100CardDevStateViewController2 alloc] init];
        }else if ([card.identifier isEqualToString:@"safeAndReport_info"]) {
            cardVC = [[G100CardCommonViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"report_info"]) {
            cardVC = [[G100CardCommonViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"remote_ctrl_info"]) {
            cardVC = [[G100CardRemoteCtrlViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"insurance_info"]) {
            cardVC = [[G100CardInsuranceViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"insurance_active"]) {
            cardVC = [[G100CardInsuranceActivityViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"mapService_info"]) {
            cardVC = [[G100CardCommonViewController alloc] init];
        }
        return cardVC;
    }
    
    return nil;
}
- (CGFloat)heightForCardViewWithItem:(id)item width:(CGFloat)width indexPath:(NSIndexPath *)indexPath{
    CGFloat result = 200;
    if ([item isKindOfClass:[G100CardModel class]]) {
        G100CardModel *card = (G100CardModel *)item;
        if ([card.identifier isEqualToString:@"bike_info"]) {
            result = [G100BikeInfoView heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"test_info"]) {
            result = [G100BikeTestView heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"find_record_info"]) {
            result = [G100FindBikeView heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"battery_info"]) {
            result = [G100BattGPSView heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"device_info"]) {
            result = [G100DevMapView heightForItem:card width:width];
        }else if ([card.identifier isEqualToString:@"safeAndReport_info"]) {
            result = [G100SafeAndReportView heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"report_info"]) {
            result = [G100BikeReportView heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"remote_ctrl_info"]) {
            result = [G100CardRemoteCtrlView heightForItem:card width:width];
        }else if ([card.identifier isEqualToString:@"insurance_info"]) {
            result = [G100InsuranceCardView heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"insurance_active"]) {
            result = [G100InsuranceActivity heightWithWidth:width];
        }else if ([card.identifier isEqualToString:@"mapService_info"]) {
            result = [G100MapServiceView heightWithWidth:width];
        }
    }
    
    return result;
}

#pragma mark - 标为废弃
- (NSArray *)dataArrayWithItem2:(id)item {
    if (!item) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        G100CardModel *cardModel = [[G100CardModel alloc] init];
        cardModel.identifier = @"bike_info";
        
        G100CardModel *cardModel1 = [[G100CardModel alloc] init];
        cardModel1.identifier = @"weather_bike_info";
        
        [result addObject:cardModel];
        [result addObject:cardModel1];
        return result;
    }
    
    if ([item isKindOfClass:[G100BikeDomain class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        G100BikeDomain *bike = (G100BikeDomain *)item;
        G100CardModel *cardModel = [[G100CardModel alloc] init];
        cardModel.bike = bike;
        cardModel.identifier = @"bike_info";
        
        G100CardModel *cardModel1 = [[G100CardModel alloc] init];
        cardModel1.bike = bike;
        cardModel1.identifier = @"weather_bike_info";
        cardModel1.device = bike.mainDevice;
        cardModel1.devid = [NSString stringWithFormat:@"%@", @(bike.mainDevice.device_id)];
        
        [result addObject:cardModel];
        [result addObject:cardModel1];
        
        NSInteger index = 1;
        for (G100DeviceDomain *device in [bike.devices sortedArrayUsingComparator:^NSComparisonResult(G100DeviceDomain * preDevice, G100DeviceDomain * nextDevice) {
            // 先按照主副设备排序 若相同则按照seq 排序
            NSComparisonResult result = [[NSNumber numberWithInteger:nextDevice.isMainDevice] compare:[NSNumber numberWithInteger:preDevice.isMainDevice]];
            if (result == NSOrderedSame) {
                result = [[NSNumber numberWithInteger:preDevice.seq] compare:[NSNumber numberWithInteger:nextDevice.seq]];
            }
            
            return result;
        }]) {
            G100CardModel *cardModel2 = [[G100CardModel alloc] init];
            cardModel2.bike = bike;
            cardModel2.device = device;
            cardModel2.devid = [NSString stringWithFormat:@"%@", @(device.device_id)];
            cardModel2.orderIndex = index;
            cardModel2.identifier = @"device_info";
            
            // 保证主设备排在第一位
            if (device.isMainDevice) {
                [result insertObject:cardModel2 atIndex:2];
            }else {
                [result addObject:cardModel2];
            }
            
            index++;
        }
        
        if (bike.isMaster) { // 主用户才拥有远程遥控功能
            for (G100DeviceDomain *device in bike.devices) { // 必须存在远程控制的设备 才显示此卡片
                if (device.func.alertor.remote_ctrl == 1) {
                    G100CardModel *cardModel3 = [[G100CardModel alloc] init];
                    cardModel3.bike = bike;
                    cardModel3.device = device;
                    cardModel3.devid = [NSString stringWithFormat:@"%@", @(device.device_id)];
                    cardModel3.identifier = @"remote_ctrl_info";
                    [result addObject:cardModel3];
                    break;
                }
            }
        }else {
            ;
        }
        
        return result;
    }
    
    return nil;
}
- (UIViewController *)cardViewControllerWithItem2:(id)item indexPath:(NSIndexPath *)indexPath idetifier:(NSString *)identifier {
    if ([item isKindOfClass:[G100CardModel class]]) {
        UIViewController *cardVC = nil;
        G100CardModel *card = (G100CardModel *)item;
        if ([card.identifier isEqualToString:@"bike_info"]) {
            cardVC = [[G100CardUserCarlViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"weather_bike_info"]) {
            cardVC = [[G100CardWeatherViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"device_info"]) {
            cardVC = [[G100CardDevStateViewController alloc] init];
        }else if ([card.identifier isEqualToString:@"remote_ctrl_info"]) {
            cardVC = [[G100CardRemoteCtrlViewController alloc] init];
        }
        return cardVC;
    }
    
    return nil;
}
- (CGFloat)heightForCardViewWithItem2:(id)item width:(CGFloat)width indexPath:(NSIndexPath *)indexPath{
    CGFloat result = 200;
    if ([item isKindOfClass:[G100CardModel class]]) {
        G100CardModel *card = (G100CardModel *)item;
        if ([card.identifier isEqualToString:@"bike_info"]) {
            result = [G100UserCarView heightWithWidth:width-2*Side_Spacing]+Line_Spacing;
        }else if ([card.identifier isEqualToString:@"weather_bike_info"]) {
            result = [G100WeatherAndCarView heightWithWidth:width-2*Side_Spacing]+Line_Spacing;
        }else if ([card.identifier isEqualToString:@"device_info"]) {
            result = [G100DevStateView heightForItem:card width:width-2*Side_Spacing]+Line_Spacing;
        }else if ([card.identifier isEqualToString:@"remote_ctrl_info"]) {
            result = [G100CardRemoteCtrlView heightForItem:card width:width-2*Side_Spacing]+Line_Spacing;
        }
    }
    
    return result;
}

@end
