//
//  EBOfflineMapTool.h
//  G100
//
//  Created by yuhanle on 2017/4/8.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "EBOfflineItem.h"

extern NSString *EBOfflineMapToolDownloadStatusDidChangeNotification;
extern NSString const *EBOfflineMapToolDownloadStageIsRunningKey;
extern NSString const *EBOfflineMapToolDownloadStageStatusKey;
extern NSString const *EBOfflineMapToolDownloadStageInfoKey;
extern NSString *EBOfflineMapToolHasShowNoticeKey;

@interface EBOfflineMapTool : NSObject

@property (assign, nonatomic) BOOL showHUD;
@property (assign, nonatomic) BOOL hasShowedNotice;

@property (nonatomic, strong) NSMutableArray *arraylocalDownLoadMapInfo;
@property (nonatomic, strong) NSMutableSet *downloadingItems;
@property (nonatomic, strong) NSMutableDictionary *downloadStages;

+ (instancetype)sharedManager;

/**
 *  根据区域编号搜索该城市
 *
 *  @param adcode 区域编码
 *
 *  @return 对应的离线地图信息
 */
- (MAOfflineItem *)searchCityWithAdcode:(NSString *)adcode;

/**
 *  根据城市名搜索该城市
 *
 *  @param cityName 城市名
 *
 *  @return 对应的离线地图信息
 */
- (MAOfflineItem *)searchCityWithName:(NSString *)cityName;

/**
 根据城市编号下载离线地图

 @param adcode 下载离线地图的城市编码
 @param downloadType 下载方式
 */
- (void)downloadOfflineMapWithAdcode:(NSString *)adcode downloadType:(EBOfflineItemDownloadType)downloadType;

/**
 下载城市离线地图

 @param oneCity 下载城市
 */
- (void)download:(MAOfflineItem *)oneCity;

/**
 暂停下载

 @param adcode 下载城市编码
 */
- (void)pauseWithAdcode:(NSString *)adcode;

/**
 删除下载城市

 @param adcode 下载城市编码
 */
- (void)deleteWithAdcode:(NSString *)adcode;

/**
 取消所有下载
 */
- (void)cancelAll;

/**
 清空离线下载
 */
- (void)clearDisk;

/**
 恢复下载 用于恢复意外中断的下载 如检查版本更新
 */
- (void)resume;

/**
 是否需要提醒用户下载该城市地图

 @param adcode 城市编码
 @return YES/NO
 */
- (BOOL)needRemainderUserWithAdcode:(NSString *)adcode;

@end
