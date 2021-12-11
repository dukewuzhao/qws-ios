//
//  CDDUser+CoreDataProperties.h
//  CoreDataDemo
//
//  Created by yuhanle on 16/7/8.
//  Copyright © 2016年 yuhanle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDDUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDDUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *account;
@property (nullable, nonatomic, retain) NSString *birthday;
@property (nullable, nonatomic, retain) NSNumber *gender;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *id_card_no;
@property (nullable, nonatomic, retain) NSNumber *integrity;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *nick_name;
@property (nullable, nonatomic, retain) NSString *phone_num;
@property (nullable, nonatomic, retain) NSString *real_name;
@property (nullable, nonatomic, retain) NSString *reg_time;
@property (nullable, nonatomic, retain) NSNumber *user_id;
@property (nullable, nonatomic, retain) CDDAccount *account_info;
@property (nullable, nonatomic, retain) NSNumber *bike_count;
@property (nullable, nonatomic, retain) NSNumber *device_count;
@property (nullable, nonatomic, retain) NSNumber *service_count;
@property (nullable, nonatomic, retain) id homeinfo;
@end

NS_ASSUME_NONNULL_END
