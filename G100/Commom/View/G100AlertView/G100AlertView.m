//
//  G100AlertView.m
//  G100
//
//  Created by Tilink on 15/2/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100AlertView.h"
#import "G100CustomOptions.h"
#import "HZAreaPickerView.h"

@interface G100AlertView () <HZAreaPickerDelegate, UITextFieldDelegate>{
    CGFloat _kbDistance;
}

@property (strong, nonatomic) UIView * alertView;
@property (strong, nonatomic) UIView * titleView;
@property (strong, nonatomic) UIView * contentView;
@property (strong, nonatomic) UIView * bottomView;
@property (strong, nonatomic) UITextField * textField;
@property (copy, nonatomic) NSString * orignalString; /**原始字符串*/
@property (strong, nonatomic) UIDatePicker * selectDatePicker;
@property (copy, nonatomic) NSString * selectDateStr;
@property (copy, nonatomic) NSString * selecteArea;

@property (strong, nonatomic) UIButton * sureButton;
@property (strong, nonatomic) UIButton * cancelButton;

@end

@implementation G100AlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

+ (void)G100AlertWithTitle:(NSString *)title message:(NSString *)message alertBlock:(G100Alert)alertBlock {
    
}

// 带有确定或取消按钮        底部
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message alertBlock:(G100Alert)alertBlock alertBlockTF:(G100AlertTf)alertBlockTF {
    
    CGRect frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = MyAlphaColor;
        self.alertBlock = alertBlock;
        self.alertBlockTF = alertBlockTF;
        self.title = title;
        self.message = message;
        
        self.maxCount = 10;
        
        self.alertStyle = G100AlertViewStyleDefault;
        // 底部设置一个 scrollView
        UIScrollView *backScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        backScrollView.scrollEnabled = NO;
        backScrollView.backgroundColor = [UIColor clearColor];
        backScrollView.showsVerticalScrollIndicator = NO;
        backScrollView.showsHorizontalScrollIndicator = NO;
        backScrollView.bounces = NO;
        [self addSubview:backScrollView];
        
        // 添加手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        [backScrollView addGestureRecognizer:tap];
        // 画图
        _alertView = [[UIView alloc]initWithFrame:CGRectMake(20, HEIGHT / 2 - 60, WIDTH - 40, 120)];
        _alertView.backgroundColor = MyBackColor;
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.cornerRadius = 6.0f;
        _alertView.tag = 200;
        _alertView.backgroundColor = [UIColor whiteColor];
        [backScrollView addSubview:_alertView];
        
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _alertView.v_width, KROWHEIGHT - 10)];
        _titleView.backgroundColor = MyNavColor;
        [_alertView addSubview:_titleView];
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:_titleView.bounds];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.text = _title;
        [_titleView addSubview:titleLabel];
        // content
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, _titleView.v_bottom, _alertView.v_width, KROWHEIGHT)];
        _contentView.backgroundColor = MyBackColor;
        [_alertView addSubview:_contentView];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message alertBlock:(G100Alert)alertBlock {
    CGRect frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = MyAlphaColor;
        self.alertBlock = alertBlock;
        self.title = title;
        self.message = message;
        self.alertStyle = G100AlertViewStyleDefault;
        
        // 底部设置一个 scrollView
        UIScrollView *backScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        backScrollView.scrollEnabled = NO;
        backScrollView.backgroundColor = [UIColor clearColor];
        backScrollView.showsVerticalScrollIndicator = NO;
        backScrollView.showsHorizontalScrollIndicator = NO;
        backScrollView.bounces = NO;
        [self addSubview:backScrollView];
        
        // 添加手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        [backScrollView addGestureRecognizer:tap];
        
        // 画图
        _alertView = [[UIView alloc]initWithFrame:CGRectMake(20, HEIGHT / 2 - 60, WIDTH - 40, 120)];
        _alertView.backgroundColor = MyBackColor;
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.cornerRadius = 6.0f;
        _alertView.tag = 200;
        _alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_alertView];
        
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _alertView.v_width, KROWHEIGHT - 10)];
        _titleView.backgroundColor = MyNavColor;
        [_alertView addSubview:_titleView];
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:_titleView.bounds];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.text = _title;
        [_titleView addSubview:titleLabel];

        // content
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, _titleView.v_bottom, _alertView.v_width, KROWHEIGHT)];
        _contentView.backgroundColor = MyBackColor;
        [_alertView addSubview:_contentView];
    }
    
    return self;
}

