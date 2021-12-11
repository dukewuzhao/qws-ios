//
//  CDDBike+CoreDataProperties.h
//  CoreDataDemo
//
//  Created by yuhanle on 16/7/8.
//  Copyright © 2016年 yuhanle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDDBike.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDDBike (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *bike_id;
@property (nullable, nonatomic, retain) NSString *is_master;
@property (nullable, nonatomic, retain) NSNumber *lost_count;
@property (nullable, nonatomic, retain) NSNumber *lost_id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *state;
@property (nullable, nonatomic, retain) NSNumber *user_count;
@property (nullable, nonatomic, retain) id model;
@property (nullable, nonatomic, retain) id feature;
@property (nullable, nonatomic, retain) id brand;
@property (nullable, nonatomic, retain) CDDAccount *account_info;
@property (nullable, nonatomic, retain) NSSet<CDDDevice *> *devices;
@property (nullable, nonatomic, retain) NSNumber *created_time;
@property (nullable, nonatomic, retain) NSString *add_url;
@property (nullable, nonatomic, retain) NSNumber *bike_seq;
@property (nullable, nonatomic, retain) NSNumber *bike_type;
@property (nullable, nonatomic, retain) NSNumber *max_speed;
@property (nullable, nonatomic, retain) NSNumber *max_speed_on;

@property (nullable, nonatomic, retain) id test_result;
@property (nullable, nonatomic, retain) id bikeRuntime;
@property (nullable, nonatomic, retain) id lastFindRecord;

@end

@interface CDDBike (CoreDataGeneratedAccessors)

- (void)addDevicesObject:(CDDDevice *)value;
- (void)removeDevicesObject:(CDDDevice *)value;
- (void)addDevices:(NSSet<CDDDevice *> *)values;
- (void)removeDevices:(NSSet<CDDDevice *> *)values;

@end

NS_ASSUME_NONNULL_END
