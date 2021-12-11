//
//  G100PopView.m
//  G100
//
//  Created by Tilink on 15/3/20.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopView.h"
#import "SoundManager.h"
#import "G100PopBoxHelper.h"
#import "G100PushMsgDomain.h"

#import "G100AlertCancelClickView.h"

@interface G100PopView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSTimer * timer;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UILabel *popTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *popContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) UIView * loadingView;

@property (strong, nonatomic) UIView * pingBiView;
@property (strong, nonatomic) UIPanGestureRecognizer *swipe;

- (IBAction)buttonClick:(UIButton *)sender;

@end

@implementation G100PopView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.ignoreButton setExclusiveTouch:YES];
    [self.helpButton setExclusiveTouch:YES];
    
    [self.ignoreButton setBackgroundImage:[[UIImage imageNamed:@"ic_pop_ignore"]resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [self.helpButton setBackgroundImage:[[UIImage imageNamed:@"ic_pop_check"]resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
}

-(void)setupView {
    self.bigImageView.image = [UIImage imageNamed:_pushMsg.imageName];
    self.popContentLabel.numberOfLines = 0;
    self.popTitleLabel.numberOfLines = 0;
    
    self.popTitleLabel.text = _pushMsg.custtitle;
    self.popContentLabel.text = _pushMsg.custdesc;
    
    [self.popTitleLabel sizeToFit];
    [self.popContentLabel sizeToFit];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(poolTime) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    
    self.swipe = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(swipeThePopView:)];
    self.swipe.enabled = NO;        // 设置上滑消失不可用
    self.swipe.delegate = self;
    [self addGestureRecognizer:_swipe];
    
    // 根据Code 重新布局  主要针对测试推送做出处理
    if (self.popCode == NOTI_MSG_CODE_TEST_PUSH) {
        // 测试推送 重新布局
        self.helpButton.hidden = YES;
        self.ignoreButton.hidden = YES;
        
        __weak G100PopView *wself = self;
        G100AlertCancelClickView *cancelBtnView = [G100AlertCancelClickView loadNibCancelClickView];
        cancelBtnView.cancelButton.layer.borderWidth = 0.0f;
        cancelBtnView.cancelButton.backgroundColor = RGBColor(253, 152, 39, 1.0);
        [cancelBtnView.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtnView.cancelButton setTitle:@"按下终止报警" forState:UIControlStateNormal];
        cancelBtnView.cancelClickBlock = ^(){
            [wself hideSelf];
            if (wself.helpClick) {
                wself.helpClick(wself.pushMsg);
            }
        };
        [self addSubview:cancelBtnView];
        
        [cancelBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@20);
            make.trailing.equalTo(@-20);
            make.bottom.equalTo(@-20);
            make.height.equalTo(@40);
        }];
    }
}

