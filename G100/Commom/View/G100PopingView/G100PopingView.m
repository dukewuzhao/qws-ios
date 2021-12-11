//
//  G100PopingView.m
//  G100
//
//  Created by William on 16/8/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PopingView.h"
#import "G100OptionsCell.h"
#import <UIImageView+WebCache.h>
#import "G100ConfirmView.h"
#import "PictureCaptcha.h"
#import <YYText.h>
@implementation G100PopingView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = KEY_WINDOW.frame;
    self.popingView.layer.masksToBounds = YES;
    self.popingView.layer.cornerRadius  = 6.0f;
    self.backgorundTouchEnable = YES;
    
    // 默认居中显示
    self.contentAlignment = PopContentAlignmentCenter;
    
    self.otherButtonTitle = @"取消";
    self.confirmButtonTitle = @"确定";
}

- (void)setNoticeType:(ClickNoticeType)noticeType {
    _noticeType = noticeType;
    [self.confirmClickView.confirmBtn setTitle:self.confirmButtonTitle forState:UIControlStateNormal];
    [self.confirmClickView.otherBtn setTitle:self.otherButtonTitle forState:UIControlStateNormal];
    switch (noticeType) {
        case ClickEventBlockCancel:
            [self.confirmClickView.otherBtn setTitleColor:[UIColor colorWithHexString:@"FF7200"] forState:UIControlStateNormal];
            break;
        case ClickEventBlockDefine:
            [self.confirmClickView.otherBtn setTitleColor:[UIColor colorWithHexString:@"EE1515"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.controlHidden) {
        self.popingView.v_height -= 46;
    }
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    if (![self superview]) {
        [super showInVc:vc view:view animation:animation];
        
        [view addSubview:self];
    }
}

-(void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    if ([self superview]) {
        [super dismissWithVc:vc animation:animation];
        
        [self removeFromSuperview];
    }
}

- (IBAction)btnClickAction:(UIButton *)sender {
    
    if (self.clickEvent) {
        self.clickEvent(sender.tag);
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.backgorundTouchEnable) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        if (!CGRectContainsPoint(self.popingView.frame, point)) {
            if (self.clickEvent) {
                self.clickEvent(0);
            }
        }
    }
}

- (void)setConfirmClickType:(ConfirmClickType)confirmClickType {
    _confirmClickType = confirmClickType;
    switch (confirmClickType) {
        case ConfirmClickTypeSingle:
            self.confirmClickView = [G100ConfirmView loadSingleConfirmView];
            break;
        case ConfirmClickTypeDouble:
            self.confirmClickView = [G100ConfirmView loadDoubleConfirmView];
            break;
        default:
            break;
    }
    
    [self.confirmView addSubview:self.confirmClickView];
    [self.confirmClickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    __weak G100PopingView * wself = self;
    self.confirmClickView.confirmBtnClick = ^(NSInteger index) {
        if (wself.clickEvent) {
            wself.clickEvent(index);
        }
    };
}

@end


@implementation G100ImageTextPopingView : G100PopingView

+ (instancetype)popingViewWithImageTextView {
    G100ImageTextPopingView * pop = [[[NSBundle mainBundle]loadNibNamed:@"G100ImageTextPopingView" owner:self options:nil]firstObject];
    return pop;
}

- (void)showPopingViewWithTitle:(NSString *)title image:(UIImage *)image content:(NSString *)content noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    
    if (!otherTitle && !confirmTitle) {
        self.controlHidden = YES;
    }
    
    if (!otherTitle) {
        self.confirmClickType = ConfirmClickTypeSingle;
    }else{
        self.confirmClickType = ConfirmClickTypeDouble;
    }
    
    self.title.text = title;
    self.otherButtonTitle = otherTitle;
    self.confirmButtonTitle = confirmTitle;
    self.noticeType = noticeType;
    self.imageViewHeightConstraint.constant = (WIDTH-140)*(image.size.height/image.size.width);
    self.imageView.image = image;
    self.contentLabel.text = content;
    
    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    
    [self showInVc:viewController view:baseView animation:YES];
}

@end

@implementation G100HomeSetPopingView : G100PopingView

+ (instancetype)popingViewWithHomeSetView {
    G100HomeSetPopingView * pop = [[[NSBundle mainBundle] loadNibNamed:@"G100HomeSetPopingView" owner:self options:nil]firstObject];
    return pop;
}

- (void)showPopingViewWithImage:(UIImage *)image topContent:(NSString *)topContent bottomContent:(NSString *)bottomContent confirmTitle:(NSString *)confirmTitle otherTitle:(NSString *)otherTitle clickEvent:(ClickSureBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    if (!otherTitle) {
        self.closeButton.hidden = YES;
    }else{
        self.closeButton.hidden = NO;
    }
    self.confirmClickView.hidden = YES;
    self.topContent.text = topContent;
    self.bottomContent.text = bottomContent;
    [self.sureTitle setTitle:confirmTitle forState:UIControlStateNormal];
    self.imageHeightConstraint.constant = (WIDTH-140)*(image.size.height/image.size.width);
    self.imageView.image = image;
    if (clickEvent) {
        self.sureBlock = clickEvent;
    }
    [self showInVc:viewController view:baseView animation:YES];
        
}
- (IBAction)closeView:(id)sender {
    [self dismissWithVc:self.popVc animation:YES];
}
- (IBAction)sureClicked:(id)sender {
    if (self.sureBlock) {
        self.sureBlock();
    }
    [self closeView:nil];
}

@end

@interface G100OptionsPopingView () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * options;

@end

@implementation G100OptionsPopingView : G100PopingView

+ (instancetype)popingViewWithOptionsView {
    G100OptionsPopingView * pop = [[[NSBundle mainBundle]loadNibNamed:@"G100OptionsPopingView" owner:self options:nil]firstObject];
    return pop;
}

- (void)showPopingViewWithTitle:(NSString *)title options:(NSArray *)options noticeType:(ClickNoticeType)noticeType optionsMode:(OptionsMode)optionsMode otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    
    if (!otherTitle && !confirmTitle) {
        self.controlHidden = YES;
    }
    
    if (!otherTitle) {
        self.confirmClickType = ConfirmClickTypeSingle;
    }else{
        self.confirmClickType = ConfirmClickTypeDouble;
    }
    
    self.title.text = title;
    self.otherButtonTitle = otherTitle;
    self.confirmButtonTitle = confirmTitle;
    self.options = [NSArray arrayWithArray:options];
    self.noticeType = noticeType;
    self.optionsMode = optionsMode;
    
    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    
    [self showInVc:viewController view:baseView animation:YES];
    if (self.options.count > 0) {
        self.tableViewHeightConstraint.constant = 46 * self.options.count;
    }
}

- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier = [NSString stringWithFormat:@"optionCell-%@", @(indexPath.row)];
    G100OptionsCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[G100OptionsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.optionLabel.text = self.options[indexPath.row];
    if (self.optionsMode == OptionsModeSingle) {
        if (indexPath.row == _selectedIndex - 1) {
            cell.optionImageView.image = [UIImage imageNamed:@"ic_poping_single_selected"];
        }else{
            cell.optionImageView.image = [UIImage imageNamed:@"ic_poping_single_normal"];
        }
    }else if (self.optionsMode == OptionsModeMultiple) {
        if ([self.selectedArray containsObject:@(indexPath.row+1)]) {
            cell.optionImageView.image = [UIImage imageNamed:@"ic_poping_multi_selected"];
        }else{
            cell.optionImageView.image = [UIImage imageNamed:@"ic_poping_multi_normal"];
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.optionsMode == OptionsModeSingle) {
        _selectedIndex = indexPath.row + 1;
    }else if (self.optionsMode == OptionsModeMultiple) {
        if ([self.selectedArray containsObject:@(indexPath.row+1)]) {
            [self.selectedArray removeObject:@(indexPath.row+1)];
        }else{
            [self.selectedArray addObject:@(indexPath.row+1)];
        }
    }
    [self.tableView reloadData];
}

@end


@implementation G100ReactivePopingView : G100PopingView

+ (instancetype)popingViewWithReactiveView {
    G100ReactivePopingView * pop = [[[NSBundle mainBundle]loadNibNamed:@"G100ReactivePopingView" owner:self options:nil]firstObject];
    return pop;
}

+ (instancetype)popingViewWithHintReactiveView {
    G100ReactivePopingView * pop = [[[NSBundle mainBundle]loadNibNamed:@"G100ReactivePopingView" owner:self options:nil]lastObject];
    return pop;
}

- (void)configConfirmViewTitleColorWithConfirmColor:(NSString *)cofirmColor otherColor:(NSString *)otherColor {
    [self.confirmClickView.confirmBtn setTitleColor:[UIColor colorWithHexString:cofirmColor] forState:UIControlStateNormal];
    [self.confirmClickView.otherBtn setTitleColor:[UIColor colorWithHexString:otherColor] forState:UIControlStateNormal];
}

- (void)showPopingViewWithTitle:(NSString *)title content:(NSString *)content noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    
    if (!otherTitle && !confirmTitle) {
        self.controlHidden = YES;
    }
    
    if (!otherTitle) {
        self.confirmClickType = ConfirmClickTypeSingle;
    }else{
        self.confirmClickType = ConfirmClickTypeDouble;
    }
    
    self.title.text = title;
    self.otherButtonTitle = otherTitle;
    self.confirmButtonTitle = confirmTitle;
    self.contentLabel.text = content;
    
    /** 居中显示
    CGSize size = [self.contentLabel.text calculateSize:CGSizeMake(self.contentLabel.frame.size.width, 100) font:[UIFont systemFontOfSize:17]];
    if (size.height > 21) {
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
    }
     */
    
    self.contentLabel.textAlignment = (NSTextAlignment)self.contentAlignment;
    
    self.noticeType = noticeType;
    
    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    
    [self showInVc:viewController view:baseView animation:YES];
}

