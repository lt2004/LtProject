//
//  XTCPublishManager.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/3.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "XTCPublishManager.h"

@implementation XTCPublishManager
static XTCPublishManager *_publishManager = nil;


+ (instancetype)sharePublishManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _publishManager = [[XTCPublishManager alloc] init];
        _publishManager.isPubishLoading = NO;
        _publishManager.publishDraftCoverPath = @"";
    });
    return _publishManager;
}

- (void)createPublishModel:(PublishNormalPostModel *)mainModel byUploadModel:(NSMutableArray *)uploadArray byIsPublish:(BOOL)isPublish {
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    // 生成发布的model
    XTCPublishMainModel *publishMainModel = [XTCPublishMainModel MR_createEntityInContext:managedObjectContext];
    publishMainModel.art_link = mainModel.art_link ? mainModel.art_link : @"";
    publishMainModel.chat_id = mainModel.chatId ? mainModel.chatId : @"";
    publishMainModel.chat_type = mainModel.chatType ? mainModel.chatType : @"";
    publishMainModel.is_bus = mainModel.is_bus ? mainModel.is_bus : @"0";
    publishMainModel.is_personal = mainModel.is_personal;
    publishMainModel.post_content = mainModel.postcontent ? mainModel.postcontent : @"";
    publishMainModel.post_title = mainModel.posttitle;
    publishMainModel.pubish_date = mainModel.dateString;
    publishMainModel.publish_tour_time = mainModel.tourTime;
    publishMainModel.share_location = mainModel.share_location;
    publishMainModel.sub_post_id = mainModel.sub_post_id ? mainModel.sub_post_id : @"";
    publishMainModel.tags = mainModel.tags ? mainModel.tags : @"";
    publishMainModel.tk = mainModel.tk ? mainModel.tk : @"";
    publishMainModel.pubish_type = mainModel.publishTypeEnum;
    publishMainModel.publish_sort_date = [NSDate date];
    publishMainModel.current_lat = mainModel.latStr ? mainModel.latStr : @"";
    publishMainModel.current_lng = mainModel.lngStr ? mainModel.lngStr : @"";
    publishMainModel.is_bus_show = mainModel.isBusShow;
    publishMainModel.ending_title = mainModel.endTitle;
    publishMainModel.ending_desc = mainModel.endDesc;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    
    NSMutableSet *mutableSet = [[NSMutableSet alloc] init];
    for (int i = 0; i<uploadArray.count; i++) {
        PublishUploadFileModel *uploadModel = uploadArray[i];
        XTCPublishSubUploadModel *publishSubUploadModel = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
        publishSubUploadModel.date_time_original = uploadModel.dateTimeOriginal;
        publishSubUploadModel.file_desc = uploadModel.file_desc ? uploadModel.file_desc : @"";
        publishSubUploadModel.file_index = i;
        publishSubUploadModel.file_type = uploadModel.file_type;
        publishSubUploadModel.lat = uploadModel.lat ? uploadModel.lat : @"";
        publishSubUploadModel.lng = uploadModel.lng ? uploadModel.lng : @"";
        publishSubUploadModel.make = uploadModel.make ? uploadModel.make : @"";
        publishSubUploadModel.model = uploadModel.model ? uploadModel.model : @"";
        publishSubUploadModel.source_path = uploadModel.file;
        if (i == 0) {
            publishMainModel.draft_cover = uploadModel.file;
        }
        publishSubUploadModel.temp_id = @"";
        publishSubUploadModel.file_title = uploadModel.file_title;
        publishSubUploadModel.post_type = uploadModel.post_type;
//        publishSubUploadModel.exposure_program = uploadModel.exposureProgram;
//        publishSubUploadModel.exposure_bias_value = uploadModel.exposureBiasValu;
        if ([uploadModel.file_type isEqualToString:@"photo"] || [uploadModel.file_type isEqualToString:@"vr"] || [uploadModel.file_type isEqualToString:@"video"]) {
            // 添加坐标
            CLLocation *location = uploadModel.sourceAsset.location;
            publishSubUploadModel.lat = @"";
            publishSubUploadModel.lng = @"";
            if (location) {
                publishSubUploadModel.lat = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
                publishSubUploadModel.lng = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
            } else {
                
            }
        } else {
            
        }
        [mutableSet addObject:publishSubUploadModel];
    }
    publishMainModel.uploads = mutableSet;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    
    if ([XTCPublishManager sharePublishManager].isPubishLoading) {
        
    } else {
        if (isPublish) {
            [self publishPost:publishMainModel];
        } else {
            
        }
    }
    DDLogInfo(@"发布数据模型保存成功");
}

