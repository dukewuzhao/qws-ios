//
//  G100InsuranceOrderCell.h
//  G100
//
//  Created by yuhanle on 2017/8/7.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100InsuranceOrderCell;
@class G100InsuranceOrder;
@protocol G100InsuranceOrderCellDelegate <NSObject>

- (void)insuranceOrderCell:(G100InsuranceOrderCell *)orderCell insuranceOrder:(G100InsuranceOrder *)order;

@end

@interface G100InsuranceOrderCell : UITableViewCell

@property (strong, nonatomic) G100InsuranceOrder *insuranceOrder;
@property (weak, nonatomic) id <G100InsuranceOrderCellDelegate> delegate;

@end
