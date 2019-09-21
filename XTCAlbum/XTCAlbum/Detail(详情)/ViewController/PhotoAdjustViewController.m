//
//  PhotoAdjustViewController.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/1.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PhotoAdjustViewController.h"

const int photoAdjustWidth = 2880;

@interface PhotoAdjustViewController () {
    
}

@end

@implementation PhotoAdjustViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _adjustTableView.backgroundColor = [UIColor blackColor];
    _adjustTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _adjustTableView.allowsSelection = NO;
    _adjustTableView.scrollEnabled = NO;
    
    // 饱和度默认值
    _saturationValue = 1;
    // 曝光度默认值
    _exposureValue = 0.0;
    
    // 对比度默认值
    _contrastValue = 1;
    
    // 亮度
    _brightnessValue = 0.0;
    
    // 细节
    _highlightShadowValue = 0.0f;
    
    [self gainShowImage];
}

- (void)gainShowImage {
    if (_sourceAsset == nil) {
        self.showImage = [XTCSourceCompressManager imageWithOriginalImage:_showImage];
        self.showImageView.image = self.showImage;
    } else {
        __weak typeof(self) weakSelf = self;
        [self showHubWithDescription:@"获取中..."];
        CGFloat width = _sourceAsset.pixelWidth;     // 源图片的宽
        if (width > 5120) {
            width = 5120;
            [[TZImageManager manager] getPhotoWithAsset:_sourceAsset photoWidth:width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) {
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideHub];
                        weakSelf.showImage = photo;
                        weakSelf.showImageView.image = weakSelf.showImage;
                    });
                }
            }];
        } else {
            [[TZImageManager manager] getOriginalPhotoWithAsset:_sourceAsset completion:^(UIImage *photo, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHub];
                    weakSelf.showImage = photo;
                    weakSelf.showImageView.image = weakSelf.showImage;
                });
            }];
        }
    }
}
#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"PhotoAdjustCellName";
    PhotoAdjustCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[PhotoAdjustCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.backgroundColor = [UIColor blackColor];
    switch (indexPath.row) {
        case 0: {
            cell.titleLabel.text = @"饱和度";
            cell.adjustSilder.minimumValue = 0;
            cell.adjustSilder.maximumValue = 2;
            cell.adjustSilder.value = _saturationValue;
            cell.adjustSilder.tag = 101;
        }
            break;
        case 1: {
            cell.titleLabel.text = @"曝光度";
            cell.adjustSilder.minimumValue = -2;
            cell.adjustSilder.maximumValue = 2;
            cell.adjustSilder.value = _exposureValue;
            cell.adjustSilder.tag = 102;
        }
            break;
        case 2: {
            cell.titleLabel.text = @"细节";
            cell.adjustSilder.minimumValue = 0;
            cell.adjustSilder.maximumValue = 1;
            cell.adjustSilder.value = _highlightShadowValue;
            cell.adjustSilder.tag = 102;
        }
            break;
        case 3: {
            cell.titleLabel.text = @"对比度";
            cell.adjustSilder.minimumValue = 0;
            cell.adjustSilder.maximumValue = 4;
            cell.adjustSilder.value = _contrastValue;
            cell.adjustSilder.tag = 104;
        }
            break;
        case 4: {
            cell.titleLabel.text = @"亮度";
            cell.adjustSilder.minimumValue = -1;
            cell.adjustSilder.maximumValue = 1;
            cell.adjustSilder.value = _brightnessValue;
            cell.adjustSilder.tag = 105;
        }
            break;
            
        default:
            break;
    }
    [cell.adjustSilder addTarget:self action:@selector(adjustSilderEnd:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)adjustSilderEnd:(UISlider *)adjustSilder {
    if (adjustSilder.tag == 101) {
        _saturationValue = adjustSilder.value;
    }
    if (adjustSilder.tag == 102) {
        _exposureValue = adjustSilder.value;
    }
    if (adjustSilder.tag == 103) {
        _highlightShadowValue = adjustSilder.value;
    }
    if (adjustSilder.tag == 104) {
        _contrastValue = adjustSilder.value;
    }
    if (adjustSilder.tag == 105) {
        _brightnessValue = adjustSilder.value;
    }
    
    GPUImagePicture *staticPicture = [[GPUImagePicture alloc] initWithImage:self.showImage smoothlyScaleOutput:YES];
    
    
    GPUImageFilterGroup *myFilterGroup = [[GPUImageFilterGroup alloc] init];
    [staticPicture addTarget:myFilterGroup];
    
    // 饱和度
    GPUImageSaturationFilter *saturationfilter = [[GPUImageSaturationFilter alloc]init];
    saturationfilter.saturation = _saturationValue;
    [self addGPUImageFilter:saturationfilter byFilterGroup:myFilterGroup];
    
    
    // 曝光度
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
    exposureFilter.exposure = _exposureValue;
    [self addGPUImageFilter:exposureFilter byFilterGroup:myFilterGroup];
    
    // 细节
    GPUImageHighlightShadowFilter *highlightShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
    highlightShadowFilter.shadows = _highlightShadowValue;
    highlightShadowFilter.highlights = 1-_highlightShadowValue;
    
    // 对比度
    GPUImageContrastFilter *contrastfilter = [[GPUImageContrastFilter alloc] init];
    contrastfilter.contrast = _contrastValue;
    [self addGPUImageFilter:contrastfilter byFilterGroup:myFilterGroup];
    
    // 亮度
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    brightnessFilter.brightness = _brightnessValue;
    [self addGPUImageFilter:brightnessFilter byFilterGroup:myFilterGroup];
    
    [staticPicture processImage];
    [myFilterGroup useNextFrameForImageCapture];
    
    UIImage *dealedImage = [myFilterGroup imageFromCurrentFramebuffer];
     _showImageView.image = dealedImage;
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
}

- (void)addGPUImageFilter:(GPUImageFilter *)filter byFilterGroup:(GPUImageFilterGroup *)filterGroup  {
    
    [filterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = filterGroup.filterCount;
    
    if (count == 1) {
        //设置初始滤镜
        filterGroup.initialFilters = @[newTerminalFilter];
        //设置末尾滤镜
        filterGroup.terminalFilter = newTerminalFilter;
        
    } else {
        GPUImageOutput<GPUImageInput> *terminalFilter    = filterGroup.terminalFilter;
        NSArray *initialFilters                          = filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        //设置初始滤镜
        filterGroup.initialFilters = @[initialFilters[0]];
        //设置末尾滤镜
        filterGroup.terminalFilter = newTerminalFilter;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)dismisButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)savePhotoButtonClick:(id)sender {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
