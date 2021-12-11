//
//  RSSwizzler.m
//  G100
//
//  Created by yuhanle on 2018/6/22.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "RSSwizzler.h"
#import <RSSwizzle/RSSwizzle.h>
#import <JRSwizzle/JRSwizzle.h>
#import <SDWebImage/SDWebImageDownloader.h>

@interface SDWebImageDownloader (RSSwizzler)

- (id <SDWebImageOperation>)rs_downloadImageWithURL:(NSURL *)url
                                            options:(SDWebImageDownloaderOptions)options
                                           progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                          completed:(SDWebImageDownloaderCompletedBlock)completedBlock;

@end

@implementation SDWebImageDownloader (RSSwizzler)

- (id <SDWebImageOperation>)rs_downloadImageWithURL:(NSURL *)url
                                            options:(SDWebImageDownloaderOptions)options
                                           progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                          completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
    options = options | SDWebImageDownloaderHandleCookies;
    return [self rs_downloadImageWithURL:url options:options progress:progressBlock completed:completedBlock];
}

@end

@implementation RSSwizzler

+ (void)rs_swizzle {
    NSError *error = nil;
    SEL selector = @selector(downloadImageWithURL:options:progress:completed:);
    [SDWebImageDownloader jr_swizzleMethod:selector
                                withMethod:@selector(rs_downloadImageWithURL:options:progress:completed:)
                                     error:&error];
}

+ (void)rs_swizzle2 {
    // HOOK SDWebImageDownloader 下载图片默认 使用 Cookie
    SEL selector = @selector(downloadImageWithURL:options:progress:completed:);
    [RSSwizzle swizzleInstanceMethod:selector
                             inClass:[SDWebImageDownloader class]
                       newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
                           return ^RSSWReturnType(id <SDWebImageOperation>)(__unsafe_unretained id self, NSURL *url, SDWebImageDownloaderOptions options, SDWebImageDownloaderProgressBlock progressBlock, SDWebImageDownloaderCompletedBlock completedBlock){
                               // 默认使用 Cookie 下载
                               options = options | SDWebImageDownloaderHandleCookies;
                               // You MUST always cast implementation to the correct function pointer.
                               id (*originalIMP)(__unsafe_unretained id, SEL, NSURL *, SDWebImageDownloaderOptions, SDWebImageDownloaderProgressBlock, SDWebImageDownloaderCompletedBlock);
                               originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
                               // Returning modified return value.
                               return originalIMP(self, selector, url, options, progressBlock, completedBlock);
                           };
                       }
                                mode:RSSwizzleModeAlways
                                 key:@"SDWebImageDownloader"];
}

@end
