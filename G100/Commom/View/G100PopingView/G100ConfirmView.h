//
//  G100ConfirmView.h
//  G100
//
//  Created by William on 16/8/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ConfirmBtnClick)(NSInteger tag);

@interface G100ConfirmView : UIView

@property (strong, nonatomic) IBOutlet UIButton *otherBtn;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;

@property (copy, nonatomic) ConfirmBtnClick confirmBtnClick;

+ (instancetype)loadSingleConfirmView;

+ (instancetype)loadDoubleConfirmView;

@end