- (void)showRichTextPopingViewWithTitle:(NSString *)title content:(NSString *)content  richText:(NSString *)richText noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent ClickRichTextlBlock:(ClickRichTextlBlock)ClickRichTextlBlock onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    if (!otherTitle && !confirmTitle) {
        self.controlHidden = YES;
    }
    if (!otherTitle) {
        self.confirmClickType = ConfirmClickTypeSingle;
    }else{
        self.confirmClickType = ConfirmClickTypeDouble;
    }
    self.promptLabel = [[YYLabel alloc] init];
    self.promptLabel.numberOfLines = 0;
    [self addSubview:self.promptLabel];
    
    if ([self.promptLabel superview] && [self.contentLabel superview]) {
        [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentLabel);
        }];
    }

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:content];
    text = [self setRichTextWithContent:content mutableString:text ClickRichTextlBlock:ClickRichTextlBlock richText:richText richTextArr:nil];
    self.title.text = title;
    self.otherButtonTitle = otherTitle;
    self.confirmButtonTitle = confirmTitle;
    self.noticeType = noticeType;
    self.contentLabel.attributedText = text;
    self.promptLabel.attributedText = text;
    self.contentLabel.hidden = YES;
    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    [self showInVc:viewController view:baseView animation:YES];

}

- (void)showMultiRichTextPopingViewWithTitle:(NSString *)title content:(NSString *)content richTextArr:(NSArray *)richTextArr noticeType:(ClickNoticeType)noticeType otherTitle:(NSString *)otherTitle confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent ClickRichTextlBlock:(ClickRichTextlBlock)ClickRichTextlBlock onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView
{
    if (!otherTitle && !confirmTitle) {
        self.controlHidden = YES;
    }
    if (!otherTitle) {
        self.confirmClickType = ConfirmClickTypeSingle;
    }else{
        self.confirmClickType = ConfirmClickTypeDouble;
    }
    self.promptLabel = [[YYLabel alloc] init];
    self.promptLabel.numberOfLines = 0;
    [self addSubview:self.promptLabel];
    
    if ([self.promptLabel superview] && [self.contentLabel superview]) {
        [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentLabel);
        }];
    }
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:content];
    for (NSString *richText in richTextArr) {
        text = [self setRichTextWithContent:content mutableString:text ClickRichTextlBlock:ClickRichTextlBlock richText:richText richTextArr:richTextArr];
    }
    self.title.text = title;
    self.otherButtonTitle = otherTitle;
    self.confirmButtonTitle = confirmTitle;
    self.noticeType = noticeType;
    self.contentLabel.attributedText = text;
    self.promptLabel.attributedText = text;
    self.contentLabel.hidden = YES;
    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    [self showInVc:viewController view:baseView animation:YES];
    

}
- (NSMutableAttributedString *)setRichTextWithContent:(NSString *)content mutableString:(NSMutableAttributedString *)text ClickRichTextlBlock:(ClickRichTextlBlock )ClickRichTextlBlock richText:(NSString *)richText richTextArr:(NSArray *)richTextArr
{
    text.yy_font = self.fontOfContent ? self.fontOfContent : [UIFont systemFontOfSize:17];
    self.colorOfRichText = self.colorOfRichText ? self.colorOfRichText : [UIColor colorWithHexString:@"157EFB"];
    self.fontOfRichTextContent = self.fontOfRichTextContent?self.fontOfRichTextContent:[UIFont boldSystemFontOfSize:17];
    NSRange rangeOfRichText = [content rangeOfString:richText];
    [text yy_setColor:self.colorOfRichText range:rangeOfRichText];
    [text yy_setFont:self.fontOfRichTextContent range:rangeOfRichText];
    YYTextHighlight *highlight = [YYTextHighlight new];
    [highlight setColor:[UIColor colorWithHexString:@"C7DEF8"]];
    highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect)
    {
        if (richTextArr.count != 0) {
           NSInteger index =  [richTextArr indexOfObject: [[text string] substringWithRange:range]];
            ClickRichTextlBlock(index ? index : 0);
        }
        else
        {
            ClickRichTextlBlock(0);
        }
     
    };
    [text yy_setTextHighlight:highlight range:rangeOfRichText];
    return text;
}
@end



