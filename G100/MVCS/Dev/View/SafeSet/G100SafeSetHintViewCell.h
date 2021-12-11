//
//  G100SafeSetHintViewCell.h
//  G100
//
//  Created by 曹晓雨 on 2017/11/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DetailBtnClicked)();
@interface G100SafeSetHintViewCell : UITableViewCell
@property (nonatomic, copy) DetailBtnClicked detailBtnClicked;
@end
