//
//  G100SearchHelper.m
//  G100
//
//  Created by 天奕 on 15/12/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100SearchHelper.h"

NSString * const kGXSearchResult = @"searchResult";

@implementation G100SearchHelper

+(instancetype)shareInstance {
    static dispatch_once_t onceTonken;
    static G100SearchHelper * shareInstance = nil;
    dispatch_once(&onceTonken, ^{
        shareInstance = [[G100SearchHelper alloc]init];
    });
    
    return shareInstance;
}

-(void)setSearchResultArray:(NSArray *)searchResultArray key:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:searchResultArray forKey:[NSString stringWithFormat:@"%@+%@",kGXSearchResult,key]];
    [userDefault synchronize];
}

- (NSArray *)searchResultArrayWithKey:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *searchResultArray = [userDefault objectForKey:[NSString stringWithFormat:@"%@+%@",kGXSearchResult,key]];
    return searchResultArray;
}

- (void)updateSearchResultWithKey:(NSString *)key andResult:(NSString *)result {
    NSArray *array = [self searchResultArrayWithKey:key];
    NSMutableArray *mutableArray;
    if (!array) {
        array = [NSArray array];
    }
    mutableArray = [array mutableCopy];
    if ([mutableArray containsObject:result]) {
        [mutableArray removeObject:result];
        [mutableArray addObject:result];
    }else{
        if (mutableArray.count < Max_Search_Result_Num) {
            [mutableArray addObject:result];
        }else{
            [mutableArray removeObjectAtIndex:0];
            [mutableArray addObject:result];
        }
    }
    [self setSearchResultArray:mutableArray.copy key:key];
}

- (void)removeSearchResultWithKey:(NSString *)key {
    NSArray *array = [self searchResultArrayWithKey:key];
    NSMutableArray *mutableArray;
    if (!array) {
        array = [NSArray array];
    }
    mutableArray = [array mutableCopy];
    [mutableArray removeAllObjects];
    [self setSearchResultArray:mutableArray.copy key:key];
}

@end