@implementation G100VerificationPopingView : G100PopingView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.veriTextfield.layer setBorderUIColor:[UIColor lightGrayColor]];
    [self.veriTextfield.layer setBorderWidth:1.0f];
    self.backgorundTouchEnable = NO;
}

+ (instancetype)popingViewWithVerificationView {
    G100VerificationPopingView * pop = [[[NSBundle mainBundle]loadNibNamed:@"G100VerificationPopingView" owner:self options:nil]firstObject];
    return pop;
}

-(void)setPictureCap:(PictureCaptcha *)pictureCap
{
    _pictureCap = pictureCap;
    self.picvcurl = _pictureCap.url;
    self.sessionid = _pictureCap.session_id;
    self.picID = _pictureCap.ID;
}
- (void)showPopingViewWithUsageType:(G100VerificationCodeUsage)usageType clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    self.confirmClickType = ConfirmClickTypeDouble;
    self.title.text = @"请输入验证码";
    self.otherButtonTitle = @"取消";
    self.confirmButtonTitle = @"确定";
    self.usageType = usageType;
    self.noticeType = ClickEventBlockCancel;

    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    [self showInVc:viewController view:baseView animation:YES];
    [self refreshVeriCode];
}

- (IBAction)refreshVeriCode:(UIButton *)sender {
    sender.enabled = NO;
    [self refreshVeriCode];
}