-(void)swipeThePopView:(UIPanGestureRecognizer *)swipe {
    CGPoint point = [swipe translationInView:self];
    CGPoint center = self.center;
    center.y = CGPointMake(swipe.view.center.x + point.x, swipe.view.center.y + point.y).y;
    
    [swipe setTranslation:CGPointMake(0, 0) inView:self];
    
    if (self.frame.origin.y > 0) {
        __weak G100PopView * wself = self;
        [UIView animateWithDuration:0.5 animations:^{
            wself.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        } completion:^(BOOL finished) {
            
        }];
    }else {
        self.center = center;
    }
    
    if (_swipe.state == UIGestureRecognizerStateCancelled || _swipe.state == UIGestureRecognizerStateEnded) {
        CGPoint center = self.center;
        if (center.y <= HEIGHT / 2.5) {
            [self hide:nil];
        }else {
            __weak G100PopView * wself = self;
            [UIView animateWithDuration:0.5 animations:^{
                wself.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

-(void)poolTime {
    CALayer * waveLayer=[CALayer layer];
    waveLayer.frame = _bigImageView.bounds;
    waveLayer.borderWidth = 0.5;
    waveLayer.cornerRadius = _bigImageView.v_width / 2;
    waveLayer.borderColor = self.lineColor.CGColor;
    
    [self.bigImageView.layer addSublayer:waveLayer];
    [self scaleBegin:waveLayer];
    
    CABasicAnimation * shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //设置抖动幅度
    shake.fromValue = [NSNumber numberWithFloat:-0.05];
    shake.toValue = [NSNumber numberWithFloat:+0.05];
    shake.duration = 0.1;
    shake.autoreverses = YES; //是否重复
    shake.repeatCount = 4;
    [_bigImageView.layer addAnimation:shake forKey:@"bigImageView"];
    _bigImageView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)stopAnimation {
    [_timer setFireDate:[NSDate distantFuture]];
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)scaleBegin:(CALayer *)aLayer
{
    const float maxScale = 2.5;
    if (aLayer.transform.m11 < maxScale) {
        if (aLayer.transform.m11 == 1.0) {
            [aLayer setTransform:CATransform3DMakeScale( 1.1, 1.1, 1.0)];
        }else{
            [aLayer setTransform:CATransform3DScale(aLayer.transform, 1.1, 1.1, 1.0)];
            aLayer.opacity = 1.0 - aLayer.transform.m11 * 0.64;
        }
        
        [self performSelector:_cmd withObject:aLayer afterDelay:0.05];
    }else {
        [aLayer removeFromSuperlayer];
    }
}

-(void)hideSelf {
    [self hide:^(){
        [[G100PopBoxHelper sharedInstance] removeOldPopView:self];
    }];
}

- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 100) {
        [self hideSelf];
        // 忽略
        if (_ignoreClick) {
            self.ignoreClick(_pushMsg);
        }
    }else {
        [self hideSelf];
        if (_helpClick) {
            self.helpClick(_pushMsg);
        }
    }
}

-(void)showWithInfoData:(G100PushMsgDomain *)infoData ignoreBlock:(IgnoreBlock)ignore helpBlock:(HelpBlock)help {
    self.ignoreClick = ignore;
    self.helpClick = help;
    self.pushMsg = infoData;
    self.lineColor = _pushMsg.lColor;
    self.popCode = infoData.errCode;
    
    // 配置
    [self setupView];
    
    self.dynamic = NO;
    self.blurRadius = 30.0f;
    self.tintColor = MyFxBlueColor;
    
    if (infoData.errCode == 7) {    // 若是故障则 立即检测
        [self.helpButton setTitle:@"立即检测" forState:UIControlStateNormal];
    }
    
    __block UIViewController * topVc = [APPDELEGATE.mainNavc topViewController];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.loadingView = topVc.view;
        
        [self show];
    }else {
        double delayInSeconds = 0.5f;   // 加延时等待
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            topVc = [APPDELEGATE.mainNavc topViewController];
            self.loadingView = topVc.view;
            
            [self show];
        });
    }
}

-(void)show {
    NSString *userid = [NSString stringWithFormat:@"%@", @(_pushMsg.userid)];
    NSString *bikeid = _pushMsg.bikeid;
    
    NSString *devid  = _pushMsg.deviceid;
    if (!_pushMsg.deviceid.length) {
        G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:userid bikeid:bikeid];
        devid = [NSString stringWithFormat:@"%@", @(bikeDomain.mainDevice.device_id)];
    }
    
    NSArray *deviceArray = [[G100InfoHelper shareInstance] findMyDevListWithUserid:userid bikeid:bikeid];
    NSInteger time = 0;
    for (G100DeviceDomain *deviceDomin in deviceArray) {
        if (deviceDomin.isMainDevice) {
            time = [[G100InfoHelper shareInstance] findMyDevWithUserid:userid bikeid:bikeid devid:devid].alarm_bell_time;
        }
    }
    [[SoundManager sharedManager] playAlertSoundWithSoundName:@"alarm.caf" isVibrate:YES time:time];
    
    if (!_pingBiView) {
        self.pingBiView = [[UIView alloc]initWithFrame:KEY_WINDOW.bounds];
        _pingBiView.backgroundColor = [UIColor clearColor];
        [self.loadingView addSubview:_pingBiView];
    }
    
    __weak G100PopView * wself = self;
    [self updateAsynchronously:YES completion:^{
        wself.frame = CGRectMake(0, -HEIGHT, WIDTH, 0);
        [self.loadingView addSubview:wself];
    }];
    
    UIViewController * topVc = [APPDELEGATE.mainNavc topViewController];
    // 屏蔽当前页面的所有点击
    [super showInVc:topVc view:topVc.view animation:YES];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];   // 设置播放时屏幕常亮
    
    [UIView animateWithDuration:0.5 animations:^{
        wself.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    } completion:^(BOOL finished) {
        [wself.timer setFireDate:[NSDate distantPast]];
    }];
    
    [[G100PopBoxHelper sharedInstance] addNewPopView:self];
}

-(void)hide:(void (^)())callback {
    __weak G100PopView * wself = self;
    [super dismissWithVc:self.popVc animation:YES];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];   // 设置播放时屏幕常亮
    [self.timer setFireDate:[NSDate distantFuture]];
    [UIView animateWithDuration:0.3 animations:^{
        [wself stopAnimation];
        wself.frame = CGRectMake(0, -HEIGHT, WIDTH, 0);
    } completion:^(BOOL finished) {
        [[SoundManager sharedManager] stopAlertSound];
        
        [wself removeGestureRecognizer:wself.swipe];
        [wself removeFromSuperview];
        [wself.pingBiView removeFromSuperview];
        
        if (callback) {
            callback();
        }
    }];
}

@end
