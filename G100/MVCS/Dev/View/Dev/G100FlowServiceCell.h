//
//  G100FlowServiceCell.h
//  G100
//
//  Created by yuhanle on 16/7/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateFunctionCustomView.h"

@class G100FlowServiceCell;
@protocol G100FlowServieCellDelegate <NSObject>

@optional

- (void)flowServieCellDidTapped:(G100FlowServiceCell *)viewCell indexPath:(NSIndexPath *)indexPath;

@end

@class G100RTCommandModel;
@interface G100FlowServiceCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger left_days;
/**
 *  流量服务 view
 */
@property (nonatomic, strong) StateFunctionCustomView *flowServiceView;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) G100RTCommandModel *rtCommand;
@property (nonatomic, weak) id <G100FlowServieCellDelegate> delegate;

@end
