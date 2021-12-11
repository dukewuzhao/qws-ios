//
//  G100GarageBikeBottomView.h
//  G100
//
//  Created by yuhanle on 2017/3/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XXNibBridge/XXNibBridge.h>

@interface G100GarageBikeBottomView : UIView <XXNibBridge>

@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultConstraintW;

- (void)setResultWithResult:(NSString *)result unit:(NSString *)unit desc:(NSString *)desc;

@end
