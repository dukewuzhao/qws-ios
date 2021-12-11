//
//  QSThreadSafeCounter.h
//  G100
//
//  Created by yuhanle on 2017/12/18.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSThreadSafeCounter : NSObject

@property (atomic, readonly) int32_t value;

- (int32_t)value;

- (int32_t)increase;

@end
