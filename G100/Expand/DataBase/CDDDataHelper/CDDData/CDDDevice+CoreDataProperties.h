//
//  CDDDevice+CoreDataProperties.h
//  CoreDataDemo
//
//  Created by yuhanle on 16/7/8.
//  Copyright © 2016年 yuhanle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDDDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDDDevice (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *comm_mode;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *device_id;
@property (nullable, nonatomic, retain) NSString *firm;
@property (nullable, nonatomic, retain) id func;
@property (nullable, nonatomic, retain) NSNumber *model_id;
@property (nullable, nonatomic, retain) NSNumber *model_type_id;
@property (nullable, nonatomic, retain) NSString *pcb;
@property (nullable, nonatomic, retain) NSString *prigin_firm;
@property (nullable, nonatomic, retain) NSString *qr;
@property (nullable, nonatomic, retain) id security;
@property (nullable, nonatomic, retain) id service;
@property (nullable, nonatomic, retain) NSString *sn;
@property (nullable, nonatomic, retain) NSNumber *state;
@property (nullable, nonatomic, retain) NSNumber *main_device;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *warranty;
@property (nullable, nonatomic, retain) NSNumber *alarm_bell_time;
@property (nullable, nonatomic, retain) NSNumber *remote_ctrl_mode;
@property (nullable, nonatomic, assign) NSNumber *location_display;
@property (nullable, nonatomic, retain) NSNumber *seq;
@property (nullable, nonatomic, retain) NSString *add_url;
@property (nullable, nonatomic, retain) CDDBike *bike;

@property (nullable, nonatomic, retain) NSNumber * left30remainder;
@property (nullable, nonatomic, retain) NSNumber * left20remainder;
@property (nullable, nonatomic, retain) NSNumber * left15remainder;
@property (nullable, nonatomic, retain) NSNumber * left10remainder;

@end

NS_ASSUME_NONNULL_END
