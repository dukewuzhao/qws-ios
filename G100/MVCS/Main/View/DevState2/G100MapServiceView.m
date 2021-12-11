//
//  G100MapServiceView.m
//  G100
//
//  Created by sunjingjing on 17/2/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100MapServiceView.h"

@implementation G100MapServiceView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100MapServiceView" owner:nil options:nil] firstObject];
}

+ (float)heightWithWidth:(float)width{
    return width * 30/207;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (IBAction)buttonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mapServiceView:buttonClicked:)]) {
        [self.delegate mapServiceView:self buttonClicked:sender];
    }
}
- (IBAction)viewTaped:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(mapServiceView:viewTaped:)]) {
        [self.delegate mapServiceView:self viewTaped:sender.view];
    }
}

@end
