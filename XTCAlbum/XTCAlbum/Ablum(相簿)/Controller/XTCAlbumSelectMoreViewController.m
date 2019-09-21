//
//  XTCAlbumSelectMoreViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/7/24.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCAlbumSelectMoreViewController.h"

@interface XTCAlbumSelectMoreViewController ()

@end

@implementation XTCAlbumSelectMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectTableView.backgroundColor = [UIColor whiteColor];
    _selectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kScreenWidth, 245) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = bezierPath.CGPath;
    _selectTableView.layer.mask = mask;
    _selectTableView.layer.masksToBounds = YES;
    _selectTableView.scrollEnabled = NO;
    
    _selectTableView.backgroundColor = [UIColor whiteColor];
    _selectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
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
            cell.textLabel.text = @"多选";
            cell.imageView.image = [UIImage imageNamed:@"home_page_more_select"];
        }
            break;
        case 1: {
            cell.textLabel.text = @"仅显示照片";
            cell.imageView.image = [UIImage imageNamed:@"home_page_show_photo"];
        }
            break;
        case 2: {
            cell.textLabel.text = @"仅显示视频";
            cell.imageView.image = [UIImage imageNamed:@"home_page_show_video"];
        }
            break;
        case 3: {
            cell.textLabel.text = @"显示全部的照片和视频";
            cell.imageView.image = [UIImage imageNamed:@"home_page_show_all"];
        }
            break;
        case 4: {
            cell.textLabel.text = @"删除";
            cell.imageView.image = [UIImage imageNamed:@"detail_more_select_delete"];
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
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectShowTypeCallBack) {
            self.selectShowTypeCallBack(indexPath.row);
        } else {
            
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
