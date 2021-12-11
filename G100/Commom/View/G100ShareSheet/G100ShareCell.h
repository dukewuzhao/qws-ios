//
//  G100ShareCell.h
//  G100ActionSheet
//
//  Created by yuhanle on 15/10/19.
//  Copyright © 2015年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kG100ShareCellHeight  120

@protocol G100ShareCellDelegate <NSObject>

@optional
- (void)selectedButton:(UIButton *)button tag:(NSInteger)tagNumber;

@end

@interface G100ShareCell : UITableViewCell

@property (nonatomic, weak) id<G100ShareCellDelegate> delegate;
@property (nonatomic, copy)   NSArray *models;

@property (nonatomic, retain) UIScrollView *scrollView;

@end