#pragma mark - 上传发布文件
- (void)publishPost:(XTCPublishMainModel *)publishMainModel {
    __weak typeof(self) weakSelf = self;
    self.publishDraftCoverPath = publishMainModel.draft_cover;
    // 压缩内存导致crash处理部分
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // 开始压缩标识
        [XTCPublishManager sharePublishManager].isPubishLoading = YES;
        weakSelf.isCanPublish = YES;
        weakSelf.uploadCurrentFlag = 0; // 当前上传到第几个
        NSSet *uploadTotalSet = publishMainModel.uploads;
        NSMutableArray *needUploadTotalArray = [[NSMutableArray alloc] init];
        NSInteger uploadTotalFlag = uploadTotalSet.count; // 上传总文件数
        for (XTCPublishSubUploadModel *uploadModel in uploadTotalSet) {
            if (uploadModel.temp_id && uploadModel.temp_id.length) {
                // 当前上传完成几个
                weakSelf.uploadCurrentFlag++;
            } else {
                [needUploadTotalArray addObject:uploadModel];
            }
        }
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (XTCPublishSubUploadModel *uploadFileModel in needUploadTotalArray) {
            //加上自动释放池，及时的释放临时变量，防止内存奔溃
            if (weakSelf.isCanPublish == NO) {
                // 上传失败了不能发布
                dispatch_semaphore_signal(semaphore);
                break;
            }
            @autoreleasepool {
                NSString *docPath = [CWAFileUtil getDocumentPath];
                NSString *fileName = [[uploadFileModel.source_path componentsSeparatedByString:@"/"] lastObject];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, fileName];
                NSData *flagData;
                if ([[uploadFileModel.source_path pathExtension] isEqualToString:@"jpg"]) {
                    if ([uploadFileModel.file_type isEqualToString:@"vr"]) {
                        // VR压缩
                        flagData = [weakSelf compressVRPublishImageLevel:filePath byLat:uploadFileModel.lat byLngStr:uploadFileModel.lng];
                    } else {
                        // 普通照片压缩
                        flagData = [weakSelf compressPublishImageLevel:filePath byLat:uploadFileModel.lat byLngStr:uploadFileModel.lng];
                    }
                    [weakSelf uploadDataToService:uploadFileModel byTotalCount:uploadTotalFlag bySemaphore:semaphore byUploadData:flagData];
                } else {
                    //  路径的直接通过滤镜获取了
                    if ([uploadFileModel.file_type isEqualToString:@"audio"]) {
                        // 音频
                        //                        flagData = [NSData dataWithContentsOfFile:filePath];
                    } else {
                        // 视频
                        //                        flagData = [NSData dataWithContentsOfFile:filePath];
                    }
                    [weakSelf uploadDataToService:uploadFileModel byTotalCount:uploadTotalFlag bySemaphore:semaphore byUploadData:nil];
                    
                }
                
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        DDLogInfo(@"压缩完后了");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.isCanPublish) {
                // 调用发布接口
                if (publishMainModel.pubish_type == PublishPhotoVideoTypeEnum) {
                    [self publishMultimediaNetworkingPost:publishMainModel];
                } else if (publishMainModel.pubish_type == PublishProTypeEnum) {
                    [self publishProNetworking:publishMainModel];
                } else {
                    [self publishNetworkingNormalPost:publishMainModel];
                }
            } else {
                [XTCPublishManager sharePublishManager].isPubishLoading = NO;
            }
        });
    });
}

- (void)uploadDataToService:(XTCPublishSubUploadModel *)uploadFileModel byTotalCount:(NSInteger)totalCount bySemaphore:(dispatch_semaphore_t)semaphore byUploadData:(NSData *)flagData {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[GlobalData sharedInstance].userModel.token forKey:@"token"];
    [requestDict setObject:[GlobalData sharedInstance].userModel.user_id forKey:@"user_id"];
    [requestDict setObject:uploadFileModel.file_type forKey:@"file_type"];
    [requestDict setObject:uploadFileModel.post_type forKey:@"post_type"];
    if (uploadFileModel.lng && uploadFileModel.lng.length) {
        [requestDict setObject:uploadFileModel.lng forKey:@"lng"];
    }
    if (uploadFileModel.lat && uploadFileModel.lat.length) {
        [requestDict setObject:uploadFileModel.lat forKey:@"lat"];
    }
    
    [requestDict setObject:@"DELETE" forKey:@"_method"];
    NSString *uploadUrl = [NSString stringWithFormat:@"%@uploadfilev1", [XTCNetworkManager apiUrl]];
    self.uploadRequest = [[ApiUploadClient sharedClient].requestSerializer multipartFormRequestWithMethod:@"POST" URLString:uploadUrl parameters:requestDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSString *docPath = [CWAFileUtil getDocumentPath];
        NSString *fileName = [[uploadFileModel.source_path componentsSeparatedByString:@"/"] lastObject];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, fileName];
        
        NSString * mimeType;
        if ([[uploadFileModel.source_path pathExtension] isEqualToString:@"jpg"]) {
            mimeType = @"image/jpeg";
            [formData appendPartWithFileData:flagData name:@"file" fileName:fileName mimeType:mimeType];
        } else {
            mimeType = @"audio/mp3";
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:fileName mimeType:mimeType error:nil];
        }
    } error:nil];
    self.uploadTask = [[ApiUploadClient sharedClient] uploadTaskWithRequest:self.uploadRequest fromData:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        // 监听上传进度
        weakSelf.uploadProgress = ((float)weakSelf.uploadCurrentFlag)/totalCount + uploadProgress.fractionCompleted/totalCount;
        NSMutableDictionary *progressDict = [[NSMutableDictionary alloc] init];
        [progressDict setObject:[NSString stringWithFormat:@"%.6f", weakSelf.uploadProgress] forKey:@"Progress"];
        NSNotification *notice = [NSNotification notificationWithName:@"PostUploadProgress" object:nil userInfo:progressDict];
        [[NSNotificationCenter defaultCenter] postNotification:notice];
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error == nil) {
            weakSelf.uploadCurrentFlag++;
            if ([responseObject[@"code"] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新上传文件id
                    uploadFileModel.temp_id = [responseObject objectForKey:@"temp_id"];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    dispatch_semaphore_signal(semaphore);
                });
                
                
            } else {
                weakSelf.isCanPublish = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
                dispatch_semaphore_signal(semaphore);
            }
        } else {
            weakSelf.isCanPublish = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
            dispatch_semaphore_signal(semaphore);
        }
    }];
    [self.uploadTask resume];
}

#pragma mark -  查询草稿箱数据
- (NSArray *)queryAllPublishMainData {
    NSArray *findArray = [XTCPublishMainModel MR_findAllSortedBy:@"publish_sort_date" ascending:NO];
    return findArray;
}

