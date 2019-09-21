//
//  XTCSelectPrivateAlbumViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/15.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCSelectPrivateAlbumViewController.h"

@interface XTCSelectPrivateAlbumViewController ()

@end

@implementation XTCSelectPrivateAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = @"请选择相册";
     _selelctTableView.separatorColor = kTableviewCellColor;
    
    __weak typeof(self) weakSelf = self;
    _privateArray = [[NSMutableArray alloc] init];
    [[PublishPostDataBase sharedDataBase] queryCurrentPrivateAlbumCallBack:^(NSMutableArray *privateAlbumArray) {
        for (XTCPrivateAlbumModel *albumModel in privateAlbumArray) {
            NSInteger flagCount = [self queryAllPhotoFile:albumModel.fileName];
            if (flagCount) {
                [weakSelf.privateArray addObject:albumModel];
            } else {
                
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.selelctTableView reloadData];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _privateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     XTCPrivateAlbumModel *albumModel = _privateArray[indexPath.row];
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
    }
    cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
    cell.textLabel.font = [UIFont fontWithName:kHelveticaBold size:16];
    cell.textLabel.text = albumModel.fileName;
    
    cell.detailTextLabel.textColor = RGBCOLOR(74, 74, 74);
    cell.detailTextLabel.font = [UIFont fontWithName:kHelvetica size:14];
    NSInteger flagCount = [self queryAllPhotoFile:albumModel.fileName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"文件数(%d)", (int)flagCount];
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

#pragma mark - 查询所有加密数据
- (NSInteger)queryAllPhotoFile:(NSString *)flagPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];
    NSString *documentPrivatePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", [GlobalData sharedInstance].userModel.user_id, flagPath]];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:documentPrivatePath error:nil]];
    return tempFileList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XTCPrivateAlbumModel *albumModel = _privateArray[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCPrivateAlbumForgetPwd" bundle:nil];
    XTCPrivateAlbumForgetPwdViewController *privateAlbumForgetPwdVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCPrivateAlbumForgetPwdViewController"];
    privateAlbumForgetPwdVC.albumModel = albumModel;
    [self.navigationController pushViewController:privateAlbumForgetPwdVC animated:YES];
}

- (void)backButtonClick {
    // 点击返回证明重置完毕
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPrivateResetFinish];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
