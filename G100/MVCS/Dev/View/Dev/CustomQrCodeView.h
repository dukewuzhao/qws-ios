//
//  CustomQrCodeView.h
//  G100
//
//  Created by Tilink on 15/7/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

@interface CustomQrCodeView : G100PopBoxBaseView

@property (weak, nonatomic) IBOutlet UIView * boxView;
@property (weak, nonatomic) IBOutlet UIImageView * devImageView;
@property (weak, nonatomic) IBOutlet UIImageView * qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel * devNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *qrLabel;

/**
 显示设备二维码页面

 @param vc      展示的页面控制器
 @param view    展示的父视图
 @param image   展示的图片
 @param devName 展示的设备名称
 @param qrCode  展示的二维码信息
 @param other   其他消息
 */
-(void)showOpenQRCodeWithVc:(UIViewController *)vc
                       view:(UIView *)view
                      image:(UIImage *)image
                    devName:(NSString *)devName
                     qrCode:(NSString *)qrCode
                      other:(id)other;

/**
 显示设备二维码页面
 
 @param vc      展示的页面控制器
 @param view    展示的父视图
 @param image   展示的图片
 @param devName 展示的设备名称
 @param qrCode  展示的二维码信息
 @param qrNumber  二维码编号
 @param other   其他消息
 */
-(void)showOpenQRCodeWithVc:(UIViewController *)vc
                       view:(UIView *)view
                      image:(UIImage *)image
                    devName:(NSString *)devName
                     qrCode:(NSString *)qrCode
                   qrNumber:(NSString *)qrNumber
                      other:(id)other;
@end
