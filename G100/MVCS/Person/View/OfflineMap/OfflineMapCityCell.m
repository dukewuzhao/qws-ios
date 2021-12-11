//
//  OfflineMapCityCell.m
//  G100
//
//  Created by Tilink on 15/5/15.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "OfflineMapCityCell.h"

@implementation OfflineMapCityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showYixiazaiCityWithItem:(MAOfflineItem *)item {
    self.cityLabel.text = item.name;
    self.sItem = item;
    
    self.statusLabel.hidden = YES;
    
    if (item.itemStatus == MAOfflineItemStatusExpired) {
        self.updateButton.hidden = NO;
        self.seperaterLine.hidden = NO;
    }else {
        self.updateButton.hidden = YES;
        self.seperaterLine.hidden = YES;
    }    
}

- (IBAction)buttonClickEvent:(UIButton *)sender {
    
    ButtonStyle buttonStyle = -1;
    if (sender.tag == 101) {
        buttonStyle = DeleteCityMap;
    }else if (sender.tag == 102) {
        buttonStyle = UpdateCityMap;
    }
    
    if ([_delegate respondsToSelector:@selector(buttonClickEventForAMapDelegate:indexPath:buttonStyle:)]) {
        [self.delegate buttonClickEventForAMapDelegate:_sItem indexPath:_indexPath buttonStyle:buttonStyle];
    }
}

#pragma mark 包大小转换工具类（将包大小转换成合适单位）
-(NSString *)getDataSizeString:(int) nSize
{
    NSString *string = nil;
    if (nSize<1024)
    {
        string = [NSString stringWithFormat:@"%dB", nSize];
    }
    else if (nSize<1048576)
    {
        string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
    }
    else if (nSize<1073741824)
    {
        if ((nSize%1048576)== 0 )
        {
            string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
        else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
    }
    else	// >1G
    {
        string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
    }
    
    return string;
}

@end
