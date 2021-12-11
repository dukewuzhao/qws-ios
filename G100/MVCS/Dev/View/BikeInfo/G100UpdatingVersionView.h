//
//  G100UpdatingVersionView.h
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100UpdatingVersionView : UIView
@property (weak, nonatomic) IBOutlet UIView *progressBackView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *predictTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *reDetectionBtn;
@property (nonatomic, copy) void(^bottomBtnBlock)();
+ (instancetype)loadG100UpdatingVersionView;

/**
 显示升级提示文案
 
 @param hint 提示文案
 @param warnning 警示性/正常
 */
- (void)showUpdateHint:(NSString *)hint warnning:(BOOL)warnning;
@end
