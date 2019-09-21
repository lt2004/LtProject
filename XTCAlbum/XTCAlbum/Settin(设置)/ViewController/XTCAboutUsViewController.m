//
//  XTCAboutUsViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCAboutUsViewController.h"

@implementation XTCAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = XTCLocalizedString(@"Setting_About_Us", nil);
    _aboutUsTableView.backgroundColor = [UIColor whiteColor];
    _aboutUsTableView.separatorColor = RGBCOLOR(229, 229, 229);
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 170)];
    _aboutUsTableView.tableHeaderView = headerView;
    
    UIImageView *aboutUsIconImageView = [[UIImageView alloc] init];
    aboutUsIconImageView.image = [UIImage imageNamed:@"about_us"];
    [headerView addSubview:aboutUsIconImageView];
    
    [aboutUsIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    if (@available(iOS 11.0, *)) {
        _aboutUsTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
    }
    cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
    cell.textLabel.font = [UIFont fontWithName:kHelvetica size:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = XTCLocalizedString(@"Setting_Build_Version", nil);
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            cell.detailTextLabel.text = appVersion;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 1: {
            cell.textLabel.text = XTCLocalizedString(@"Setting_Privacy_Service", nil);
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
            break;
        case 2: {
            cell.textLabel.text = XTCLocalizedString(@"Setting_About_XTC_Album", nil);
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        CommonWebViewViewController *commonWebView = [[CommonWebViewViewController alloc] init];
        commonWebView.titleString = @"隐私政策";
        commonWebView.urlString = @"http://www.viewspeaker.com/policy";
        [self.navigationController pushViewController:commonWebView animated:YES];
    } else if (indexPath.row == 2) {
        CommonWebViewViewController *commonWebView = [[CommonWebViewViewController alloc] init];
        commonWebView.titleString = @"关于小棠菜相册";
        commonWebView.urlString = @"http://www.viewspeaker.com/about";
        [self.navigationController pushViewController:commonWebView animated:YES];
    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end
