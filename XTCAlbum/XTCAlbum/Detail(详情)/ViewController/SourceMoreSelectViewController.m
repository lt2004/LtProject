//
//  SourceMoreSelectViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "SourceMoreSelectViewController.h"

@interface SourceMoreSelectViewController ()

@end

@implementation SourceMoreSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectTableView.backgroundColor = [UIColor whiteColor];
    _selectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kScreenWidth, 195) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = bezierPath.CGPath;
    _selectTableView.layer.mask = mask;
    _selectTableView.layer.masksToBounds = YES;
    
    _selectTableView.backgroundColor = [UIColor whiteColor];
    _selectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.textLabel.font = [UIFont fontWithName:kHelvetica size:16];
    cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
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
            if (_isLock) {
                cell.textLabel.textColor = [UIColor lightGrayColor];
            } else {
                cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
            }
        }
            break;
        case 2: {
            cell.textLabel.text = @"分享";
            cell.imageView.image = [UIImage imageNamed:@"detail_more_select_share"];
            if (_isLock) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.detailSelectMoreCallBack) {
            self.detailSelectMoreCallBack(indexPath.row);
        }
    }];
}

- (IBAction)dismisButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