-(void)configBottomUI {
    // content
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, _contentView.v_bottom, _alertView.v_width, KROWHEIGHT + 4)];
    
    CGFloat wbutton = (_bottomView.v_width - 12 * 2 - 16) * 0.5;
    // 120:50
    self.sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureButton.frame = CGRectMake(_bottomView.v_width - 12 - wbutton, 0, wbutton, 54);
    _sureButton.tag = 101;
    
    _sureButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
    
    [_sureButton setExclusiveTouch:YES];
    [_sureButton setBackgroundImage:[[UIImage imageNamed:@"ic_location_sure_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    
    [_sureButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_sureButton];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(12, 0, wbutton, 54);
    _cancelButton.tag = 100;
    
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    
    [_cancelButton setExclusiveTouch:YES];
    [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"ic_location_cancel_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    
    _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_cancelButton];
    
    [_alertView addSubview:_bottomView];
    
    _alertView.v_height += _bottomView.v_height;
    _alertView.center = self.center;
}

// 默认
+ (void)G100AlertWithTitle:(NSString *)title message:(NSString *)message alertBlock:(G100Alert)alertBlock sureButtonTitle:(NSString *)sureButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle {
    G100AlertView * g100AlertView = [[G100AlertView alloc]initWithTitle:title message:message alertBlock:alertBlock alertBlockTF:nil];
    
    [g100AlertView configContentView];
    [g100AlertView configBottomUI];
    
    [g100AlertView show];
}
// 默认的
-(void)configContentView {
    UILabel * messageLabel = [[UILabel alloc]initWithFrame:_contentView.bounds];
    messageLabel.numberOfLines = 0;
    messageLabel.backgroundColor = [UIColor whiteColor];
    messageLabel.text = _message;
    CGSize contentSize = [_message boundingRectWithSize:CGSizeMake(messageLabel.v_width, 200) options:NSStringDrawingTruncatesLastVisibleLine |
     NSStringDrawingUsesFontLeading |
     NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil].size;
    messageLabel.v_height = contentSize.height + 30;
    messageLabel.font = [UIFont systemFontOfSize:18];
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:messageLabel];
    //
    _contentView.v_height = messageLabel.v_bottom;
    _alertView.v_height = _contentView.v_bottom;
    _alertView.center = self.center;
}
// 不带确定取消按钮
+ (void)G100AlertWithTitle:(NSString *)title alertBlock:(G100Alert)alertBlock btnTitleArr:(NSArray *)btnTitle {
    G100AlertView * alert = [[G100AlertView alloc]initWithTitle:title message:nil alertBlock:alertBlock alertBlockTF:nil];
    [alert configContentViewBtns:btnTitle];
    
    [alert show];
}
// 修改头像&性别
-(void)configContentViewBtns:(NSArray *)btnTitle {
    for (NSInteger i = 0; i < [btnTitle count]; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, (KROWHEIGHT - 10 + 1) * i, _alertView.v_width, KROWHEIGHT - 10);
        button.tag = 100 + i + 1;
        if (i == btnTitle.count - 1) {
            button.tag = 100;
        }
        [button setTitle:btnTitle[i] forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor blackColor];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        [button setExclusiveTouch:YES];
        [button setBackgroundImage:CreateImageWithColor(MySelectedColor) forState:UIControlStateHighlighted];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:button];
    }
    _contentView.v_height = (KROWHEIGHT - 10) * btnTitle.count;
    _alertView.v_height = _contentView.v_bottom;
    _alertView.center = self.center;
}

+(instancetype)G100AlertWithTitle:(NSString *)title placehoder:(NSString *)holder alertBlock:(G100AlertTf)alertBlockTF {
    G100AlertView * alert = [[G100AlertView alloc]initWithTitle:title message:nil alertBlock:nil alertBlockTF:alertBlockTF];
    
    alert.alertStyle = G100AlertViewStyleInput;
    [alert configContentViewTF:holder];
    [alert configBottomUI];
    
    return alert;
}
// 带有textfield
- (void)configContentViewTF:(NSString *)holder {
    _kbDistance = [IQKeyHelper keyboardDistanceFromTextField];
    [IQKeyHelper setKeyboardDistanceFromTextField:80];
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, _contentView.v_width - 40, 40)];
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _contentView.backgroundColor = [UIColor whiteColor];

    _textField.tag = 1000;
    _textField.text = holder;
    self.orignalString = holder;
    [_textField setBorderStyle:UITextBorderStyleLine];
    [_contentView addSubview:_textField];
    _contentView.v_height = _textField.v_bottom + 10;
    _textField.center = CGPointMake(_contentView.v_width / 2.0f, _contentView.v_height / 2.0);
    _alertView.v_height = _contentView.v_bottom;
    _alertView.center = self.center;
}

