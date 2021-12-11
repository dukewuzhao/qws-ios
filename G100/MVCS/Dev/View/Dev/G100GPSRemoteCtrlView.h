//
//  G100GPSRemoteCtrlView.h
//  G100
//
//  Created by yuhanle on 16/8/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100FXBlurPopBoxBaseView.h"
#import "G100CardManager.h"

@class G100CardRemoteCtrlViewController;
@interface G100GPSRemoteCtrlView : G100FXBlurPopBoxBaseView

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

@property (nonatomic, strong) G100CardModel *cardModel;

@property (nonatomic, strong) G100CardRemoteCtrlViewController *cardRemoteCtrlVC;

@end
