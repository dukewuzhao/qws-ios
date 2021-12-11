//
//  G100BikeUserDisCell.h
//  G100
//
//  Created by yuhanle on 2017/6/3.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100UserDomain;
@interface G100BikeUserDisCell : UITableViewCell

- (void)setUserDomain:(G100UserDomain *)userDomain isYourself:(BOOL)yourself;

@end
