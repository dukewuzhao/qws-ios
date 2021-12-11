//
//  G100MsgAllSelDeleteView.h
//  G100
//
//  Created by yuhanle on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100MsgAllSelDeleteView;

@protocol G100MsgAllSelDeleteViewDelegate <NSObject>

- (void)msgAllSelDeleteViewWillAppear;
- (void)msgAllSelDeleteViewDidAppear;
- (void)msgAllSelDeleteViewWillDisAppear;
- (void)msgAllSelDeleteViewDidDisAppear;

- (void)msgAllSelDeleteView:(G100MsgAllSelDeleteView *)selDeleteView index:(NSInteger)index sender:(UIButton *)sender;

@end

@interface G100MsgAllSelDeleteView : UIView

@property (weak, nonatomic) id <G100MsgAllSelDeleteViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *allSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
- (IBAction)allSelectBtnClick:(UIButton *)sender;
- (IBAction)deleteBtnClick:(UIButton *)sender;

+ (instancetype)allSelDeleteView;

/**
 *  显示底部按钮
 */
- (void)showAllSelDeleteView;

/**
 *  隐藏底部按钮
 */
- (void)hideAllSelDeleteView;

/**
 *  控制全选状态
 */
- (void)allSelectStatus:(BOOL)status;

@end
