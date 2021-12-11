//
//  ScoreTestingCell.h
//  G100
//
//  Created by Tilink on 15/3/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HandleSet)(NSInteger action);

@class G100DevTestDomain;

@interface NewScoreTestingCell : UITableViewCell

/** result */
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UILabel *testTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *testStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *IKnowButton;

@property (copy, nonatomic) HandleSet handleSetSoon;

- (void)showResultWithModel:(G100DevTestDomain *)model;

/** test */
@property (weak, nonatomic) IBOutlet UIImageView *resultLeftImage;
@property (weak, nonatomic) IBOutlet UILabel *resultTitleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *testIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *completeImageView;

- (void)showUIWithModel:(G100DevTestDomain *)model test:(BOOL)isTest;

@end
