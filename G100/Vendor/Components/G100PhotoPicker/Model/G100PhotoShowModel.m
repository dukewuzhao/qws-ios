//
//  G100PhotoShowModel.m
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import "G100PhotoShowModel.h"

@implementation G100PhotoShowModel

+ (NSArray *)showModelWithUrlArray:(NSArray *)urlArray {
    NSMutableArray * array = [NSMutableArray array];
    for (NSString * url in urlArray) {
        G100PhotoShowModel *model = [[self alloc] init];
        model.photoName = @"qws";
        model.url = url;
        [array addObject:model];
    }
    return array.copy;
}

+ (NSArray *)showModelWithDataArray:(NSArray *)dataArray {
    NSMutableArray * array = [NSMutableArray array];
    for (NSData * data in dataArray) {
        G100PhotoShowModel *model = [[self alloc] init];
        model.photoName = @"qws";
        model.data = data;
        [array addObject:model];
    }
    return array.copy;
}

+ (NSArray *)showModelWithBase64Array:(NSArray *)base64Array {
    NSMutableArray * array = [NSMutableArray array];
    for (NSString * base64 in base64Array) {
        G100PhotoShowModel *model = [[self alloc] init];
        model.photoName = @"qws";
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
        model.image = [UIImage imageWithData:data];
        [array addObject:model];
    }
    return array.copy;
}

@end
