//
//  EBOfflineMapTool.m
//  G100
//
//  Created by yuhanle on 2017/4/8.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "EBOfflineMapTool.h"
#import "MJExtension.h"

NSString *EBOfflineMapToolDownloadStatusDidChangeNotification = @"com.360qws.EBOfflineMapToolDownloadStatusDidChangeNotification";
NSString const *EBOfflineMapToolDownloadStageIsRunningKey           = @"com.360qws.EBOfflineMapToolDownloadStageIsRunningKey";
NSString const *EBOfflineMapToolDownloadStageStatusKey              = @"com.360qws.EBOfflineMapToolDownloadStageStatusKey";
NSString const *EBOfflineMapToolDownloadStageInfoKey                = @"com.360qws.EBOfflineMapToolDownloadStageInfoKey";
NSString *EBOfflineMapToolHasShowNoticeKey                          = @"com.360qws.EBOfflineMapToolHasShowNoticeKey";
NSString *EBOfflineMapToolDownloadItemsKey                    = @"com.360qws.EBOfflineMapToolDownloadItemsKey";

@interface EBOfflineMapTool (MapdownloadItems)

- (void)setupMapDownloadItems;

- (void)checkMapDownloadItems;

- (void)saveMapDownloadItems;

@end

@interface EBOfflineMapTool ()

/**
 记录正在下载的下载方式和下载状态
 */
@property (nonatomic, strong) NSMutableDictionary *map_downloadItems;

@end

@implementation EBOfflineMapTool
@synthesize downloadingItems = _downloadingItems;
@synthesize downloadStages = _downloadStages;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFNetworkingReachabilityDidChangeNotification
                                                  object:nil];
}

+ (instancetype)sharedManager {
    static EBOfflineMapTool * sharedInstance = nil;
    static dispatch_once_t onceTonken;
    dispatch_once(&onceTonken, ^{
        sharedInstance = [[EBOfflineMapTool alloc] init];
        
        sharedInstance.hasShowedNotice = NO;
        sharedInstance.arraylocalDownLoadMapInfo = [[NSMutableArray alloc] init];
        sharedInstance.downloadingItems = [NSMutableSet set];
        sharedInstance.downloadStages = [NSMutableDictionary dictionary];
        [sharedInstance setupMapDownloadItems];
        
        // 初始化离线地图数据，如果第一次运行且offlinePackage.plist文件不存在，则需要首先执行此方法。否则MAOfflineMap中的省、市、版本号等数据都为空。
        [[MAOfflineMap sharedOfflineMap] setupWithCompletionBlock:^(BOOL setupSuccess) {}];
        
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                 selector:@selector(kEBOfflineMapToolNetworkChanged:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                 selector:@selector(kEBOfflineMapToolWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    });
    
    return sharedInstance;
}

- (BOOL)hasShowedNotice {
    NSUserDefaults *p = [NSUserDefaults standardUserDefaults];
    return [p boolForKey:EBOfflineMapToolHasShowNoticeKey];
}

- (MAOfflineItem *)searchCityWithAdcode:(NSString *)adcode {
    // 城市编码 全国离线地图
    if ([adcode isEqualToString:@"100000"]) {
        return [[MAOfflineMap sharedOfflineMap] nationWide];
    }
    
    NSArray * allcities = [[MAOfflineMap sharedOfflineMap] cities];
    
    if (adcode.length == 0) {
        return nil;
    }
    
    NSArray *centralCity = @[ @"11", @"12", @"31", @"50" ];/* 北京 天津 上海 重庆 */
    NSString *newCityCode;
    if ([centralCity containsObject:[adcode substringToIndex:2]]) {/* 直辖市 */
        newCityCode = [[adcode substringToIndex:2] stringByAppendingString:@"0000"];
    }else{
        newCityCode = [[adcode substringToIndex:4] stringByAppendingString:@"00"];
    }
    
    for (MAOfflineItem * item in allcities) {
        if ([item.adcode isEqualToString:newCityCode]) {
            return item;
        }
    }
    
    return nil;
}

- (MAOfflineItem *)searchCityWithName:(NSString *)cityName {
    NSArray * allcities = [[MAOfflineMap sharedOfflineMap] cities];
    
    for (MAOfflineItem * item in allcities) {
        if ([item.name hasContainString:cityName]) {
            return item;
        }
    }
    
    return nil;
}

#pragma mark - 下载地图
- (void)downloadOfflineMapWithAdcode:(NSString *)adcode downloadType:(EBOfflineItemDownloadType)downloadType {
    EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcode];
    
    if (!ebitem) {
        ebitem = [[EBOfflineItem alloc] init];
        [self.map_downloadItems setObject:ebitem forKey:adcode];
    }
    
    ebitem.adcode = adcode;
    ebitem.downloadType = downloadType;
    ebitem.downloadStatus = EBOfflineItemDownloadStatusStart;
    
    MAOfflineItem *offlineItem = [self searchCityWithAdcode:adcode];
    [self downloadOfflineItem:offlineItem ebitem:ebitem];
}

- (void)download:(MAOfflineItem *)oneCity {
    NSString *adcode = oneCity.adcode;
    
    EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcode];
    
    if (!ebitem) {
        ebitem = [[EBOfflineItem alloc] init];
        [self.map_downloadItems setObject:ebitem forKey:adcode];
    }
    
    ebitem.adcode = adcode;
    ebitem.downloadType = EBOfflineItemDownloadTypeDefault;
    ebitem.downloadStatus = EBOfflineItemDownloadStatusStart;
    
    [self downloadOfflineItem:oneCity ebitem:ebitem];
}

