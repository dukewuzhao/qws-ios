//
//  G100PhotoShowModel.h
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100PhotoShowModel : NSObject

@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *photoName;

+ (NSArray *)showModelWithUrlArray:(NSArray *)urlArray;

+ (NSArray *)showModelWithDataArray:(NSArray *)dataArray;

+ (NSArray *)showModelWithBase64Array:(NSArray *)base64Array;

@end
