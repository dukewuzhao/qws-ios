//
//  G100UMShareHelper.m
//  G100
//
//  Created by yuhanle on 16/1/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UMSocialHelper.h"
#import "G100UserApi.h"
#import <UMShare/UMShare.h>
#import "ExtString.h"
#import "G100ShareSheet.h"
#import <SDWebImage/SDWebImageManager.h>
#import "G100UMSocialConfig.h"
//#import <UMCommon/UMConfigure.h>
@implementation UMShareModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"shareto" : @"shareto",
             @"shareTopic" : @"topic",
             @"shareTitle" : @"title",
             @"shareText" : @"content",
             @"shareAtUser" : @"at",
             @"sharePicUrl" : @"icon",
             @"shareJumpUrl" : @"url"
             };
}

@end

@interface G100UMSocialHelper ()

@property (nonatomic, copy) void (^shareSelected)(NSInteger shareto);
@property (nonatomic, copy) void (^shareComplete)(NSInteger shareto, BOOL success);
@property (nonatomic, strong) UIViewController *shareOnViewController;
/** 存储分享到各个平台的分享内容 从服务器根据shareid 获取*/
@property (nonatomic, strong) NSMutableDictionary *shareContentMap;

@end

@implementation G100UMSocialHelper

+ (instancetype)shareInstance {
    static dispatch_once_t onceTonken;
    static G100UMSocialHelper * shareInstance = nil;
    dispatch_once(&onceTonken, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

+ (void)socialConfiguration {
    // 设置友盟key
    //[[UMSocialManager defaultManager] setUmSocialAppkey:UmengKey];
    //[UMConfigure initWithAppkey:UmengKey channel:ISProduct ? @"APPS_A001" : @"BETA_A001"];
#if DEBUG
    [[UMSocialManager defaultManager] openLog:YES];
#elif ADHOC
    [[UMSocialManager defaultManager] openLog:YES];
#endif
    
    // 新浪微博 密钥：0c6cd5b2267f648466ff2e598e89a37b
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina
                                          appKey:@"3763600640"
                                       appSecret:@"0c6cd5b2267f648466ff2e598e89a37b"
                                     redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    
    // QQ
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ
                                          appKey:@"1104588523"
                                       appSecret:@"9Isey2PGelWGsYgN"
                                     redirectURL:@"https://www.qiweishi.com"];
    
    // 微信
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:@"wxfca35ef3c2669919"
                                       appSecret:@"8864a61a978381b7a7a037b2c48a2847"
                                     redirectURL:@"https://www.qiweishi.com"];
    
    // 设置分享的客户端
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_WechatFavorite];
}

+ (void)didFinishGetUMSocialDataWithResponse:(UMSocialShareResponse *)response eventid:(NSInteger)eventid {
    
    NSInteger shareto = 1;
    UMSocialPlatformType platform = response.platformType;
    if (platform == UMSocialPlatformType_WechatSession) {
        // 分享到微信会话回调
        shareto = 1;
    }else if (platform == UMSocialPlatformType_WechatTimeLine) {
        // 分享到微信朋友圈回调
        shareto = 2;
    }else if (platform == UMSocialPlatformType_QQ) {
        // 分享到QQ回调
        shareto = 3;
    }else if (platform == UMSocialPlatformType_Qzone) {
        // 分享到QQ空间回调
        shareto = 4;
    }else if (platform == UMSocialPlatformType_Sina) {
        // 分享到新浪微博回调
        shareto = 5;
    }
    
    BOOL result = 0;
    if (response) {
        result = 1;
    }
    
    if (result) {
        [[G100UserApi sharedInstance] uploadSocialShareResultWithEventid:eventid
                                                                 shareto:shareto
                                                                  result:result
                                                                callback:nil];
    }
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [[UMSocialManager defaultManager] handleOpenURL:url];
}

