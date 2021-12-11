//
//  G100AlertOtherClickView.h
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OtherClickBlock)();

@interface G100AlertOtherClickView : UIView

@property (strong, nonatomic) IBOutlet UIButton *otherButton;

@property (copy, nonatomic) OtherClickBlock otherClickBlock;

@end
