//
//  G100HoledView.m
//  HoledViewTest
//
//  Created by Colin on 15/4/7.
//  Copyright (c) 2015年 icephone. All rights reserved.
//

#import "G100HoledView.h"


#pragma mark - holes objects

@interface G100Hole : NSObject
@property (assign) G100HoleType holeType;
@end

@implementation G100Hole
@end

@interface G100CircleHole : G100Hole
@property (assign) CGPoint holeCenterPoint;
@property (assign) CGFloat holeDiameter;
@end

@implementation G100CircleHole
@end

@interface G100RectHole : G100Hole
@property (assign) CGRect holeRect;
@end

@implementation G100RectHole
@end

@interface G100RoundedRectHole : G100RectHole
@property (assign) CGFloat holeCornerRadius;
@end

@implementation G100RoundedRectHole
@end

@interface G100CustomRectHole : G100RectHole
@property (strong) UIView *customView;
@end

@implementation G100CustomRectHole
@end

@interface G100HoledView ()
@property (strong, nonatomic) NSMutableArray *holes;  //Array of G100Hole
@property (strong, nonatomic) NSMutableArray *focusView; // Array of focus
@end

@implementation G100HoledView

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _holes = [NSMutableArray new];
    _focusView = [NSMutableArray new];
    self.backgroundColor = [UIColor clearColor];
    _dimingColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetectedForGesture:)];
    [self addGestureRecognizer:tapGesture];
}


#pragma mark - UIView Overrides

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self)
    {
        for (UIView *focus in self.focusView) {
            if (CGRectContainsPoint(focus.frame, point))
            {
                return focus;
            }
        }
    }

    return hitView;
}


- (void)drawRect:(CGRect)rect
{
    [self removeCustomViews];
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return;
    }
    
    [self.dimingColor setFill];
    UIRectFill(rect);
    
    for (G100Hole* hole in self.holes) {
        
        [[UIColor clearColor] setFill];
        
        if (hole.holeType == G100HoleTypeRoundedRect) {
            G100RoundedRectHole *rectHole = (G100RoundedRectHole *)hole;
            CGRect frame = self.frame;
            frame.size.height += 100;
            // 保证最下方的提示框可以切掉圆角
            CGRect holeRectIntersection = CGRectIntersection( rectHole.holeRect, frame);
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:holeRectIntersection
                                                                  cornerRadius:rectHole.holeCornerRadius];
            
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor clearColor] CGColor]);
            CGContextAddPath(UIGraphicsGetCurrentContext(), bezierPath.CGPath);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
        } else if (hole.holeType == G100HoleTypeRect) {
            G100RectHole *rectHole = (G100RectHole *)hole;
            CGRect holeRectIntersection = CGRectIntersection( rectHole.holeRect, self.frame);
            UIRectFill( holeRectIntersection );
            
        } else if (hole.holeType == G100HoleTypeCirle) {
            G100CircleHole *circleHole = (G100CircleHole *)hole;
            CGRect rectInView = CGRectMake(floorf(circleHole.holeCenterPoint.x - circleHole.holeDiameter*0.5f),
                                           floorf(circleHole.holeCenterPoint.y - circleHole.holeDiameter*0.5f),
                                           circleHole.holeDiameter,
                                           circleHole.holeDiameter);
            CGContextSetFillColorWithColor( context, [UIColor clearColor].CGColor );
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextFillEllipseInRect( context, rectInView );
        }
    }
    
    [self addCustomViews];
}

#pragma mark - Add methods

- (NSInteger)addHoleCircleCenteredOnPosition:(CGPoint)centerPoint andDiameter:(CGFloat)diameter
{
    G100CircleHole *circleHole = [G100CircleHole new];
    circleHole.holeCenterPoint = centerPoint;
    circleHole.holeDiameter = diameter;
    circleHole.holeType = G100HoleTypeCirle;
    [self.holes addObject:circleHole];
    [self setNeedsDisplay];
    
    return [self.holes indexOfObject:circleHole];
}

