//
//  G100BaseCell.m
//  G100
//
//  Created by 温世波 on 15/12/3.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseCell.h"
#import "G100BaseItem.h"
#import "G100BaseSwitchItem.h"
#import "G100BaseArrowItem.h"
#import "G100BaseLabelItem.h"
#import "G100BaseImageItem.h"
#import "G100BaseTextFieldItem.h"

#import <UIImageView+WebCache.h>

@interface G100BaseCell ()

@property (nonatomic, weak) UIView *divider;

@end

@implementation G100BaseCell

- (UIImageView *)arrowView
{
    if (_arrowView == nil) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_arrow"]];
    }
    return _arrowView;
}

- (UISwitch *)switchView
{
    if (_switchView == nil) {
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self action:@selector(switchStateChange) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (UIImageView *)rightImageView {
    if (_rightImageView == nil) {
        _rightImageView = [[UIImageView alloc] init];
    }
    
    __weak UIImageView * weakIv = _rightImageView;
    if (_item.rightImageUrl.length) {
        [_rightImageView sd_setImageWithURL:[NSURL URLWithString:_item.rightImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGSize imageSize = image.size;
            CGFloat imageH = CGRectGetHeight(self.frame) - 10;
            CGFloat imagew = imageH / imageSize.height * imageSize.width;
            CGRect newFrame = weakIv.frame;
            newFrame.size = CGSizeMake(imagew, imageH);
            weakIv.frame = newFrame;
        }];
    }
    
    return _rightImageView;
}

- (UITextField *)rightTextField {
    if (_rightTextField == nil) {
        _rightTextField = [[UITextField alloc] init];
        _rightTextField.delegate = self;
        _rightTextField.bounds = CGRectMake(0, 0, WIDTH-120, 30);
        _rightTextField.font = [UIFont systemFontOfSize:14];
        _rightTextField.textColor = [UIColor colorWithHexString:@"7D7D7D"];
        _rightTextField.textAlignment = NSTextAlignmentRight;
        //_rightTextField.returnKeyType = UIReturnKeyDone;
        [_rightTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _rightTextField;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 初始化操作
        
        // 1.初始化背景
        // [self setupBg];
        
        // 2.初始化子控件
        [self setupSubviews];
        
        // 3.初始化分割线
        if (NO == iOS7) {
            [self setupDivider];
        }
        
        self.maxAllowCount = NSIntegerMax;
    }
    return self;
}

/**
 *  初始化子控件
 */
- (void)setupSubviews
{
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.requriedView];
    [self.requriedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@6);
        make.centerY.equalTo(self.mas_centerY).with.offset(@-3);
    }];
    self.requriedView.hidden = YES;
}

/**
 *  初始化背景
 */
- (void)setupBg
{
    // 设置普通背景
    UIView *bg = [[UIView alloc] init];
    bg.backgroundColor = [UIColor whiteColor];
    self.backgroundView = bg;
    
    // 设置选中时的背景
    UIView *selectedBg = [[UIView alloc] init];
    selectedBg.backgroundColor = RGBColor(237, 233, 218, 1);
    self.selectedBackgroundView = selectedBg;
}

/**
 *  初始化分割线
 */
- (void)setupDivider
{
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [UIColor blackColor];
    divider.alpha = 0.2;
    [self.contentView addSubview:divider];
    self.divider = divider;
}

/**
 *  监听开关状态改变
 */
- (void)switchStateChange
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    if (self.item.key) {
    [defaults setBool:self.switchView.isOn forKey:self.item.title];
    [defaults synchronize];
    //    }
}

- (UILabel *)labelView
{
    if (_labelView == nil) {
        _labelView = [[UILabel alloc] init];
        _labelView.textAlignment = NSTextAlignmentRight;
        _labelView.font = [UIFont systemFontOfSize:14];
        _labelView.textColor = [UIColor colorWithHexString:@"7D7D7D"];
        _labelView.bounds = CGRectMake(0, 0, WIDTH - 120, 30);
    }
    return _labelView;
}

