//
//  G100InsuranceManager.h
//  G100
//
//  Created by sunjingjing on 16/12/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100BannerButtonDomain.h"

@class G100BaseDomain;
@interface G100InsuranceActivityDomain : G100BaseDomain

@property (assign, nonatomic) NSInteger activity_id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *activity_code;
@property (copy, nonatomic) NSString *begin_time;
@property (copy, nonatomic) NSString *end_time;
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString *picture;
@property (copy, nonatomic) NSString *url;

@end

@interface G100InsuranceActivityList : G100BaseDomain

@property (copy, nonatomic) NSArray <G100InsuranceActivityDomain *> *list;

@end

@interface G100InsurancePromptDomain : G100BaseDomain
@property (assign, nonatomic) NSInteger prompt_id;
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *url;

@end

@interface G100InsuranceBanner : G100BaseDomain

@property (assign, nonatomic) NSInteger banner_id;
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *brief;
@property (strong, nonatomic) G100BannerButtonDomain *button;
/** 盗抢险可领取剩余天数*/
@property (nonatomic, assign) NSInteger number;

@end

@interface G100InsuranceBannerList : G100BaseDomain

@property (copy, nonatomic) NSArray <G100InsuranceBanner *> *list;

@end

@interface G100InsuranceCardModel : G100BaseDomain

@property (copy, nonatomic) NSString *userid;
@property (copy, nonatomic) NSString *bikeid;
@property (strong, nonatomic) G100InsurancePromptDomain *prompt;
@property (copy, nonatomic) NSArray *bannerList;
@property (copy, nonatomic) NSArray *activityList;

@end

typedef void(^G100InsuranceModelCallback)(G100InsuranceCardModel *insuranceModel);
typedef void(^G100InsuranceBannerListCallback)(G100InsuranceBannerList *bannerList);

@interface G100InsuranceManager : NSObject

/**
 请求保险活动卡片相关数据

 @param bikeid 可领取保险bikeid
 @param callback  返回保险活动卡片数据
 */
- (void)getInsuranceModelWithUserid:(NSString *)userid bikeid:(NSString *)bikeid compete:(G100InsuranceModelCallback)callback;

/**
 请求盗抢险状态

 @param userid
 @param bikeid
 @param callback
 */
- (void)getInsuranceBannerWithUserid:(NSString *)userid bikeid:(NSString *)bikeid compete:(G100InsuranceBannerListCallback)callback;

@end
