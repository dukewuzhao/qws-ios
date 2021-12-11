//
//  G100TopInteractionHintView.h
//  CloseHintDemo
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  如下所示 有多条消息的时候 同时叠加
 *  XXXXXXXXXXXXXXXXXXX X
 *  XXXXXXXXXXXXXXXXXXX X
 *  XXXXXXXXXXXXXXXXXXX X
 *  XXXXXXXXXXXXXXXXXXX X
 */

typedef void(^G100InteractionDidSelected)();
typedef void(^G100InteractionClose)();

@interface G100TopInteractionHintView : UIView

@property (nonatomic, copy) G100InteractionDidSelected didSelectedHintBlock;
@property (nonatomic, copy) G100InteractionClose closeHintBlock;

@property (nonatomic, assign) CGFloat mws_height;

- (CGFloat)mws_heightForHint:(NSString *)hint;

- (void)mws_showHint:(NSString *)hint animated:(BOOL)animated complete:(void (^)())complete;
- (void)mws_dismissWithAnimated:(BOOL)animated;

@end