- (UILabel *)requriedView {
    if (!_requriedView) {
        _requriedView = [[UILabel alloc] init];
        _requriedView.textColor = [UIColor colorWithHexString:@"FF7200"];
        _requriedView.font = [UIFont systemFontOfSize:14];
        _requriedView.text = @"*";
    }
    return _requriedView;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"base";
    G100BaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[G100BaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    cell.maxAllowCount = NSIntegerMax;
    
    return cell;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView item:(G100BaseItem *)item {
    NSString *identifier = item.itemkey;
    if (!identifier)
        identifier = NSStringFromClass([item class]);
    G100BaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[G100BaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    cell.maxAllowCount = NSIntegerMax;
    
    return cell;
}

+ (NSString *)idForItem:(G100BaseItem *)item {
    if (item.itemkey) {
        return item.itemkey;
    }
    return NSStringFromClass([item class]);
}

+ (CGFloat)heightForItem:(G100BaseItem *)item {
    return 44;
}

+ (NSString *)cellID
{
    return NSStringFromClass([self class]);
}
+ (void)registerToTabelView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:[self cellID] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[self cellID]];
}

/**
 *  拦截frame的设置
 */
- (void)setFrame:(CGRect)frame
{
    if (NO == iOS7) {
        CGFloat padding = 10;
        frame.size.width += padding * 2;
        frame.origin.x = -padding;
    }
    [super setFrame:frame];
}

/**
 *  设置子控件的frame
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (iOS7) return;
    
    // 设置分割线的frame
    CGFloat dividerH = 1;
    CGFloat dividerW = [UIScreen mainScreen].bounds.size.width;
    CGFloat dividerX = 0;
    CGFloat dividerY = self.contentView.frame.size.height - dividerH;
    self.divider.frame = CGRectMake(dividerX, dividerY, dividerW, dividerH);
}

- (void)setItem:(G100BaseItem *)item
{
    _item = item;
    
    // 1.设置数据
    [self setupData];
    
    [self setupLeftContent];
    // 2.设置右边的内容
    [self setupRightContent];
}

- (void)setItem:(G100BaseItem *)item rightTextfiledBound:(CGRect)rightConentBound{
    _item = item;
    
    // 1.设置数据
    [self setupData];
    
    [self setupLeftContent];
    // 2.设置右边的内容
    [self setupRightContentWithRightTextfiledBound:rightConentBound];
}

- (void)setLastRowInSection:(BOOL)lastRowInSection
{
    _lastRowInSection = lastRowInSection;
    
    self.divider.hidden = lastRowInSection;
}

/**
 *  设置左边的内容 如红点提示
 */
- (void)setupLeftContent {
    if (self.item.isRequired) {
        // 必选项 需添加必选标志
        self.requriedView.hidden = NO;
    }else {
        self.requriedView.hidden = YES;
    }
}

/**
 *  设置右边的内容
 */
- (void)setupRightContent
{
    if ([self.item isKindOfClass:[G100BaseArrowItem class]]) { // 箭头
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([self.item isKindOfClass:[G100BaseSwitchItem class]]) { // 开关
        self.accessoryView = self.switchView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 设置开关的状态
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.switchView.on = [defaults boolForKey:self.item.title];
    } else if ([self.item isKindOfClass:[G100BaseLabelItem class]]) { // 标签
        self.accessoryView = self.labelView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([self.item isKindOfClass:[G100BaseImageItem class]]) {
        self.accessoryView = self.rightImageView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([self.item isKindOfClass:[G100BaseTextFieldItem class]]) {
        self.accessoryView = self.rightTextField;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.accessoryView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
}

- (void)setupRightContentWithRightTextfiledBound:(CGRect)rightTextfiledBound
{
    if ([self.item isKindOfClass:[G100BaseArrowItem class]]) { // 箭头
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([self.item isKindOfClass:[G100BaseSwitchItem class]]) { // 开关
        self.accessoryView = self.switchView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 设置开关的状态
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.switchView.on = [defaults boolForKey:self.item.title];
    } else if ([self.item isKindOfClass:[G100BaseLabelItem class]]) { // 标签
        self.accessoryView = self.labelView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([self.item isKindOfClass:[G100BaseImageItem class]]) {
        self.accessoryView = self.rightImageView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([self.item isKindOfClass:[G100BaseTextFieldItem class]]) {
        self.rightTextField.bounds = rightTextfiledBound;
        self.accessoryView = self.rightTextField;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.accessoryView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
}
/**
 *  设置数据
 */
- (void)setupData
{
    if (self.item.icon) {
        self.imageView.image = [UIImage imageNamed:self.item.icon];
    }
    
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    self.detailTextLabel.textColor = [UIColor colorWithHexString:@"7D7D7D"];

    self.textLabel.text = self.item.title;
    
    self.labelView.text = _item.subtitle;
    self.rightTextField.text = _item.subtitle;
    if ([_item isKindOfClass:[G100BaseTextFieldItem class]] ||
        [_item isKindOfClass:[G100BaseLabelItem class]]) {
        return;
    }
    self.detailTextLabel.text = self.item.subtitle;
}

#pragma mark - UITextFieldDelegate
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (toBeString.length > self.maxAllowCount) {
        [CURRENTVIEWCONTROLLER showHint:self.maxHint];
        return NO;
    }
    
    return YES;
}
 */
- (void)textFieldDidChange:(UITextField *)textField
{
    if (!_maxAllowCount) {
        _item.subtitle = textField.text;
        
        if (_textFieldChanged) {
            self.textFieldChanged(textField);
        }
        
        return;
    }
    
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
            if (toBeString.length > _maxAllowCount) {
                [CURRENTVIEWCONTROLLER showHint:self.maxHint];
                textField.text = [toBeString subEmojiStringToIndex:_maxAllowCount];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > _maxAllowCount) {
            [CURRENTVIEWCONTROLLER showHint:self.maxHint];
            textField.text = [toBeString subEmojiStringToIndex:_maxAllowCount];
        }
    }
    
    _item.subtitle = textField.text;
    
    if (_textFieldChanged) {
        self.textFieldChanged(textField);
    }
}

@end

#pragma mark - G100BaseContextCell
@implementation G100BaseContextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 初始化操作
     //  [self setupSubviews];
        
        self.maxAllowCount = NSIntegerMax;
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView item:(G100BaseItem *)item {
    NSString *identifier = item.itemkey;
    if (!identifier)
        identifier = NSStringFromClass([item class]);
    G100BaseContextCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[G100BaseContextCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.maxAllowCount = NSIntegerMax;
    
    return cell;
}

+ (CGFloat)heightForItem:(G100BaseItem *)item {
    // 根据item 的subtitle 动态计算行高
    CGFloat subH = [item.subtitle calculateSize:CGSizeMake(WIDTH - 25, 999) font:[UIFont systemFontOfSize:14]].height;
    subH = 12 + 20 + 12 + 12 + subH;
    subH = subH > 44 ? subH : 44;
    return subH;
}

- (void)setItem:(G100BaseItem *)item {
    _item = item;
    
    [self setupData];
    
    [self setupLeftContent];
}

- (void)setupSubviews {
    _contextTitleLabel = [[UILabel alloc] init];
    _contextTitleLabel.font = [UIFont systemFontOfSize:16];
    _contextDetailLabel = [[UILabel alloc] init];
    _contextDetailLabel.font = [UIFont systemFontOfSize:14];
    _contextDetailLabel.numberOfLines = 0;
    _contextDetailLabel.textColor = [UIColor colorWithHexString:@"7D7D7D"];
    
    [self.contentView addSubview:_contextTitleLabel];
    [self.contentView addSubview:_contextDetailLabel];
    
    [_contextTitleLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(@-10);
        make.top.equalTo(@12);
        make.height.equalTo(@20);
    }];
    
    [_contextDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_contextTitleLabel);
        make.trailing.equalTo(_contextTitleLabel);
        make.top.equalTo(_contextTitleLabel.mas_bottom).with.offset(12);
        make.bottom.equalTo(@-12);
    }];
    
    [self.contentView addSubview:self.requriedView];
    [self.requriedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@6);
        make.centerY.equalTo(self.mas_centerY).with.offset(@-3);
    }];
    self.requriedView.hidden = YES;
}

- (void)setupData {
    _contextTitleLabel.text = _item.title;
    _contextDetailLabel.text = _item.subtitle;
}

@end

#pragma mark - G100BaseContextEditCell
@interface G100BaseContextEditCell ()

@property (assign, nonatomic) NSInteger maxAllowCount;

@end

@implementation G100BaseContextEditCell
@dynamic maxAllowCount;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 初始化操作
      //  [self setupSubviews];
        
        self.maxAllowCount = NSIntegerMax;
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView item:(G100BaseItem *)item {
    NSString *identifier = item.itemkey;
    if (!identifier)
        identifier = NSStringFromClass([item class]);
    G100BaseContextEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[G100BaseContextEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.maxAllowCount = NSIntegerMax;
    
    return cell;
}

+ (CGFloat)heightForItem:(G100BaseItem *)item {
    // 根据item 的subtitle 动态计算行高
//    CGFloat subH = [item.subtitle calculateSize:CGSizeMake(WIDTH - 45, 999) font:[UIFont systemFontOfSize:14]].height;
//    subH = subH > 40 ? subH : 40;
//    subH = 12 + 20 + 6 + 8 + subH;
//    if (subH > 100) {
//        return 100;
//    }
    return 88;
}

- (void)setItem:(G100BaseItem *)item {
    _item = item;
    
    [self setupData];
    
    [self setupLeftContent];
}

- (void)setupSubviews {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    _contextTitleLabel = [[UILabel alloc] init];
    _contextTitleLabel.font = [UIFont systemFontOfSize:16];
    _contextDetailTextView = [[IQTextView alloc] init];
    _contextDetailTextView.font = [UIFont systemFontOfSize:14];
    _contextDetailTextView.textColor = [UIColor colorWithHexString:@"7D7D7D"];
    _contextDetailTextView.delegate = self;
    
    [self.contentView addSubview:_contextTitleLabel];
    [self.contentView addSubview:_contextDetailTextView];
    
    [_contextTitleLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(@-10);
        make.top.equalTo(@12);
        make.height.equalTo(@20);
    }];
    
    [_contextDetailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.width.equalTo(WIDTH-25);
        make.top.equalTo(_contextTitleLabel.mas_bottom);
        make.height.equalTo(@46);
    }];
    
    [self.contentView addSubview:self.requriedView];
    [self.requriedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@6);
        make.centerY.equalTo(self.mas_centerY).with.offset(@-3);
    }];
    self.requriedView.hidden = YES;
}

- (void)setupData {
    _contextTitleLabel.text = _item.title;
    _contextDetailTextView.text = _item.subtitle;
}

#pragma mark - UITextFieldDelegate
/*
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (toBeString.length > self.maxAllowCount) {
        [CURRENTVIEWCONTROLLER showHint:self.maxHint];
        return NO;
    }
    
    return YES;
}
 */
- (void)textViewDidChange:(UITextView *)textView {
    if (!self.maxAllowCount) {
        _item.subtitle = textView.text;
        return;
    }
    
    NSString *toBeString = textView.text;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    NSString *lang = current.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.maxAllowCount) {
                [CURRENTVIEWCONTROLLER showHint:self.maxHint];
                textView.text = [toBeString subEmojiStringToIndex:self.maxAllowCount];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > self.maxAllowCount) {
            [CURRENTVIEWCONTROLLER showHint:self.maxHint];
            textView.text = [toBeString subEmojiStringToIndex:self.maxAllowCount];
        }
    }
    
    _item.subtitle = textView.text;
}

@end