- (void)pauseWithAdcode:(NSString *)adcode {
    EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcode];
    MAOfflineItem *offlineItem = [self searchCityWithAdcode:adcode];
    
    [[MAOfflineMap sharedOfflineMap] pauseItem:offlineItem];
    
    ebitem.downloadStatus = EBOfflineItemDownloadStatusPause;
}

- (void)deleteWithAdcode:(NSString *)adcode {
    MAOfflineItem *offlineItem = [self searchCityWithAdcode:adcode];
    [[MAOfflineMap sharedOfflineMap] deleteItem:offlineItem];
    [self.map_downloadItems removeObjectForKey:adcode];
    
    self.hasShowedNotice = NO;
}

- (void)cancelAll {
    [[MAOfflineMap sharedOfflineMap] cancelAll];
    
    for (NSString *adcoce in [self.map_downloadItems allKeys]) {
        EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcoce];
        if (ebitem.downloadStatus == EBOfflineItemDownloadStatusIng) {
            
        }
        
        [self.map_downloadItems removeAllObjects];
    }
    
    self.hasShowedNotice = NO;
}

- (void)clearDisk {
    [[MAOfflineMap sharedOfflineMap] clearDisk];
    
    for (NSString *adcoce in [self.map_downloadItems allKeys]) {
        EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcoce];
        if (ebitem.downloadStatus == EBOfflineItemDownloadStatusIng) {
            
        }
        
        [self.map_downloadItems removeAllObjects];
    }
    
    self.hasShowedNotice = NO;
}

- (void)resume {
    for (NSString *adcoce in [self.map_downloadItems allKeys]) {
        EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcoce];
        if (ebitem.downloadStatus == EBOfflineItemDownloadStatusIng ||
            ebitem.downloadStatus == EBOfflineItemDownloadStatusStart) {
            // 判断网络情况
            NSInteger netstatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
            
            if (netstatus == AFNetworkReachabilityStatusReachableViaWWAN) {
                if (ebitem.downloadType == EBOfflineItemDownloadTypeWWAN) {
                    [self downloadOfflineMapWithAdcode:ebitem.adcode downloadType:ebitem.downloadType];
                }
            } else if (netstatus == AFNetworkReachabilityStatusReachableViaWiFi) {
                [self downloadOfflineMapWithAdcode:ebitem.adcode downloadType:ebitem.downloadType];
            }
        }
    }
}

