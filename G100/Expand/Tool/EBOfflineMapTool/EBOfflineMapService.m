//
//  EBOfflineMapService.m
//  G100
//
//  Created by yuhanle on 2017/4/8.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "EBOfflineMapService.h"

@implementation EBOfflineMapService

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:EBOfflineMapToolDownloadStatusDidChangeNotification
                                                  object:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // 监听地图下载情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(EBOfflineMapServiceNotification:)
                                                 name:EBOfflineMapToolDownloadStatusDidChangeNotification
                                               object:nil];
}

- (void)EBOfflineMapServiceNotification:(NSNotification *)noti {
    /** 推送中 userinfo 结构
    NSDictionary *dcit = @{ @"tool"             : self,
                            @"downloadItem"     : downloadItem,
                            @"downloadingItems" : self.downloadingItems,
                            @"downloadStages"   : self.downloadStages,
                            @"downloadStatus"   : [NSNumber numberWithInteger:downloadStatus],
                            @"info"             : info ? info : @{} };
     */
    
    NSDictionary *dict = [noti userInfo];
    EBOfflineMapTool *tool = dict[@"tool"];
    MAOfflineItem *downloadItem = dict[@"downloadItem"];
    NSMutableSet *downloadingItems = dict[@"downloadingItems"];
    NSMutableDictionary *downloadStages = dict[@"downloadStages"];
    NSInteger downloadStatus = [dict[@"downloadStatus"] integerValue];
    id info = dict[@"info"];
    
    if ([self.delegate respondsToSelector:@selector(mapTool:downloadingItem:downloadItems:option:info:)]) {
        [self.delegate mapTool:tool downloadingItem:downloadItem downloadItems:downloadingItems option:downloadStages info:info];
    }
    
    if (downloadStatus == MAOfflineMapDownloadStatusFinished) {
        if ([self.delegate respondsToSelector:@selector(mapTool:didFinishedItem:)]) {
            [self.delegate mapTool:tool didFinishedItem:downloadItem];
        }
    }
}

@end
