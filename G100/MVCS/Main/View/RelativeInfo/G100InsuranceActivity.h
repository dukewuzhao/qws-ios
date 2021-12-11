//
//  G100InsuranceActivity.h
//  G100
//
//  Created by sunjingjing on 16/12/7.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
#import "G100ScrollView.h"

@class G100InsuranceCardModel;
@interface G100InsuranceActivity : G100CardBaseView

@property (strong, nonatomic) G100ScrollView *imageScrollView;

@property (strong, nonatomic) UIButton *expireButton;

@property (copy, nonatomic) void (^expireButtonTaped)();

@property (strong, nonatomic) G100InsuranceCardModel *insuranceCardModel;
/**
 *  根据View的宽度算出View的高
 *
 *  @param width
 *
 *  @return View的高
 */
+ (float)heightWithWidth:(float)width;
@end
