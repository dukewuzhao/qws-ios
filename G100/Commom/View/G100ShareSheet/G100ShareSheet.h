//
//  G100ShareSheet.h
//  G100ActionSheet
//
//  Created by yuhanle on 15/10/19.
//  Copyright © 2015年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100ShareModel.h"

@interface G100ShareSheet : UIView


- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)addShareModel:(G100ShareModel *)shareModel;

- (void)show;

@end

