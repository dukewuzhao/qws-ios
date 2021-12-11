//
//  G100SearchView.h
//  G100
//
//  Created by 天奕 on 15/12/23.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100SearchView : UIView

@property (nonatomic, strong) UITextField *searchTextFiled;

@property (nonatomic, copy) void (^clickWithoutInput)();

@property (nonatomic, copy) void (^commitSearchContent)(NSString *commitStr);

@property (nonatomic, copy) void (^startEditing)();

@property (nonatomic, copy) void (^clearEditing)();

- (instancetype)initWithEnableClick:(BOOL)enable;

@end
