//
//  G100ThemeInfoDoamin.h
//  G100
//
//  Created by 温世波 on 15/12/8.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100ThemeInfoChannelInfo : G100BaseDomain
/** 渠道id，唯一表示符，8位字符串 */
@property (nonatomic, copy) NSString * channel;
/** 渠道名称，最长10位字符串 */
@property (nonatomic, copy) NSString * name;
/** 渠道slogan，最长20位字符串 */
@property (nonatomic, copy) NSString * slogan;
/** 渠道客服电话，最长20位字符串 */
@property (nonatomic, copy) NSString * servicenum;
/** 渠道网址,最长256位字符串 */
@property (nonatomic, copy) NSString * weburl;
/** 大logo网址，PNG格式，最长256位字符串，312px*264px，用于启动页显示 */
@property (nonatomic, copy) NSString * logo_big;
/** 中logo网址，PNG格式，最长256位字符串，270px*120px，用于首页显示 */
@property (nonatomic, copy) NSString * logo_mid;
/** 小logo网址，PNG格式，最长256位字符串，198px*54px，用于绑定页显示 */
@property (nonatomic, copy) NSString * logo_small;

@end

@interface G100ThemeInfoBikeModel : G100BaseDomain
/** 渠道id，表示归属的渠道 */
@property (nonatomic, copy) NSString * channel;
/** 车辆型号id */
@property (nonatomic, assign) NSInteger modelid;
/** 车型名称，最长10位字符串 */
@property (nonatomic, copy) NSString * model;
/** 车型图片，PNG格式，最长256位字符串，912x912，用于绑定界面等显示 */
@property (nonatomic, copy) NSString * pic_big;
/** 车型图片，PNG格式，最长256位字符串，252x252，用于车辆管理界面等显示 */
@property (nonatomic, copy) NSString * pic_small;

@end

@interface G100ThemeInfoDoamin : G100BaseDomain

/** 品牌 */
@property (nonatomic, strong) NSDictionary * channel_info;
/** 车型 */
@property (nonatomic, strong) NSArray * bike_info;

/** 品牌 */
@property (nonatomic, strong) G100ThemeInfoChannelInfo * theme_channel_info;
/** 车型 */
@property (nonatomic, strong) NSArray * theme_bike_model;

- (G100ThemeInfoBikeModel *)findThemeInfoBikeModelWithModelid:(NSInteger)modelid;

@end
