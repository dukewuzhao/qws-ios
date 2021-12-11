//
//  G100MyInsuraceCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MyInsuraceCell.h"
#import "G100InsuranceOrder.h"
#import "InsuranceCheckService.h"

@interface G100MyInsuraceCell ()

@property (weak, nonatomic) IBOutlet UILabel *lingquBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gurantedBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiredBadgeLabel;

@end

@implementation G100MyInsuraceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateStatusUI {
    NSInteger lingquCount = [InsuranceCheckService sharedService].lingquCount + [InsuranceCheckService sharedService].waitPayCount;
    NSInteger expiredCount = [InsuranceCheckService sharedService].expiredCount;
    
    self.lingquBadgeLabel.hidden = !lingquCount;
    self.expiredBadgeLabel.hidden = !expiredCount;
    
    self.lingquBadgeLabel.text = [NSString stringWithFormat:@"%@", @(lingquCount)];
    self.expiredBadgeLabel.text = [NSString stringWithFormat:@"%@", @(expiredCount)];
}

- (IBAction)brnClicked:(id)sender {
    UIButton *btn = sender;
    //tag is 1001 ~ 1003;
    self.insuranceStatebtnClickBlock(btn.tag);
}

@end