#pragma mark - 查询是否草稿箱是否有数据
- (BOOL)queryIsHaveDraft {
    NSArray *findArray = [XTCPublishMainModel MR_findAllSortedBy:@"publish_sort_date" ascending:NO];
    if (findArray && findArray.count) {
        return YES;
    } else {
        return NO;
    }
}
#pragma mark - 直接将图片放到沙盒路径下
- (NSArray *)writeImageToFilePath:(UIImage *)corverImage {
    NSMutableArray * writeFileOps = [NSMutableArray array];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *imageData = UIImageJPEGRepresentation(corverImage, 1.0);
    NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:filePath atomically:NO];
    [writeFileOps addObject:filePath];
    return writeFileOps;
}

#pragma mark - 照片或视频导出到发布的文件夹下
- (NSArray *)exportImages:(NSArray *)assetArray {
    __weak typeof(self) weakSelf = self;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray * writeFileOps = [NSMutableArray array];
    __block dispatch_semaphore_t sem1 = dispatch_semaphore_create(0);
    @autoreleasepool {
        for (PHAsset *flagAsset in assetArray) {
            PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.synchronous = YES;
            options.networkAccessAllowed = YES;
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestImageDataForAsset:flagAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *image = [UIImage imageWithData:imageData];
                if (orientation != UIImageOrientationUp) {
                    // 修正方向
                    image = [weakSelf fixOrientation:image];
                } else {
                    
                }
                // 获取exif信息
                CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
                NSDictionary *flagMetadata =  (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, NULL));
                NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:flagMetadata];
                imageData = UIImageJPEGRepresentation(image, 1.0);
                imageData = [weakSelf writeExifInfor:imageData byMetadata:metadata];
                NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
                NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
                NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
                [imageData writeToFile:filePath atomically:NO];
                [writeFileOps addObject:filePath];
                imageData = nil;
                dispatch_semaphore_signal(sem1);
            }];
            dispatch_semaphore_wait(sem1, DISPATCH_TIME_FOREVER);
        }
    }
    return writeFileOps;
}

#pragma mark 导入到本地的照片方向修正
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (aImage.imageOrientation == UIImageOrientationUp) return aImage;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark - 普通照片压缩
- (NSData *)compressPublishImageLevel:(NSString *)filePath byLat:(NSString *)latStr byLngStr:(NSString *)lngStr {
    __weak typeof(self) weakSelf = self;
    NSMutableData *flagImageData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    
    //  取出照片的exif信息
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)flagImageData, NULL);
    NSDictionary *imageInfo = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    NSMutableDictionary *metadata = [imageInfo mutableCopy];
    
    UIImage *flagImage = [UIImage imageWithData:flagImageData];
    CGFloat compress_level = 1;
    BOOL isCompress = NO;
    // 如果长宽比大于3:1 限制4M
    int limitSize = 2;
    if (1.0*flagImage.size.width/flagImage.size.height > 3 || 1.0*flagImage.size.height/flagImage.size.width > 3) {
        limitSize = 4;
    } else {
        
    }
    if (flagImageData.length > limitSize*1024*1024) {
        isCompress = YES;
        if (flagImage.size.width > 1800 && flagImage.size.height > 1800) {
            // 首先进行尺寸压缩
            flagImage = [weakSelf imageWithOriginalImage:flagImage];
        } else {
            DDLogInfo(@"尺寸不用被压缩");
        }
        DDLogInfo(@"进行质量压缩");
        @autoreleasepool {
            flagImageData = [[NSMutableData alloc] initWithData:UIImageJPEGRepresentation(flagImage, compress_level)];
            while (flagImageData.length > limitSize*1024*1024) {
                compress_level -= 0.01;
                flagImageData = [[NSMutableData alloc] initWithData:UIImageJPEGRepresentation(flagImage, compress_level)];
            }
        }
    } else {
        // 不必压缩
        DDLogInfo(@"不用被压缩");
    }
    // 写入exif信息
    [metadata setObject:@(1) forKey:@"Orientation"];
    NSDictionary *tiffDict = metadata[@"{TIFF}"];
    
    if (tiffDict) {
        NSMutableDictionary *tiffMutableDict = [[NSMutableDictionary alloc] initWithDictionary:tiffDict];
        [tiffMutableDict setObject:@(1) forKey:@"Orientation"];
        [metadata setObject:tiffMutableDict forKey:@"{TIFF}"];
    } else {
        
    }
    if (latStr && latStr.length && lngStr && lngStr.length) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latStr doubleValue] longitude:[lngStr doubleValue]];
        [metadata setObject: [XTCSourceCompressManager gpsDictionaryForLocation:location] forKey:(NSString *)kCGImagePropertyGPSDictionary];
    } else {
        
    }
    if (isCompress) {
        [metadata setObject:@(flagImage.size.width) forKey:@"PixelWidth"];
        [metadata setObject:@(flagImage.size.height) forKey:@"PixelHeight"];
        [metadata setObject:@(compress_level) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
    } else {
        // 不压缩
//        [metadata setObject:@(1) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
        
    }
    flagImageData = [self writeExifInfor:flagImageData byMetadata:metadata];
    DDLogInfo(@"压缩%.1f", flagImageData.length/1024.0/1024);
    return flagImageData;
}

#pragma mark - 写入exif和Gps信息到照片中
- (NSMutableData *)writeExifInfor:(NSData *)flagImageData byMetadata:(NSDictionary *)metadata {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(flagImageData), NULL);
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)@"image/jpeg", NULL);
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, uti, 1, NULL);
    CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, (__bridge CFDictionaryRef)metadata);
    CGImageDestinationFinalize(imageDestination);
    CFRelease(imageDestination);
    CFRelease(uti);
    return imageData;
}