#pragma mark - 下载核心代码
- (void)downloadOfflineItem:(MAOfflineItem *)offlineItem ebitem:(EBOfflineItem *)ebitem {
    if (offlineItem == nil || offlineItem.itemStatus == MAOfflineItemStatusInstalled) {
        [self.map_downloadItems removeObjectForKey:ebitem.adcode];
        return;
    }
    
    // 判断网络状态
    NSInteger netstatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (netstatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        // 运营商网络下 仅下载用户手动确认过的item
        if (ebitem.downloadType == EBOfflineItemDownloadTypeWWAN ||
            ebitem.downloadType == EBOfflineItemDownloadTypeDefault) {
            
        } else {
            return;
        }
    } else if (netstatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        // Wifi 状态下立即开始下载
        
    } else if (netstatus == AFNetworkReachabilityStatusNotReachable) {
        // 网络不可达
        
    }
    
    // 开始下载
    [[MAOfflineMap sharedOfflineMap] downloadItem:offlineItem shouldContinueWhenAppEntersBackground:YES downloadBlock:^(MAOfflineItem * downloadItem, MAOfflineMapDownloadStatus downloadStatus, id info) {
        
        if (![self.downloadingItems containsObject:downloadItem])
        {
            [self.downloadingItems addObject:downloadItem];
            [self.downloadStages setObject:[NSMutableDictionary dictionary] forKey:downloadItem.adcode];
        }
        
        /* Manipulations to your application’s user interface must occur on the main thread. */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *stage  = [self.downloadStages objectForKey:downloadItem.adcode];
            
            if (downloadStatus == MAOfflineMapDownloadStatusWaiting)
            {
                [stage setObject:[NSNumber numberWithBool:YES] forKey:EBOfflineMapToolDownloadStageIsRunningKey];
                ebitem.downloadStatus = EBOfflineItemDownloadStatusStart;
            }
            else if(downloadStatus == MAOfflineMapDownloadStatusProgress)
            {
                [stage setObject:info forKey:EBOfflineMapToolDownloadStageInfoKey];
                
                NSDictionary *progressDict = [stage objectForKey:EBOfflineMapToolDownloadStageInfoKey];
                
                long long recieved = [[progressDict objectForKey:MAOfflineMapDownloadReceivedSizeKey] longLongValue];
                long long expected = [[progressDict objectForKey:MAOfflineMapDownloadExpectedSizeKey] longLongValue];
                
                CGFloat progress = 0;
                if (expected != 0) {
                    progress = recieved / 1.0 / (float)expected;
                }
                
                DLog(@"城市名：%@ 比率：%f", downloadItem.name, progress);
                ebitem.downloadStatus = EBOfflineItemDownloadStatusIng;
            }
            else if(downloadStatus == MAOfflineMapDownloadStatusCancelled
                    || downloadStatus == MAOfflineMapDownloadStatusError
                    || downloadStatus == MAOfflineMapDownloadStatusFinished)
            {
                [stage setObject:[NSNumber numberWithBool:NO] forKey:EBOfflineMapToolDownloadStageIsRunningKey];
                
                // clear
                [self.downloadingItems removeObject:downloadItem];
                [self.downloadStages removeObjectForKey:downloadItem.adcode];
                
                if (downloadStatus == MAOfflineMapDownloadStatusError) {
                    // 下载出错 则删除离线资源包
                    [self deleteWithAdcode:downloadItem.adcode];
                }
            }
            
            [stage setObject:[NSNumber numberWithInt:downloadStatus] forKey:EBOfflineMapToolDownloadStageStatusKey];
            
            if (downloadStatus == MAOfflineMapDownloadStatusFinished) {
                [self.map_downloadItems removeObjectForKey:ebitem.adcode];
                
                UIViewController *rootvc = [UIApplication sharedApplication].keyWindow.rootViewController;
                [rootvc showHint:@"离线地图下载已完成"];
            }
            
            /* Update UI. */
            //更新触发下载操作的item涉及到的UI 刷新所有可见的            
            NSDictionary *dcit = @{ @"tool"             : self,
                                    @"downloadItem"     : downloadItem,
                                    @"downloadingItems" : self.downloadingItems,
                                    @"downloadStages"   : self.downloadStages,
                                    @"downloadStatus"   : [NSNumber numberWithInteger:downloadStatus],
                                    @"info"             : info ? info : @{} };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EBOfflineMapToolDownloadStatusDidChangeNotification
                                                                object:nil
                                                              userInfo:dcit];
        });
    }];
}

