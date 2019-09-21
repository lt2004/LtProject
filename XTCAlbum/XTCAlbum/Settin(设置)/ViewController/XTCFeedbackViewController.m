//
//  XTCFeedbackViewController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/2.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCFeedbackViewController.h"
#import <SAMTextView/SAMTextView.h>

@interface XTCFeedbackViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet SAMTextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthButton;
@property (weak, nonatomic) IBOutlet UIButton *firstDelete;
@property (weak, nonatomic) IBOutlet UIButton *secondDelete;
@property (weak, nonatomic) IBOutlet UIButton *thirdDelete;
@property (weak, nonatomic) IBOutlet UIButton *fourthDelete;
//@property (nonatomic) NSMutableArray *imageArray;
@property (nonatomic) NSMutableArray *sourceAssetArray;
@property (nonatomic) NSMutableArray *buttonArray;
@property (nonatomic) NSMutableArray *deleteButtonArray;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end



@implementation XTCFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = XTCLocalizedString(@"Setting_Send_Feedback", nil);
    
    _emailText.placeholder = XTCLocalizedString(@"Setting_Email", nil);
    
    _textView.placeholder = XTCLocalizedString(@"Setting_Send_Feedback_Content", nil);
    _textView.delegate = self;
    _textView.layoutManager.allowsNonContiguousLayout = NO;
    
    _numberLabel.text = [NSString stringWithFormat:@"%@(%lu/4)", XTCLocalizedString(@"Setting_Offer_Photo", nil), (unsigned long)_sourceAssetArray.count];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:XTCLocalizedString(@"XTC_Commit", nil) forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(0, 0, 55, 44);
    [sendButton setTitleColor:RGBCOLOR(31, 31, 31) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [sendButton addTarget:self action:@selector(feedbackAction) forControlEvents:UIControlEventTouchUpInside];
//    sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    UIBarButtonItem *rightSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSeperator.width = -10.0;
    self.navigationItem.rightBarButtonItems = @[rightSeperator, rightBarItem];
    
    
    
    _firstButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _secondButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _thirdButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _fourthButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _sourceAssetArray = [NSMutableArray array];
    _buttonArray = [NSMutableArray arrayWithObjects:_firstButton, _secondButton, _thirdButton, _fourthButton, nil];
    _deleteButtonArray = [NSMutableArray arrayWithObjects:_firstDelete, _secondDelete, _thirdDelete, _fourthDelete, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)feedbackAction {
    __weak typeof(self) wealkself = self;
    if (![self isValidateEmail:_emailText.text]) {
        [KVNProgress showErrorWithStatus:@"邮箱格式不正确" completion:^{
            
        }];
        return;
    }
    
    if (_textView.text.length == 0) {
        [KVNProgress showErrorWithStatus:@"请输入反馈内容" completion:^{
            
        }];
        return;
    }
    
    __block BOOL isFailed = NO;
    [KVNProgress showWithStatus:@"正在发送"];
    NSArray *array = [XTCSourceCompressManager compressImagesByAsset:_sourceAssetArray];
    
    
    dispatch_time_t showTime = dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC);
    dispatch_after(showTime, dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSMutableArray *images = [NSMutableArray array];
        for (NSString * filePath in array) {
            if (isFailed) {
                break;
            } else {
                
                [XTCUserModel sendOtherData:[NSURL fileURLWithPath:filePath] fileName:[filePath.pathComponents lastObject] withBlock:^(id response, NSError *error) {
                    if (response) {
                        NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
                        if ([code isEqualToString:@"1"]) {
                            // 成功
                            NSString *file_id = response[@"file_id"];
                            [images addObject:file_id];
                            dispatch_semaphore_signal(semaphore);
                        } else {
                            // 失败
                            isFailed = YES;
                            dispatch_semaphore_signal(semaphore);
                        }
                    } else {
                        // 失败
                        isFailed = YES;
                        dispatch_semaphore_signal(semaphore);
                    }
                    
                }];
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (isFailed) {
            [KVNProgress showSuccessWithStatus:@"发送失败" completion:^{
                
            }];
            return;
        } else {
            
        }
        NSString *image;
        if (images.count > 0) {
            image = [images componentsJoinedByString:@","];
        } else {
            image = @"";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [XTCUserModel feedbackEmail:wealkself.emailText.text desc:wealkself.textView.text images:image withBlock:^(id response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress dismiss];
                    if (error) {
                        [KVNProgress showSuccessWithStatus:@"发送失败" completion:^{
                            
                        }];
                    } else {
                        NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
                        if ([code isEqualToString:@"1"]) {
                            [KVNProgress showSuccessWithStatus:@"发送成功" completion:^{
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                        } else {
                            [KVNProgress showSuccessWithStatus:@"发送失败" completion:^{
                                
                            }];
                        }
                    }
                });
                
            }];
        });
        
    });
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 299) {
        [self alertMessage:@"最多只能输入300个字"];
        textView.text =  [textView.text substringWithRange:NSMakeRange(0, 299)];
    } else {
        
    }
}

- (BOOL)isValidateEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

- (IBAction)firstTouch:(UIButton *)sender {
    [self touchAction:sender];
}

- (IBAction)secondTouch:(UIButton *)sender {
    [self touchAction:sender];
}

- (IBAction)thirdTouch:(UIButton *)sender {
    [self touchAction:sender];
}

- (IBAction)fourthTouch:(UIButton *)sender {
    [self touchAction:sender];
}

- (IBAction)firstDeleteTouch:(UIButton *)sender {
    [self deleteAction:sender];
}