#pragma mark - 普通照片压缩
- (UIImage *)imageWithOriginalImage:(UIImage *)sourceImage{
    UIImage *newImage = nil;             // 尺寸压缩后的新图
    CGSize imageSize = sourceImage.size; // 源图片的size
    CGFloat width = imageSize.width;     // 源图片的宽
    CGFloat height = imageSize.height;   // 原图片的高
    CGFloat scaledWidth;      // 压缩时的宽度 默认是参照像素
    CGFloat scaledHeight;     // 压缩是的高度 默认是参照像素
    if (width > height) {
        scaledHeight = 1800;
        scaledWidth = 1800*width/height;
    } else {
        scaledWidth = 1800;
        scaledHeight = 1800*height/width;
    }
    
    // 如果图片需要重绘 就按照新的宽高压缩重绘图片
    UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight));
    // 绘制改变大小的图片
    [sourceImage drawInRect:CGRectMake(0, 0, scaledWidth,scaledHeight)];
    // 从当前context中创建一个改变大小后的图片
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 防止出错  可以删掉的
    if (newImage == nil) {
        newImage = sourceImage;
    }
    return newImage;
}

#pragma mark - VR照片压缩
- (NSData *)compressVRPublishImageLevel:(NSString *)filePath byLat:(NSString *)latStr byLngStr:(NSString *)lngStr {
    NSData *flagImageData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    //  取出照片的exif信息
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    
    
    UIImage *flagImage = [UIImage imageWithData:flagImageData];
    BOOL isCompress = NO;
    
    
    // 如果是VR图片上传，将宽度设定为2880。
    //如果两个边都大于最小边
    if(flagImage.size.width>2880 && flagImage.size.height>2880) {
        isCompress = YES;
        CGFloat smallSide = flagImage.size.width;                     //先假设width是最小边
        if(flagImage.size.width>flagImage.size.height) {                    //如果width>height，那height是最小边
            smallSide = flagImage.size.height;
        }
        CGFloat scale = 2880/smallSide;
        CGFloat w = flagImage.size.width;
        CGFloat h = flagImage.size.height;
        if (flagImage.imageOrientation == UIImageOrientationLeft || flagImage.imageOrientation == UIImageOrientationRight) {
            w = flagImage.size.height;
            h = flagImage.size.width;
        }
        CGSize sz = CGSizeMake(w*scale, h*scale);
        flagImage = [flagImage resizedImageToSize:sz];
    } else {
        
    }
    
    flagImageData = UIImageJPEGRepresentation(flagImage, 1);
    CGFloat compress_level = 1;
    while (flagImageData.length > 2880 * 1024) {
        compress_level -= 0.1;
        flagImageData = UIImageJPEGRepresentation(flagImage, compress_level);
    }
    
    // 写入exif信息
    [metadata setObject:@(1) forKey:@"Orientation"];
    if (latStr && latStr.length && lngStr && lngStr.length) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latStr doubleValue] longitude:[lngStr doubleValue]];
        [metadata setObject: [XTCSourceCompressManager gpsDictionaryForLocation:location] forKey:(NSString *)kCGImagePropertyGPSDictionary];
    } else {
        
    }
    if (isCompress) {
        [metadata setObject:@(flagImage.size.width) forKey:@"PixelWidth"];
        [metadata setObject:@(flagImage.size.height) forKey:@"PixelHeight"];
        [metadata setObject:@(compress_level) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
    } else {
        
    }
    flagImageData = [self writeExifInfor:flagImageData byMetadata:metadata];
    return flagImageData;
}

