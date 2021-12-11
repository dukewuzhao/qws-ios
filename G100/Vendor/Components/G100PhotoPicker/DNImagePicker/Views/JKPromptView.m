//
//  JKPromptView.m
//  JKImagePicker
//
//  Created by Jecky on 15/1/12.
//  Copyright (c) 2015年 Jecky. All rights reserved.
//

#import "JKPromptView.h"
#import "UIView+DNImagePicker.h"

static JKPromptView *instancePrompt;

@implementation JKPromptView

- (instancetype)initWithImageName:(NSString*)imageName message:(NSString *)string
{
    self = [super init];
    if (self) {
        self.hidden = NO;
        self.alpha = 1.0f;
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        
        self.backgroundColor = [UIColor colorWithRed:0x17/255.0f green:0x17/255.0 blue:0x17/255.0 alpha:0.9];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4;
        
        UIImage *img = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.text = string;
        [label sizeToFit];
        [self addSubview:label];
        
        if (imageView.dn_width<label.dn_width) {
            self.dn_width = label.dn_width + 20;
        }else{
            self.dn_width = imageView.dn_width + 20;
        }
        
        if (img) {
            self.dn_height = label.dn_height +imageView.dn_height+ 40;
        }else{
            self.dn_height = label.dn_height+ 20;
        }
        self.dn_left = ([UIScreen mainScreen].bounds.size.width - self.dn_width)/2;
        self.dn_top = ([UIScreen mainScreen].bounds.size.height - self.dn_height)/2;
        
        if (img) {
            imageView.dn_centerX = self.dn_width/2;
            imageView.dn_top = 15;
            label.dn_centerX = self.dn_width/2;
            label.dn_top = imageView.dn_bottom+10;
        }else{
            label.dn_centerX = self.dn_width/2;
            label.dn_top = 10;
        }
    }
    return self;
}

+ (void)showWithImageName:(NSString*)imageName message:(NSString *)string;
{
    instancePrompt = [[JKPromptView alloc] initWithImageName:imageName message:string];
    instancePrompt.alpha = 0;
    [UIView animateWithDuration:.3 animations:^{
        instancePrompt.alpha = 1;
    }];
    [instancePrompt performSelector:@selector(animationHide) withObject:nil afterDelay:2];
}

- (void)animationHide {
    [UIView animateWithDuration:.3 animations:^{
        instancePrompt.alpha = 0;
    } completion:^(BOOL finished) {
        instancePrompt = nil;
    }];
}

@end
