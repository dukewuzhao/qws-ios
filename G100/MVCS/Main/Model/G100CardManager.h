//
//  G100CardManager.h
//  G100
//
//  Created by yuhanle on 16/7/4.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class G100BikeDomain;
@class G100DeviceDomain;
@class G100InsuranceCardModel;
@class G100InsuranceBanner;
@interface G100CardModel : NSObject

@property (nonatomic, copy) NSString *devid;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) G100BikeDomain *bike;
@property (nonatomic, strong) G100DeviceDomain *device;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIViewController *ownerVc;
@property (nonatomic, strong) UIViewController *cardVc;
@property (nonatomic, assign) NSInteger orderIndex;
@property (strong, nonatomic) G100InsuranceCardModel *insuranceModel;
@property (strong, nonatomic) G100InsuranceBanner *banner;
@end

/**
 *  2.0 主页 卡片管理器
 */
@class G100BikeDomain;
@class G100InsuranceCardModel;
@interface G100CardManager : NSObject

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;

/**
 *  卡片管理器 属于的车辆模型
 */
@property (nonatomic, strong) G100BikeDomain *bike;
/**
 *  卡片管理器 属于的保险模型
 */
@property (strong, nonatomic) G100InsuranceCardModel *insurance;
/**
 *  卡片的个数 只读 通过设置bike 属性后才会有该值
 */
@property (nonatomic, assign, readonly) NSInteger numberOfRows;
/**
 *  卡片的数据源 只读 通过设置bike 属性
 */
@property (nonatomic, strong, readonly) NSArray *dataArray;
/**
 *  管理卡片的对应视图控制器
 */
@property (nonatomic, strong) NSMutableArray *cardViewControllersArray;

/**
 添加卡片

 @param cardVC    卡片控制器
 @param indexPath 索引
 */
- (void)addCardViewController:(UIViewController *)cardVC indexPath:(NSIndexPath *)indexPath;
/**
 清空卡片管理器中的所有卡片
 */
- (void)removeAllCardViewController;
/**
 *  通过该方法 返回一个卡片
 *
 *  @param item       item
 *  @param indexPath  索引
 *  @param identifier 标识符
 *
 *  @return 卡片控制器
 */
- (UIViewController *)cardViewControllerWithItem:(id)item indexPath:(NSIndexPath *)indexPath idetifier:(NSString *)identifier;
/**
 *  通过该方法 返回卡片的高度
 *
 *  @param item      item
 *  @param width     卡片宽度
 *  @param indexPath 索引
 *
 *  @return 卡片高度
 */
- (CGFloat)heightForCardViewWithItem:(id)item width:(CGFloat)width indexPath:(NSIndexPath *)indexPath;

@end
