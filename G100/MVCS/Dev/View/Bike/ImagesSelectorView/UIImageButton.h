//
//  UIImageButton.h
//  G100
//
//  Created by yuhanle on 14-4-18.
//  Copyright (c) 2014年 tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageButton : UIImageView

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
