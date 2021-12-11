//
//  EBOfflineMapService.h
//  G100
//
//  Created by yuhanle on 2017/4/8.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBOfflineMapTool.h"

@protocol EBOfflineMapServiceDelegate <NSObject>

@optional
/**
 监听离线地图下载过程
 
 @param MAOfflineItem * downloadItem, MAOfflineMapDownloadStatus downloadStatus, id info
 */
- (void)mapTool:(EBOfflineMapTool *)tool downloadingItem:(MAOfflineItem *)downloadItem downloadItems:(NSMutableSet *)downloadItems option:(NSMutableDictionary *)downloadStages info:(id)info;

/**
 离线地图完成下载
 
 @param tool tool
 @param downloadItem
 */
- (void)mapTool:(EBOfflineMapTool *)tool didFinishedItem:(MAOfflineItem *)downloadItem;

@end

@interface EBOfflineMapService : NSObject

@property (nonatomic, weak) id <EBOfflineMapServiceDelegate> delegate;

@end
