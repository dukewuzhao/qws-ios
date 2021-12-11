//
//  G100TopInteractionBaseView.h
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100TopInteractionHintView.h"

/**
 *  用于承载hintView 以及对其管理
 *  XXXXXXXXXXXXXXXXXXX X -> G100TopInteractionHintView
 *  XXXXXXXXXXXXXXXXXXX X
 *  XXXXXXXXXXXXXXXXXXX X
 *  XXXXXXXXXXXXXXXXXXX X
 */

@interface G100TopInteractionBaseView : UIView

@property (nonatomic, assign) CGFloat mws_maxDisplayHeight;

- (void)mws_showHint:(NSString *)hint didSelected:(G100InteractionDidSelected)selectedBlock close:(G100InteractionClose)closeBlock animated:(BOOL)animated;
- (void)mws_dismissWithAnimated:(BOOL)animated;

@end
