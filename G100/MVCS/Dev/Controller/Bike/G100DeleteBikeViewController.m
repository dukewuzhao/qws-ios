//
//  G100JiebangViewController.m
//  G100
//
//  Created by Tilink on 15/4/22.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100DeleteBikeViewController.h"
#import "G100BikeApi.h"

#import "G100DevDataHelper.h"

@interface G100DeleteBikeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation G100DeleteBikeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.surnBtn setExclusiveTouch:YES];
    [self.btn1 setExclusiveTouch:YES];
    [self.btn2 setExclusiveTouch:YES];
    [self.btn3 setExclusiveTouch:YES];
    [self.btn4 setExclusiveTouch:YES];
    
    [self.surnBtn setBackgroundImage:[[UIImage imageNamed:@"ic_service_commit_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"删除车辆"];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    
    self.label1.numberOfLines = 0;
    self.label2.numberOfLines = 0;
    self.label3.numberOfLines = 0;
    self.label4.numberOfLines = 0;
    CGSize size1 = [self.label1.text calculateSize:CGSizeMake(_label1.frame.size.width, 100) font:[UIFont systemFontOfSize:17]];
    
    self.firstLabelHeightContraint.constant = size1.height + 1;
    
    CGSize size2 = [self.label2.text calculateSize:CGSizeMake(_label2.frame.size.width, 100) font:[UIFont systemFontOfSize:17]];
    
    self.firstLabelHeightContraint.constant = size2.height + 1;
    CGSize size3 = [self.label3.text calculateSize:CGSizeMake(_label3.frame.size.width, 100) font:[UIFont systemFontOfSize:17]];
    self.secondLabelHeightContraint.constant = size3.height + 1;
    // CGSize size4 = [self.label4.text calculateSize:CGSizeMake(_label3.frame.size.width, 200) font:[UIFont systemFontOfSize:17]];
    
    self.bgImageView.image = [[UIImage imageNamed:@"ic_jiebang_null"] stretchableImageWithLeftCapWidth:0 topCapHeight:400];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonEventClick:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)buttonSure:(UIButton *)sender {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    __weak G100DeleteBikeViewController * wself = self;
    [[G100BikeApi sharedInstance] deleteBikeWithUserid:self.userid bikeid:self.bikeid callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [[UserManager shareManager] updateBikeListWithUserid:wself.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGNDeleteBikeSuccess
                                                                        object:response
                                                                      userInfo:@{@"userid" : EMPTY_IF_NIL(wself.userid),
                                                                                 @"bikeid" : EMPTY_IF_NIL(wself.bikeid)}];
                    
                    [wself.navigationController popToRootViewControllerAnimated:YES];
                }else {
                    [wself showHint:response.errDesc];
                }
                
                [[G100InfoHelper shareInstance] clearRelevantDataWithUserid:wself.userid bikeid:wself.bikeid];
            }];
        }else {
            [wself showHint:response.errDesc];
        }
    }];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        if (self.btn1.selected && self.btn2.selected && self.btn3.selected && self.btn4.selected) {
            self.surnBtn.enabled = YES;
        }else {
            self.surnBtn.enabled = NO;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.btn1 addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.btn2 addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.btn3 addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.btn4 addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.btn1 removeObserver:self forKeyPath:@"selected" context:nil];
    [self.btn2 removeObserver:self forKeyPath:@"selected" context:nil];
    [self.btn3 removeObserver:self forKeyPath:@"selected" context:nil];
    [self.btn4 removeObserver:self forKeyPath:@"selected" context:nil];
    [super viewWillDisappear:YES];
}

@end