#pragma mark - 显示分享页面
- (void)showShareWithData:(G100ShareDomain *)domain {
    self.shareOnViewController = CURRENTVIEWCONTROLLER;
    
    //设置分享内容，和回调对象
    __block NSString *kDefaultShareTopic = @"骑卫士";
    __block NSString *kDefaultShareTitle = @"骑卫士";
    __block NSString *kDefaultShareContent = @"我是骑卫士...";
    
    NSString * tmpShareTopic   = domain.shareTopic;
    NSString * tmpShareTitle   = domain.shareTitle;
    NSString * tmpShareContent = domain.shareText;
    NSString * tmpShareAtUser  = domain.shareAtUser;
    NSString * tmpShareJumpUrl = domain.shareJumpUrl;
    NSString * tmpSharePicUrl  = domain.sharePicUrl;
    
    __block NSString *kShareTopic   = tmpShareTopic ? : kDefaultShareTopic;
    __block NSString *kShareTitle   = tmpShareTitle ? : kDefaultShareTitle;
    __block NSString *kShareContent = tmpShareContent ? : kDefaultShareContent;
    __block NSString *kShareAtUser  = tmpShareAtUser ? : @"";
    __block NSString *kShareJumpUrl = tmpShareJumpUrl ? : @"https://www.qiweishi.com/";
    __block NSString *kSharePicUrl  = tmpSharePicUrl;
    
    __block UIImage *shareImage = nil;
    if (domain.shareImage) {
        if ([domain.shareImage isKindOfClass:[NSString class]]) {
            if (((NSString *)domain.shareImage).length)
                shareImage = [UIImage imageNamed:domain.shareImage];
            else
                shareImage = [UIImage imageNamed:@"share_thumicon_for_wx_l"];
        }else if ([domain.shareImage isKindOfClass:[UIImage class]]) {
            shareImage = domain.shareImage;
        }else if ([domain.shareImage isKindOfClass:[NSData class]]) {
            shareImage = [UIImage imageWithData:domain.shareImage];
        }
    }
    if (kSharePicUrl.length) {
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:kSharePicUrl]]) {
            shareImage = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:kSharePicUrl];
        }
        
        if (nil == shareImage) {
            if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:kSharePicUrl]]) {
                shareImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:kSharePicUrl];
            }else {
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:kSharePicUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (finished) shareImage = image;
                }];
            }
        }
    }
    
    G100ShareSheet *shareSheet = [[G100ShareSheet alloc] initWithTitle:nil cancelButtonTitle:nil];
    for (NSNumber *pft in [[UMSocialManager defaultManager] platformTypeArray]) {
        NSString *snsName = [UMSocialPlatformConfig platformNameWithPlatformType:[pft integerValue]];
        
        G100ShareModel *shareModel = [G100ShareModel shareModelWithSnsPlatform:snsName handler:^(G100ShareModel *shareModel) {
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            NSDictionary * dict = [kShareJumpUrl paramsFromURL];
            NSDictionary * params = [dict objectForKey:@"PARAMS"];
            NSInteger eventid = [params[@"eventid"] integerValue];
            [G100UMSocialHelper shareInstance].eventid = eventid;
            
            if ([snsName isEqualToString:G100UMShareToSina]) {
                // 新浪微博
                messageObject.text = [NSString stringWithFormat:@"%@ %@ (来自@骑卫士 %@ )", [NSString stringWithFormat:@"%@%@", kShareTopic, kShareContent], kShareAtUser, !kShareJumpUrl.length ? @"" : [NSString stringWithFormat:@"%@&shareto=5", kShareJumpUrl]];
                
                if (shareImage) {
                    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
                    shareObject.thumbImage = shareImage;
                    shareObject.shareImage = shareImage;
                    
                    messageObject.shareObject = shareObject;
                }
            } else if ([snsName isEqualToString:G100UMShareToWechatSession]) {
                // 微信会话
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=1", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }else if ([snsName isEqualToString:G100UMShareToWechatTimeline]) {
                // 微信朋友圈
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=2", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }else if ([snsName isEqualToString:G100UMShareToQQ]) {
                // QQ
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=3", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }else if ([snsName isEqualToString:G100UMShareToQzone]) {
                // QQ空间
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=4", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }
            
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:[pft integerValue] messageObject:messageObject currentViewController:self.shareOnViewController completion:^(id data, NSError *error) {
                if (error) {
                    UMSocialLogInfo(@"************Share fail with error %@*********",error);
                }else{
                    if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                        UMSocialShareResponse *resp = data;
                        [G100UMSocialHelper didFinishGetUMSocialDataWithResponse:resp eventid:eventid];
                    }else{
                        UMSocialLogInfo(@"response data is %@",data);
                    }
                }
            }];
            
            NSInteger shareto = 1;
            if ([snsName isEqualToString:G100UMShareToWechatSession]) {
                shareto = 1;
            }else if ([snsName isEqualToString:G100UMShareToWechatTimeline]) {
                shareto = 2;
            }else if ([snsName isEqualToString:G100UMShareToQQ]) {
                shareto = 3;
            }else if ([snsName isEqualToString:G100UMShareToQzone]) {
                shareto = 4;
            }else if ([snsName isEqualToString:G100UMShareToSina]) {
                shareto = 5;
            }
            
            if (_shareSelected) {
                self.shareSelected(shareto);
            }
        }];
        
        if (domain) {
            shareModel.enable = YES;
        }else {
            shareModel.enable = NO;
        }
        [shareSheet addShareModel:shareModel];
    }
    
    [shareSheet show];
}

