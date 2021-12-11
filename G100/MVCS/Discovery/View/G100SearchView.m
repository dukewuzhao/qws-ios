//
//  G100SearchView.m
//  G100
//
//  Created by 天奕 on 15/12/23.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100SearchView.h"

@interface G100SearchView () <UITextFieldDelegate>

@property (nonatomic, assign) BOOL clickEnable;

@end

@implementation G100SearchView

- (instancetype)initWithEnableClick:(BOOL)enable {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.clickEnable = enable;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIImageView *searchImageView = [[UIImageView alloc]init];
    searchImageView.userInteractionEnabled = YES;
    UIImage *searchImage = [[UIImage imageNamed:@"search_background"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
    searchImageView.image = searchImage;
    [self addSubview:searchImageView];
    [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(@0);
        make.leading.and.trailing.equalTo(@0);
    }];
    
    self.searchTextFiled = [[UITextField alloc]init];
    self.searchTextFiled.backgroundColor = [UIColor clearColor];
    self.searchTextFiled.borderStyle = UITextBorderStyleNone;
    self.searchTextFiled.clearButtonMode = UITextFieldViewModeAlways;
    self.searchTextFiled.enablesReturnKeyAutomatically = YES;
    [self.searchTextFiled setReturnKeyType:UIReturnKeySearch];
    self.searchTextFiled.textColor = [UIColor whiteColor];
    self.searchTextFiled.placeholder = @"请输入店铺名";
    self.searchTextFiled.delegate = self;
    [searchImageView addSubview:self.searchTextFiled];
    [self.searchTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(@0);
        make.leading.equalTo(@13);
        make.trailing.equalTo(@-5);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!self.clickEnable) {
        if (self.clickWithoutInput) {
            self.clickWithoutInput();
        }
        return NO;
    }
    if (self.startEditing) {
        self.startEditing();
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.commitSearchContent && self.searchTextFiled.text.length != 0) {
        self.commitSearchContent(self.searchTextFiled.text);
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.clearEditing) {
        self.clearEditing();
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
