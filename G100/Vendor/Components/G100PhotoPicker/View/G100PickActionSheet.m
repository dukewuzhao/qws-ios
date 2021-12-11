//
//  G100PickActionSheet.m
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import "G100PickActionSheet.h"
#import "G100PickerSheetCell.h"

//@brief 按钮的高度
#define ACTION_SHEET_TITLE_HEIGHT 40.0f
#define ACTION_SHEET_BTN_HEIGHT 50.0f

@interface G100PickActionSheet () <UITableViewDataSource, UITableViewDelegate>

@property (copy,nonatomic) ClickedIndexBlock block;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) UIView *backgroundView;

@property (strong,nonatomic) NSMutableArray *otherButtons;

@property (assign,nonatomic) CGFloat tableViewHeight;
@property (assign,nonatomic) NSInteger buttonCount;

@end

@implementation G100PickActionSheet

- (instancetype)initWithTitle:(NSString *)title
               clickedAtIndex:(ClickedIndexBlock)block
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (self) {
        
        //FIXME 宝宝还不知道如何传递可变参数，只能重复地再写一遍代码了
        self.titleText = [title copy];
        self.cancelText = [cancelButtonTitle copy];
        self.block = block;
        
        self.otherButtons = [[NSMutableArray alloc]init];
        
        // 获取可变参数
        [_otherButtons addObject:otherButtonTitles];
        va_list list;
        NSString *curStr;
        va_start(list, otherButtonTitles);
        while ((curStr = va_arg(list, NSString *))) {
            
            [_otherButtons addObject:curStr];
            
        }
        
        //初始化子视图
        [self installSubViews];
        
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
               clickedAtIndex:(ClickedIndexBlock)block
            cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitlesArray:(NSArray *)otherButtonTitlesArray{
    self = [super init];
    if (self) {
        
        
        //FIXME 宝宝还不知道如何传递可变参数，只能重复地再写一遍代码了
        self.titleText = [title copy];
        self.cancelText = [cancelButtonTitle copy];
        self.block = block;
        
        self.otherButtons = [[NSMutableArray alloc]initWithArray:otherButtonTitlesArray];
        
        //初始化子视图
        [self installSubViews];
        
    }
    return self;
}
#pragma mark - Public Method
/**
 *  @brief 显示ActionSheet
 */
- (void)show
{
    __block typeof(self) weakSelf = self;
    
    [CURRENTVIEWCONTROLLER.view addSubview:self];
    self.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 0.4f;
        CGRect frame = weakSelf.tableView.frame;
        CGSize screenSisze = [UIScreen mainScreen].bounds.size;
        frame.origin.y = screenSisze.height - self.tableViewHeight;
        
        weakSelf.tableView.frame = frame;
        weakSelf.tableView.hidden = NO;
        
    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  @brief 隐藏ActionSheet
 */
-(void)hide
{
    __block typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 0.0f;
        CGRect frame = weakSelf.tableView.frame;
        CGSize screenSisze = [UIScreen mainScreen].bounds.size;
        frame.origin.y = screenSisze.height + self.tableViewHeight;
        
        weakSelf.tableView.frame = frame;
    } completion:^(BOOL finished) {
        weakSelf.hidden = YES;
        weakSelf.tableView.hidden = YES;
        [weakSelf removeFromSuperview];
        
    }];
}

/**
 *  @brief 添加按钮
 *
 *  @param title 按钮标题
 *
 *  @return 按钮的Index
 */
- (NSInteger)addButtonWithTitle:(NSString *)title {
    [self.otherButtons addObject:[title copy]];
    return self.otherButtons.count - 1;
}

#pragma mark - Private

/**
 *  @brief 初始化子视图
 */
- (void)installSubViews {
    
    self.frame = [UIScreen mainScreen].bounds;
    
    // 初始化遮罩视图
    self.backgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.142 alpha:1.000];
    self.backgroundView.alpha = 0.0f;
    [self addSubview:_backgroundView];
    
    // 初始化TableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f,self.bounds.size.height, self.bounds.size.width, self.tableViewHeight)
                                                 style:UITableViewStylePlain];
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self addSubview:_tableView];
    
    // TableView加上高斯模糊效果
    if (NSClassFromString(@"UIVisualEffectView") && !UIAccessibilityIsReduceTransparencyEnabled()) {
        self.tableView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [blurEffectView setFrame:self.tableView.frame];
        
        self.tableView.backgroundView = blurEffectView;
    }
    
    // 遮罩加上手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    [self.backgroundView addGestureRecognizer:tap];
    
    self.hidden = YES;
    self.tableView.hidden = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"G100PickerSheetCell" bundle:nil] forCellReuseIdentifier:@"G100PickerSheetCell"];
}

#pragma mark - Util
/**
 *  颜色转图片
 *
 *  @param color 颜色
 *
 *  @return 图片
 */
-(UIImage *)imageWithUIColor:(UIColor *)color{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - GET/SET

/**
 *  @brief TableView高度
 *
 *  @return TableView高度
 */
-(CGFloat)tableViewHeight {
    return self.buttonCount * ACTION_SHEET_BTN_HEIGHT + (self.titleText.length > 0 ? ACTION_SHEET_TITLE_HEIGHT : 0) + kBottomPadding;
}

/**
 *  @brief 按钮的总个数(包括Title和取消)
 *
 *  @return 按钮的总个数
 */
-(NSInteger)buttonCount {
    
    NSInteger count = 0;
    
    if(self.cancelText && ![@"" isEqualToString:self.cancelText]) {
        count+=1;
    }
    
    count+=self.otherButtons.count;
    
    
    return count;
    
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return ACTION_SHEET_BTN_HEIGHT + kBottomPadding;
    }
    
    return ACTION_SHEET_BTN_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(section == 0 && self.titleText) {
        return ACTION_SHEET_TITLE_HEIGHT;
    }
    
    if(section == 1 && self.cancelText) {
        return 5.0f;
    }
    
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 0 && self.titleText) {
        
        UILabel *label = [[UILabel alloc]init];
        [label setFont:[UIFont systemFontOfSize:15.0f]];
        [label setText:self.titleText];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor lightGrayColor]];
        [label setAdjustsFontSizeToFitWidth:YES];
        UIImageView *sepLine = [[UIImageView alloc]initWithImage:[self imageWithUIColor:[UIColor lightGrayColor]]];
        sepLine.frame = CGRectMake(0, ACTION_SHEET_TITLE_HEIGHT - 0.3f, self.tableView.bounds.size.width, 0.3f);
        [label addSubview:sepLine];
        
        return label;
    }
    
    
    if(section == 1 && self.cancelText) {
        
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor lightGrayColor];
        
        return view;
        
    }
    
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = self.otherButtons.count;
    
    if(indexPath.section == 0) {
        index = indexPath.row+1;
    }else if (indexPath.section == 1) {
        index = 0;
    }
    
    // Block方式返回结果
    if(self.block) {
        self.block(index);
    }
    
    [self hide];
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"G100PickerSheetCell";
    G100PickerSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    [cell.oneLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [cell.oneLabel setTextColor:[UIColor blackColor]];
    [cell.oneLabel setTextAlignment:NSTextAlignmentCenter];
    
    if(indexPath.section == 0){
        [cell.oneLabel setText:self.otherButtons[indexPath.row]];
    }
    
    if(indexPath.section == 1){
        [cell.oneLabel setText:self.cancelText];
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(self.cancelText) {
        return 2;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return self.otherButtons.count;
    }
    
    if(section == 1 && self.cancelText) {
        return 1;
    }
    
    return 0;
}
@end
