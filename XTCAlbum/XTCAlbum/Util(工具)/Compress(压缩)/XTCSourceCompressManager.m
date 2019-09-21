//
//  XTCSourceCompressManager.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/9.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCSourceCompressManager.h"

@implementation XTCSourceCompressManager

#pragma mark - VR照片压缩
+ (NSArray *)compressVRImages:(NSArray *)assetArray {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray * writeFileOps = [NSMutableArray array];
    NSMutableArray * localFiles = [NSMutableArray array];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    PHImageContentMode mode = PHImageContentModeDefault;
    CGSize s = PHImageManagerMaximumSize;
    s = CGSizeMake(5760, 2880);
    mode = PHImageContentModeAspectFit;
    for (id obj in assetArray) {
        
        NSBlockOperation * wop = [NSBlockOperation blockOperationWithBlock:^{
            
            __block UIImage *img = nil;
            PHAsset *assetObj = nil;
            if ([obj isKindOfClass:[UIImage class]]) {
                img = obj;
            }else {
                assetObj = obj;
                __block dispatch_semaphore_t sem1 = dispatch_semaphore_create(0);
                PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                options.synchronous = YES;
                options.networkAccessAllowed = YES;
                [manager requestImageForAsset:assetObj
                                   targetSize:s
                                  contentMode:mode
                                      options:options
                                resultHandler:^void(UIImage *image, NSDictionary *info) {
                                    img = image;
                                    dispatch_semaphore_signal(sem1);
                                    
                                }];
                dispatch_semaphore_wait(sem1, DISPATCH_TIME_FOREVER);
            }
            float compressScale = 1; // 照片压缩系数
            // 如果是VR图片上传，将宽度设定为2880。
            if(img.size.width>2880 && img.size.height>2880) {   //如果两个边都大于最小边
                CGFloat smallSide = img.size.width;                     //先假设width是最小边
                if(img.size.width>img.size.height) {                    //如果width>height，那height是最小边
                    smallSide = img.size.height;
                }
                CGFloat scale = 2880/smallSide;
                //DDLogInfo(@"img resize from %@", NSStringFromCGSize(img.size));
                CGFloat w = img.size.width;
                CGFloat h = img.size.height;
                if (img.imageOrientation==UIImageOrientationLeft || img.imageOrientation==UIImageOrientationRight) {
                    w = img.size.height;
                    h = img.size.width;
                }
                CGSize sz = CGSizeMake(w*scale, h*scale);
                
                img = [img resizedImageToSize:sz];
                
            }
            
            
            __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
            
            if (assetObj != nil) {
                metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:assetObj]];
            }
            [metadata setObject:@(1) forKey:@"Orientation"];
            NSDictionary *tiffDict = metadata[@"{TIFF}"];
            if (tiffDict) {
                NSMutableDictionary *tiffMutableDict = [[NSMutableDictionary alloc] initWithDictionary:tiffDict];
                [tiffMutableDict setObject:@(1) forKey:@"Orientation"];
                [metadata setObject:tiffMutableDict forKey:@"{TIFF}"];
            } else {
                
            }
            NSData *fileData;
            CGFloat compress_level = compressScale;
            [metadata setObject:@(compress_level) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
            fileData = [XTCSourceCompressManager dataFromImage:img metadata:metadata];
            while (fileData.length > 2800 * 1024) {
                compress_level -= 0.1;
                if (compress_level <= 0.1) {
                    break;
                }
                [metadata setObject:@(compress_level) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
                fileData = [XTCSourceCompressManager dataFromImage:img metadata:metadata];
            }
            
            img = nil;
            
            NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
            NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
            
            [fileData writeToFile:filePath atomically:NO];
            [localFiles addObject:filePath];
            fileData = nil;
        }];
        
        [writeFileOps addObject:wop];
    }
    
    NSOperationQueue *writeQueue = [[NSOperationQueue alloc] init];
    [writeQueue setMaxConcurrentOperationCount:1];
    [writeQueue addOperations:writeFileOps waitUntilFinished:YES];
    DDLogInfo(@"all image file resized and saved to local");
    
    return localFiles;
}

