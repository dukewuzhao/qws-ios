//
//  EBOfflineItem.h
//  G100
//
//  Created by yuhanle on 2017/4/8.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EBOfflineItemDownloadTypeDefault = 0,
    EBOfflineItemDownloadTypeWWAN,
    EBOfflineItemDownloadTypeWIFI,
} EBOfflineItemDownloadType;

typedef enum : NSUInteger {
    EBOfflineItemDownloadStatusStart = 0,
    EBOfflineItemDownloadStatusIng,
    EBOfflineItemDownloadStatusPause,
    EBOfflineItemDownloadStatusFinished,
} EBOfflineItemDownloadStatus;

@interface EBOfflineItem : NSObject

/**
 城市编码
 */
@property (nonatomic, assign) NSString *adcode;

/**
 下载方式
 */
@property (nonatomic, assign) EBOfflineItemDownloadType downloadType;

/**
 下载状态
 */
@property (nonatomic, assign) EBOfflineItemDownloadStatus downloadStatus;

@end
