//
//  G100BikeInfoUserViewController.h
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100BikeInfoCardModel.h"

@protocol G100BikeInfoUserViewControllerDelegate <NSObject>

@required

- (void)featchUserListFinished;

@end

@interface G100BikeInfoUserViewController : UIViewController

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;

@property (nonatomic, strong) G100BikeInfoCardModel *bikeInfoModel;

@property (weak, nonatomic) id <G100BikeInfoUserViewControllerDelegate> delegate;

- (CGFloat)heightForItem:(id)item width:(CGFloat)width;

@end
