//
//  G100MenuPopView.m
//  G100
//
//  Created by William on 16/8/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MenuPopView.h"

#define CellLineEdgeInsets UIEdgeInsetsMake(0, 10, 0, 10)
#define LeftToView 10.f
#define TopToView 10.f

@interface G100MenuPopView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) G100MenuPopViewDirection direction;

@end

@implementation G100MenuPopView
- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(G100MenuPopViewDirection)direction {
    if (self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)]) {
        //背景色为clearColor
        self.backgroundColor = [UIColor clearColor];
        self.origin = origin;
        self.height = height;
        self.width = width;
        self.direction = direction;
        self.dataArray = dataArray;
        if (height <= 0) {
            height = 44;
        }
        if (direction == G100MenuPopViewDirectionLeft) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, height * _dataArray.count) style:UITableViewStylePlain];
        }else {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, -width, height * _dataArray.count) style:UITableViewStylePlain];
        }
        
        _tableView.separatorColor = [UIColor colorWithWhite:0.3 alpha:1];
        _tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
        _tableView.bounces = NO;
        _tableView.layer.cornerRadius = 3;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 1)];
        
        //注册cell
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [self addSubview:self.tableView];
        
        //cell线条
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:CellLineEdgeInsets];
        }
        
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:CellLineEdgeInsets];
        }
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.backgroundColor = [UIColor clearColor];
    //取出模型
    G100MenuPopModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.title;
    if ([model.imageName length]) {
        cell.imageView.image = [UIImage imageNamed:model.imageName];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //通知代理处理点击事件
    if ([self.delegate respondsToSelector:@selector(didSelectedAtIndexPath:)]) {
        [self.delegate didSelectedAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismiss];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:CellLineEdgeInsets];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:CellLineEdgeInsets];
    }
}

//画出尖尖
- (void)drawRect:(CGRect)rect {
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    //利用path进行绘制三角形
    CGContextBeginPath(context);//标记
    
    if (self.direction == G100MenuPopViewDirectionLeft) {
        CGFloat startX = self.origin.x + 20;
        CGFloat startY = self.origin.y;
        CGContextMoveToPoint(context, startX, startY);//设置起点
        
        CGContextAddLineToPoint(context, startX + 5, startY - 5);
        
        CGContextAddLineToPoint(context, startX + 10, startY);
    }else {
        CGFloat startX = self.origin.x - 20;
        CGFloat startY = self.origin.y;
        CGContextMoveToPoint(context, startX, startY);//设置起点
        
        CGContextAddLineToPoint(context, startX + 5, startY - 5);
        
        CGContextAddLineToPoint(context, startX + 10, startY);
    }
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    [self.tableView.backgroundColor setFill]; //设置填充色
    
    
    [self.tableView.backgroundColor setStroke];
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
    
    
}

- (void)pop {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    //动画效果弹出
    self.alpha = 0;
    CGRect frame = self.tableView.frame;
    self.tableView.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self.tableView.frame = frame;
    }];
}

- (void)dismiss {
    //动画效果淡出
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.tableView.frame = CGRectMake(self.origin.x, self.origin.y, self.width, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if (self.dismissOperation) {
                self.dismissOperation();
            }
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:self.tableView]) {
        [self dismiss];
    }
}

@end

#pragma mark - G100MenuPopModel

@implementation G100MenuPopModel

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName {
    G100MenuPopModel *model = [[G100MenuPopModel alloc] init];
    model.title = title;
    model.imageName = imageName;
    return model;
}


@end
