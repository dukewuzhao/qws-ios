//
//  G100PinView.h
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100PaopaoView.h"

@interface G100PinView : UIView

/**
 *  记录pin 的类型   如丢车位置、车辆位置、人的位置
 */
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString * image;

@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSString * content;

@property (nonatomic, strong) G100PaopaoView * calloutView;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

// 更改显示信息
- (void)setInfoWithTitle:(NSString *)title content:(NSString *)content;

@end
