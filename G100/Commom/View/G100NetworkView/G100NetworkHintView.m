//
//  G100NetworkHintView.m
//  G100
//
//  Created by 曹晓雨 on 2017/8/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100NetworkHintView.h"

@implementation G100NetworkHintView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color{
    self = [super init];
    if (self) {
        self.backgroundColor = color;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        label.text = title;
        label.backgroundColor = color;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
    
- (void)click {
    NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
        [[UIApplication sharedApplication] openURL:appSettings options:@{} completionHandler:nil];

    }else {
        [[UIApplication sharedApplication] openURL:appSettings];
    }
}
    
@end
