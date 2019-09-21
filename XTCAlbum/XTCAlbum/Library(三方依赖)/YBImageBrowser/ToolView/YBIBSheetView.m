//
//  YBIBSheetView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/6.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBSheetView.h"
#import "YBIBUtilities.h"
#import "YBIBCopywriter.h"


@implementation YBIBSheetAction
+ (instancetype)actionWithName:(NSString *)name byImageName:(NSString *)imageName action:(YBIBSheetActionBlock)action {
    YBIBSheetAction *sheetAction = [YBIBSheetAction new];
    sheetAction.name = name;
    sheetAction.imageName = imageName;
    sheetAction.action = action;
    return sheetAction;
}
@end

@interface YBIBSheetView () <UITableViewDelegate, UITableViewDataSource> {
    
}

@end

@implementation YBIBSheetView {
    CGRect _tableShowFrame;
    CGRect _tableHideFrame;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _cancelText = [YBIBCopywriter sharedCopywriter].cancel;
        _maxHeightScale = 0.7;
        _showDuration = 0.2;
        _hideDuration = 0.1;
        _cellHeight = 45;
        _backAlpha = 0.3;
        _actions = [NSMutableArray array];
        _isLock = NO;
        _isPrivateAlbum = NO;
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark - public

- (void)showToView:(UIView *)view orientation:(UIDeviceOrientation)orientation {
    if (self.actions.count == 0) return;
    
    [view addSubview:self];
    self.frame = view.bounds;
    
    CGFloat footerHeight = 0.01;
    CGFloat tableHeight;
    if (kDevice_Is_iPhoneX) {
        tableHeight = self.cellHeight * 4 + 15 + kBottom_iPhoneX;
    } else {
        tableHeight = self.cellHeight * 4 + 15;
    }
    
    
    _tableShowFrame = self.frame;
    _tableShowFrame.origin.y = self.bounds.size.height - tableHeight;
    
    _tableHideFrame = _tableShowFrame;
    _tableHideFrame.origin.y = self.bounds.size.height;
    
    self.backgroundColor = [RGBCOLOR(31, 31, 31) colorWithAlphaComponent:0];
    self.tableView.frame = _tableHideFrame;
    self.tableView.tableFooterView.bounds = CGRectMake(0, 0, self.tableView.frame.size.width, footerHeight);
    
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kScreenWidth, tableHeight) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = bezierPath.CGPath;
    self.tableView.layer.mask = mask;
    self.tableView.layer.masksToBounds = YES;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [UIView animateWithDuration:self.showDuration animations:^{
        self.backgroundColor = [RGBCOLOR(31, 31, 31) colorWithAlphaComponent:self->_backAlpha];
        self.tableView.frame = self->_tableShowFrame;
    }];
}

- (void)hideWithAnimation:(BOOL)animation {
    if (!self.superview) return;
    
    void(^animationsBlock)(void) = ^{
        self.tableView.frame = self->_tableHideFrame;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    };
    void(^completionBlock)(BOOL n) = ^(BOOL n){
        [self removeFromSuperview];
    };
    if (animation) {
        [UIView animateWithDuration:self.hideDuration animations:animationsBlock completion:completionBlock];
    } else {
        animationsBlock();
        completionBlock(NO);
    }
}

#pragma mark - touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    if (!CGRectContainsPoint(self.tableView.frame, point)) {
        [self hideWithAnimation:YES];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.actions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (kDevice_Is_iPhoneX) {
        return 5 + kBottom_iPhoneX;
    } else {
        return 5;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor whiteColor];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.textLabel.font = [UIFont fontWithName:kHelvetica size:16];
    cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"删除";
            cell.imageView.image = [UIImage imageNamed:@"detail_more_select_delete"];
            if (_isLock) {
                cell.textLabel.textColor = [UIColor lightGrayColor];
            } else {
                cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
            }
        }
            break;
        case 1: {
            cell.textLabel.text = @"移动";
            cell.imageView.image = [UIImage imageNamed:@"detail_more_select_move"];
            if (_isLock || _isPrivateAlbum) {
                cell.textLabel.textColor = [UIColor lightGrayColor];
            } else {
                cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
            }
        }
            break;
        case 2: {
            cell.textLabel.text = @"分享";
            cell.imageView.image = [UIImage imageNamed:@"detail_more_select_share"];
            if (_isLock || _isPrivateAlbum) {
                cell.textLabel.textColor = [UIColor lightGrayColor];
            } else {
                cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
            }
        }
            break;
        case 3: {
            if (_isLock) {
                cell.textLabel.text = @"解锁";
                cell.imageView.image = [UIImage imageNamed:@"detail_more_select_lock"];
            } else {
                cell.textLabel.text = @"锁定";
                cell.imageView.image = [UIImage imageNamed:@"detail_more_select_unlock"];
            }
            cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
        }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isLock && indexPath.row != 3) {
        
    } else {
        if (_isPrivateAlbum && (indexPath.row == 1 || indexPath.row == 2)) {
            
        } else {
            YBIBSheetAction *action = self.actions[indexPath.row];
            if (action.action) action.action(self.currentdata());
        }
    }
}

#pragma mark - getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 45;
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.alwaysBounceVertical = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
        }
    }
    return _tableView;
}

@end
