//
//  BindErrorView.m
//  G100
//
//  Created by 温世波 on 16/1/6.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "BindErrorView.h"
#import "ApiResponse.h"
#import <YYText.h>

#import "G100WebViewController.h"
#import "G100UrlManager.h"


@interface BindErrorView ()

@property (nonatomic, strong) ApiResponse * response;

@property (weak, nonatomic) IBOutlet UIScrollView *qrCodeHintScrollView;
@property (weak, nonatomic) IBOutlet UILabel *qrCodeHintContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *qrCodeHintReasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *qrCodeHintResolveLabel;
@property (weak, nonatomic) IBOutlet UILabel *qrCodeHintContactLabel;
@property (weak, nonatomic) IBOutlet UIView *qrCodeFuzhuView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraintBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrCodeFuzhuViewConstraintH;

@property (weak, nonatomic) IBOutlet UILabel *failedHintContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *failedSorryHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *failedHintContactLabel;

@property (weak, nonatomic) IBOutlet UIImageView *otherHintImageView;
@property (weak, nonatomic) IBOutlet UILabel *otherHintTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherHintContentLabel;

@end

@implementation BindErrorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)bindErrorViewWithErrorCode:(NSInteger)errCode response:(ApiResponse *)respponse {
    NSArray * viewArray = [[NSBundle mainBundle] loadNibNamed:@"BindErrorView" owner:self options:nil];
    NSInteger index = 0;
    
    if (errCode == SERV_RESP_BIND_INVALID_QRCODE) {
        index = 0;
    }else if (errCode == SERV_RESP_BIND_ERROR_DEV_BIND || errCode == SERV_RESP_BIND_ERROR_FAILED || respponse == nil) {
        index = 1;
    }else {
        index = 2;
    }
    
    BindErrorView * errorView = viewArray[index];
    errorView.response = respponse;
    
    return errorView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.topViewConstraintHeight.constant = kNavigationBarHeight;
    self.bottomViewConstraintBottom.constant = kBottomHeight + 20;
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    [self showInView:view animation:animation];
}

- (void)showInView:(UIView *)view animation:(BOOL)animation {
    
    if (_response.errCode == SERV_RESP_BIND_INVALID_QRCODE) {
        // qr
        self.qrCodeHintContentLabel.text = _response.errDesc;
        
        self.qrCodeHintReasonLabel.text = @"您可能扫描了错误的二维码\n请参考下图重新扫描说明书或设备背面的二维码";
        self.qrCodeHintResolveLabel.text = @"扫描时请将摄像头对准标签红框处的二维码";
        self.qrCodeHintContactLabel.text = @"如始终提示以上错误\n请拨打骑卫士客服电话400-920-2890";
        
    }else if (_response.errCode == SERV_RESP_BIND_ERROR_DEV_BIND ||
              _response.errCode == SERV_RESP_BIND_ERROR_FAILED ||
              _response == nil) {
        // failed
        self.failedHintContentLabel.text = _response.errDesc;
        // 常见绑定问题
        self.failedSorryHintLabel.textColor = [UIColor clearColor];
        self.failedSorryHintLabel.userInteractionEnabled = YES;

        YYLabel *label = [[YYLabel alloc]init];
        label.textColor = [UIColor grayColor];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:15];
        [self.failedSorryHintLabel addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(@0);
            make.left.and.right.equalTo(@0);
        }];

        NSString * content = @"对不起，我们无法连接到您的骑卫士设备，\n您可以点击这里查看常见绑定问题";
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:content];
        text.yy_font = [UIFont systemFontOfSize:14];
        text.yy_color = [UIColor grayColor];
        text.yy_alignment = NSTextAlignmentCenter;
        NSRange hiRange = [content rangeOfString:@"常见绑定问题"];
        
        [text yy_setColor:RGBColor(74, 94, 173, 1.0) range:hiRange];
        label.attributedText = text;
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:[UIColor grayColor]];
        
        highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            G100WebViewController * helper = [G100WebViewController loadNibWebViewController];
            helper.isAllowBackSlip = NO;
            helper.httpUrl = [[G100UrlManager sharedInstance] getBindCommonFAQWithUserid:[[G100InfoHelper shareInstance] buserid]
                                                                                   devid:self.bindResultDomain.device_id
                                                                            locmodeltype:[NSString stringWithFormat:@"%ld", (long)self.bindResultDomain.locmodeltype]];
            [CURRENTVIEWCONTROLLER.navigationController pushViewController:helper animated:YES];
        };
        [text yy_setTextHighlight:highlight range:hiRange];
        
        label.attributedText = text;
        
        self.failedHintContactLabel.text = @"如重试多次仍无法解决您的绑定问题，\n请拨打骑卫士客服电话400-920-2890";
        
    }else {
        // other
        self.otherHintContentLabel.text = _response.errDesc;
        
        if (_response.errCode == SERV_RESP_BIND_DEV_ACTIVEING || _response.errCode == SERV_RESP_BIND_CAR_BIND_VERIFYING) {
            self.otherHintTitleLabel.text = @"请稍候";
            self.otherHintImageView.image = [UIImage imageNamed:@"ic_bind_activing"];
        }else {
            self.otherHintTitleLabel.text = @"出错了";
            self.otherHintImageView.image = [UIImage imageNamed:@"ic_bind_warn"];
        }
        
    }
    
    if (![self superview]) {
        [view addSubview:self];
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    [super dismissWithVc:vc animation:animation];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (IBAction)bindErrorRebind:(UIButton *)sender {
    if (_bindErrorViewRebind) {
        self.bindErrorViewRebind();
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}
- (IBAction)bindErrorExit:(UIButton *)sender {
    if (_bindErrorViewExit) {
        self.bindErrorViewExit();
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

@end
