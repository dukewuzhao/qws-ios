//
//  WSGuidePageView.m
//  G100
//
//  Created by 温世波 on 15/11/5.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "WSGuidePage.h"

@interface WSGuidePage ()

@property (nonatomic, strong) WSIntroductionViewController *guideViewController;

@end

@implementation WSGuidePage

+ (BOOL)hasGuidePageForShow {
    if ([[G100InfoHelper shareInstance] isFirstOpenFromNewAppVersion]) {
        return YES;
    }
    return NO;
}

- (WSIntroductionViewController *)showGuidePageViewOnViewController1:(UIViewController *)onViewController animated:(BOOL)animated {
    // Added Introduction View Controller
    NSArray *coverImageNames = @[@"p1", @"p2", @"p3", @"p4"];
    NSArray *backgroundImageNames = @[@"p1_bg", @"p2_bg", @"p3_bg", @"p4_bg"];
    
    // Example 2
    UIButton *enterButton = [UIButton new];
    enterButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [enterButton setTitleColor:[UIColor colorWithRed:75 / 255.0 green:70 / 255.0 blue:71 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [enterButton setTitle:@"立即体验" forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"button_down"] forState:UIControlStateHighlighted];
    
    self.guideViewController = [[WSIntroductionViewController alloc] initWithCoverImageNames:coverImageNames
                                                                        backgroundImageNames:backgroundImageNames
                                                                                      button:enterButton];
    
    // 设置索引图片
    [_guideViewController setImage:[UIImage imageNamed:@"index"] highlightedImage:[UIImage imageNamed:@"index_sel"] dotRadius:6.0f];
    
    if (onViewController) {
        [onViewController presentViewController:_guideViewController animated:YES completion:nil];
    }
    
    __weak WSIntroductionViewController * weakIntroductionView = self.guideViewController;
    self.guideViewController.didSelectedEnter = ^() {
        [G100InfoHelper shareInstance].oldAppVersion = [G100InfoHelper shareInstance].appVersion;
        [weakIntroductionView dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    return self.guideViewController;
}

- (WSIntroductionViewController *)showGuidePageViewOnViewController2:(UIViewController *)onViewController animated:(BOOL)animated {
    NSArray *coverImageNames = nil;
    
    if (ISIPHONE_4) coverImageNames = @[@"two_p_ip4_1", @"two_p_ip4_2", @"two_p_ip4_3"];
    else coverImageNames = @[@"two_p_1", @"two_p_2", @"two_p_3"];
    
    UIButton *enterButton = [UIButton new];
    self.guideViewController = [[WSIntroductionViewController alloc] initWithCoverImageNames:coverImageNames
                                                                        backgroundImageNames:nil
                                                                                      button:enterButton];
    [self.guideViewController setIndexImageNames:@[@"two_index_1", @"two_index_2", @""]];
    
    if (onViewController) {
        [onViewController presentViewController:_guideViewController animated:YES completion:nil];
    }
    
    __weak WSIntroductionViewController * weakIntroductionView = self.guideViewController;
    self.guideViewController.didSelectedEnter = ^() {
        [G100InfoHelper shareInstance].oldAppVersion = [G100InfoHelper shareInstance].appVersion;
        [weakIntroductionView dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    
    return self.guideViewController;
}

- (WSIntroductionViewController *)showGuidePageViewOnViewController:(UIViewController *)onViewController animated:(BOOL)animated {
    NSArray *coverImageNames = @[@"newguide_page1", @"newguide_page2", @"newguide_page3", @"newguide_page4"];
    NSArray *backImageNames = @[@"newguide_BG",@"newguide_BG",@"newguide_BG",@"newguide_BG"];
    // Example 2
    UIButton *enterButton = [UIButton new];
    enterButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [enterButton setTitle:@"立即体验" forState:UIControlStateNormal];
    [enterButton setTitleColor:[UIColor colorWithRed:0.13 green:0.80 blue:0.84 alpha:1.00] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"newguideBtn-bg"] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"newguideBtn-bg"] forState:UIControlStateHighlighted];
    
    self.guideViewController = [[WSIntroductionViewController alloc] initWithCoverImageNames:coverImageNames
                                                                        backgroundImageNames:backImageNames
                                                                                      button:enterButton];
    
    // 设置索引图片
    [_guideViewController setImage:[UIImage imageNamed:@"no-select"] highlightedImage:[UIImage imageNamed:@"select"] dotRadius:6.0f];
    
    if (onViewController) {
        [onViewController presentViewController:_guideViewController animated:YES completion:nil];
    }
    
    __weak WSIntroductionViewController * weakIntroductionView = self.guideViewController;
    self.guideViewController.didSelectedEnter = ^() {
        [G100InfoHelper shareInstance].oldAppVersion = [G100InfoHelper shareInstance].appVersion;
        [weakIntroductionView dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    
    return self.guideViewController;
}
- (WSIntroductionViewController *)showGuidePageViewOnViewController:(UIViewController *)onViewController animated:(BOOL)animated immediatly:(BOOL)immediatly {
    if (immediatly) {
        return [self showGuidePageViewOnViewController:onViewController animated:animated];
    }else {
        if ([[G100InfoHelper shareInstance] isFirstOpenFromNewAppVersion]) {
            return [self showGuidePageViewOnViewController:onViewController animated:animated];
        }else {
            [G100InfoHelper shareInstance].oldAppVersion = [G100InfoHelper shareInstance].appVersion;
        }
    }
    
    return nil;
}

-(void)hideGuidePageView:(BOOL)animated {
    [self.guideViewController dismissViewControllerAnimated:animated completion:nil];
}

@end