- (void)loadShareWithShareid:(NSInteger)shareid complete:(void (^)(NSDictionary *dict, BOOL isSuccess))complete {
    [self loadShareWithShareid:shareid shareUrl:nil complete:complete];
}

- (void)loadShareWithShareid:(NSInteger)shareid shareUrl:(NSString *)shareUrl complete:(void (^)(NSDictionary *dict, BOOL isSuccess))complete {
    [self loadShareWithShareid:shareid shareUrl:nil sharePic:nil complete:complete];
}

- (void)loadShareWithShareid:(NSInteger)shareid shareUrl:(NSString *)shareUrl sharePic:(id)sharePic complete:(void (^)(NSDictionary *dict, BOOL isSuccess))complete {
    __weak G100UMSocialHelper *wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [wself.shareContentMap removeObjectForKey:@(shareid)];
            NSArray *data = response.data[@"share"];
            NSMutableDictionary *idShareDict = [[NSMutableDictionary alloc] init];
            for (NSDictionary *dict in data) {
                UMShareModel *umShareModel = [[UMShareModel alloc] initWithDictionary:dict];
                if (umShareModel) {
                    NSString *snsName = G100UMShareToSina;
                    if (umShareModel.shareto == 1) {
                        snsName = G100UMShareToWechatSession;
                    }else if (umShareModel.shareto == 2) {
                        snsName = G100UMShareToWechatTimeline;
                    }else if (umShareModel.shareto == 3) {
                        snsName = G100UMShareToQQ;
                    }else if (umShareModel.shareto == 4) {
                        snsName = G100UMShareToQzone;
                    }else if (umShareModel.shareto == 5) {
                        snsName = G100UMShareToSina;
                    }
                    if (shareUrl && shareUrl.length) {
                        umShareModel.shareJumpUrl = shareUrl;
                    }
                    if (sharePic) {
                        if ([sharePic isKindOfClass:[NSString class]]) {
                            // url
                            umShareModel.sharePicUrl = sharePic;
                        }else {
                            umShareModel.shareImage = sharePic;
                        }
                    }
                    
                    if (umShareModel.sharePicUrl && umShareModel.sharePicUrl.length) {
                        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:umShareModel.sharePicUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (finished) umShareModel.shareImage = image;
                        }];
                    }
                    [idShareDict setObject:umShareModel forKey:snsName];
                }
            }
            if (idShareDict)
                [wself.shareContentMap setObject:idShareDict forKey:@(shareid)];
            
            if (complete) {
                complete(idShareDict, YES);
            }
        }else {
            if (complete) {
                complete(nil, NO);
            }
        }
    };
    [[G100UserApi sharedInstance] getShareWithShareid:shareid callback:callback];
}

- (void)showShareWithShareid:(NSInteger)shareid {
    [self showShareWithShareid:shareid onViewController:CURRENTVIEWCONTROLLER complete:nil];
}

- (void)showShareWithShareid:(NSInteger)shareid onViewController:(UIViewController *)onViewController complete:(void (^)(NSInteger shareto, BOOL success))complete {
    [self showShareWithShareid:shareid onViewController:onViewController selected:nil complete:complete];
}