#pragma mark - 普通发布
- (void)publishNetworkingNormalPost:(XTCPublishMainModel *)publishMainModel  {
    NSSet *uploadSet = publishMainModel.uploads;
    // 排序
    NSMutableArray *flagSortArray = [[NSMutableArray alloc] init];
    NSMutableArray *imageIdArray = [[NSMutableArray alloc] init];
    NSMutableArray *imageDescArray = [[NSMutableArray alloc] init];
    NSMutableArray *imageTitleArray = [[NSMutableArray alloc] init];
    
    for (PublishSourceModel *uploadMoel in uploadSet) {
        [flagSortArray addObject:uploadMoel];
    }
    for (int i = 0; i < flagSortArray.count; i++) {
        for (int j = i+1; j < flagSortArray.count; j++) {
            XTCPublishSubUploadModel *headerModel = flagSortArray[i];
            XTCPublishSubUploadModel *backModel = flagSortArray[j];
            if (headerModel.file_index> backModel.file_index) {
                [flagSortArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            } else {
                
            }
        }
    }
    // 音频id
    NSString *audioId = @"";
    NSString *video = @"";
    NSString *videoCorver = @"";
    for (XTCPublishSubUploadModel *imageIdModel in flagSortArray) {
        if ([imageIdModel.file_type isEqualToString:@"audio"]) {
            audioId = imageIdModel.temp_id;
        } else if ([imageIdModel.file_type isEqualToString:@"video"]) {
            video = imageIdModel.temp_id;
        } else if ([imageIdModel.file_type isEqualToString:@"video_cover"]) {
            videoCorver = imageIdModel.temp_id;
        } else {
            [imageIdArray addObject:imageIdModel.temp_id];
            [imageDescArray addObject:imageIdModel.file_desc];
            [imageTitleArray addObject:imageIdModel.file_title];
        }
    }
    NSString * imageIds = [imageIdArray componentsJoinedByString:@","];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[GlobalData sharedInstance].userModel.token forKey:@"token"];
    [requestDict setObject:[GlobalData sharedInstance].userModel.user_id forKey:@"user_id"];
    [requestDict setObject:publishMainModel.post_title forKey:@"posttitle"];
    if (publishMainModel.post_content) {
        [requestDict setObject:publishMainModel.post_content forKey:@"postcontent"];
    } else {
        
    }
    [requestDict setObject:publishMainModel.share_location forKey:@"share_location"];
    [requestDict setObject:publishMainModel.is_personal forKey:@"is_personal"];
    [requestDict setObject:publishMainModel.tags forKey:@"tags"];
    if (publishMainModel.art_link.length && publishMainModel.art_link) {
        [requestDict setObject:publishMainModel.art_link forKey:@"art_link"];
    } else {
        
    }
    
    if (imageTitleArray.count) {
        [requestDict setObject:imageTitleArray forKey:@"images_title"];
    } else {
        
    }
    
    if (imageDescArray.count) {
        [requestDict setObject:imageDescArray forKey:@"images_desc"];
    } else {
        
    }
    
    if (imageIds.length && imageIds) {
        [requestDict setObject:imageIds forKey:@"images"];
    } else {
        
    }
    
    
    //  音频
    if (audioId.length) {
        [requestDict setObject:audioId forKey:@"audio"];
    }
    
    // 视频
    if (video.length) {
        [requestDict setObject:video forKey:@"video"];
    }
    
    // 视频封面
    if (videoCorver.length) {
        [requestDict setObject:videoCorver forKey:@"video_cover"];
    }
    
    if (publishMainModel.is_bus && publishMainModel.is_bus.length) {
        [requestDict setObject:publishMainModel.is_bus forKey:@"is_bus"];
    } else {
        [requestDict setObject:@"0" forKey:@"is_bus"];
    }
    
    if (publishMainModel.tk && publishMainModel.tk.length) {
        [requestDict setObject:publishMainModel.tk forKey:@"tk"];
    } else {
        
    }
    
    if (publishMainModel.publish_tour_time) {
        [requestDict setObject:publishMainModel.publish_tour_time forKey:@"tour_time"];
    }
    [requestDict setObject:publishMainModel.current_lng forKey:@"cur_lng"];
    [requestDict setObject:publishMainModel.current_lat forKey:@"cur_lat"];
    
    // 有的草稿箱链接是错误的处理
    if ([publishMainModel.art_link isEqualToString:@"http://(null)"]) {
        publishMainModel.art_link = @"";
        [requestDict setObject:@"" forKey:@"art_link"];
    } else {
        
    }
    
    // 互动帖子id
    if (publishMainModel.sub_post_id && publishMainModel.sub_post_id.length) {
        [requestDict setObject:publishMainModel.sub_post_id forKey:@"sub_post_id"];
    } else {
        
    }
    
    // 云聊跟帖
    if (publishMainModel.chat_id && publishMainModel.chat_id.length && ![publishMainModel.chat_id isEqualToString:@"(null)"]) {
        [requestDict setObject:publishMainModel.chat_id forKey:@"chat_id"];
    }
    if (publishMainModel.chat_type && publishMainModel.chat_type.length && ![publishMainModel.chat_type isEqualToString:@"(null)"]) {
        [requestDict setObject:publishMainModel.chat_type forKey:@"chat_type"];
    }
    [requestDict setObject:(publishMainModel.is_bus_show ? @"1" : @"0") forKey:@"is_bus_show"];
    
    // 尾部标题描述
    if (publishMainModel.ending_title && publishMainModel.ending_title.length) {
        [requestDict setObject:publishMainModel.ending_title forKey:@"ending_title"];
    }
    
    if (publishMainModel.ending_desc && publishMainModel.ending_desc.length) {
        [requestDict setObject:publishMainModel.ending_desc forKey:@"ending_desc"];
    }
    
    NSString *str = [XTCNetworkManager convertToJSONData:requestDict];
    
    
    NSDictionary *paras = @{@"_method":@"DELETE",
                            @"result":str};
    [[APIClient sharedClient] POST:@"/publishv1" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDict = responseObject;
        DDLogInfo(@"pubPost:%@", responseDict);
        if ([responseDict[@"code"] boolValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostSuccess" object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [publishMainModel MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            });
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogInfo(@"pubPost error:%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
    }];
}

#pragma mark - 多媒体发布
- (void)publishMultimediaNetworkingPost:(XTCPublishMainModel *)publishMainModel {
    // 多媒体上传
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[GlobalData sharedInstance].userModel.token forKey:@"token"];
    [requestDict setObject:[GlobalData sharedInstance].userModel.user_id forKey:@"user_id"];
    [requestDict setObject:publishMainModel.post_title forKey:@"posttitle"];
    if (publishMainModel.post_content) {
        [requestDict setObject:publishMainModel.post_content forKey:@"postcontent"];
    } else {
        
    }
    [requestDict setObject:publishMainModel.share_location forKey:@"share_location"];
    [requestDict setObject:publishMainModel.is_personal forKey:@"is_personal"];
    [requestDict setObject:publishMainModel.tags forKey:@"tags"];
    if (publishMainModel.art_link.length && publishMainModel.art_link) {
        [requestDict setObject:publishMainModel.art_link forKey:@"art_link"];
    } else {
        
    }
    // 互动帖子id
    if (publishMainModel.sub_post_id && publishMainModel.sub_post_id.length) {
        [requestDict setObject:publishMainModel.sub_post_id forKey:@"sub_post_id"];
    } else {
        
    }
    
    // 排序
    NSMutableArray *flagSortArray = [[NSMutableArray alloc] init];
    for (PublishSourceModel *uploadMoel in publishMainModel.uploads) {
        [flagSortArray addObject:uploadMoel];
    }
    for (int i = 0; i < flagSortArray.count; i++) {
        for (int j = i+1; j < flagSortArray.count; j++) {
            XTCPublishSubUploadModel *headerModel = flagSortArray[i];
            XTCPublishSubUploadModel *backModel = flagSortArray[j];
            if (headerModel.file_index> backModel.file_index) {
                [flagSortArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            } else {
                
            }
        }
    }
    NSMutableArray *requestArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *videoRequestDict = [[NSMutableDictionary alloc] init];
    int videoIndexflag = 0;
    for (int i=0; i<flagSortArray.count; i++) {
        XTCPublishSubUploadModel *requestModel = flagSortArray[i];
        NSMutableDictionary *flagRequestDict = [[NSMutableDictionary alloc] init];
        if ([requestModel.file_type isEqualToString:@"audio"]) {
            [requestDict setObject:requestModel.temp_id forKey:@"audio"];
        } else if ([requestModel.file_type isEqualToString:@"photo"]) {
            [flagRequestDict setValue:requestModel.temp_id forKey:@"id"];
            [flagRequestDict setValue:@"photo" forKey:@"type"];
            [flagRequestDict setValue:requestModel.file_desc forKey:@"text"];
            [flagRequestDict setValue:requestModel.file_title forKey:@"title"];
            [requestArray addObject:flagRequestDict];
        } else if ([requestModel.file_type isEqualToString:@"video_cover"]) {
            [videoRequestDict setValue:requestModel.temp_id forKey:@"cover_id"];
            [videoRequestDict setValue:@"video" forKey:@"type"];
            [videoRequestDict setValue:requestModel.file_desc forKey:@"text"];
            [videoRequestDict setValue:requestModel.file_title forKey:@"title"];
            videoIndexflag = i;
        } else {
            [videoRequestDict setValue:requestModel.temp_id forKey:@"id"];
            [videoRequestDict setValue:@"video" forKey:@"type"];
            [videoRequestDict setValue:requestModel.file_desc forKey:@"text"];
            [videoRequestDict setValue:requestModel.file_title forKey:@"title"];
        }
    }
    if (publishMainModel.is_bus && publishMainModel.is_bus.length && ![publishMainModel.is_bus isEqualToString:@"(null)"]) {
        [requestDict setObject:publishMainModel.is_bus forKey:@"is_bus"];
    } else {
        [requestDict setObject:@"0" forKey:@"is_bus"];
    }
    [requestArray insertObject:videoRequestDict atIndex:videoIndexflag];
    if (publishMainModel.publish_tour_time) {
        [requestDict setObject:publishMainModel.publish_tour_time forKey:@"tour_time"];
    }
    [requestDict setObject:requestArray forKey:@"resource"];
    
    // 发布贴在带上当前参考坐标
    [requestDict setObject:publishMainModel.current_lng forKey:@"cur_lng"];
    [requestDict setObject:publishMainModel.current_lat forKey:@"cur_lat"];
    
    if (publishMainModel.chat_id && publishMainModel.chat_id.length && ![publishMainModel.chat_id isEqualToString:@"(null)"]) {
        [requestDict setObject:publishMainModel.chat_id forKey:@"chat_id"];
    }
    if (publishMainModel.chat_type && publishMainModel.chat_type.length && ![publishMainModel.chat_type isEqualToString:@"(null)"]) {
        [requestDict setObject:publishMainModel.chat_type forKey:@"chat_type"];
    }
    
    // 有的草稿箱链接是错误的处理
    if ([publishMainModel.art_link isEqualToString:@"http://(null)"]) {
        publishMainModel.art_link = @"";
        [requestDict setObject:@"" forKey:@"art_link"];
    } else {
        
    }
    [requestDict setObject:(publishMainModel.is_bus_show ? @"1" : @"0") forKey:@"is_bus_show"];
    
    // 尾部标题描述
    if (publishMainModel.ending_title && publishMainModel.ending_title.length) {
        [requestDict setObject:publishMainModel.ending_title forKey:@"ending_title"];
    }
    
    if (publishMainModel.ending_desc && publishMainModel.ending_desc.length) {
        [requestDict setObject:publishMainModel.ending_desc forKey:@"ending_desc"];
    }
    
    
    NSString *str = [XTCNetworkManager convertToJSONData:requestDict];
    NSDictionary *paras = @{@"_method":@"DELETE",
                            @"result":str};
    [[APIClient sharedClient] POST:@"/publishmultimedia" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [XTCPublishManager sharePublishManager].isPubishLoading = NO;
        NSDictionary *responseDict = responseObject;
        if ([responseDict[@"code"] boolValue]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostSuccess" object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [publishMainModel MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            });
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogInfo(@"pubPost error:%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
    }];
}

#pragma mark - Pro数据发布数据添加到CoreData
- (void)createPublishProModel:(PublishNormalPostModel *)mainModel {
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    // 生成发布的model
    XTCPublishMainModel *publishMainModel = [XTCPublishMainModel MR_createEntityInContext:managedObjectContext];
    publishMainModel.art_link = mainModel.art_link ? mainModel.art_link : @"";
    publishMainModel.chat_id = mainModel.chatId ? mainModel.chatId : @"";
    publishMainModel.chat_type = mainModel.chatType ? mainModel.chatType : @"";
    publishMainModel.is_bus = mainModel.is_bus ? mainModel.is_bus : @"0";
    publishMainModel.is_personal = mainModel.is_personal;
    publishMainModel.post_content = mainModel.postcontent ? mainModel.postcontent : @"";
    publishMainModel.post_title = mainModel.posttitle;
    publishMainModel.pubish_date = mainModel.dateString;
    publishMainModel.publish_tour_time = mainModel.tourTime;
    publishMainModel.share_location = mainModel.share_location;
    publishMainModel.sub_post_id = mainModel.sub_post_id ? mainModel.sub_post_id : @"";
    publishMainModel.tags = mainModel.tags ? mainModel.tags : @"";
    publishMainModel.tk = mainModel.tk ? mainModel.tk : @"";
    publishMainModel.pubish_type = PublishProTypeEnum;
    publishMainModel.publish_sort_date = [NSDate date];
    publishMainModel.current_lat = mainModel.latStr ? mainModel.latStr : @"";
    publishMainModel.current_lng = mainModel.lngStr ? mainModel.lngStr : @"";
    publishMainModel.is_bus_show = mainModel.isBusShow;
    
    NSMutableSet *mutableSet = [[NSMutableSet alloc] init];
    // 向草稿箱插入数据
    
    // 添加照片
    NSMutableArray *uploadImageArray = [[NSMutableArray alloc] init];
    if (mainModel.proFirstDetailModel && mainModel.proFirstDetailModel.vrImage) {
        [uploadImageArray addObject:mainModel.proFirstDetailModel];
    }
    if (mainModel.proSecondDetailModel && mainModel.proSecondDetailModel.firstImage && mainModel.proSecondDetailModel.vrImage) {
        [uploadImageArray addObject:mainModel.proSecondDetailModel];
    }
    if (mainModel.proThirdDetailModel && mainModel.proThirdDetailModel.firstImage && mainModel.proThirdDetailModel.vrImage) {
        [uploadImageArray addObject:mainModel.proThirdDetailModel];
    }
    
    for (int i=0; i<uploadImageArray.count; i++) {
        ProDetailModel *proDetailModel = uploadImageArray[i];
        XTCPublishSubUploadModel *uploadModel_1 = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
        uploadModel_1.file_type = @"photo";
        uploadModel_1.post_type = @"mix";
        uploadModel_1.source_path = [self exportImages:@[proDetailModel.firstImage]].firstObject;
        uploadModel_1.pro_index = i;
        uploadModel_1.file_index = mutableSet.count;
        uploadModel_1.file_desc = proDetailModel.firstText ? proDetailModel.firstText : @"";
        [mutableSet addObject:uploadModel_1];
        
        XTCPublishSubUploadModel *uploadModel_2 = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
        uploadModel_2.file_type = @"photo";
        uploadModel_2.post_type = @"mix";
        uploadModel_2.source_path = [self exportImages:@[proDetailModel.secondImage]].firstObject;
        uploadModel_2.pro_index = i;
        uploadModel_2.file_index = mutableSet.count;
        uploadModel_2.file_desc = proDetailModel.secondText ? proDetailModel.secondText : @"";
        [mutableSet addObject:uploadModel_2];
        
        XTCPublishSubUploadModel *uploadModel_3 = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
        uploadModel_3.file_type = @"photo";
        uploadModel_3.post_type = @"mix";
        uploadModel_3.source_path = [self exportImages:@[proDetailModel.thirdImage]].firstObject;
        uploadModel_3.pro_index = i;
        uploadModel_3.file_index = mutableSet.count;
        uploadModel_3.file_desc = proDetailModel.thirdText ? proDetailModel.thirdText : @"";
        [mutableSet addObject:uploadModel_3];
        
        XTCPublishSubUploadModel *uploadModel = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
        uploadModel.file_type = @"vr";
        uploadModel.post_type = @"mix";
        uploadModel.source_path = [self exportImages:@[proDetailModel.vrImage]].firstObject;
        uploadModel.pro_index = i;
        uploadModel.file_index = mutableSet.count;
        uploadModel.file_desc = proDetailModel.vrTitle ? proDetailModel.vrTitle : @"";
        [mutableSet addObject:uploadModel];
        
        if (proDetailModel.voiceFile && proDetailModel.voiceFile.length) {
            XTCPublishSubUploadModel *audioUploadModel = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
            audioUploadModel.file_type = @"audio";
            audioUploadModel.post_type = @"mix";
            audioUploadModel.source_path = proDetailModel.voiceFile;
            audioUploadModel.pro_index = i;
            audioUploadModel.file_index = mutableSet.count;
            [mutableSet addObject:audioUploadModel];
        }
    }
    
    
    // 上传视频
    XTCPublishSubUploadModel *publishSubUploadModel = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
    publishSubUploadModel.file_type = @"video";
    publishSubUploadModel.post_type = @"mix";
    publishSubUploadModel.source_path = mainModel.proVideoFilePath;
    publishSubUploadModel.file_index = mutableSet.count;
    [mutableSet addObject:publishSubUploadModel];
    
    // 上传视频封面
    XTCPublishSubUploadModel *videoCoverUploadModel = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
    videoCoverUploadModel.file_type = @"video_cover";
    videoCoverUploadModel.post_type = @"mix";
    videoCoverUploadModel.source_path = mainModel.proCorverVideoImageFilePath;
    publishSubUploadModel.file_index = mutableSet.count;
    [mutableSet addObject:videoCoverUploadModel];
    
    // 上传pro封面
    XTCPublishSubUploadModel *proCoverUploadModel = [XTCPublishSubUploadModel MR_createEntityInContext:managedObjectContext];
    proCoverUploadModel.file_type = @"cover";
    proCoverUploadModel.post_type = @"mix";
    proCoverUploadModel.source_path = mainModel.proCorverImageFilePath;
    publishSubUploadModel.file_index = mutableSet.count;
    [mutableSet addObject:proCoverUploadModel];
    
    publishMainModel.draft_cover = mainModel.proCorverImageFilePath;
    
    publishMainModel.uploads = mutableSet;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    DDLogInfo(@"发布数据模型保存成功");
    
    if ([XTCPublishManager sharePublishManager].isPubishLoading) {
        // 正在上传的直接进入小秘书了
    } else {
        // 执行发布操作
        [self publishPost:publishMainModel];
    }
    
}

- (void)publishProNetworking:(XTCPublishMainModel *)publishMainModel {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    // 排序
    NSMutableArray *flagSortArray = [[NSMutableArray alloc] init];
    for (PublishSourceModel *uploadMoel in publishMainModel.uploads) {
        [flagSortArray addObject:uploadMoel];
    }
    for (int i = 0; i < flagSortArray.count; i++) {
        for (int j = i+1; j < flagSortArray.count; j++) {
            XTCPublishSubUploadModel *headerModel = flagSortArray[i];
            XTCPublishSubUploadModel *backModel = flagSortArray[j];
            if (headerModel.file_index> backModel.file_index) {
                [flagSortArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            } else {
                
            }
        }
    }
    
    
    
    NSMutableArray *vrIdArray = [[NSMutableArray alloc] init];
    NSMutableArray *adudioIdArray = [[NSMutableArray alloc] init];
    NSMutableArray *imageIdArray = [[NSMutableArray alloc] init];
    for (XTCPublishSubUploadModel *imageIdModel in flagSortArray) {
        if ([imageIdModel.file_type isEqualToString:@"cover"]) {
            [requestDict setObject:imageIdModel.temp_id forKey:@"cover"];
            continue;
        }
        if ([imageIdModel.file_type isEqualToString:@"video"]) {
            [requestDict setObject:imageIdModel.temp_id forKey:@"video"];
            continue;
        }
        if ([imageIdModel.file_type isEqualToString:@"video_cover"]) {
            [requestDict setObject:imageIdModel.temp_id forKey:@"video_cover"];
            continue;
        }
        if ([imageIdModel.file_type isEqualToString:@"vr"]) {
            [vrIdArray addObject:imageIdModel];
        }
        if ([imageIdModel.file_type isEqualToString:@"audio"]) {
            [adudioIdArray addObject:imageIdModel];
        }
        if ([imageIdModel.file_type isEqualToString:@"photo"]) {
            [imageIdArray addObject:imageIdModel];
        }
    }
    // vr与image拼接
    NSMutableArray *detailed = [[NSMutableArray alloc] init];
    for (int i = 0; i < vrIdArray.count; i++) {
        XTCPublishSubUploadModel *vrIdModel = vrIdArray[i];
        NSMutableDictionary *vrDict = [[NSMutableDictionary alloc] init];
        [vrDict setObject:vrIdModel.temp_id forKey:@"vr"];
        [vrDict setObject:vrIdModel.file_desc forKey:@"vr_title"];
        
        for (int y = 0; y < adudioIdArray.count; y++) {
            XTCPublishSubUploadModel *audioIdModel = adudioIdArray[y];
            if (audioIdModel.pro_index == i) {
                [vrDict setObject:audioIdModel.temp_id forKey:@"audio"];
            } else {
                
            }
        }
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (int flag = 0; flag<3; flag++) {
            XTCPublishSubUploadModel *imageIdModel = imageIdArray[i*3+flag];
            NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
            [imageDict setObject:imageIdModel.temp_id forKey:@"url"];
            [imageDict setObject:imageIdModel.file_desc forKey:@"photodesc"];
            [imagesArray addObject:imageDict];
            
        }
        [vrDict setObject:imagesArray forKey:@"images"];
        [detailed addObject:vrDict];
    }
    [requestDict setObject:detailed forKey:@"detailed"];
    [requestDict setObject:[GlobalData sharedInstance].userModel.token forKey:@"token"];
    [requestDict setObject:[GlobalData sharedInstance].userModel.user_id forKey:@"user_id"];
    [requestDict setObject:publishMainModel.post_title forKey:@"posttitle"];
    if (publishMainModel.post_content) {
        [requestDict setObject:publishMainModel.post_content forKey:@"desc"];
    } else {
        
    }
    
    [requestDict setObject:publishMainModel.share_location forKey:@"share_location"];
    [requestDict setObject:publishMainModel.is_personal forKey:@"is_personal"];
    [requestDict setObject:publishMainModel.tags forKey:@"tags"];
    if (publishMainModel.art_link.length && publishMainModel.art_link) {
        [requestDict setObject:publishMainModel.art_link forKey:@"art_link"];
    } else {
        
    }
    
    // 互动帖子id
    if (publishMainModel.sub_post_id && publishMainModel.sub_post_id.length) {
        [requestDict setObject:publishMainModel.sub_post_id forKey:@"sub_post_id"];
    } else {
        
    }
    
    [requestDict setObject:publishMainModel.current_lng forKey:@"cur_lng"];
    [requestDict setObject:publishMainModel.current_lat forKey:@"cur_lat"];
    
    if (publishMainModel.chat_id && publishMainModel.chat_id.length && ![publishMainModel.chat_id isEqualToString:@"(null)"]) {
        [requestDict setObject:publishMainModel.chat_id forKey:@"chat_id"];
    }
    if (publishMainModel.chat_type && publishMainModel.chat_type.length && ![publishMainModel.chat_type isEqualToString:@"(null)"]) {
        [requestDict setObject:publishMainModel.chat_type forKey:@"chat_type"];
    }
    if (publishMainModel.tk && publishMainModel.tk.length) {
        [requestDict setObject:publishMainModel.tk forKey:@"tk"];
    }
    [requestDict setObject:(publishMainModel.is_bus_show ? @"1" : @"0") forKey:@"is_bus_show"];
    NSString *str = [XTCNetworkManager convertToJSONData:requestDict];
    
    NSDictionary *paras = @{@"_method":@"DELETE",
                            @"result":str};
    
    DDLogInfo(@"pubPost:%@", requestDict);
    [[APIClient sharedClient] POST:@"/publishmix" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [XTCPublishManager sharePublishManager].isPubishLoading = NO;
        NSDictionary *responseDict = responseObject;
        if ([responseDict[@"code"] boolValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostSuccess" object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [publishMainModel MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            });
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogInfo(@"pubPost error:%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PublishPostFailed" object:nil];
    }];
}

@end
