//
//  PublishDraftListViewController.m
//  vs
//
//  Created by Xie Shu on 2017/10/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishDraftListViewController.h"
#import "PublishDraftCell.h"

@interface PublishDraftListViewController () {
    
}

@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@end

@implementation PublishDraftListViewController
@synthesize draftTableView = _draftTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *flagArray = [[XTCPublishManager sharePublishManager] queryAllPublishMainData];
    NSMutableArray *draftArray = [[NSMutableArray alloc] init];
    for (XTCPublishMainModel *publishMainModel in flagArray) {
        XTCDraftPublishModel *draftPublishModel = [[XTCDraftPublishModel alloc] init];
        draftPublishModel.publishMainModel = publishMainModel;
        [draftArray addObject:draftPublishModel];
    }
    if (flagArray) {
        _dataSourceArray = [[NSMutableArray alloc] initWithArray:draftArray];
    } else {
        _dataSourceArray = [[NSMutableArray alloc] init];
    }
    self.navigationItem.title = @"小秘书";
    _draftTableView.estimatedRowHeight = 50.0f;
    _draftTableView.rowHeight = UITableViewAutomaticDimension;
    _draftTableView.backgroundColor = kTableviewColor;
    _draftTableView.separatorColor = kTableviewCellColor;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postUploadProgress:) name:@"PostUploadProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishPostSuccessClick) name:@"PublishPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishPostFailedClick) name:@"PublishPostFailed" object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XTCDraftPublishModel *publishMainModel = [_dataSourceArray objectAtIndex:indexPath.row];
    static NSString *cellName = @"PublishDraftCellName";
    PublishDraftCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[PublishDraftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell insertDataToCell:publishMainModel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([XTCPublishManager sharePublishManager].isPubishLoading) {
        
        NSString *publishCorver = [[XTCPublishManager sharePublishManager].publishDraftCoverPath componentsSeparatedByString:@"/"].lastObject;
        NSString *flagCorver = [publishMainModel.publishMainModel.draft_cover componentsSeparatedByString:@"/"].lastObject;
        if ([publishCorver isEqualToString:flagCorver]) {
            // 发布中情况
            float progress = [XTCPublishManager sharePublishManager].uploadProgress;
            cell.circleProgress.progress = progress;
            cell.circleProgress.pathFillColor = HEX_RGB(0x8FDA3C);
        } else {
            cell.circleProgress.pathFillColor = RGBCOLOR(204, 204, 204);
        }
    } else {
        cell.circleProgress.pathFillColor = RGBCOLOR(204, 204, 204);
    }

    cell.circleProgress.tag = indexPath.row;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startUploadPostFile:)];
    [cell.circleProgress addGestureRecognizer:tapGes];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    XTCDraftPublishModel *publishMainModel = [_dataSourceArray objectAtIndex:indexPath.row];
    if ([XTCPublishManager sharePublishManager].isPubishLoading) {
        NSString *publishCorver = [[XTCPublishManager sharePublishManager].publishDraftCoverPath componentsSeparatedByString:@"/"].lastObject;
        NSString *flagCorver = [publishMainModel.publishMainModel.draft_cover componentsSeparatedByString:@"/"].lastObject;
        if ([publishCorver isEqualToString:flagCorver]) {
            return NO;
        } else {
            
        }
    } else {
        
    }
    return YES;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除此条帖子草稿" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"删除成功"];
            });
            XTCDraftPublishModel *publishMainModel = [self.dataSourceArray objectAtIndex:indexPath.row];
            [publishMainModel.publishMainModel MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self.dataSourceArray removeObjectAtIndex:indexPath.row];
            [self.draftTableView reloadData];
           
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}
// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 添加一个删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除此条帖子草稿" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"删除成功"];
            });
            XTCDraftPublishModel *publishMainModel = [self.dataSourceArray objectAtIndex:indexPath.row];
            [publishMainModel.publishMainModel MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self.dataSourceArray removeObjectAtIndex:indexPath.row];
            [self.draftTableView reloadData];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
        
    }];
    return @[deleteRowAction];
}

- (void)startUploadPostFile:(UIGestureRecognizer *)tagGes {
    if ([XTCPublishManager sharePublishManager].isPubishLoading) {
        
    } else {
        ZZCircleProgress *circleProgress = (ZZCircleProgress *)tagGes.view;
        XTCDraftPublishModel *publishMainModel = [_dataSourceArray objectAtIndex:circleProgress.tag];
        [[XTCPublishManager sharePublishManager] publishPost:publishMainModel.publishMainModel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.draftTableView reloadData];
        });
        
    }
   
}

- (void)postUploadProgress:(NSNotification*)notification
{
    NSInteger flagPublishIndex = 0;
    for (int i=0; i<_dataSourceArray.count; i++) {
        XTCDraftPublishModel *publishMainModel = _dataSourceArray[i];
        NSString *publishCorver = [[XTCPublishManager sharePublishManager].publishDraftCoverPath componentsSeparatedByString:@"/"].lastObject;
        NSString *flagCorver = [publishMainModel.publishMainModel.draft_cover componentsSeparatedByString:@"/"].lastObject;
        if ([publishCorver isEqualToString:flagCorver]) {
            flagPublishIndex = i;
        } else {
            
        }
    }
    PublishDraftCell *cell = [_draftTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:flagPublishIndex inSection:0]];
    NSDictionary *progressDict = notification.userInfo;
    DDLogInfo(@"%@", progressDict);
    float flagProgress = [[progressDict objectForKey:@"Progress"] floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        // 上传进度
        cell.circleProgress.progress = flagProgress;
        cell.circleProgress.pathFillColor = HEX_RGB(0x8FDA3C);
    });
}

- (void)publishPostSuccessClick {
    NSInteger flagPublishIndex = 0;
    for (int i=0; i<_dataSourceArray.count; i++) {
        XTCDraftPublishModel *publishMainModel = _dataSourceArray[i];
        NSString *publishCorver = [[XTCPublishManager sharePublishManager].publishDraftCoverPath componentsSeparatedByString:@"/"].lastObject;
        NSString *flagCorver = [publishMainModel.publishMainModel.draft_cover componentsSeparatedByString:@"/"].lastObject;
        if ([publishCorver isEqualToString:flagCorver]) {
            flagPublishIndex = i;
        } else {
            
        }
    }
    [_dataSourceArray removeObjectAtIndex:flagPublishIndex];
    [XTCPublishManager sharePublishManager].isPubishLoading = NO;
     [_draftTableView reloadData];
}

- (void)publishPostFailedClick {
    [_draftTableView reloadData];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PostUploadProgress" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PublishPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PublishPostFailed" object:nil];
    DDLogInfo(@"草稿箱内存释放");
}

- (void)backButtonClick {
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