- (void)setUsageType:(G100VerificationCodeUsage)usageType picvcurl:(NSString *)picvcurl {
    
    _usageType = usageType;
    self.veriTextfield.text = @"";
   
    [self.veriImageView sd_setImageWithURL:[NSURL URLWithString:picvcurl] placeholderImage:[UIImage imageNamed:@"ic_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.refreshBtn.enabled = YES;
        if (!image) { //加载失败
            self.veriImageView.image = [UIImage imageNamed:@"ic_load_failed"];
        }
    }];

}
- (void)refreshVeriCode {
    
    [[G100UserApi sharedInstance] sv_requestPicvcVerificationWithUsage:self.usageType callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        self.refreshBtn.enabled = YES;
        if (requestSuccess) {
            self.veriTextfield.text = @"";
            if ([response needPicvcVerified]) { //验证码图片url
                self.pictureCap = [[PictureCaptcha alloc] initWithDictionary:response.data[@"picture_captcha"]];
            }
            [self setUsageType:self.usageType picvcurl:self.picvcurl];
            
        }else{
            self.veriImageView.image = [UIImage imageNamed:@"ic_load_failed"];
        }
    }];
}

@end

@implementation G100TextEnterPopingView : G100PopingView

+ (instancetype)popingViewWithTextEnterView
{
    G100TextEnterPopingView * pop = [[[NSBundle mainBundle]loadNibNamed:@"G100TextEnterPopingView" owner:self options:nil]firstObject];
    pop.max_count = 10;
    pop.max_hint = @"已到输入上限";
    return pop;
}

- (void)showPopingViewWithclickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;
{
    
    self.confirmClickType = ConfirmClickTypeDouble;
    self.otherButtonTitle = @"取消";
    self.confirmButtonTitle = @"确定";
    self.noticeType = ClickEventBlockCancel;
    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:)
                                                name:@"UITextFieldTextDidChangeNotification" object:self.enterTextfield];
   // [self.enterTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self showInVc:viewController view:baseView animation:YES];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.baseScrollView.contentSize = CGSizeMake(self.bounds.size.width, self.baseScrollView.bounds.size.height);

}
#pragma mark - UITextFieldDelegate
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@""])  //按回车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (textField == _enterTextfield) {
        if (toBeString.length > self.max_count) {
            [CURRENTVIEWCONTROLLER showHint:self.max_hint];
            return NO;
        }
    }
    return YES;
}
 */
- (void)textFieldDidChange:(NSNotification*)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"])// 简体中文输入
    {
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > self.max_count)
            {
                textField.text = [toBeString subEmojiStringToIndex:self.max_count];
                [CURRENTVIEWCONTROLLER showHint:self.max_hint];
            }
        }        
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length > self.max_count)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.max_count];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString subEmojiStringToIndex:self.max_count];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.max_count)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
            [CURRENTVIEWCONTROLLER showHint:self.max_hint];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                  name:@"UITextFieldTextDidChangeNotification"
                                                object:self.enterTextfield];
}
@end

@implementation G100StatusPopingView

+ (instancetype)popingViewWithStatusView
{
    G100StatusPopingView * pop = [[[NSBundle mainBundle]loadNibNamed:@"G100StatusPopingView" owner:self options:nil]firstObject];
    pop.statueLevel = G100StatusPopingViewLevelWarn;
    return pop;
}

- (void)setStatueLevel:(G100StatusPopingViewLevel)statueLevel {
    _statueLevel = statueLevel;
    
    NSString *hintImage = @"ic_warn";
    if (statueLevel == G100StatusPopingViewLevelOk) {
        hintImage = @"ic_agree_ok";
    } else if (statueLevel == G100StatusPopingViewLevelError) {
        hintImage = @"ic_warn";
    }
    
    self.hintImageView.image = [UIImage imageNamed:hintImage];
}

- (void)showPopingViewWithMessage:(NSString *)message confirmTitle:(NSString *)confirmTitle clickEvent:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView {
    self.confirmClickType = ConfirmClickTypeSingle;
    self.confirmButtonTitle = confirmTitle;
    self.contentLabel.text = message;
    self.noticeType = ClickEventBlockDefine;
    
    if (clickEvent) {
        self.clickEvent = clickEvent;
    }
    
    [self showInVc:viewController view:baseView animation:YES];
}

@end