- (NSInteger)addHoleRectOnRect:(CGRect)rect
{
    G100RectHole *rectHole = [G100RectHole new];
    rectHole.holeRect = rect;
    rectHole.holeType = G100HoleTypeRect;
    [self.holes addObject:rectHole];
    [self setNeedsDisplay];
    
    return [self.holes indexOfObject:rectHole];
}

- (NSInteger)addHoleRoundedRectOnRect:(CGRect)rect withCornerRadius:(CGFloat)cornerRadius
{
    G100RoundedRectHole *rectHole = [G100RoundedRectHole new];
    rectHole.holeRect = rect;
    rectHole.holeCornerRadius = cornerRadius;
    rectHole.holeType = G100HoleTypeRoundedRect;
    [self.holes addObject:rectHole];
    [self setNeedsDisplay];
    
    return [self.holes indexOfObject:rectHole];
}

- (NSInteger)addHCustomView:(UIView *)customView onRect:(CGRect)rect
{
    G100CustomRectHole *customHole = [G100CustomRectHole new];
    customHole.holeRect = rect;
    customHole.customView = customView;
    customHole.holeType = G100HoleTypeCustomRect;
    [self.holes addObject:customHole];
    [self setNeedsDisplay];
    
    return [self.holes indexOfObject:customHole];
}

- (void)addFocusView:(UIView *)focus
{
    [self.focusView addObject:focus];
}

- (void)removeHoles
{
    [self.holes removeAllObjects];
    [self removeCustomViews];
    [self setNeedsDisplay];
}

#pragma mark - Overided setter

- (void)setDimingColor:(UIColor *)dimingColor
{
    _dimingColor = dimingColor;
    [self setNeedsDisplay];
}

#pragma mark - Tap Gesture

- (void)tapGestureDetectedForGesture:(UITapGestureRecognizer *)gesture
{
    if ([self.holeViewDelegate respondsToSelector:@selector(holedView:didSelectHoleAtIndex:)]) {
        CGPoint touchLocation = [gesture locationInView:self];
        [self.holeViewDelegate holedView:self didSelectHoleAtIndex:[self holeViewIndexForAtPoint:touchLocation]];
    }
}

- (NSUInteger)holeViewIndexForAtPoint:(CGPoint)touchLocation
{
    __block NSUInteger idxToReturn = NSNotFound;
    [self.holes enumerateObjectsUsingBlock:^(G100Hole *hole, NSUInteger idx, BOOL *stop) {
        if (hole.holeType == G100HoleTypeRoundedRect ||
            hole.holeType == G100HoleTypeRect ||
            hole.holeType == G100HoleTypeCustomRect) {
            G100RectHole *rectHole = (G100RectHole *)hole;
            if (CGRectContainsPoint(rectHole.holeRect, touchLocation)) {
                idxToReturn = idx;
                *stop = YES;
            }
            
        } else if (hole.holeType == G100HoleTypeCirle) {
            G100CircleHole *circleHole = (G100CircleHole *)hole;
            CGRect rectInView = CGRectMake(floorf(circleHole.holeCenterPoint.x - circleHole.holeDiameter*0.5f),
                                           floorf(circleHole.holeCenterPoint.x - circleHole.holeDiameter*0.5f),
                                           circleHole.holeDiameter,
                                           circleHole.holeDiameter);
            if (CGRectContainsPoint(rectInView, touchLocation)) {
                idxToReturn = idx;
                *stop = YES;
            }
        }
    }];
    
    return idxToReturn;
}

#pragma mark - Custom Views

- (void)removeCustomViews
{
    [self.holes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[G100CustomRectHole class]]) {
            G100CustomRectHole *hole = (G100CustomRectHole *)obj;
            [hole.customView removeFromSuperview];
        }
    }];
}

- (void)addCustomViews
{
    [self.holes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[G100CustomRectHole class]]) {
            G100CustomRectHole *hole = (G100CustomRectHole *)obj;
            [hole.customView setFrame:hole.holeRect];
            [self addSubview:hole.customView];
        }
    }];
}

@end