- (IBAction)secondDeleteTouch:(UIButton *)sender {
    [self deleteAction:sender];
}

- (IBAction)thirdDeleteTouch:(UIButton *)sender {
    [self deleteAction:sender];
}

- (IBAction)fourthDeleteTouch:(UIButton *)sender {
    [self deleteAction:sender];
}

- (void)touchAction:(UIButton *)sender {
    if (sender.tag > _sourceAssetArray.count) {
        TZImagePickerController *picker = [[TZImagePickerController alloc] initWithMaxImagesCount:4 - _sourceAssetArray.count delegate:self];
        picker.allowPickingVideo = NO;
        picker.allowPickingOriginalPhoto = NO;
        picker.isSelectOriginalPhoto = YES;
        picker.selectedAssets = _sourceAssetArray;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        browser.displayNavArrows = NO;
        browser.displaySelectionButtons = NO;
        browser.zoomPhotosToFill = YES;
        browser.alwaysShowControls = NO;
        browser.enableGrid = YES;
        browser.startOnGrid = NO;
        browser.autoPlayOnAppear = NO;
        browser.displayActionButton = NO;
        [browser setCurrentPhotoIndex:sender.tag];
        // 未完待续
        /*
        browser.isPublishDelete = YES;
        browser.deleteCallBack = ^(PHAsset *deleteAsset) {
            for (int i =0; i<self->_sourceAssetArray.count; i++) {
                PHAsset *asset = self->_sourceAssetArray[i];
                if ([deleteAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.tag = 5+i;
                    [self deleteAction:button];
                } else {
                    
                }
            }
        };
         */
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _sourceAssetArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _sourceAssetArray.count) {
        XTCDateFormatter *dateFormatter = [XTCDateFormatter shareDateFormatter];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
        PHAsset *asset = _sourceAssetArray[index];
        MWPhoto *photo;
        if (asset.pixelWidth > 3264 || asset.pixelHeight > 3264) {
            if (asset.pixelWidth > asset.pixelHeight) {
                photo = [MWPhoto photoWithAsset:asset targetSize:CGSizeMake(3264, 3264.0*asset.pixelHeight/asset.pixelWidth)];
            } else {
                photo = [MWPhoto photoWithAsset:asset targetSize:CGSizeMake(3264.0*asset.pixelWidth/asset.pixelHeight, 3264)];
            }
        } else {
            photo = [MWPhoto photoWithAsset:asset targetSize:PHImageManagerMaximumSize];
        }
        // 未完待续
//        photo.dateString = [dateFormatter stringFromDate:asset.creationDate];
        return photo;
    }
    return nil;
}

- (void)deleteAction:(UIButton *)sender {
    [_sourceAssetArray removeObjectAtIndex:sender.tag - 5];
    NSString *countStr = [NSString stringWithFormat:@"%@(%lu/4)", XTCLocalizedString(@"Setting_Offer_Photo", nil), (unsigned long)_sourceAssetArray.count];
    _numberLabel.text = countStr;
    for (NSInteger i = 0; i < _buttonArray.count; i++) {
        if (i < _sourceAssetArray.count) {
            UIButton *button = _buttonArray[i];
            button.hidden = NO;
            [[TZImageManager manager] getPhotoWithAsset:_sourceAssetArray[i] photoWidth:480 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [button setImage:photo forState:UIControlStateNormal];
                });
            }];
//            [button setImage:_sourceAssetArray[i] forState:UIControlStateNormal];
        } else if (i == _sourceAssetArray.count){
            UIButton *button = _buttonArray[i];
            [button setImage:[UIImage imageNamed:@"share_addphoto"] forState:UIControlStateNormal];
            button.hidden = NO;
            UIButton *delete = _deleteButtonArray[i];
            delete.hidden = YES;
        } else {
            UIButton *delete = _deleteButtonArray[i];
            delete.hidden = YES;
            
            UIButton *button = _buttonArray[i];
            button.hidden = YES;
        }
    }
}


- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
     [TZImageManager manager].pickerDelegate = nil;
//    [_sourceAssetArray addObjectsFromArray:assets];
    _sourceAssetArray = [[NSMutableArray alloc] initWithArray:assets];
    _numberLabel.text = [NSString stringWithFormat:@"%@(%lu/4)", XTCLocalizedString(@"Setting_Offer_Photo", nil), (unsigned long)_sourceAssetArray.count];
    for (NSInteger i = 0; i < _buttonArray.count; i++) {
        if (i < _sourceAssetArray.count ) {
            UIButton *button = _buttonArray[i];
            button.hidden = NO;
            [[TZImageManager manager] getPhotoWithAsset:_sourceAssetArray[i] photoWidth:480 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [button setImage:photo forState:UIControlStateNormal];
                });
            }];
            
            UIButton *delete = _deleteButtonArray[i];
            delete.hidden = NO;
        } else if (i == _sourceAssetArray.count){
            UIButton *button = _buttonArray[i];
            [button setImage:[UIImage imageNamed:@"share_addphoto"] forState:UIControlStateNormal];
            button.hidden = NO;
            UIButton *delete = _deleteButtonArray[i];
            delete.hidden = YES;
        } else {
            UIButton *delete = _deleteButtonArray[i];
            delete.hidden = YES;
            
            UIButton *button = _buttonArray[i];
            button.hidden = YES;
        }
    }

}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [TZImageManager manager].pickerDelegate = nil;
    NSLog(@"照片选择取消");
}


- (void)dealloc {
    NSLog(@"发送反馈内存释放");
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
