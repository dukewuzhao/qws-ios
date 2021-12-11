//
//  G100MenuPopView.h
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol G100MenuPopViewDelegate <NSObject>

@required
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath;

@end

typedef void(^DismissWithOperation)();

typedef NS_ENUM(NSUInteger, G100MenuPopViewDirection) {
    G100MenuPopViewDirectionLeft = 1,
    G100MenuPopViewDirectionRight
};

@interface G100MenuPopView : UIView

@property (nonatomic, weak) id<G100MenuPopViewDelegate> delegate;
@property (nonatomic, strong) DismissWithOperation dismissOperation;

/**
 *  初始化方法
 *
 *  @param dataArray 模型数组
 *  @param origin    弹出原点
 *  @param width     宽度
 *  @param height    高度
 *  @param direction 方向
 *
 *  @return MenuPopView
 */
- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(G100MenuPopViewDirection)direction;

/*弹出*/
- (void)pop;
/*消失*/
- (void)dismiss;

@end



@interface G100MenuPopModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end


