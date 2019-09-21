//
//  PhotoFilterViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PhotoFilterViewController.h"

@interface PhotoFilterViewController ()

@end

@implementation PhotoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectShowIndex = 0;
    self.view.backgroundColor = [UIColor blackColor];
    [_dismisButton addTarget:self action:@selector(dismisButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.hidden = YES;
    
    
    // 渐变色添加
    _topBgView.backgroundColor = [UIColor clearColor];
    CAGradientLayer *topGradientLayer = [CAGradientLayer layer];
    topGradientLayer.colors = @[(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor clearColor].CGColor];
    topGradientLayer.locations = @[@0.0, @0.95];
    topGradientLayer.startPoint = CGPointMake(0, 0.0);
    topGradientLayer.endPoint = CGPointMake(0.0, 1.0);
    topGradientLayer.frame = CGRectMake(0, 0, kScreenWidth, 44+kAppStatusBar+20);
    [_topBgView.layer addSublayer:topGradientLayer];
    
    
    [self createFilterUI];
    [self gainShowImage];
    
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)gainShowImage {
    if (_showAsset == nil) {
        self.showImage = [XTCSourceCompressManager imageWithOriginalImage:_showImage];
        self.showImageView.image = self.showImage;
        _stillImageSource = [[GPUImagePicture alloc]initWithImage:self.showImage];//添加上滤镜
        self.beautifyImage = [self gainBeautifyImage];
        [self gainStyleImage];
        [self.filterCollectionView reloadData];
    } else {
        __weak typeof(self) weakSelf = self;
         [self showHubWithDescription:@"获取中..."];
        
        CGFloat width = _showAsset.pixelWidth;     // 源图片的宽
        CGFloat height = _showAsset.pixelHeight;   // 源图片的高
        CGFloat scaledWidth;      // 压缩时的宽度 默认是参照像素
        CGFloat scaledHeight;     // 压缩是的高度 默认是参照像素
        if (width > height) {
            scaledHeight = 1800;
            scaledWidth = 1800*width/height;
        } else {
            scaledWidth = 1800;
            scaledHeight = 1800*height/width;
        }
        [[TZImageManager manager] getPhotoWithAsset:_showAsset photoWidth:scaledWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) {
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideHub];
                    weakSelf.showImage = [XTCSourceCompressManager imageWithOriginalImage:photo];
                    weakSelf.showImageView.image = weakSelf.showImage;
                    weakSelf.stillImageSource = [[GPUImagePicture alloc]initWithImage:weakSelf.showImage];//添加上滤镜
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        weakSelf.beautifyImage = [weakSelf gainBeautifyImage];
                        [weakSelf gainStyleImage];
                        [weakSelf.filterCollectionView reloadData];
                    });
                });
            }
        }];
    }
}

- (void)createFilterUI {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.itemSize = CGSizeMake(105, 105);
    _filterCollectionView.backgroundColor = RGBCOLOR(31, 31, 31);
    _filterCollectionView.collectionViewLayout = flowLayout;
    _filterCollectionView.delegate = self;
    _filterCollectionView.dataSource = self;
    [_filterCollectionView registerClass:[PhotoFilterCell class] forCellWithReuseIdentifier:@"PhotoFilterCellName"];
    _filterCollectionView.showsHorizontalScrollIndicator = NO;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_showImage) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoFilterCellName" forIndexPath:indexPath];
    switch (indexPath.item) {
        case 0: {
            cell.titleLabel.text = @"原图";
            cell.filterImageView.image = _showImage;
        }
            break;
        case 1: {
            cell.titleLabel.text = @"美颜";
            cell.filterImageView.image = _beautifyImage;
        }
            break;
        case 2: {
            cell.titleLabel.text = @"#1";
            cell.filterImageView.image = _styleImage1;
        }
            break;
        case 3: {
            cell.titleLabel.text = @"#2";
            cell.filterImageView.image = _styleImage2;
        }
            break;
        case 4: {
            cell.titleLabel.text = @"#3";
            cell.filterImageView.image = _styleImage3;
        }
            break;
        case 5: {
            cell.titleLabel.text = @"#4";
            cell.filterImageView.image = _styleImage4;
        }
            break;
        case 6: {
            cell.titleLabel.text = @"#5";
            cell.filterImageView.image = _styleImage5;
        }
            break;
            
        default:
            break;
    }
    if (indexPath.item == _selectShowIndex) {
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.titleLabel.font = [UIFont fontWithName:kHelveticaBold size:12];
    } else {
        cell.titleLabel.textColor = [UIColor lightGrayColor];
        cell.titleLabel.font = [UIFont fontWithName:kHelvetica size:12];
    }
    return cell;
}

- (UIImage *)gainBeautifyImage {
    // 美颜
    GPUImageBeautifyFilter *disFilter = [[GPUImageBeautifyFilter alloc] init];
    [disFilter forceProcessingAtSize:self.showImage.size];//设置要渲染的区域
    [disFilter useNextFrameForImageCapture];//获取数据源
    [_stillImageSource addTarget:disFilter];//开始渲染
    [_stillImageSource processImage];//获取渲染后的图片
    UIImage *newImage = [disFilter imageFromCurrentFramebuffer];
    [disFilter removeOutputFramebuffer];
    return newImage;
}

