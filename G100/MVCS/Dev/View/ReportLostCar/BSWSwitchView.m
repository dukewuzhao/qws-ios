//
//  BSWSwitchView.m
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "BSWSwitchView.h"

@interface BSWSwitchView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

- (IBAction)buttonclick:(UIButton *)sender;

@end

@implementation BSWSwitchView

+ (instancetype)switchView {
    BSWSwitchView * sw = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    return sw;
}

- (void)setTitleLabelText:(NSString *)titleText {
    _titleLabel.text = titleText;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    _rightButton.enabled = NO;
    _currentIndex = [_dataArray count] - 1;
    _contentLabel.text = [_dataArray lastObject];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)buttonclick:(UIButton *)sender {
    NSInteger count = [_dataArray count];
    if (sender == _leftButton) {
        _currentIndex--;
        if (_currentIndex == 0) {
            _leftButton.enabled = NO;
        }
        
        _rightButton.enabled = YES;
    }else if (sender == _rightButton) {
        _currentIndex++;
        if (_currentIndex == count - 1) {
            _rightButton.enabled = NO;
        }
        
        _leftButton.enabled = YES;
    }
    
    _contentLabel.text = _dataArray[_currentIndex];
    
    if ([_delegate respondsToSelector:@selector(bswSwitchViewValueChanged:index:)]) {
        [self.delegate bswSwitchViewValueChanged:self index:_currentIndex];
    }
}
@end