#pragma mark - 照片压缩
+ (NSArray *)compressImagesByAsset:(NSArray *)assetArray {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray * writeFileOps = [NSMutableArray array];
    NSMutableArray * localFiles = [NSMutableArray array];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    for (PHAsset *flagAsset in assetArray) {
        NSBlockOperation * wop = [NSBlockOperation blockOperationWithBlock:^{
            __block UIImage *lastImg = nil;
            __block NSData *flagImageData = nil;
            __block dispatch_semaphore_t sem1 = dispatch_semaphore_create(0);
            PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.synchronous = YES;
            options.networkAccessAllowed = YES;
            //            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11) {
            CGFloat width = flagAsset.pixelWidth;     // 源图片的宽
            CGFloat height = flagAsset.pixelHeight;   // 原图片的高
            CGFloat scaledWidth;      // 压缩时的宽度 默认是参照像素
            CGFloat scaledHeight;     // 压缩是的高度 默认是参照像素
            NSInteger flag = 1800;
            if (width < flag && height < flag) {
                scaledWidth = width;
                scaledHeight = height;
            } else {
                if (width < flag || height < flag) {
                    scaledWidth = width;
                    scaledHeight = height;
                } else {
                    if (width > height) {
                        scaledHeight = flag;
                        scaledWidth = flag*width/height;
                    } else {
                        scaledWidth = flag;
                        scaledHeight = flag*height/width;
                    }
                }
            }
            [manager requestImageForAsset:flagAsset targetSize:CGSizeMake(scaledWidth, scaledHeight) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
                metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:flagAsset]];
                flagImageData = [XTCSourceCompressManager dataFromImage:result metadata:metadata];
                lastImg = result;
                
                dispatch_semaphore_signal(sem1);
            }];
            /*
             } else {
             [manager requestImageDataForAsset:flagAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
             if ([dataUTI containsString:@"heic"]) {
             __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
             metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:flagAsset]];
             flagImageData = [XTCSourceCompressManager dataFromImage:[UIImage imageWithData:imageData] metadata:metadata];
             lastImg = [UIImage imageWithData:flagImageData];
             } else {
             flagImageData = imageData;
             lastImg = [UIImage imageWithData:imageData];
             }
             
             dispatch_semaphore_signal(sem1);
             }];
             }
             */
            dispatch_semaphore_wait(sem1, DISPATCH_TIME_FOREVER);
            
            if (flagImageData.length > 1.47*1024*1024) {
                lastImg = [XTCSourceCompressManager imageWithOriginalImage:lastImg];
                CGFloat compress_level = 1;
                NSData *fileData = UIImageJPEGRepresentation(lastImg, 1);
                if ((1.0*lastImg.size.width/lastImg.size.height) >= 3.0 || (1.0*lastImg.size.height/lastImg.size.width) >= 3.0) {
                    // 全景照片
                    while (fileData.length > 3.0 * 1024 * 1024) {
                        compress_level -= 0.02;
                        fileData = UIImageJPEGRepresentation(lastImg, compress_level);
                    }
                } else {
                    // 普通照片
                    while (fileData.length > 1.7 * 1024 * 1024) {
                        compress_level -= 0.02;
                        fileData = UIImageJPEGRepresentation(lastImg, compress_level);
                    }
                }
                // 写入exif信息
                __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
                metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:flagAsset]];
                [metadata setObject:@(1) forKey:@"Orientation"];
                NSDictionary *tiffDict = metadata[@"{TIFF}"];
                if (tiffDict) {
                    NSMutableDictionary *tiffMutableDict = [[NSMutableDictionary alloc] initWithDictionary:tiffDict];
                    [tiffMutableDict setObject:@(1) forKey:@"Orientation"];
                    [metadata setObject:tiffMutableDict forKey:@"{TIFF}"];
                } else {
                    
                }
                if ([metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary][@"Latitude"] == nil || [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary][@"Longitude"] == nil) {
                    if (flagAsset.location != nil) {
                        [metadata setObject: [XTCSourceCompressManager gpsDictionaryForLocation:flagAsset.location] forKey:(NSString *)kCGImagePropertyGPSDictionary];
                    } else {
                        
                    }
                }
                
                [metadata setObject:@(lastImg.size.width) forKey:@"PixelWidth"];
                [metadata setObject:@(lastImg.size.height) forKey:@"PixelHeight"];
                [metadata setObject:@(compress_level) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
                fileData = [XTCSourceCompressManager dataFromImage: [UIImage imageWithData:fileData] metadata:metadata];
                
                NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
                NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
                NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
                
                [fileData writeToFile:filePath atomically:NO];
                [localFiles addObject:filePath];
                fileData = nil;
                flagImageData = nil;
                lastImg = nil;
            } else {
                
                __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
                metadata = [NSMutableDictionary dictionaryWithDictionary:[XTCSourceCompressManager getMedata:flagAsset]];
                [metadata setObject:@(1) forKey:@"Orientation"];
                NSDictionary *tiffDict = metadata[@"{TIFF}"];
                if (tiffDict) {
                    NSMutableDictionary *tiffMutableDict = [[NSMutableDictionary alloc] initWithDictionary:tiffDict];
                    [tiffMutableDict setObject:@(1) forKey:@"Orientation"];
                    [metadata setObject:tiffMutableDict forKey:@"{TIFF}"];
                } else {
                    
                }
                
                if ([metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary][@"Latitude"] == nil || [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary][@"Longitude"] == nil) {
                    if (flagAsset.location != nil) {
                        [metadata setObject: [XTCSourceCompressManager gpsDictionaryForLocation:flagAsset.location] forKey:(NSString *)kCGImagePropertyGPSDictionary];
                    } else {
                        
                    }
                }
                
                [metadata setObject:@(lastImg.size.width) forKey:@"PixelWidth"];
                [metadata setObject:@(lastImg.size.height) forKey:@"PixelHeight"];
                
                NSData *fileData = [XTCSourceCompressManager dataFromImage:[XTCSourceCompressManager fixOrientation:lastImg] metadata:metadata];
                
                
                NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
                NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
                NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
                
                [fileData writeToFile:filePath atomically:NO];
                [localFiles addObject:filePath];
                flagImageData = nil;
                lastImg = nil;
            }
            
        }];
        [writeFileOps addObject:wop];
    }
    
    NSOperationQueue *writeQueue = [[NSOperationQueue alloc] init];
    [writeQueue setMaxConcurrentOperationCount:1];
    [writeQueue addOperations:writeFileOps waitUntilFinished:YES];
    return localFiles;
}


