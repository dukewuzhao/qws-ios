//
//  BindWaitingView.h
//  G100
//
//  Created by 温世波 on 15/11/17.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"
#import "G100DeviceDomainExpand.h"

@interface BindWaitingView : G100PopBoxBaseView

@property (copy, nonatomic) NSString *waitingTitle;

+ (instancetype)bindWaitingView;

@property (strong, nonatomic) G100DevBindResultDomain * bindResult;

- (void)stopAnimation;

@end
