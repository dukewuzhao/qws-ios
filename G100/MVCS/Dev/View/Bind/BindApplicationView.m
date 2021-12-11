//
//  BindApplicationView.m
//  G100
//
//  Created by Tilink on 15/4/22.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "BindApplicationView.h"

#import "G100PushMsgDomain.h"

#import "G100DevApi.h"

#import "NSDate+TimeString.h"


#define ViceUserApply @"ViceUserApply"
@interface BindApplicationView ()

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *devnameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UITextField *commenTextField;

@end

@implementation BindApplicationView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.mainView.layer.masksToBounds = YES;
    self.mainView.layer.cornerRadius = 6.0f;
    
    self.accountLabel.numberOfLines = 0;
    self.devnameLabel.numberOfLines = 0;
    self.frame = KEY_WINDOW.bounds;
    
    self.sureBtn.layer.masksToBounds = YES;
    self.sureBtn.layer.cornerRadius = 6.0f;
    self.cancelBtn.layer.masksToBounds = YES;
    self.cancelBtn.layer.cornerRadius = 6.0f;
    [self.sureBtn setExclusiveTouch:YES];
    [self.cancelBtn setExclusiveTouch:YES];
}

- (void)showBindApplicationViewWithVc:(UIViewController *)vc
                                 view:(UIView *)view
                                 user:(G100PushMsgDomain *)userinfo
                          buttonClick:(ButtonClick)buttonClick
                             animated:(BOOL)animated {
    [super showInVc:vc view:view animation:animated];
    
    [self showBindApplicationViewWithView:view
                                     user:userinfo
                              buttonClick:buttonClick
                                 animated:animated];
}

- (IBAction)dismissBindView:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:ViceUserApply object:nil];
    [super dismissWithVc:self.popVc animation:YES];
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

-(void)showBindApplicationViewWithView:(UIView *)view
                                  user:(G100PushMsgDomain *)userinfo
                           buttonClick:(ButtonClick)buttonClick
                              animated:(BOOL)animated {
    self.pushDomain = userinfo;
    self.buttonClick = buttonClick;
    
    NSDictionary * addval = [_pushDomain.addval mj_JSONObject];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    self.accountLabel.text = [addval safe_objectForKey:@"phone"];
    self.accountLabel.textAlignment = NSTextAlignmentCenter;
    self.devnameLabel.text = [addval safe_objectForKey:@"nickname"];
    self.devnameLabel.font = [UIFont systemFontOfSize:17];
    self.devnameLabel.textAlignment = NSTextAlignmentCenter;
    
    self.timeLable.text =  [NSDate timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",userinfo.mcts]];
    
    if (![self superview]) {
        [view addSubview:self];
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    NSDictionary * addval = [_pushDomain.addval mj_JSONObject];
    
    __weak UIViewController * wvc = APPDELEGATE.window.rootViewController;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeInfoWithUserid:[G100InfoHelper shareInstance].buserid
                                                          bikeid:[addval objectForKey:@"devid"]
                                                      updateType:BikeInfoAddType
                                                        complete:nil];
            
            NSString *viceUid = [addval safe_objectForKey:@"requestor"];
            [self updateDevInfo:viceUid];
            [[NSNotificationCenter defaultCenter]postNotificationName:ViceUserApply object:nil];
        }else {
            if (response) {
                [wvc showHint:response.errDesc];
            }
        }
        
        // 操作完成后的回调
        if (_buttonClick) {
            self.buttonClick(sender.tag - 200);
        }
    };
    
    [[G100DevApi sharedInstance] grantDevPrivsWithBikeid:[addval objectForKey:@"devid"]
                                                   Devid:nil
                                                  userid:[addval objectForKey:@"requestor"]
                                                   grant:[NSString stringWithFormat:@"%ld", (long)sender.tag - 200]
                                                   privs:@"2"
                                                   msgid:[self.pushDomain.msgid integerValue]
                                                callback:callback];
    
    [super dismissWithVc:self.popVc animation:YES];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (void)updateDevInfo:(NSString *)viceUid {
    if (!self.commenTextField.text || self.commenTextField.text == NULL) {
        return;
    }
    
    NSDictionary * addval = [_pushDomain.addval mj_JSONObject];
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeInfoWithUserid:[G100InfoHelper shareInstance].buserid
                                                          bikeid:[addval objectForKey:@"devid"]
                                                      updateType:BikeInfoAddType
                                                        complete:nil];
        } else {
            
        }
        
        // 操作完成后的回调
        if (_buttonClick) {
            self.buttonClick(999);
        }
    };
    
    [[G100UserApi sharedInstance] sv_commentUserWithUserid:viceUid
                                                    bikeid:[addval objectForKey:@"devid"]
                                                   comment:self.commenTextField.text
                                                  callback:callback];
}

@end
