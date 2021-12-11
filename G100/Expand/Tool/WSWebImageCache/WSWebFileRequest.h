//
//  WSWebFileRequest.h
//  G100
//
//  Created by 温世波 on 15/12/8.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WSWebFileRequestSuccessBlock)(NSString * aFilename, NSData * aData);
typedef void(^WSWebFileRequestProgressBlock)(float progressValue);
typedef void(^WSWebFileRequestFailureBlock)(NSError *error);

@interface WSWebFileRequest : NSObject

@property (nonatomic, assign) BOOL isCache;

@property (nonatomic, copy) NSString * httpUrl;

@property (nonatomic, strong) NSMutableData * downloadData;

- (void)startRequestWithUrl:(NSString *)httpUrl success:(WSWebFileRequestSuccessBlock)success failure:(WSWebFileRequestFailureBlock)failure;

- (void)stopRequest;

@end
