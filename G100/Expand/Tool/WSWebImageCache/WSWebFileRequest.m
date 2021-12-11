//
//  WSWebFileRequest.m
//  G100
//
//  Created by 温世波 on 15/12/8.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "WSWebFileRequest.h"
#import "WSWebFileManager.h"

#define CACHE_FILE_TIMEOUT (60*60)
@implementation WSWebFileRequest {
    NSURLSessionTask * _task;
}

- (instancetype)init {
    if (self = [super init]) {
        _downloadData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)startRequestWithUrl:(NSString *)httpUrl success:(WSWebFileRequestSuccessBlock)success failure:(WSWebFileRequestFailureBlock)failure {
    self.httpUrl = httpUrl;
    
    NSString * aFilename = [self.httpUrl stringFromMD5];
    NSString * aFullPath = [WSWebFileManager filePath:aFilename];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:aFullPath]) {
        if (![NSFileManager isTimeout:aFullPath time:CACHE_FILE_TIMEOUT]) {
            NSError * error = nil;
            NSString * string = [NSString stringWithContentsOfFile:aFullPath encoding:NSUTF8StringEncoding error:&error];
            NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
            
            if (data) {
                if (success) {
                    success(aFullPath, data);
                }
            }
            
            return;
        }else {
            // 过期则删除文件
            [fm removeItemAtPath:aFullPath error:nil];
        }
    }
    
    [self downloadFileURL:httpUrl savePath:aFullPath fileName:aFilename success:^(NSString *aFilename, NSData *aData) {
        if (success) {
            success(aFilename, aData);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } progress:nil];
}

- (void)stopRequest {
    if (_task) {
        [_task cancel];
        _task = nil;
    }
}

- (void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName success:(WSWebFileRequestSuccessBlock)success failure:(WSWebFileRequestFailureBlock)failure progress:(WSWebFileRequestProgressBlock)progress
{
    NSURL * url = [[NSURL alloc] initWithString:aUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];

    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask * downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:aSavePath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        if (!error) {
            NSString * string = [NSString stringWithContentsOfFile:aSavePath encoding:NSUTF8StringEncoding error:nil];
            NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
            
            if (!data) {
                return;
            }
            
            if(success) success(aSavePath, data);
        }else{
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:aSavePath]) {
                [fm removeItemAtPath:aSavePath error:nil];
            }
            
            if (failure) failure(error);
        }
    }];
    [downloadTask resume];
    _task = downloadTask;
}

@end
