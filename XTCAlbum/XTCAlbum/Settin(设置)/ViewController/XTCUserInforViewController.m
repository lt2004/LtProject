//
//  XTCUserInforViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCUserInforViewController.h"

@implementation XTCUserInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = XTCLocalizedString(@"Infor_User_Info", nil);
    if (@available(iOS 11.0, *)) {
        self.userInforTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.userInforTableView.backgroundColor = [UIColor whiteColor];
    self.userInforTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_exitButton addTarget:self action:@selector(exitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_exitButton setTitle:XTCLocalizedString(@"XTC_Login_Exit", nil) forState:UIControlStateNormal];
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *cellName = @"XTCUserHeaderCellName";
        XTCUserHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[XTCUserHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        [cell.userHeaderButton sd_setImageWithURL:[NSURL URLWithString:[GlobalData sharedInstance].userModel.headimgurl] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageRetryFailed];
        cell.titleLabel.textColor = RGBCOLOR(31, 31, 31);
        cell.titleLabel.font = [UIFont fontWithName:kHelvetica size:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.userHeaderButton addTarget:self action:@selector(userHeaderButtonClick) forControlEvents:UIControlEventTouchUpInside];
        cell.userHeaderButton.backgroundColor = kTableviewColor;
        cell.titleLabel.text = XTCLocalizedString(@"Infor_Head_Portrait", nil);
        return cell;
    } else {
        static NSString *cellName = @"cellName";
        XTCUserInforCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[XTCUserInforCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
        }
        cell.textLabel.font = [UIFont fontWithName:kHelvetica size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:kHelvetica size:16];
        cell.textLabel.textColor = RGBCOLOR(31, 31, 31);
        cell.detailTextLabel.textColor = RGBCOLOR(31, 31, 31);
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch (indexPath.row) {
            case 1: {
                cell.textLabel.text = XTCLocalizedString(@"Infor_Nick_Name", nil);
                cell.detailTextLabel.text = [GlobalData sharedInstance].userModel.nick_name;
            }
                break;
            case 2: {
                cell.textLabel.text = XTCLocalizedString(@"Login_Phone", nil);
                cell.detailTextLabel.text = [GlobalData sharedInstance].userModel.mobile;
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            }
                break;
            case 3: {
                cell.textLabel.text = XTCLocalizedString(@"Infor_Modify_Password", nil);
                cell.detailTextLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 75.0f;
    } else {
        return 50.0f;
    }
    
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

- (void)exitButtonClick {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:XTCLocalizedString(@"Login_Exit_Title", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"XTC_Login_Exit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            XTCUserModel *userModel = [[XTCUserModel alloc] init];;
            [GlobalData sharedInstance].userModel = [[XTCUserModel alloc] init];
            [[EGOCache globalCache] setObject:userModel forKey:CACHE_USER_OBJECT];
            if (weakSelf.exitLoginCallBack) {
                weakSelf.exitLoginCallBack(NO);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 1) {
        [self modifyNickName];
    }
    if (indexPath.row == 3) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"XTCModifyPassword" bundle:nil];
        XTCModifyPasswordViewController *modifyPasswordVC = [storyBoard instantiateViewControllerWithIdentifier:@"XTCModifyPasswordViewController"];
        modifyPasswordVC.hidesBottomBarWhenPushed = YES;
        modifyPasswordVC.modifyPasswordSuccessBlock = ^() {
            XTCUserModel *userModel = [[XTCUserModel alloc] init];;
            [GlobalData sharedInstance].userModel = [[XTCUserModel alloc] init];
            [[EGOCache globalCache] setObject:userModel forKey:CACHE_USER_OBJECT];
            if (weakSelf.exitLoginCallBack) {
                weakSelf.exitLoginCallBack(YES);
            }
        };
        [self.navigationController pushViewController:modifyPasswordVC animated:YES];
    }
}

- (void)modifyNickName {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"昵称" message:@"请输入您想要修改的昵称" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = [GlobalData sharedInstance].userModel.nick_name;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *login = alertController.textFields.firstObject;
        SetinfoRequestModel *requestModel = [[SetinfoRequestModel alloc] init];
        requestModel.nick_name = login.text;
        requestModel.token = [GlobalData sharedInstance].userModel.token;
        requestModel.user_id = [GlobalData sharedInstance].userModel.user_id;
        [[XTCNetworkManager shareRequestConnect] networkingCommonByRequestEnum:RequestSetinfoEnum byRequestDict:requestModel callBack:^(id object, RSResponseErrorModel *errorModel) {
            if (errorModel.errorEnum == ResponseSuccessEnum) {
                [KVNProgress showSuccessWithStatus:@"修改成功" completion:^{
                    [GlobalData sharedInstance].userModel.nick_name = login.text;
                    [[EGOCache globalCache] setObject:[GlobalData sharedInstance].userModel forKey:CACHE_USER_OBJECT];
                    [weakSelf.userInforTableView reloadData];
                    if (weakSelf.modifyNickNameCallBack) {
                        weakSelf.modifyNickNameCallBack();
                    }
                }];
            } else {
                [KVNProgress showErrorWithStatus:errorModel.errorString completion:^{
                    
                }];
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)userHeaderButtonClick {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];;
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"Info_Select_Photograph", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [XTCPermissionManager imagePickerHelperByImagePickerEnum:XTCImagePickerCameraEnum byMessage:@"更换头像拍照需要使用您的相机权限" byViewController:self callback:^(PermissionEnum permissionFlag) {
            if (permissionFlag == PermissionNotSureEnum) {
                
            } else {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
        }];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:XTCLocalizedString(@"Info_Select_Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [XTCPermissionManager imagePickerHelperByImagePickerEnum:XTCImagePickerPhotoEnum byMessage:@"相册选择照片需要访问您的相册权限" byViewController:self callback:^(PermissionEnum permissionFlag) {
            if (permissionFlag == PermissionNotSureEnum) {
                
            } else {
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:albumAction];
    [alert addAction:cameraAction];
    [alert addAction:cancelAction];
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        XTCUserHeaderCell *cell = (XTCUserHeaderCell *)[self.userInforTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        popPresenter.sourceView = cell.userHeaderButton;
        popPresenter.sourceRect = cell.userHeaderButton.bounds;
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = [[UIImage alloc] init];
    UIImage *editedImage = [[UIImage alloc] init];
    UIImage *imageToSave = [[UIImage alloc] init];
    if (CFStringCompare((CFStringRef) [info objectForKey:UIImagePickerControllerMediaType], kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (editedImage != nil) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
    }
    [picker dismissViewControllerAnimated:YES completion:^() {
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:imageToSave cropFrame:CGRectMake(0, (kScreenHeight-kScreenWidth)*0.5, kScreenWidth, kScreenWidth) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        imgCropperVC.cancelTitle = @"取消";
        imgCropperVC.confirmTitle = @"确定";
        imgCropperVC.shouldInitiallyAspectFillImage = YES;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            
        }];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    __weak typeof(self) weakSelf = self;
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
    editedImage = [editedImage resizedImageToSize:CGSizeMake(320, 320)];
    if (editedImage) {
        [KVNProgress showWithStatus:XTCLocalizedString(@"XTC_Loading", nil)];
        NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.6);
        NSDictionary *para = @{@"_method":@"DELETE",
                               @"token":[GlobalData sharedInstance].userModel.token,
                               @"user_id":[GlobalData sharedInstance].userModel.user_id
                               };
        [[APIClient sharedClient] POST:@"/setheadimg" parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSData* xmlData = [@"iosimage" dataUsingEncoding:NSUTF8StringEncoding];
            [formData appendPartWithFormData:xmlData name:@"name"];
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"image.jpg" mimeType:@"image/jpg"];
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = responseObject;
            [GlobalData sharedInstance].userModel.headimgurl = dict[@"headimgurl"];
            [[EGOCache globalCache] setObject:[GlobalData sharedInstance].userModel forKey:CACHE_USER_OBJECT];
            [self.userInforTableView reloadData];
            if (weakSelf.modifyNickNameCallBack) {
                weakSelf.modifyNickNameCallBack();
            }
            [KVNProgress showSuccessWithStatus:XTCLocalizedString(@"Info_Modify_User_Image_Success", nil) completion:^{
                
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [KVNProgress showSuccessWithStatus:XTCLocalizedString(@"Info_Modify_User_Image_Failed", nil) completion:^{
                
            }];
        }];
    } else {
        [KVNProgress showSuccessWithStatus:XTCLocalizedString(@"Info_Modify_User_Image_Failed", nil) completion:^{
            
        }];
    }
}
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
