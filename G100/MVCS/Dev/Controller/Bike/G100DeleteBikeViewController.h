//
//  G100JiebangViewController.h
//  G100
//
//  Created by Tilink on 15/4/22.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@class G100BikeDomain;
@interface G100DeleteBikeViewController : G100BaseXibVC

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstLabelHeightContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondLabelHeightContraint;
@property (weak, nonatomic) IBOutlet UIImageView * bgImageView;
@property (weak, nonatomic) IBOutlet UILabel * label1;
@property (weak, nonatomic) IBOutlet UILabel * label2;
@property (weak, nonatomic) IBOutlet UILabel * label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UIButton * btn1;
@property (weak, nonatomic) IBOutlet UIButton * btn2;
@property (weak, nonatomic) IBOutlet UIButton * btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;
@property (weak, nonatomic) IBOutlet UIButton * surnBtn;
@property (weak, nonatomic) G100BikeDomain * bikeDomain;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;

- (IBAction)buttonEventClick:(UIButton *)sender;
- (IBAction)buttonSure:(UIButton *)sender;

@end
