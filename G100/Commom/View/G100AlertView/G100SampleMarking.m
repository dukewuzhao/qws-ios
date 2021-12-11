//
//  G100SampleMarking.m
//  G100
//
//  Created by 温世波 on 15/10/28.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100SampleMarking.h"

@interface G100SampleMarking ()

@property (weak, nonatomic) IBOutlet UILabel * markingLabel;

@end

@implementation G100SampleMarking

+(instancetype)shareInstance {
    static G100SampleMarking * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[[NSBundle mainBundle]loadNibNamed:@"G100SampleMarking" owner:self options:nil]lastObject];
    });
    
    return instance;
}

-(void)addSampleMarkingView {
    self.frame = [UIScreen mainScreen].bounds;
    self.center = [[[[UIApplication sharedApplication] delegate] window] center];

    if (![self superview]) {
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    }
}

-(void)removeSampleMarkingView {
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

@end
