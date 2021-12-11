//
//  G100PopView.h
//  G100
//
//  Created by Tilink on 15/3/20.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100FXBlurPopBoxBaseView.h"

@class G100PushMsgDomain;
typedef void(^IgnoreBlock)(G100PushMsgDomain *pushMsg);
typedef void(^HelpBlock)(G100PushMsgDomain *pushMsg);

@interface G100PopView : G100FXBlurPopBoxBaseView

@property (copy, nonatomic) IgnoreBlock ignoreClick;
@property (copy, nonatomic) HelpBlock helpClick;
@property (strong, nonatomic) G100PushMsgDomain *pushMsg;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) NSInteger popCode;

-(void)showWithInfoData:(G100PushMsgDomain *)infoData ignoreBlock:(IgnoreBlock)ignore helpBlock:(HelpBlock)help;

-(void)hideSelf;

@end
