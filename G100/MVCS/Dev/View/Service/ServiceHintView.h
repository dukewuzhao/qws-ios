//
//  ServiceHintView.h
//  G100
//
//  Created by Tilink on 15/4/20.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

typedef void(^HintViewSureEvent)();

@interface ServiceHintView : G100PopBoxBaseView

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UIButton *iKnowButton;
@property (weak, nonatomic) IBOutlet UILabel * messageLabel;
- (IBAction)iKnowBtnEvent:(UIButton *)sender;

@property (copy, nonatomic) HintViewSureEvent sureEvent;

-(void)show;

@end
