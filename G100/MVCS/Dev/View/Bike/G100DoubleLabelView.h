//
//  G100DoubleLabelView.h
//  G100
//
//  Created by yuhanle on 2016/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100DoubleLabelView : UIView

@property (nonatomic, assign) CGFloat mainFontSize;
@property (nonatomic, assign) CGFloat viceFontSize;

@property (nonatomic, copy) NSString *mainText;
@property (nonatomic, copy) NSString *viceText;

@property (nonatomic, assign) BOOL normalMainText;
@property (nonatomic, assign) BOOL leftTextAlignment;
@end
