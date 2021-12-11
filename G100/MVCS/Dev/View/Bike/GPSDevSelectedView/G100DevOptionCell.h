//
//  G100DevOptionCell.h
//  G100
//
//  Created by yuhanle on 2016/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100DeviceDomain;
@class G100DevOptionCell;
@protocol G100DevOptionCellDelegate <NSObject>

@optional
- (void)G100DevOptionCell:(G100DevOptionCell *)optionCell device:(G100DeviceDomain *)device visibleState:(BOOL)visibleState;

- (BOOL)G100DevOptionCell:(G100DevOptionCell *)optionCell visibleDevice:(G100DeviceDomain *)device;

@end


@interface G100DevOptionCell : UITableViewCell

@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) G100DeviceDomain *device;
@property (nonatomic, weak) id <G100DevOptionCellDelegate> delegate;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL selectedStatus;

@end
