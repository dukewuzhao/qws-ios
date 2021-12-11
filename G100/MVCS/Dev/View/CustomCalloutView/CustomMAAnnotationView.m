//
//  CustomMAAnnotationView.m
//  G100
//
//  Created by Tilink on 15/10/13.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "CustomMAAnnotationView.h"
#import "DevPositionPaoPaoView.h"
#import "UserPositionPaoPaoView.h"

@implementation CustomMAAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
       //† [self masterFlagView];
        self.isMainDevice = NO;
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (self.calloutView == nil && _positionDomain.topTitle.length) {
            if (self.positionDomain.devid.length) {
                self.calloutView = [DevPositionPaoPaoView loadXibView];
            }else {
                self.calloutView = [[UserPositionPaoPaoView alloc] init];
            }
            
            [self.calloutView showBusInfoViewWithDomain:_positionDomain];
            
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            [self addSubview:self.calloutView];
        }
    }else {
        [self.calloutView removeFromSuperview];
        self.calloutView = nil;
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

- (void)setPositionDomain:(PositionDomain *)positionDomain {
    _positionDomain = positionDomain;
    
    self.isMainDevice = positionDomain.isMainDevice;
    
    if (self.selected == NO) {
        return;
    }
    
    if (self.selected) {
        if ([self.calloutView superview]) {
            [self.calloutView showBusInfoViewWithDomain:_positionDomain];
            
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
    }else {
        [self.calloutView removeFromSuperview];
        self.calloutView = nil;
    }
}

- (UIImageView *)masterFlagView {
    if (!_masterFlagView) {
        _masterFlagView = [[UIImageView alloc] init];
        _masterFlagView.image = [UIImage imageNamed:@"ic_devindex_main"];
        
        [self addSubview:_masterFlagView];
    }
    return _masterFlagView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    /*
    _masterFlagView.frame = CGRectMake(0, -8, 14, 14);
    _masterFlagView.v_centerX = self.v_width/2.0;
    
    _masterFlagView.hidden = !_isMainDevice;*/
}

- (void)setIsMainDevice:(BOOL)isMainDevice {
    _isMainDevice = isMainDevice;
    
    [self layoutSubviews];
}

@end
