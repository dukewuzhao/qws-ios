//
//  G100DevFindLostListDomain.h
//  G100
//
//  Created by William on 16/4/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100DevLostListDomain.h"

typedef enum : NSInteger {
    FindingRecordTypeOpenSwitch = 1,//开电门
    FindingRecordTypeCloseSwitch,//关电门
    FindingRecordTypeLocatePosition,//定位点
    FindingRecordTypeCustom,//用户自定义
    FindingRecordTypeStartFinding,//开始寻车
    FindingRecordTypeEndFinding,//结束寻车
    FindingRecordTypeLostPosition,//丢车地点
    FindingRecordTypeLostHasClaims,//已理赔
    FindingRecordTypeBatteryRemove,//电瓶移除
}FindingRecordType;

@interface G100DevFindLostDomain : G100BaseDomain
/** 记录序号 */
@property (nonatomic, assign) NSInteger findlostid;
/** 时间 */
@property (nonatomic, copy) NSString * time;
/** 记录类型 1开电门 2关电门 3定位点 4用户自定义 5开始寻车 6结束寻车 */
@property (nonatomic, assign) FindingRecordType type;
/** 寻车记录文本 */
@property (nonatomic, copy) NSString * desc;
/** 图片，可为空 */
@property (nonatomic, copy) NSArray * picture;

/** 行高 */
@property (nonatomic, assign) CGFloat cellHeight;

@end

@interface G100DevFindLostListDomain : G100BaseDomain

@property (nonatomic, strong) G100DevLostDomain *lostdetail;
@property (nonatomic, copy) NSArray * findlost; /** G100DevFindLostDomain */

@end
