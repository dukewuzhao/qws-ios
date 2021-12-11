//
//  G100VerificationCodeView.m
//  G100
//
//  Created by William on 16/5/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100VerificationCodeView.h"
#import <XXNibBridge.h>
#import <UIImageView+WebCache.h>

@interface G100VerificationCodeView () <XXNibBridge>

@property (strong, nonatomic) IBOutlet UIButton *codeRefreshBtn;

@end

@implementation G100VerificationCodeView

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImageView * verCodeleft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    verCodeleft.v_size = CGSizeMake(8, _verCodeTF.v_height);
    [_verCodeTF setLeftView:verCodeleft];
    _verCodeTF.leftViewMode = UITextFieldViewModeAlways;
    
    if (WIDTH > 320) {
        [self.verCodeTF setPlaceholder:@"  请输入验证码"];
    }else{
        [self.verCodeTF setPlaceholder:@"  验证码"];
    }
}

- (void)setUsageType:(G100VerificationCodeUsage)usageType picvcurl:(NSString *)picvcurl {
    _usageType = usageType;
    _picvcurl = picvcurl;
    
    self.verCodeTF.text = @"";
    [self.verCodeImageView sd_setImageWithURL:[NSURL URLWithString:picvcurl] placeholderImage:[UIImage imageNamed:@"ic_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.codeRefreshBtn.enabled = YES;
        if (!image) { //加载失败
            self.verCodeImageView.image = [UIImage imageNamed:@"ic_load_failed"];
        }
    }];
    if (picvcurl.length>0) {
        NSString * sessionid = [NSString getSessionidWithStr:picvcurl];
        NSString * picvcName = [NSString getPicNameWithPicvcurl:picvcurl];
        
        if (self.refreshVeriCodeBlock) {
            self.refreshVeriCodeBlock(sessionid, picvcName);
        }
    }
}

- (void)refreshVericode {
    [self refreshVeriCodeWithUsage:self.usageType];
}

- (void)refreshVeriCodeWithUsage:(G100VerificationCodeUsage)usageType {
    _usageType = usageType;
    
    [[G100UserApi sharedInstance] requestPicvcVerificationWithUsage:self.usageType callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        self.codeRefreshBtn.enabled = YES;
        if (requestSuccess) {
            self.verCodeTF.text = @"";
            if ([[response.data allKeys]containsObject:@"picvcurl"]) {
                NSString *picvcurl = response.data[@"picvcurl"];
                if (picvcurl.length>0) {
                    NSString * sessionid = [NSString getSessionidWithStr:response.data[@"picvcurl"]];
                    NSString * picName = [NSString getPicNameWithPicvcurl:response.data[@"picvcurl"]];
                    
                    if (self.refreshVeriCodeBlock) {
                        self.refreshVeriCodeBlock(sessionid, picName);
                    }
                }
            }
            
            [self.verCodeImageView sd_setImageWithURL:[NSURL URLWithString:response.data[@"picvcurl"]] placeholderImage:[UIImage imageNamed:@"ic_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.codeRefreshBtn.enabled = YES;
                if (!image) { //加载失败
                    self.verCodeImageView.image = [UIImage imageNamed:@"ic_load_failed"];
                }
            }];
            
        }else{
            self.verCodeImageView.image = [UIImage imageNamed:@"ic_load_failed"];
        }
    }];
}

 
- (void)setDisplayStyle:(DisplayStyle)displayStyle {
    _displayStyle = displayStyle;
    if (displayStyle == DisplayStyleDefault) {
        
        [_verCodeTF.layer setBorderWidth:0];
        [_verCodeImageView.layer setBorderWidth:0];
    }else if (displayStyle == DisplayStyleWithBorder){
        if (WIDTH > 320) {
            [_verCodeTF setPlaceholder:@"图形验证码"];
        }else{
            [_verCodeTF setPlaceholder:@"验证码"];
        }
        
        [_verCodeTF.layer setBorderWidth:1.0f];
        [_verCodeTF.layer setBorderUIColor:[UIColor lightGrayColor]];
        [_verCodeImageView.layer setBorderWidth:1.0f];
        [_verCodeImageView.layer setBorderUIColor:[UIColor lightGrayColor]];
    }
}

- (IBAction)refreshVerCode:(UIButton *)sender {
    sender.enabled = NO;
    [self refreshVericode];
}

@end
