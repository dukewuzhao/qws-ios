//
//  CustomMAAnnotationView.m
//  G100
//
//  Created by Tilink on 15/10/13.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100CustomShopAnnotationView.h"

@implementation G100CustomShopAnnotationView

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (self.calloutView == nil) {
            self.calloutView = [[G100ShopInfoPaoPaoView alloc] init];
            [self.calloutView showShopInfoViewWithDomain:_shopPlaceDomain];
            
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        
        [self addSubview:self.calloutView];
    }else {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

@end
