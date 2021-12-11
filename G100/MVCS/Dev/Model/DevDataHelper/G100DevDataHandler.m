//
//  G100DevDataHandler.m
//  G100
//
//  Created by William on 16/8/17.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevDataHandler.h"
#import "G100DevDataHelper.h"

@implementation G100DevDataHandler

- (instancetype)initWithUserid:(NSString *)userid
                        bikeid:(NSString *)bikeid {
    if (self = [super init]) {
        _userid = userid;
        _bikeid = bikeid;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(devDataReceivedNotification:)
                                                     name:kDevDataReceivedNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)devDataReceivedNotification:(NSNotification *)noti {
    NSString * userid = noti.userInfo[@"userid"];
    NSString * bikeid = noti.userInfo[@"bikeid"];
    
    ApiResponse *response = noti.object;
    if ([userid isEqualToString:self.userid] &&
        [bikeid isEqualToString:self.bikeid]) {
        if ([_delegate respondsToSelector:@selector(G100DevDataHandler:receivedData:withUserid:bikeid:)]) {
            [_delegate G100DevDataHandler:self receivedData:response withUserid:userid bikeid:bikeid];
        }
    }
}

- (void)addConcern {
    [[G100DevDataHelper shareInstance] addConcernWithUserid:self.userid bikeid:self.bikeid];
}

- (void)removeConcern {
    [[G100DevDataHelper shareInstance] removeConcernWithUserid:self.userid bikeid:self.bikeid];
}

- (void)addConcernByCustomInterval {
    [G100DevDataHelper shareInstance].isCustomInterval = YES;
    [self addConcern];
}

- (void)removeConcernByCustomInterval {
    [G100DevDataHelper shareInstance].isCustomInterval = NO;
    [self removeConcern];
}

- (void)concernNow:(API_CALLBACK)callback {
    [[G100DevDataHelper shareInstance] concernNowWithUserid:self.userid
                                                     bikeid:self.bikeid
                                                   callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (callback) {
            callback(statusCode, response, requestSuccess);
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDevDataReceivedNotification
                                                  object:nil];
}

@end
