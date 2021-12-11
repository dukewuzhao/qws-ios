//
//  G100AlertCancelClickView.h
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CancelClickBlock)();

@interface G100AlertCancelClickView : UIView

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (copy, nonatomic) CancelClickBlock cancelClickBlock;

+ (instancetype)loadNibCancelClickView;

@end
