//
//  G100ImageMsgTableViewCell.h
//  G100
//
//  Created by William on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100MsgDomain;
@interface G100ImageMsgTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@property (strong, nonatomic) G100MsgDomain *domain;

@end
