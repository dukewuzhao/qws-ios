//
//  MAGeoCodeResult.m
//  G100
//
//  Created by 温世波 on 15/11/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "MAGeoCodeResult.h"

@implementation MAGeoCodeResult

+(instancetype)instance {
    static MAGeoCodeResult * sharedInstance = nil;
    static dispatch_once_t onceTonken;
    dispatch_once(&onceTonken, ^{
        sharedInstance = [[MAGeoCodeResult alloc]init];
    });
    
    return sharedInstance;
}

@end