+ (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


+ (NSArray *)compressImagesByImage:(NSArray *)images {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray * writeFileOps = [NSMutableArray array];
    NSMutableArray * localFiles = [NSMutableArray array];
    
    for (UIImage *flagImage in images) {
        __block UIImage *lastImg = nil;
        NSBlockOperation * wop = [NSBlockOperation blockOperationWithBlock:^{
            lastImg = [XTCSourceCompressManager imageWithOriginalImage:flagImage];
            
            CGFloat compress_level = 1;
            NSData *fileData = UIImageJPEGRepresentation(lastImg, 1);
            if ((1.0*lastImg.size.width/lastImg.size.height) >= 3.0 || (1.0*lastImg.size.height/lastImg.size.width) >= 3.0) {
                // 全景照片
                while (fileData.length > 3.0 * 1024 * 1024) {
                    compress_level -= 0.001;
                    fileData = UIImageJPEGRepresentation(lastImg, compress_level);
                }
            } else {
                // 普通照片
                while (fileData.length > 1.7 * 1024 * 1024) {
                    compress_level -= 0.001;
                    fileData = UIImageJPEGRepresentation(lastImg, compress_level);
                }
            }
            
            
            
            // 写入exif信息
            __block NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
            
            NSData *imageData = UIImageJPEGRepresentation(flagImage, 1);
            CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
            NSDictionary *flagMetadata =  (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, NULL));
            
            
            metadata = [NSMutableDictionary dictionaryWithDictionary:flagMetadata];
            [metadata setObject:@(1) forKey:@"Orientation"];
            NSDictionary *tiffDict = metadata[@"{TIFF}"];
            if (tiffDict) {
                NSMutableDictionary *tiffMutableDict = [[NSMutableDictionary alloc] initWithDictionary:tiffDict];
                [tiffMutableDict setObject:@(1) forKey:@"Orientation"];
                [metadata setObject:tiffMutableDict forKey:@"{TIFF}"];
            } else {
                
            }
            
            [metadata setObject:@(lastImg.size.width) forKey:@"PixelWidth"];
            [metadata setObject:@(lastImg.size.height) forKey:@"PixelHeight"];
            [metadata setObject:@(compress_level) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
            fileData = [XTCSourceCompressManager dataFromImage: [UIImage imageWithData:fileData] metadata:metadata];
            
            lastImg = nil;
            
            NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
            NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
            
            [fileData writeToFile:filePath atomically:NO];
            [localFiles addObject:filePath];
            fileData = nil;
            
        }];
        [writeFileOps addObject:wop];
    }
    
    NSOperationQueue *writeQueue = [[NSOperationQueue alloc] init];
    [writeQueue setMaxConcurrentOperationCount:1];
    [writeQueue addOperations:writeFileOps waitUntilFinished:YES];
    return localFiles;
}


+ (NSDictionary *) gpsDictionaryForLocation:(CLLocation *)location
{
    CLLocationDegrees exifLatitude  = location.coordinate.latitude;
    CLLocationDegrees exifLongitude = location.coordinate.longitude;
    
    NSString * latRef;
    NSString * longRef;
    if (exifLatitude < 0.0) {
        exifLatitude = exifLatitude * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }
    
    if (exifLongitude < 0.0) {
        exifLongitude = exifLongitude * -1.0f;
        longRef = @"W";
    } else {
        longRef = @"E";
    }
    
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
    
    // requires ImageIO
    if (location == nil) {
        
    } else {
        [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    }
    
    [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [locDict setObject:longRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
    [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    
    return locDict;
    
}

+ (NSDictionary *)getMedata:(PHAsset *)asset {
    PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    
    
    PHImageManager *manager = [PHImageManager defaultManager];
    __block NSDictionary * metadata = [[NSDictionary alloc] init];
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        metadata = [XTCSourceCompressManager metadataFromImageData:imageData];
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return  metadata;
}

+ (NSDictionary*)metadataFromImageData:(NSData*)imageData{
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
        }
        CFRelease(imageSource);
    }
    
    DDLogInfo(@"Can't read metadata");
    return nil;
}

+ (UIImage *)imageWithOriginalImage:(UIImage *)sourceImage {
    CGFloat cgImageBytesPerRow = CGImageGetBytesPerRow(sourceImage.CGImage);
    CGFloat cgImageHeight = CGImageGetHeight(sourceImage.CGImage);
    NSUInteger size  = cgImageHeight * cgImageBytesPerRow;
    if (size > 1024*1024*2) {
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
        
        NSData * scaledImageData = nil;
        if (UIImageJPEGRepresentation(newImage, 1) == nil) {
            scaledImageData = UIImagePNGRepresentation(newImage);
        }else{
            scaledImageData = UIImageJPEGRepresentation(newImage, 1);
            if (scaledImageData.length > 1.8*1024*1024) {
                scaledImageData = UIImageJPEGRepresentation(newImage, 0.99);
            } else {
                
            }
        }
        return [UIImage imageWithData:scaledImageData];
    } else {
        return sourceImage;
    }
}

+ (NSMutableData *)dataFromImage:(UIImage *)image metadata:(NSDictionary *)metadata {
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)@"image/jpeg", NULL);
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, uti, 1, NULL);
    
    if (imageDestination == NULL)
    {
        DDLogInfo(@"Failed to create image destination");
        imageData = nil;
    }
    else
    {
        CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)metadata);
        
        if (CGImageDestinationFinalize(imageDestination) == NO)
        {
            DDLogInfo(@"Failed to finalise");
            imageData = nil;
        }
        CFRelease(imageDestination);
    }
    
    CFRelease(uti);
    
    return imageData;
}

