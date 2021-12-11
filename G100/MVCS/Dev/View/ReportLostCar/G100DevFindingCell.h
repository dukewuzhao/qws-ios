//
//  G100DevFindingCell.h
//  G100
//
//  Created by William on 16/4/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100DevFindLostDomain;

extern NSString * const kNibNameDevFindingNormalCell;
extern NSString * const kNibNameDevFindingCustomCell;

@interface G100DevFindingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UIImageView *findingTypeImageView;

@property (strong, nonatomic) IBOutlet UILabel *findingDescLabel;

@property (strong, nonatomic) IBOutlet UIButton *delFindingBtn;

@property (strong, nonatomic) IBOutlet UIView *photoBackgroundView;

@property (strong, nonatomic) IBOutlet UICollectionView *photoCollectionView;

@property (nonatomic, copy) void (^deleteFindingRecordBlock)(NSInteger findlostid);

- (IBAction)deleteFindingRecord:(UIButton *)sender;

- (void)setCellDataWithModel:(G100DevFindLostDomain *)domain;

+ (CGFloat)heightForRow:(G100DevFindLostDomain *)domain;

+ (NSString *)identifierForRow:(G100DevFindLostDomain *)domain;

@end
