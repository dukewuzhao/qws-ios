//
//  G100InsuranceManager.m
//  G100
//
//  Created by sunjingjing on 16/12/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100InsuranceManager.h"
#import "G100InsuranceApi.h"

@interface G100InsuranceManager ()

@property (nonatomic, strong) G100InsuranceCardModel *insuranceCardModel;

@end

@implementation G100InsuranceManager

- (G100InsuranceCardModel *)insuranceCardModel {
    if (!_insuranceCardModel) {
        _insuranceCardModel = [[G100InsuranceCardModel alloc] init];
    }
    return _insuranceCardModel;
}

- (void)getInsuranceModelWithUserid:(NSString *)userid bikeid:(NSString *)bikeid compete:(G100InsuranceModelCallback)callback {
    self.insuranceCardModel.userid = userid;
    self.insuranceCardModel.bikeid = bikeid;
    
    __weak typeof(self) wself = self;
    dispatch_queue_t tasksQueue = dispatch_queue_create("insuranceTasksQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(tasksQueue, ^{
        dispatch_queue_t performTasksQueue = dispatch_queue_create("insurancePerformTasksQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_enter(group);
        dispatch_async(performTasksQueue, ^{
            [[G100InsuranceApi sharedInstance] queryInsurancePrompt:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    wself.insuranceCardModel.prompt = [[G100InsurancePromptDomain alloc] initWithDictionary:[response.data objectForKey:@"prompt"]];
                }
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_enter(group);
        dispatch_async(performTasksQueue, ^{
            [[G100InsuranceApi sharedInstance] queryAllInsuranceActivityWithBikeid:bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    wself.insuranceCardModel.activityList = [[G100InsuranceActivityList alloc] initWithDictionary:response.data].list;
                }
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_enter(group);
        dispatch_async(performTasksQueue, ^{
            [[G100InsuranceApi sharedInstance] queryInsuranceFreeWithUserid:userid bikeid:bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    G100InsuranceBannerList *banner = [[G100InsuranceBannerList alloc] initWithDictionary:response.data];
                    wself.insuranceCardModel.bannerList = banner.list;
                }
                dispatch_group_leave(group);
            }];
        });
        
        //此方法会阻塞当前线程 不推荐
        //dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_group_notify(group, dispatch_get_main_queue(),^{
            if (callback) {
                callback(wself.insuranceCardModel);
            }
        });
    });
}

- (void)getInsuranceBannerWithUserid:(NSString *)userid bikeid:(NSString *)bikeid compete:(G100InsuranceBannerListCallback)callback {
    [[G100InsuranceApi sharedInstance] queryInsuranceFreeWithUserid:userid bikeid:bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        G100InsuranceBannerList *bannerList = [[G100InsuranceBannerList alloc] initWithDictionary:response.data];
        if (callback) {
            callback(bannerList);
        }
    }];
}

@end

@implementation G100InsuranceCardModel

@end

@implementation G100InsuranceBanner

@end

@implementation G100InsuranceBannerList

- (void)setList:(NSArray<G100InsuranceBanner *> *)list{
    if (NOT_NULL(list)) {
        _list = [list mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100InsuranceBanner alloc]initWithDictionary:item];
            }else if (INSTANCE_OF(item, G100InsuranceBanner)){
                return item;
            }
            return nil;
        }];
    }
}
@end

@implementation G100InsuranceActivityDomain

@end

@implementation G100InsuranceActivityList
- (void)setList:(NSArray<G100InsuranceActivityDomain *> *)list{
    if (NOT_NULL(list)) {
        _list = [list mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100InsuranceActivityDomain alloc]initWithDictionary:item];
            }else if (INSTANCE_OF(item, G100InsuranceActivityDomain)){
                return item;
            }
            return nil;
        }];
    }
}
@end

@implementation G100InsurancePromptDomain

@end
