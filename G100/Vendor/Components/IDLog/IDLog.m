//
//  IDLog.m
//  idlFrame
//  Abstract:Colorful & Interesting Log helper ：］
//  Created by Nick(xuli02) on 15/1/22.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "IDLog.h"
#import "AFNetworking.h"

@implementation IDLog

+ (void)idlLogWithType:(IDLogType)type andLogString:(NSString *)log andFileName:(char *)fileName andLineNumber:(NSInteger)lineNumber
{
#ifdef DEBUG
    NSString *idlPrefix = @"IDLog:";
    NSString *file = [NSString stringWithUTF8String:fileName];
    file = [file lastPathComponent];
    
    switch (type) {
        case IDLogTypeError:
            idlPrefix = @"❌ IDLogError:";
            // STDLogRemoteWithErrorString([NSString stringWithFormat:@"%@ %@[%ld] - %@",idlPrefix,file,(long)lineNumber,log]);
            break;
        case IDLogTypeWarning:
            idlPrefix = @"⚠️ IDLogWarning:";
            // STDLogRemoteWithWarningString([NSString stringWithFormat:@"%@ %@[%ld] - %@",idlPrefix,file,(long)lineNumber,log]);
            break;
        case IDLogTypeDebug:
            idlPrefix = @"🔧 IDLogDebug:";
            // STDLogRemoteWithDebugString([NSString stringWithFormat:@"%@ %@[%ld] - %@",idlPrefix,file,(long)lineNumber,log]);
            break;
        default:
            idlPrefix = @"ℹ️ IDLogInfo:";
            // STDLogRemoteWithNoticeString([NSString stringWithFormat:@"%@ %@[%ld] - %@",idlPrefix,file,(long)lineNumber,log]);
            break;
    }
    
    dispatch_async(dispatch_queue_create("printf", NULL), ^{
        NSLog(@"%@ %@[%ld] - %@",idlPrefix,file,(long)lineNumber,log);
    });
#endif
}

void STDLogRemoteWithDebugString(NSString *string) {
    STDLogRemoteWithString(string, @"000000");
}

void STDLogRemoteWithNoticeString(NSString *string) {
    STDLogRemoteWithString(string, @"199DD6");
}


void STDLogRemoteWithWarningString(NSString *string) {
    STDLogRemoteWithString(string, @"FF7300");
}


void STDLogRemoteWithErrorString(NSString *string) {
    STDLogRemoteWithString(string, @"FF0000");
}

void STDLogRemoteWithString(NSString *string, NSString *colorString) {
    if (string.length == 0) {
        return;
    }
    static AFHTTPSessionManager * _logNetwork;
    NSString *remoteURL = @"http://192.168.0.67:10304";
    if (remoteURL) {
        if (!_logNetwork) {
            _logNetwork = [AFHTTPSessionManager manager];
            _logNetwork.responseSerializer = [AFHTTPResponseSerializer serializer];
            _logNetwork.operationQueue.maxConcurrentOperationCount = 6;
            _logNetwork.requestSerializer.timeoutInterval = 60;
        }
    } else {
        _logNetwork = nil;
    }
    if (colorString.length == 0) {
        colorString = @"000000";
    }
    NSDictionary *parameters = @{@"parameter":dateMessageString(string), @"color":colorString};
    [_logNetwork POST:remoteURL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [task cancel];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [task cancel];
    }];
}

static inline NSString* dateMessageString(NSString *string){
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"Y-M-d H:m:S.F"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@ %@",date ,string];
}

@end
