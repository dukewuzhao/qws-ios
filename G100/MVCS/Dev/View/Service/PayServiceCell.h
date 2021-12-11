//
//  PayServiceCell.h
//  G100
//
//  Created by Tilink on 15/3/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100OrderDomain;
@class G100GoodDomain;

@protocol OrderCellDelegate <NSObject>
@optional

- (void)handleCancelOrderWithIndexPath:(NSIndexPath*)indexPath;
- (void)handlePayOrderWithIndexPath:(NSIndexPath*)indexPath;

@end

@interface PayServiceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serLabel;
@property (weak, nonatomic) IBOutlet UILabel *masterLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *orderExtraView;
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *payOrderBtn;
@property (weak, nonatomic) IBOutlet UILabel *seperateLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic, weak) id<OrderCellDelegate> delegate;

-(void)showOrderUIWithModel:(G100OrderDomain *)model;

@end
