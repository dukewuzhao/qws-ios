//
//  G100BikeInfoNavigationView.h
//  G100
//
//  Created by 曹晓雨 on 2017/6/2.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonTapAction)(NSInteger);

@class G100BikeDomain;
@interface G100BikeInfoNavigationView : UIView

@property (nonatomic, copy) NSString *navigationTitle;
@property (nonatomic, copy) ButtonTapAction tapAction;

@property (nonatomic, strong) G100BikeDomain *bikeDoamin;

+ (instancetype)loadXibView;

@end
