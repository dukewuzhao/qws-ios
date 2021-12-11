
//
//  OfflineMapCityCell.h
//  G100
//
//  Created by Tilink on 15/5/15.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

typedef enum : NSUInteger {
    UpdateCityMap = 0,
    DeleteCityMap
} ButtonStyle;

@protocol OfflineMapCityCellDelegate <NSObject>

@optional

-(void)buttonClickEventForAMapDelegate:(MAOfflineItem *)oneCity indexPath:(NSIndexPath *)indexPath buttonStyle:(ButtonStyle)buttonStyle;

@end

@interface OfflineMapCityCell : UITableViewCell

@property (weak, nonatomic) id <OfflineMapCityCellDelegate> delegate;
@property (strong, nonatomic) MAOfflineItem * sItem;
@property (strong, nonatomic) NSIndexPath * indexPath;
@property (weak, nonatomic) IBOutlet UIButton * deleteButton;
@property (weak, nonatomic) IBOutlet UIButton * updateButton;
@property (weak, nonatomic) IBOutlet UILabel * seperaterLine;
@property (weak, nonatomic) IBOutlet UILabel * cityLabel;
@property (weak, nonatomic) IBOutlet UILabel * sizeLabel;

@property (weak, nonatomic) IBOutlet UIButton * statusButton;
@property (weak, nonatomic) IBOutlet UILabel * statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView * xiazaiProgress;

-(void)showYixiazaiCityWithItem:(MAOfflineItem *)item;

- (IBAction)buttonClickEvent:(UIButton *)sender;

@end
