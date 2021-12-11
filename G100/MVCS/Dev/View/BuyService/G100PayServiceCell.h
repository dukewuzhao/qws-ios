//
//  G100PayServiceCell.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
@class G100GoodDomain;

@interface G100PayServiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeForService;
@property (weak, nonatomic) IBOutlet UILabel *masterLabel;
@property (weak, nonatomic) IBOutlet UILabel *serLabel;

-(void)showUIWithModel:(G100GoodDomain *)model;
@end