- (void )gainStyleImage {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    GPUImageToneCurveFilter *toneCurveFilter;
    
    // 第一种样式
    NSURL *filterAmaro = [NSURL fileURLWithPath:[bundle pathForResource:@"rixi" ofType:@"acv"]];
    toneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:filterAmaro];
    [toneCurveFilter forceProcessingAtSize:self.showImage.size];//设置要渲染的区域
    [toneCurveFilter useNextFrameForImageCapture];
    [_stillImageSource addTarget:toneCurveFilter];
    [_stillImageSource processImage];
    _styleImage1 = [toneCurveFilter imageFromCurrentFramebuffer];
    [toneCurveFilter removeOutputFramebuffer];
    [_stillImageSource removeTarget:toneCurveFilter];
    
    
    filterAmaro = [NSURL fileURLWithPath:[bundle pathForResource:@"wennuan" ofType:@"acv"]];
    toneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:filterAmaro];
    [toneCurveFilter forceProcessingAtSize:self.showImage.size];//设置要渲染的区域
    [toneCurveFilter useNextFrameForImageCapture];
    [_stillImageSource addTarget:toneCurveFilter];
    [_stillImageSource processImage];
    _styleImage2 = [toneCurveFilter imageFromCurrentFramebuffer];
    [toneCurveFilter removeOutputFramebuffer];
     [_stillImageSource removeTarget:toneCurveFilter];
    
    
    filterAmaro = [NSURL fileURLWithPath:[bundle pathForResource:@"nuanxin" ofType:@"acv"]];
    toneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:filterAmaro];
    [toneCurveFilter forceProcessingAtSize:self.showImage.size];//设置要渲染的区域
    [toneCurveFilter useNextFrameForImageCapture];
    [_stillImageSource addTarget:toneCurveFilter];
    [_stillImageSource processImage];
    _styleImage3 = [toneCurveFilter imageFromCurrentFramebuffer];
    [toneCurveFilter removeOutputFramebuffer];
     [_stillImageSource removeTarget:toneCurveFilter];
    
    
    filterAmaro = [NSURL fileURLWithPath:[bundle pathForResource:@"jiaopian" ofType:@"acv"]];
    toneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:filterAmaro];
    [toneCurveFilter forceProcessingAtSize:self.showImage.size];//设置要渲染的区域
    [toneCurveFilter useNextFrameForImageCapture];
    [_stillImageSource addTarget:toneCurveFilter];
    [_stillImageSource processImage];
    _styleImage4 = [toneCurveFilter imageFromCurrentFramebuffer];
    [toneCurveFilter removeOutputFramebuffer];
     [_stillImageSource removeTarget:toneCurveFilter];
    
    filterAmaro = [NSURL fileURLWithPath:[bundle pathForResource:@"keai" ofType:@"acv"]];
    toneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:filterAmaro];
    [toneCurveFilter forceProcessingAtSize:self.showImage.size];//设置要渲染的区域
    [toneCurveFilter useNextFrameForImageCapture];
    [_stillImageSource addTarget:toneCurveFilter];
    [_stillImageSource processImage];
    _styleImage5 = [toneCurveFilter imageFromCurrentFramebuffer];
    [toneCurveFilter removeOutputFramebuffer];
     [_stillImageSource removeTarget:toneCurveFilter];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectShowIndex = indexPath.item;
     _saveButton.hidden = NO;
    switch (indexPath.item) {
        case 0: {
            _showImageView.image = _showImage;
             _saveButton.hidden = YES;
        }
            break;
        case 1: {
            _showImageView.image = _beautifyImage;
        }
            break;
        case 2: {
            _showImageView.image = _styleImage1;
        }
            break;
        case 3: {
            _showImageView.image = _styleImage2;
        }
            break;
        case 4: {
            _showImageView.image = _styleImage3;
        }
            break;
        case 5: {
            _showImageView.image = _styleImage4;
        }
            break;
        case 6: {
            _showImageView.image = _styleImage5;
        }
            break;
            
        default:
            break;
    }
    [_filterCollectionView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)saveButtonClick {
    [self showHubWithDescription:@"保存中..."];
    NSMutableDictionary *metadataMutableDict = [[NSMutableDictionary alloc] initWithDictionary:self.metadataInfor];
    NSDictionary *gpsDict = [self.metadataInfor objectForKey:@"{GPS}"];
    if ([gpsDict[@"Latitude"] description] && [gpsDict[@"Latitude"] description].length && [gpsDict[@"Longitude"] description] && [gpsDict[@"Longitude"] description].length) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[gpsDict[@"Latitude"] doubleValue] longitude:[gpsDict[@"Longitude"] doubleValue]];
        [metadataMutableDict setObject: [XTCSourceCompressManager gpsDictionaryForLocation:location] forKey:(NSString *)kCGImagePropertyGPSDictionary];
    } else {
        
    }
    [metadataMutableDict setObject:@(1) forKey:@"Orientation"];
    [metadataMutableDict setObject:@(_showImageView.image.size.width) forKey:@"PixelWidth"];
    [metadataMutableDict setObject:@(_showImageView.image.size.height) forKey:@"PixelHeight"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary writeImageToSavedPhotosAlbum:_showImageView.image.CGImage metadata:metadataMutableDict completionBlock:^(NSURL *assetURL, NSError *error) {
        [self hideHub];
        if (error) {
            [self alertMessage:@"保存失败"];
        } else {
            [self alertMessage:@"保存成功"];
        }
    }];
#pragma clang diagnostic pop
}

- (void)dealloc {
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    DDLogInfo(@"滤镜内存释放");
}

- (void)dismisButtonClick {
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
