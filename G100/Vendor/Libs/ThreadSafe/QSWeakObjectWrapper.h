//
//  QSWeakObjectWrapper.h
//  G100
//
//  Created by yuhanle on 2017/12/18.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSWeakObjectWrapper : NSObject

@property (nonatomic, weak, readonly) id weakObject;

- (id)initWithWeakObject:(id)weakObject;

@end