- (BOOL)needRemainderUserWithAdcode:(NSString *)adcode {
    MAOfflineItem *item = [self searchCityWithAdcode:adcode];
    EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcode];
    
    // 如果该城市离线地图不存在 且下载队列中不存在该城市 则需要提示用户
    if (item.itemStatus == MAOfflineItemStatusNone && !ebitem) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 网络状态变化
- (void)kEBOfflineMapToolNetworkChanged:(NSNotification *)noti {
    BOOL isDownloading = NO;
    BOOL isWWANDownloading = NO;
    
    NSMutableArray *ebitems = [[NSMutableArray alloc] init];
    for (NSString *adcoce in [self.map_downloadItems allKeys]) {
        EBOfflineItem *ebitem = [self.map_downloadItems objectForKey:adcoce];
        if (ebitem.downloadStatus == EBOfflineItemDownloadStatusIng ||
            ebitem.downloadStatus == EBOfflineItemDownloadStatusStart) {
            isDownloading = YES;
            
            if (ebitem.downloadType == EBOfflineItemDownloadTypeWWAN) {
                isWWANDownloading = YES;
            }
        }
        
        [ebitems addObject:ebitem];
    }
    
    UIViewController * tmp = [UIApplication sharedApplication].keyWindow.rootViewController;
    NSInteger status = [[[noti userInfo] objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
        {
            if (isDownloading)
            {
                if (_showHUD) [tmp showWarningHint:@"网络无连接,下载暂停"];
            }else {
                if (_showHUD) [tmp showHint:@"网络无连接"];
            }
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
        {
            if (isDownloading)
            {
                if (_showHUD) [tmp showHint:@"Wifi已连接,下载开始"];
                
                for (EBOfflineItem *ebitem in ebitems) {
                    [self downloadOfflineMapWithAdcode:ebitem.adcode downloadType:ebitem.downloadType];
                }
            }else {
                if (_showHUD) [tmp showHint:@"Wifi已连接"];
            }
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            if (isDownloading)
            {
                if (_showHUD) [tmp showHint:@"3G/4G已连接,下载暂停"];
                
                for (EBOfflineItem *ebitem in ebitems) {
                    if (ebitem.downloadType != EBOfflineItemDownloadTypeWWAN) {
                        // 不是用户手动暂停 需保留下载中状态
                        MAOfflineItem *offlineItem = [self searchCityWithAdcode:ebitem.adcode];
                        [[MAOfflineMap sharedOfflineMap] pauseItem:offlineItem];
                    } else {
                        [self downloadOfflineMapWithAdcode:ebitem.adcode downloadType:ebitem.downloadType];
                    }
                }
            }else {
                if (_showHUD) [tmp showHint:@"3G/4G已连接"];
            }
        }
            break;
        default:
            break;
    }
    
    [ebitems removeAllObjects];
}

- (void)kEBOfflineMapToolWillResignActive:(NSNotification *)noti {
    [self saveMapDownloadItems];
}

@end

@implementation EBOfflineMapTool (MapdownloadItems)

- (void)setupMapDownloadItems {
    if (_map_downloadItems) {
        return;
    }
    
    NSUserDefaults *p = [NSUserDefaults standardUserDefaults];
    NSDictionary *result = [p valueForKey:EBOfflineMapToolDownloadItemsKey];
    
    // 只初始化一次
    if (result) {
        self.map_downloadItems = [[NSMutableDictionary alloc] init];
        for (NSString *adcode in [result allKeys]) {
            NSDictionary *dict = result[adcode];
            if (result) {
                EBOfflineItem *item = [EBOfflineItem mj_objectWithKeyValues:dict];
                [self.map_downloadItems setObject:item forKey:adcode];
            }
        }
    } else {
        self.map_downloadItems = [[NSMutableDictionary alloc] init];
    }
}

- (void)checkMapDownloadItems {
    
}

- (void)saveMapDownloadItems {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (NSString *adcode in [self.map_downloadItems allKeys]) {
        EBOfflineItem *item = self.map_downloadItems[adcode];
        NSDictionary *dict = [item mj_keyValues].copy;
        [result setObject:dict forKey:adcode];
    }
    
    NSUserDefaults *p = [NSUserDefaults standardUserDefaults];
    [p setObject:result.copy forKey:EBOfflineMapToolDownloadItemsKey];
    [p synchronize];
}

@end