- (void)showShareWithShareid:(NSInteger)shareid onViewController:(UIViewController *)onViewController selected:(void (^)(NSInteger shareto))selected complete:(void (^)(NSInteger shareto, BOOL success))complete {
    if (shareid == 0) {
        return;
    }
    self.shareOnViewController = onViewController;
    self.shareSelected = selected;
    self.shareComplete = complete;
    
    NSDictionary *dict = [self.shareContentMap objectForKey:@(shareid)];
    if (dict) {
        // 取出字典调用分享控件
        [self showShareSheetWithDict:dict];
    }else {
        [self.shareOnViewController showHudInView:self.shareOnViewController.view hint:nil];
        
        __weak UIViewController *baseVC = self.shareOnViewController;
        [self loadShareWithShareid:shareid complete:^(NSDictionary *dict, BOOL isSuccess){
            [baseVC hideHud];
            // 取出字典调用分享控件
            if (isSuccess && dict) {
                [self showShareSheetWithDict:dict];
            }else {
                [baseVC showHint:@"请稍后重试"];
            }
        }];
    }
}

- (void)showShareWithShareJSONStr:(NSString *)shareJSONStr onViewController:(UIViewController *)onViewController selected:(void (^)(NSInteger shareto))selected complete:(void (^)(NSInteger shareto, BOOL success))complete {
    if (!shareJSONStr || !shareJSONStr.length) {
        return;
    }
    
    self.shareOnViewController = onViewController;
    self.shareSelected = selected;
    self.shareComplete = complete;
    
    NSData *jsonData = [shareJSONStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@", err);
    }else {
        NSMutableDictionary *idShareDict = [[NSMutableDictionary alloc] init];
        for (NSDictionary *dict in result) {
            UMShareModel *umShareModel = [[UMShareModel alloc] initWithDictionary:dict];
            if (umShareModel) {
                NSString *snsName = G100UMShareToSina;
                if (umShareModel.shareto == 1) {
                    snsName = G100UMShareToWechatSession;
                }else if (umShareModel.shareto == 2) {
                    snsName = G100UMShareToWechatTimeline;
                }else if (umShareModel.shareto == 3) {
                    snsName = G100UMShareToQQ;
                }else if (umShareModel.shareto == 4) {
                    snsName = G100UMShareToQzone;
                }else if (umShareModel.shareto == 5) {
                    snsName = G100UMShareToSina;
                }
                
                if (umShareModel.sharePicUrl && umShareModel.sharePicUrl.length) {
                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:umShareModel.sharePicUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        if (finished) umShareModel.shareImage = image;
                    }];
                }
                [idShareDict setObject:umShareModel forKey:snsName];
            }
        }
        if ([idShareDict count]) {
            [self showShareSheetWithDict:idShareDict];
        }
    }
}

