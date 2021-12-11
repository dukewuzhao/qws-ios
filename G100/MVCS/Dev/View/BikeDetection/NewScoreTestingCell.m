//
//  ScoreTestingCell.m
//  G100
//
//  Created by Tilink on 15/3/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "NewScoreTestingCell.h"
#import "G100DevTestDomain.h"

@interface NewScoreTestingCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *OneSaveBtnLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TwoSaveBtnLeftConstraint;

@end

@implementation NewScoreTestingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.testStatusLabel.numberOfLines = 0;
    self.testTitleLabel.numberOfLines = 0;
    
    self.resultTitleLabel.numberOfLines = 0;
    
    [self setSelected:NO animated:NO];
    [self.setButton setExclusiveTouch:YES];
    
    [self.setButton setBackgroundImage:CreateImageWithColor([UIColor whiteColor]) forState:UIControlStateNormal];
    [self.setButton setBackgroundImage:CreateImageWithColor(MySelectedColor) forState:UIControlStateHighlighted];
    
    [self.IKnowButton setExclusiveTouch:YES];
    
    [self.IKnowButton setBackgroundImage:CreateImageWithColor([UIColor whiteColor]) forState:UIControlStateNormal];
    [self.IKnowButton setBackgroundImage:CreateImageWithColor(MySelectedColor) forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    // Configure the view for the selected state
    
}

- (void)showResultWithModel:(G100DevTestDomain *)model {
    NSMutableString * imageName = [[NSMutableString alloc]init];
    if (model.deduct == 0) {
        [imageName appendString:@"ic_scan_"];
    }else {
        [imageName appendString:@"ic_scan_n_"];
    }
    
    if (model.item) {
        [imageName appendString:model.item];
    }
    
    self.leftImageView.image = [UIImage imageNamed:imageName];
    
    self.testTitleLabel.text = model.description_pro;
    self.testStatusLabel.text = model.suggestions.description_pro;
    
    G100SecurityActionButtons *actionBtn1 = [model.suggestions.action_buttons safe_objectAtIndex:0];
    G100SecurityActionButtons *actionBtn2 = [model.suggestions.action_buttons safe_objectAtIndex:1];
    [self.IKnowButton setTitle:actionBtn1.text forState:UIControlStateNormal];
    [self.setButton setTitle:actionBtn2.text forState:UIControlStateNormal];
    
    if (model.suggestions.action_buttons.count == 2) {
        self.OneSaveBtnLeftConstraint.priority = 749;
        self.TwoSaveBtnLeftConstraint.priority = 750;
        self.setButton.hidden = NO;
    }else{
        self.OneSaveBtnLeftConstraint.priority = 750;
        self.TwoSaveBtnLeftConstraint.priority = 749;
        self.setButton.hidden = YES;
    }
}

- (void)showUIWithModel:(G100DevTestDomain *)model test:(BOOL)isTest {
    NSMutableString * imageName = [[NSMutableString alloc]init];
    if (model.deduct == 0) {
        [imageName appendString:@"ic_scan_"];
    }else {
        [imageName appendString:@"ic_scan_n_"];
    }
    
    if (model.item) {
        [imageName appendString:model.item];
    };
    
    self.resultLeftImage.image = [UIImage imageNamed:imageName];
    
    if (isTest) {
        self.testIndicator.hidden = NO;
        self.resultTitleLabel.text = model.checking_desc;
        [self.testIndicator startAnimating];
    }else {
        self.testIndicator.hidden = YES;
        self.resultTitleLabel.text = model.description_pro;
        [self.testIndicator stopAnimating];
        if (model.deduct == 0) {
            self.completeImageView.hidden = NO;
        }
    }
    
    G100SecurityActionButtons *actionBtn1 = [model.suggestions.action_buttons safe_objectAtIndex:0];
    G100SecurityActionButtons *actionBtn2 = [model.suggestions.action_buttons safe_objectAtIndex:1];
    [self.IKnowButton setTitle:actionBtn1.text forState:UIControlStateNormal];
    [self.setButton setTitle:actionBtn2.text forState:UIControlStateNormal];
    
    if (model.suggestions.action_buttons.count == 2) {
        self.OneSaveBtnLeftConstraint.priority = 749;
        self.TwoSaveBtnLeftConstraint.priority = 750;
        self.setButton.hidden = NO;
    }else {
        self.OneSaveBtnLeftConstraint.priority = 750;
        self.TwoSaveBtnLeftConstraint.priority = 749;
        self.setButton.hidden = YES;
    }
}

- (IBAction)setClickAction:(UIButton *)sender {
    if (sender.tag == 100) {
        if (_handleSetSoon) {
            self.handleSetSoon(1);
        }
    }else if (sender.tag == 200){
        if (_handleSetSoon) {
            self.handleSetSoon(2);
        }
    }
}

@end
