//
//  G100TrackFuncView.h
//  G100
//
//  Created by 曹晓雨 on 2017/8/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol G100TrackFuncViewDelegate<NSObject>
- (void)btnClickedWithTag:(NSInteger)tag;
@optional
- (void)speedBtnClicked:(int)speed;
@end
@interface G100TrackFuncView : UIView
@property (nonatomic, weak) id <G100TrackFuncViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *speeddBtn;
@property (weak, nonatomic) IBOutlet UIButton *mapTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *cureTypeBtn;
+ (instancetype)loadXibView;
@end
