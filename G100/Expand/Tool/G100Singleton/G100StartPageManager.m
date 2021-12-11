//
//  G100StartPageManager.m
//  G100
//
//  Created by 温世波 on 15/12/15.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100StartPageManager.h"
#import <SDWebImage/SDWebImageManager.h>
#import "G100InfoHelper.h"
#import "G100UserApi.h"

NSString * const kGXStartPageList = @"startpagelist";
@implementation G100StartPageManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static G100StartPageManager * instance = nil;
    dispatch_once(&once, ^{
        instance = [[G100StartPageManager alloc] init];
        
        NSArray * pageList = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXStartPageList];
        if (pageList && pageList.count) {
            instance.pageList = pageList;
        }else {
            instance.pageList = [[NSArray alloc] init];
        }
    });
    return instance;
}

- (G100StartPageDomain *)loadStartPageDomain {
    G100StartPageDomain * page = nil;
    
    // 各种策略 从本地中选取一张作为启动图
    NSArray * validPagelist = [self validPagelistWithList:_pageList];
    
    for (G100StartPageDomain * tmp in validPagelist) {
        if (!page) {
            page = tmp;
        }
        
        // 找到优先级最高的page 返回
        if (tmp.priority < page.priority) {
            page = tmp;
        }
    }
    
    return page;
}

- (NSArray *)validPagelistWithList:(NSArray *)pagelist {
    NSMutableArray * newPagelist = [[NSMutableArray alloc] init];
    
    for (G100StartPageDomain * page in pagelist) {
        if ([self isValidWithPage:page]) {
            [newPagelist addObject:page];
        }
    }
    
    return newPagelist;
}

- (void)setPageList:(NSArray *)pageList {
    if (!pageList || !pageList.count) {
        
        if (_pageList) {    // 清空page
            [self clearAllPage];
        }
        
        [[G100InfoHelper shareInstance] clearAsynchronousWithKey:kGXStartPageList];
        return;
    }
    
    if (_pageList) {
        // 做一下列表的处理操作 清空过期的图片
        [self handlePageList];
    }
    
    // 将启动页信息存储至本地userdefault
    [[G100InfoHelper shareInstance] setAsynchronous:pageList withKey:kGXStartPageList];
    
    _pageList = [pageList mapWithBlock:^id(id item, NSInteger idx) {
        if (INSTANCE_OF(item, NSDictionary)) {
            return [[G100StartPageDomain alloc] initWithDictionary:item];
        }else if (INSTANCE_OF(item, G100StartPageDomain)) {
            return item;
        }
        return nil;
    }];
    
    // 下载所有有效的启动图
    _pageList = [self validPagelistWithList:_pageList];
    for (G100StartPageDomain *page in _pageList) {
        if (page) {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:page.picture]
                                                            options:SDWebImageContinueInBackground
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                              
                                                          }];
        }
    }
}

// 清空本地所有图片
- (void)clearAllPage {
    [_pageList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (INSTANCE_OF(obj, G100StartPageDomain)) {
            //
            G100StartPageDomain * page = (G100StartPageDomain *)obj;
            [self removeStartPageFoyKey:page.picture];
        }
    }];
}
// 处理过期缓存图片
- (void)handlePageList {
    [_pageList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (INSTANCE_OF(obj, G100StartPageDomain)) {
            //
            G100StartPageDomain * page = (G100StartPageDomain *)obj;
            
            // 判断page是否过期
            if ([self isExpiredWithPage:page]) {
                [self removeStartPageFoyKey:page.picture];
            }
        }
    }];
}

- (BOOL)isCurrentLocationWithPage:(G100StartPageDomain *)page {
    return YES;
}

- (BOOL)isBeforeWithPage:(G100StartPageDomain *)page {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    if (page.begintime) {
        NSDate * begintime = [formatter dateFromString:page.begintime];
        NSDate * date = [NSDate date];
        
        if ([begintime isEarlierThanDate:date]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isExpiredWithPage:(G100StartPageDomain *)page {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    if (page.endtime) {
        NSDate * endtime = [formatter dateFromString:page.endtime];
        NSDate * date = [NSDate date];
        
        if ([endtime isLaterThanDate:date]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isValidWithPage:(G100StartPageDomain *)page {
    if ([self isBeforeWithPage:page] || [self isExpiredWithPage:page]) {
        return NO;
    }
    
    return YES;
}

// 移除本地已下载page
- (void)removeStartPageFoyKey:(NSString *)key {
    // 如果磁盘中存在这个page 则删除
    if ([[[SDWebImageManager sharedManager] imageCache] diskImageExistsWithKey:key]) {
        [[[SDWebImageManager sharedManager] imageCache] removeImageForKey:key];
    }
}

#pragma mark - Public Method
- (void)updateAdPageList:(NSString *)location {
    [[G100UserApi sharedInstance] getStartupPageWithLocation:location callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            NSArray *pages = response.data[@"page"];
            if (pages) {
                [[G100StartPageManager sharedInstance] setPageList:pages];
            }
        } else {
            DLog(@"更新广告图失败: %@", response.data[@"state_info"]);
        }
    }];
}

@end
