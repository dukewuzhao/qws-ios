//
//  CDDAccount+CoreDataProperties.h
//  CoreDataDemo
//
//  Created by yuhanle on 16/7/8.
//  Copyright © 2016年 yuhanle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDDAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDDAccount (CoreDataProperties)

@property (nullable, nonatomic, retain) id app_func;
@property (nullable, nonatomic, retain) id app_watermark;
@property (nullable, nonatomic, retain) NSString *picvc_url;
@property (nullable, nonatomic, retain) NSString *push_block;
@property (nullable, nonatomic, retain) NSString *solution;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSNumber *user_id;
@property (nullable, nonatomic, retain) NSSet<CDDBike *> *bikes;
@property (nullable, nonatomic, retain) CDDUser *user_info;

@end

@interface CDDAccount (CoreDataGeneratedAccessors)

- (void)addBikesObject:(CDDBike *)value;
- (void)removeBikesObject:(CDDBike *)value;
- (void)addBikes:(NSSet<CDDBike *> *)values;
- (void)removeBikes:(NSSet<CDDBike *> *)values;

@end

NS_ASSUME_NONNULL_END
