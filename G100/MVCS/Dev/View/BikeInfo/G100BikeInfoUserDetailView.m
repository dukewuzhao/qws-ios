//
//  G100BikeInfoUserDetailView.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/2.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoUserDetailView.h"


@interface G100BikeInfoUserDetailView ()@property (weak, nonatomic) IBOutlet UILabel *commenLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UILabel *bindTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteUseBtn;
@property (weak, nonatomic) IBOutlet UILabel *devNameLabel;
@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextfiled;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (nonatomic, strong) G100UserDomain *userDomain;
@property (nonatomic, strong) NSString *oldComment;
@end

@implementation G100BikeInfoUserDetailView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.deleteUseBtn.layer.masksToBounds = YES;
    self.deleteUseBtn.layer.cornerRadius = 6.0f;
    
    self.confirmBtn.layer.masksToBounds = YES;
    self.confirmBtn.layer.cornerRadius = 6.0f;
    
    self.boxView.layer.masksToBounds = YES;
    self.boxView.layer.cornerRadius = 6.0f;
}

- (void)showBindApplicationViewWithVc:(UIViewController *)vc
                                 view:(UIView *)view
                                 user:(G100UserDomain *)userDomain
                          buttonClick:(BikeInfoUserDetailButtonClick)buttonClick
                             animated:(BOOL)animated {
    [super showInVc:vc view:view animation:animated];
    
    self.buttonClick = buttonClick;
    self.userDomain = userDomain;
    
    self.oldComment = userDomain.comment ;
    
    self.frame = view.bounds;
    
    self.devNameLabel.text = self.userDomain.nickname;
    self.commentTextfiled.text = self.userDomain.comment;
    self.telLabel.text = self.userDomain.phonenum;
    self.bindTimeLabel.text = [self.userDomain.created_time substringToIndex:10];
    
    if (![self superview]) {
        [view addSubview:self];
    }
}

- (IBAction)deleteUserAction:(id)sender {
    self.buttonClick(2,NO,nil);
}
- (IBAction)confirmAction:(id)sender {
    
    BOOL hasChanged = [self checkChange];
    self.buttonClick(1,hasChanged,self.commentTextfiled.text);
}

- (IBAction)dismissViewAction:(id)sender {
    BOOL hasChanged = [self checkChange];
    if (hasChanged) {
         self.buttonClick(3,hasChanged,self.commentTextfiled.text);
    }else{
         [super dismissWithVc:self.popVc animation:YES];
    }
  
    if ([self superview]) {
        [self removeFromSuperview];
    }
}
- (BOOL)checkChange{
    BOOL hasChanged = NO;
    if (![self.oldComment isEqualToString:self.commentTextfiled.text]) {
        hasChanged = YES;
    }
    return hasChanged;
}
@end
