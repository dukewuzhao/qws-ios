//
//  G100AlertConfirmClickView.h
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ConfirmClickBlock)();

@interface G100AlertConfirmClickView : UIView

+ (instancetype)confirmClickView;

@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

@property (copy, nonatomic) ConfirmClickBlock confirmClickBlock;

@end
