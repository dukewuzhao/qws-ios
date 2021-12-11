//
//  G100UpdateVersionCell.h
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100UpdateVersionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textView;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

+ (instancetype)loadXibView;

+ (void)registerNibCell:(UITableView *)tableView;

+ (CGFloat)heightForDesc:(NSString *)desc;
@end
