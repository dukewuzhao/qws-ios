//
//  QSThreadSafeCounter.m
//  G100
//
//  Created by yuhanle on 2017/12/18.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "QSThreadSafeCounter.h"
#import <libkern/OSAtomic.h>

@implementation QSThreadSafeCounter{
    
    int32_t _value;
}


- (int32_t)value
{
    return _value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
