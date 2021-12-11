//
//  ADPageModule.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "ADPageModule.h"
#import "UIImageView+WebCache.h"
#import "G100ThemeManager.h"
#import "LanuchShopAdditionView.h"
#import "G100StartPageManager.h"
#import "G100StartPageView.h"
#import "WSGuidePage.h"

@interface ADPageModule ()

@property (strong, nonatomic) G100StartPageView *adLunchImageView;
@property (strong, nonatomic) LanuchShopAdditionView *lanuchShopAdditionView;

@end

@implementation ADPageModule

- (G100StartPageView *)adLunchImageView {
    if (!_adLunchImageView) {
        _adLunchImageView = [G100StartPageView startPageView];
    }
    return _adLunchImageView;
}

+ (instancetype)pageModule {
    static ADPageModule *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[ADPageModule alloc] init];
    });
    return instance;
}

- (void)loadADPage {
    if ([G100StartPageView canShowStartPageView]) {
        // 存在启动页 则加载云端启动页
        __weak ADPageModule *wself = self;
        self.adLunchImageView.page = [[G100StartPageManager sharedInstance] loadStartPageDomain];
        _adLunchImageView.frame = [UIApplication sharedApplication].delegate.window.bounds;
        
        _adLunchImageView.completeBlock = ^(void (^callback)()){
            [wself removeAdImageView:callback];
        };
        _adLunchImageView.tappedBlock = ^(G100StartPageDomain * page){
            if (page.url.length) {
                if ([G100Router canOpenURL:page.url]) {
                    [G100Router openURL:page.url];
                }else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:page.url]];
                }
            }
        };
        
        [_adLunchImageView showInView:[UIApplication sharedApplication].delegate.window animated:YES];
    }else {
        // 云端启动页不存在则判断厂商主题
        [self showAdImageView];
    }
}

- (void)showAdImageView {
    CGSize viewSize = [UIApplication sharedApplication].delegate.window.bounds.size;
    NSString *viewOrientation = @"Portrait";
    NSString *launchImage = nil;
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    
    UIImageView *launchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
    launchView.frame = [UIApplication sharedApplication].delegate.window.bounds;
    launchView.userInteractionEnabled = YES;
    launchView.contentMode = UIViewContentModeScaleAspectFill;
    
    // 厂商定制logo添加
    BOOL isCustomLogo = NO;
    if (IsLogin()) {
        NSArray * devList = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:[[G100InfoHelper shareInstance] buserid]];
        NSMutableArray *allBikesArray = [NSMutableArray array];
        for (G100BikeDomain * bike in devList) {
            if ([bike isNormalBike]) {
                [allBikesArray addObject:bike];
            }
        }
        __block NSMutableArray *logoImagesArray = [NSMutableArray array];
        for (G100BikeDomain * bike in allBikesArray) {
            [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:bike.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
                if (success) {
                    // 判断地址是否nil    数组不能添加nil
                    if (theme.theme_channel_info.logo_big && ![logoImagesArray containsObject:theme.theme_channel_info.logo_big]) {
                        [logoImagesArray addObject:theme.theme_channel_info.logo_big];
                    }
                }
            }];
        }
        
        if (logoImagesArray.count != 0) {
            if (!_lanuchShopAdditionView) {
                _lanuchShopAdditionView = [[LanuchShopAdditionView alloc] initWithFrame:CGRectMake(0,
                                                                                                   [UIApplication sharedApplication].delegate.window.bounds.size.height / 2,
                                                                                                   [UIApplication sharedApplication].delegate.window.bounds.size.width,
                                                                                                   [UIApplication sharedApplication].delegate.window.bounds.size.height / 2)
                                                                       lanuchImageArray:logoImagesArray];
                [launchView addSubview:_lanuchShopAdditionView];
            }
            
            isCustomLogo = YES;
        }
    }
    
    [[UIApplication sharedApplication].delegate.window addSubview:launchView];
    
    if (IsLogin() && isCustomLogo) {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(logoDismissAnimate:) userInfo:@{@"kLogoImageView":launchView} repeats:NO];
    } else {
        if ([WSGuidePage hasGuidePageForShow]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowMainView object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowGuidePage object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowMainView object:nil];
        }
        
        [UIView animateWithDuration:1.0f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             launchView.alpha = 0.0f;
                             launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1);
                             [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                         }
                         completion:^(BOOL finished) {
                             [launchView removeFromSuperview];
                         }];
    }
}

- (void)logoDismissAnimate:(NSTimer*)timer {
    UIImageView *logoImageView = [timer.userInfo objectForKey:@"kLogoImageView"];
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         logoImageView.alpha = 0.0f;
                         logoImageView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1);
                         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                     }
                     completion:^(BOOL finished) {
                         [logoImageView removeFromSuperview];
                     }];
    [timer invalidate];
    timer = nil;
    
    if ([WSGuidePage hasGuidePageForShow]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowMainView object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowGuidePage object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowMainView object:nil];
    }
}

- (void)removeAdImageView:(void (^)())completeBlock {
    if ([WSGuidePage hasGuidePageForShow]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowMainView object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowGuidePage object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowMainView object:nil];
    }
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.adLunchImageView.alpha = 0.0f;
                         self.adLunchImageView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1);
                         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                     }
                     completion:^(BOOL finished) {
                         if (completeBlock) {
                             completeBlock();
                         }
                         [self.adLunchImageView removeFromSuperview];
                     }];
}

@end
