//
//  G100ThemeManager.m
//  G100
//
//  Created by 温世波 on 15/12/9.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100ThemeManager.h"
#import "WSWebFileRequest.h"
#import <SDWebImage/SDWebImageManager.h>

@interface G100ThemeManager ()

@end

@implementation G100ThemeManager

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static G100ThemeManager * instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)findThemeInfoDomainWithJsonUrl:(NSString *)jsonUrl completeBlock:(void (^)(G100ThemeInfoDoamin *, BOOL, NSError *))completeBlock {
    
    if (!jsonUrl || !jsonUrl.length) {
        if (completeBlock) {
            completeBlock(nil, NO, nil);
        }
        
        DLog(@"资源地址不能为空！！！");
        
        return;
    }
    
    WSWebFileRequest * request = [[WSWebFileRequest alloc] init];
    
    [request startRequestWithUrl:jsonUrl success:^(NSString *aFilename, NSData *aData) {
        NSError * error = nil;
        NSDictionary * dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:aData options:kNilOptions error:&error];
        
        if (dict == nil) {
            if (completeBlock) {
                completeBlock(nil, NO, error);
            }
        }else {
            G100ThemeInfoDoamin * theme = [[G100ThemeInfoDoamin alloc] initWithDictionary:dict];
            
            NSArray * pic_urlsArr = @[
                                      theme.theme_channel_info.logo_big ? : @"",
                                      theme.theme_channel_info.logo_mid ? : @"",
                                      theme.theme_channel_info.logo_small ? : @"",
                                      ];
            
            for (NSString * pic_urlstr in pic_urlsArr) {
                if (!pic_urlstr || !pic_urlstr.length) {
                    continue;
                }
                
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:pic_urlstr] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    
                }];
            }
            
            if (theme) {
                if (completeBlock) {
                    completeBlock(theme, YES, nil);
                }
            }else {
                if (completeBlock) {
                    completeBlock(nil, NO, error);
                }
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(nil, NO, error);
        }
    }];
}

- (void)findThemeBikeModelWithModelid:(NSInteger)modelid inThemeUrl:(NSString *)themeUrl completeBlock:(void (^)(G100ThemeInfoBikeModel *))completeBlock {
    [self findThemeInfoDomainWithJsonUrl:themeUrl completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
        if (success) {
            if (completeBlock) {
                completeBlock([theme findThemeInfoBikeModelWithModelid:modelid]);
            }
        }else {
            if (completeBlock) {
                completeBlock(nil);
            }
        }
    }];
}

// theme已存在的时候
- (G100ThemeInfoBikeModel *)findThemeBikeModelWithModelid:(NSInteger)modelid inTheme:(G100ThemeInfoDoamin *)theme {
    return [theme findThemeInfoBikeModelWithModelid:modelid];
}

@end
