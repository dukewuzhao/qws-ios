//
//  G100BikeInfoCardModel.h
//  G100
//
//  Created by yuhanle on 2017/5/27.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100BikeInfoCardModel : NSObject

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) G100BikeDomain *bike;

@end
