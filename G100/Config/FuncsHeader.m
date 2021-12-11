//
//  FuncsHeader.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "FuncsHeader.h"

@implementation FuncsHeader

void MyAlert(NSString * title, NSString * message){
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"我知道了"
                                           otherButtonTitles:nil];
    [alert show];
}
void MyAlertTitle(NSString * message){
    MyAlert(@"提示", message);
}

void G100MAlert(NSString * title, NSString * message, bool center, ABlock aBlock) {
    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
    box.backgorundTouchEnable = NO;
    
    __weak UIViewController *topVC = CURRENTVIEWCONTROLLER;
    [box showPopingViewWithTitle:title
                            content:message
                         noticeType:ClickEventBlockCancel
                         otherTitle:@"取消"
                       confirmTitle:@"确定"
                         clickEvent:^(NSInteger index) {
                             if (index == 2) {
                                 if (aBlock) {
                                     aBlock();
                                 }
                             }
                             [box dismissWithVc:topVC animation:YES];
                         }
                   onViewController:topVC
                         onBaseView:topVC.view];
}
void G100MAlertTitleWithBlock(NSString * message, ABlock aBlock) {
    G100MAlert(@"提示", message, YES,  aBlock);
}
void G100MAlertIKnow(NSString * title, NSString * message, bool center, ABlock aBlock) {
    G100ReactivePopingView *box = [G100ReactivePopingView popingViewWithReactiveView];
    box.backgorundTouchEnable = NO;
    
    __weak UIViewController *topVC = CURRENTVIEWCONTROLLER;
    [box showPopingViewWithTitle:title
                            content:message
                         noticeType:ClickEventBlockCancel
                         otherTitle:nil
                       confirmTitle:@"我知道了"
                         clickEvent:^(NSInteger index) {
                             if (index == 2) {
                                 if (aBlock) {
                                     aBlock();
                                 }
                             }
                             [box dismissWithVc:topVC animation:YES];
                         }
                   onViewController:topVC
                         onBaseView:topVC.view];
}

NSString * GetCurrentTimeStr() {
    return GetStrFromDate([NSDate date]);
}
NSString * GetStrFromDate(NSDate * date) {
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

UIImage * CreateImageWithColor(UIColor * color) {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

bool IsLogin() {
    return [UserManager shareManager].isLogin;
}

bool IsBind() {
    return [UserManager shareManager].isBind;
}

@end
