//
//  BikeQRCodeView.h
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

@interface BikeQRCodeView : G100PopBoxBaseView

+ (instancetype)loadViewFromNibWithTitle:(NSString *)title qrcode:(NSString *)qrcode;

@end
