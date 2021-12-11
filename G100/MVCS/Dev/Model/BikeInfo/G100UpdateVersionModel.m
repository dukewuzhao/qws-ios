//
//  G100UpdateVersionModel.m
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100UpdateVersionModel.h"

@implementation G100UpdateVersionModel
- (void)setUpgrade_his:(NSArray<G100DeviceFirmUpgradeHisModel *> *)upgrade_his{
    if (NOT_NULL(upgrade_his)) {
        _upgrade_his = [upgrade_his mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100DeviceFirmUpgradeHisModel alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100DeviceFirmUpgradeHisModel)){
                return item;
            }
            return nil;
        }];
    }
}
@end
@implementation G100DeviceFirmInfoModel
@end
@implementation G100DeviceFirmUpgradeHisModel
@end

