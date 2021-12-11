//
//  G100BikeReportView.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeReportView.h"

@implementation G100BikeReportView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BikeReportView" owner:nil options:nil] firstObject];
}

+ (float)heightWithWidth:(float)width{
    return width * 30/197;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}
- (void)setUnreadMsgCount:(NSInteger)unreadMsgCount {
    _unreadMsgCount = unreadMsgCount;
    
    if (unreadMsgCount) {
        self.bikeReportInfo.hidden = NO;
        self.bikeReportInfo.text = [NSString stringWithFormat:@"您有%@条未读报告", @(unreadMsgCount)];
    }else {
        self.bikeReportInfo.hidden = YES;
    }
}

- (IBAction)viewTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushCardReportDetailWithView:)]) {
        [self.delegate viewTapToPushCardReportDetailWithView:self];
    }
}
@end
