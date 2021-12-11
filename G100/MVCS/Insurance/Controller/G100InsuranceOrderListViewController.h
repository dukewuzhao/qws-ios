//
//  G100InsuranceOrderListViewController.h
//  G100
//
//  Created by yuhanle on 2017/8/7.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, InsuranceOrderType) {
    InsuranceOrderAll= 0,
    InsuranceOrderWaitPay = 10,
    InsuranceOrderAuditting = 2,
    InsuranceOrderGuarantee = 1,
    InsuranceOrderExpired = 8,
};

@interface G100InsuranceOrderListViewController : UIViewController

@property (nonatomic, copy) NSString *userid;

@property (assign, nonatomic) InsuranceOrderType insuranceOrderType;

@end
