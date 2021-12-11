//
//  ThirdAccountCell.h
//  G100
//
//  Created by Tilink on 15/6/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100TrAccountDomain;

@protocol G100TrAccountDomainDelegate <NSObject>

-(void)authorizeorCancelWithAccount:(G100TrAccountDomain *)domain On_off:(BOOL)isBind;

@end

@interface ThirdAccountCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel * accountLabel;
@property (strong, nonatomic) IBOutlet UISwitch * on_off;

@property (strong, nonatomic) G100TrAccountDomain * domain;
@property (weak, nonatomic) id <G100TrAccountDomainDelegate> delegate;
-(void)showCellWithDomain:(G100TrAccountDomain *)domain;

- (IBAction)switchOpenOff:(UISwitch *)sender;

@end