#pragma mark - 生日的日期选择器
+(void)G100DatePickerWithTitle:(NSString *)title current:(NSString *)dateStr alertBlock:(G100AlertObject)alertBlock {
    G100AlertView * dateView = [[G100AlertView alloc]initWithTitle:title message:nil alertBlock:nil alertBlockTF:nil];
    dateView.alertStyle = G100AlertViewDatePicker;
    dateView.alertObject = alertBlock;
    [dateView configDatePicker:dateStr];
    [dateView configBottomUI];
    
    [dateView show];
}

-(void)configDatePicker:(NSString *)dateStr {
    self.selectDatePicker = [[UIDatePicker alloc]init];
    self.selectDatePicker.frame = CGRectMake(0, 0, _contentView.v_width, 162);
    _contentView.backgroundColor = [UIColor whiteColor];
    self.selectDatePicker.tag = 8001;
    _selectDatePicker.datePickerMode = UIDatePickerModeDate;
    NSCalendar * greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-120]; // 设置最小时间为120年前
    NSDate * minDate = [greCalendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    _selectDatePicker.minimumDate = minDate;
    _selectDatePicker.maximumDate = [NSDate date];
    [_selectDatePicker addTarget:self action:@selector(selectDateOut:) forControlEvents:UIControlEventValueChanged];
    self.selectDatePicker.backgroundColor = [UIColor clearColor];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
    self.selectDatePicker.locale = locale;
    self.selectDateStr = dateStr;
    
    //设置为指定时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //设置日期格式
    NSString *date = dateStr.length ? dateStr : [dateFormatter stringFromDate:[NSDate date]];
    self.selectDateStr = date;
    NSDate *now = [dateFormatter dateFromString:date];
    
    [self.selectDatePicker setDate:now animated:NO];
    [_contentView addSubview:_selectDatePicker];
    //
    _contentView.v_height = _selectDatePicker.v_height;
    _alertView.v_height = _contentView.v_bottom;
    _alertView.center = self.center;
}

-(void)selectDateOut:(UIDatePicker *)picker {
    //设置为指定时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //设置日期格式
    _selectDateStr = [dateFormatter stringFromDate:picker.date];
}

#pragma mark - 城市选择器
+ (void)G100CityPickerWithTitle:(NSString *)title current:(NSString *)areaStr alertBlock:(G100AlertObject)alertBlock {
    G100AlertView * cityView = [[G100AlertView alloc]initWithTitle:title message:nil alertBlock:nil alertBlockTF:nil];
    cityView.alertStyle = G100AlertViewCitySelect;
    cityView.alertObject = alertBlock;
    cityView.selecteArea = areaStr;
    [cityView configCityPicker:areaStr];
    [cityView configBottomUI];
    [cityView show];
}
-(void)configCityPicker:(NSString *)areaStr {
    HZAreaPickerView * locatePicker = [[HZAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, _contentView.v_width, 162) Style:HZAreaPickerWithStateAndCity delegate:self];
    _contentView.backgroundColor = [UIColor whiteColor];
    
    if (areaStr && areaStr.length) {
        self.selecteArea = areaStr;
    }else {
        self.selecteArea = @"北京 通州";
    }
    
    locatePicker.defaultArea = self.selecteArea;
    
    [_contentView addSubview:locatePicker];
    
    _contentView.v_height = locatePicker.v_height;
    _alertView.v_height = _contentView.v_bottom;
    _alertView.center = self.center;
}
#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    self.selecteArea = [NSString stringWithFormat:@"%@ %@", picker.locate.state, picker.locate.city];
}

#pragma mark - 加载视图到window
- (void)show {
    [self showInVc:CURRENTVIEWCONTROLLER view:CURRENTVIEWCONTROLLER.view animation:YES];
}
- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    if (![self superview]) {
        [view addSubview:self];
    }
}