+ (NSString *)sam_stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

#pragma mark - 帖子发布的当前坐标
+(void)publishGPS:(NSString *)publishId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([INTULocationManager locationServicesState] == INTULocationServicesStateAvailable || [INTULocationManager locationServicesState] == INTULocationServicesStateNotDetermined) {
            INTULocationManager *locMgr = [INTULocationManager sharedInstance];
            [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity timeout:10 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                if (status == INTULocationStatusSuccess) {
                    if (currentLocation) {
                        CLLocationCoordinate2D coordinate = currentLocation.coordinate;
                        NSString *coorStr = [NSString stringWithFormat:@"%f_%f", coordinate.longitude, coordinate.latitude];
                        [[EGOCache globalCache] setObject:coorStr forKey:publishId];
                    } else {
                        
                    }
                } else {
                    
                }
            }];
        } else {
            
        }
    });
}

+ (NSArray *)compressBuinessImagesByImage:(NSArray *)images {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray *writeFileOps = [NSMutableArray array];
    NSMutableArray *localFiles = [NSMutableArray array];
    @autoreleasepool {
        for (UIImage *flagImage in images) {
            NSBlockOperation * wop = [NSBlockOperation blockOperationWithBlock:^{
                NSData *flagImageData = UIImageJPEGRepresentation(flagImage, 1);
                if (flagImageData.length > 2.0*1024*1024) {
                    CGFloat compress_level = 1;
                    NSData *fileData = UIImageJPEGRepresentation(flagImage, 1);
                    // 普通照片
                    while (fileData.length > 2.0 * 1024 * 1024) {
                        compress_level -= 0.05;
                        fileData = UIImageJPEGRepresentation(flagImage, compress_level);
                    }
                    NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
                    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
                    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
                    
                    [fileData writeToFile:filePath atomically:NO];
                    [localFiles addObject:filePath];
                    fileData = nil;
                    flagImageData = nil;
                } else {
                    NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
                    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
                    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
                    
                    [flagImageData writeToFile:filePath atomically:NO];
                    [localFiles addObject:filePath];
                    flagImageData = nil;
                }
            }];
            [writeFileOps addObject:wop];
        }
    }
    NSOperationQueue *writeQueue = [[NSOperationQueue alloc] init];
    [writeQueue setMaxConcurrentOperationCount:1];
    [writeQueue addOperations:writeFileOps waitUntilFinished:YES];
    return localFiles;
}

+ (NSString *)compressRoadImagesByImage:(UIImage *)flagImage {
    UIImage *sourceImage = [self imageWithOriginalImage:flagImage];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray * localFiles = [NSMutableArray array];
    NSData *flagImageData = UIImageJPEGRepresentation(sourceImage, 1);
    if (flagImageData.length > 0.5*1024*1024) {
        CGFloat compress_level = 1;
        NSData *fileData = UIImageJPEGRepresentation(sourceImage, 1);
        // 普通照片
        while (fileData.length > 0.5 * 1024 * 1024) {
            compress_level -= 0.1;
            fileData = UIImageJPEGRepresentation(sourceImage, compress_level);
        }
        NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
        NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
        
        [fileData writeToFile:filePath atomically:NO];
        [localFiles addObject:filePath];
        fileData = nil;
    } else {
        NSString *name = [XTCSourceCompressManager sam_stringWithUUID];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
        NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
        
        [flagImageData writeToFile:filePath atomically:NO];
        [localFiles addObject:filePath];
        flagImageData = nil;
    }
    return localFiles.firstObject;
}


@end
