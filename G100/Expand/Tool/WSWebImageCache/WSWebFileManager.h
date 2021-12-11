//
//  WSWebFileManager.h
//  G100
//
//  Created by 温世波 on 15/12/8.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFileManager+PathSize.h"

@interface WSWebFileManager : NSObject

+ (instancetype)sharedManager;

+ (NSString *)filePath:(NSString *)fileName;

@end