#pragma mark - 确定取消
- (void)buttonClick:(UIButton *)button {
    if (button.tag - 100 == 0) {
        [self hide];
    }else if (_alertBlock || _alertBlockTF || _alertObject) {
        if (self.alertStyle == G100AlertViewStyleInput) {
            if (_alertBlockTF) {
                self.alertBlockTF(_textField.tag - 1000, _textField.text);
            }else {
                [self hide];
            }
        }else {
            if (self.alertStyle == G100AlertViewDatePicker) {
                self.alertObject(_selectDateStr);
            }else if (self.alertStyle == G100AlertViewCitySelect){
                self.alertObject(_selecteArea);
            }else{
                if (_alertBlock) {
                    self.alertBlock(button.tag - 100);
                }
            }
            
            [self hide];
        }
    }else {
        [self hide];
    }
}

#pragma mark - 点击空白取消
-(void)tapView:(UITapGestureRecognizer *)tap {
    if (IQKeyHelper.keyboardIsVisible) {
        [self endEditing:YES];
        return;
    }
    CGPoint point = [tap locationInView:self];
    if (CGRectContainsPoint(_alertView.frame, point)) {
        return;
    }
    
    [self hide];
}

#pragma mark - 延长服务期
+ (void)G100AlertWithTitle:(NSString *)title options:(NSArray *)options alertBlock:(G100Alert)alertBlock style:(G100AlertViewStyle)style {
    G100AlertView * popView = [[G100AlertView alloc]initWithTitle:title message:nil alertBlock:alertBlock];
    popView.alertStyle = style;
    [popView configContentViewWithOptions:options];
    [popView show];
}
// 需要自定义的单选项    各种view
-(void)configContentViewWithOptions:(NSArray *)options {
    G100CustomOptions * tmpview = (G100CustomOptions *)[options safe_objectAtIndex:0];
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:_contentView.bounds];
    scrollView.bounces = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:scrollView];
    
    if (options.count >= 3) {
        scrollView.v_size = CGSizeMake(_contentView.v_width, 3 * tmpview.v_height);
        scrollView.contentSize = CGSizeMake(_contentView.v_width, tmpview.v_height * options.count);
    }else {
        scrollView.v_size = CGSizeMake(_contentView.v_width, options.count * tmpview.v_height);
        scrollView.contentSize = CGSizeMake(_contentView.v_width, tmpview.v_height * options.count);
    }
    
    for (NSInteger i = 0; i < options.count; i++) {
        G100CustomOptions * tmpview = (G100CustomOptions *)[options safe_objectAtIndex:i];
        tmpview.frame = CGRectMake(0, i * (tmpview.frame.size.height + 1), _contentView.v_width, tmpview.v_height);
        UITapGestureRecognizer * optionTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(optionSelected:)];
        [tmpview addGestureRecognizer:optionTap];
        [scrollView addSubview:tmpview];
    }
    
    _contentView.v_height = scrollView.v_height;
    _alertView.v_height = _contentView.v_bottom;
    _alertView.center = self.center;
}
-(void)optionSelected:(UITapGestureRecognizer *)optiontap {
    for (UIView * tmpView in self.contentView.subviews) {
        if (INSTANCE_OF(tmpView, [UIScrollView class])) {
            for (UIView * tmp in tmpView.subviews) {
                if (INSTANCE_OF(tmp, [G100CustomOptions class])) {
                    G100CustomOptions * view = (G100CustomOptions *)tmp;
                    view.selected = NO;
                }
            }
        }
    }
    
    G100CustomOptions * view = (G100CustomOptions *)optiontap.view;
    view.selected = YES;
    if (_alertBlock) {
        self.alertBlock(optiontap.view);
    }
    
    [self hide];
}


#pragma mark - UITextFieldDelegate
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (toBeString.length > self.maxCount) {
        return NO;
    }
    
    return YES;
}
 */

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    NSString *lang = current.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.maxCount) {
                textField.text = [toBeString subEmojiStringToIndex:self.maxCount];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > self.maxCount) {
            textField.text = [toBeString subEmojiStringToIndex:self.maxCount];
        }
    }
}

-(void)hide {
    [self dismissWithVc:self.popVc animation:YES];
    
    if ([self superview]) {
        if (_kbDistance) {
            [IQKeyHelper setKeyboardDistanceFromTextField:_kbDistance];
        }
        
        [self removeFromSuperview];
    }
}

@end