- (void)showShareSheetWithDict:(NSDictionary *)dict {
    
    G100ShareSheet *shareSheet = [[G100ShareSheet alloc] initWithTitle:nil cancelButtonTitle:nil];
    for (NSNumber *pft in [[UMSocialManager defaultManager] platformTypeArray]) {
        NSString *snsName = [UMSocialPlatformConfig platformNameWithPlatformType:[pft integerValue]];
        
        UMShareModel *domain = dict[snsName];
        //设置分享内容，和回调对象
        __block NSString *kDefaultShareTopic = @"骑卫士";
        __block NSString *kDefaultShareTitle = @"骑卫士";
        __block NSString *kDefaultShareContent = @"我是骑卫士...";
        
        NSString * tmpShareTopic   = domain.shareTopic;
        NSString * tmpShareTitle   = domain.shareTitle;
        NSString * tmpShareContent = domain.shareText;
        NSString * tmpShareAtUser  = domain.shareAtUser;
        NSString * tmpShareJumpUrl = domain.shareJumpUrl;
        NSString * tmpSharePicUrl  = domain.sharePicUrl;
        
        __block NSString *kShareTopic   = tmpShareTopic ? : kDefaultShareTopic;
        __block NSString *kShareTitle   = tmpShareTitle ? : kDefaultShareTitle;
        __block NSString *kShareContent = tmpShareContent ? : kDefaultShareContent;
        __block NSString *kShareAtUser  = tmpShareAtUser ? : @"";
        __block NSString *kShareJumpUrl = tmpShareJumpUrl ? : @"https://www.qiweishi.com/";
        __block NSString *kSharePicUrl  = tmpSharePicUrl;
        
        __block UIImage *shareImage = nil;
        if (domain.shareImage) {
            if ([domain.shareImage isKindOfClass:[NSString class]]) {
                if (((NSString *)domain.shareImage).length)
                    shareImage = [UIImage imageNamed:domain.shareImage];
            }else if ([domain.shareImage isKindOfClass:[UIImage class]]) {
                shareImage = domain.shareImage;
            }else if ([domain.shareImage isKindOfClass:[NSData class]]) {
                shareImage = [UIImage imageWithData:domain.shareImage];
            }
        }
        if (kSharePicUrl.length) {
            if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:kSharePicUrl]]) {
                shareImage = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:kSharePicUrl];
            }
            
            if (nil == shareImage) {
                if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:kSharePicUrl]]) {
                    shareImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:kSharePicUrl];
                }else {
                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:kSharePicUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        if (finished) shareImage = image;
                    }];
                }
            }
        }
        
        G100ShareModel *shareModel = [G100ShareModel shareModelWithSnsPlatform:snsName handler:^(G100ShareModel *shareModel) {
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            NSDictionary * dict = [kShareJumpUrl paramsFromURL];
            NSDictionary * params = [dict objectForKey:@"PARAMS"];
            NSInteger eventid = [params[@"eventid"] integerValue];
            [G100UMSocialHelper shareInstance].eventid = eventid;
            
            if ([snsName isEqualToString:G100UMShareToSina]) {
                // 新浪微博
                messageObject.text = [NSString stringWithFormat:@"%@ %@ (来自@骑卫士 %@ )", [NSString stringWithFormat:@"%@%@", kShareTopic, kShareContent], kShareAtUser, !kShareJumpUrl.length ? @"" : [NSString stringWithFormat:@"%@&shareto=5", kShareJumpUrl]];
                
                if (shareImage) {
                    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
                    shareObject.thumbImage = shareImage;
                    shareObject.shareImage = shareImage;
                    
                    messageObject.shareObject = shareObject;
                }
            } else if ([snsName isEqualToString:G100UMShareToWechatSession]) {
                // 微信会话
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=1", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }else if ([snsName isEqualToString:G100UMShareToWechatTimeline]) {
                // 微信朋友圈
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=2", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }else if ([snsName isEqualToString:G100UMShareToQQ]) {
                // QQ
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=3", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }else if ([snsName isEqualToString:G100UMShareToQzone]) {
                // QQ空间
                messageObject.text = kShareContent;
                
                if (kShareJumpUrl.length) {
                    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:kShareTitle
                                                                                             descr:kShareContent
                                                                                         thumImage:kSharePicUrl];
                    shareObject.webpageUrl = [NSString stringWithFormat:@"%@&shareto=4", kShareJumpUrl];
                    messageObject.shareObject = shareObject;
                }
            }
            
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:[pft integerValue] messageObject:messageObject currentViewController:self.shareOnViewController completion:^(id data, NSError *error) {
                if (error) {
                    UMSocialLogInfo(@"************Share fail with error %@*********",error);
                }else{
                    if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                        UMSocialShareResponse *resp = data;
                        [G100UMSocialHelper didFinishGetUMSocialDataWithResponse:resp eventid:eventid];
                    }else{
                        UMSocialLogInfo(@"response data is %@",data);
                    }
                }
            }];
            
            NSInteger shareto = 1;
            if ([snsName isEqualToString:G100UMShareToWechatSession]) {
                shareto = 1;
            }else if ([snsName isEqualToString:G100UMShareToWechatTimeline]) {
                shareto = 2;
            }else if ([snsName isEqualToString:G100UMShareToQQ]) {
                shareto = 3;
            }else if ([snsName isEqualToString:G100UMShareToQzone]) {
                shareto = 4;
            }else if ([snsName isEqualToString:G100UMShareToSina]) {
                shareto = 5;
            }
            
            if (_shareSelected) {
                self.shareSelected(shareto);
            }
        }];
        
        if (domain) {
            shareModel.enable = YES;
        }else {
            shareModel.enable = NO;
        }
        [shareSheet addShareModel:shareModel];
    }
    
    [shareSheet show];
}

#pragma mark - 懒加载
- (NSMutableDictionary *)shareContentMap {
    if (!_shareContentMap) {
        _shareContentMap = [[NSMutableDictionary alloc] init];
    }
    return _shareContentMap;
}

@end
