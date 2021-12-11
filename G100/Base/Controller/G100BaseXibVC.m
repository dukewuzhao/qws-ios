//
//  G100BaseXibVC.m
//  G100
//
//  Created by Tilink on 15/4/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

@interface G100BaseXibVC ()

@end

@implementation G100BaseXibVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.contentView removeFromSuperview];
}

- (void)setupNavigationBarView {
    [super setupNavigationBarView];
    
    self.navigationView.backgroundColor = [UIColor blackColor];
    
    self.navigationView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.navigationView.layer.shadowOffset = CGSizeMake(0, 2);
    self.navigationView.layer.shadowOpacity = 0.8;
    self.navigationView.layer.shadowRadius = 2;
    
    self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight;
    self.substanceViewtoBottomConstraint.constant = kBottomHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
