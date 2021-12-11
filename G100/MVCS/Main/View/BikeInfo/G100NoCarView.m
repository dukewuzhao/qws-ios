//
//  G100NoCarView.m
//  G100
//
//  Created by sunjingjing on 16/7/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100NoCarView.h"
#import "UIImage+JTSImageEffects.h"

@interface G100NoCarView ()

@end
@implementation G100NoCarView

- (void)awakeFromNib {
    [super awakeFromNib];
     _mapStaticView.image = [[UIImage imageNamed:@"icon_map_static"] JTS_applyDarkEffect];
}

+(instancetype)showView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100NoCarView" owner:nil options:nil] firstObject];
}


- (IBAction)buttonClickedToAddCar:(UIButton*)sender {

    if ([self.delegate respondsToSelector:@selector(buttonClickedToAddCar:)]) {
        [self.delegate buttonClickedToAddCar:sender];
    }
    
}
- (IBAction)viewTouchedToPushWithView:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(viewTouchedToPushWithView:)]) {
        [self.delegate viewTouchedToPushWithView:self];
    }
}

@end
