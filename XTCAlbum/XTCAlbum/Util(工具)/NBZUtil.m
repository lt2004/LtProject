//
//  NBUtil.m
//  Podbean
//
//  Created by Jacky on 11/12/14.
//  Copyright (c) 2014 Podbean. All rights reserved.
//

#import "NBZUtil.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "TQLocationConverter.h"
#import <ImageIO/ImageIO.h>

@implementation NBZUtil

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title inVC:(UIViewController *)vc {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [vc presentViewController:alert animated:YES completion:nil];
}


+ (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *bzpath  = [UIBezierPath bezierPath];
    
    CGFloat theta       = 2.0 * M_PI / sides;                           // how much to turn at every corner
    CGFloat offset      = cornerRadius * tanf(theta / 2.0);             // offset from which to start rounding corners
    CGFloat squareWidth = MIN(square.size.width, square.size.height);   // width of the square
    
    // calculate the length of the sides of the polygon
    
    CGFloat length      = squareWidth - lineWidth;
    if (sides % 4 != 0) {                                               // if not dealing with polygon which will be square with all sides ...
        length = length * cosf(theta / 2.0) + offset/2.0;               // ... offset it inside a circle inside the square
    }
    CGFloat sideLength = length * tanf(theta / 2.0);
    
    // start drawing at `point` in lower right corner
    
    CGPoint point = CGPointMake(squareWidth / 2.0 + sideLength / 2.0 - offset, squareWidth - (squareWidth - length) / 2.0);
    CGFloat angle = M_PI;
    [bzpath moveToPoint:point];
    
    // draw the sides and rounded corners of the polygon
    
    for (NSInteger side = 0; side < sides; side++) {
        point = CGPointMake(point.x + (sideLength - offset * 2.0) * cosf(angle), point.y + (sideLength - offset * 2.0) * sinf(angle));
        [bzpath addLineToPoint:point];
        
        CGPoint center = CGPointMake(point.x + cornerRadius * cosf(angle + M_PI_2), point.y + cornerRadius * sinf(angle + M_PI_2));
        [bzpath addArcWithCenter:center radius:cornerRadius startAngle:angle - M_PI_2 endAngle:angle + theta - M_PI_2 clockwise:YES];
        
        point = bzpath.currentPoint; // we don't have to calculate where the arc ended ... UIBezierPath did that for us
        angle += theta;
    }
    
    [bzpath closePath];
    
    // rotate it 90 degrees
    [bzpath applyTransform:CGAffineTransformMakeRotation(M_PI/2)];
    // now move it back so that the top left of its bounding box is (0,0)
    [bzpath applyTransform:CGAffineTransformMakeTranslation(squareWidth, 0)];
    
    return bzpath;
}

+ (NSString *)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
}


+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSInteger)gainStringNumber {
    NSString *flagString = [[NSUserDefaults standardUserDefaults] objectForKey:@"FlagStreamingLine"];
    if (flagString) {
        if ([flagString intValue] < kStreamSystemMin) {
            return kStreamSystemMin;
        } else if ([flagString intValue] > kStreamSystemMax) {
            return kStreamSystemMax;
        } else {
            return [flagString integerValue];
        }
    } else {
        return kStreamSystemMin;
    }
}


+ (void)setStreamNumber:(NSInteger)number {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", number] forKey:@"FlagStreamingLine"];
}

+ (BOOL)checkIphoneX {
    if(kDevice_Is_iPhoneX) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)saveHistoryTag:(PublishNormalPostModel *)flagModel {
    NSMutableArray *historyTagArray = [[NSMutableArray alloc] init];
    NSString *historyTagString = [[NSUserDefaults standardUserDefaults] objectForKey:@"HistoryTag"];
    if (historyTagString && historyTagString.length) {
        [historyTagArray addObjectsFromArray: [historyTagString componentsSeparatedByString:@","]];
    } else {
        
    }
    NSArray *flagArray = [flagModel.tags componentsSeparatedByString:@","];
    for (NSString *flagString in flagArray) {
        if ([historyTagArray containsObject:flagString]) {
            
        } else {
            if ([flagString isEqualToString:@"风景"] || [flagString isEqualToString:@"美食"] || [flagString isEqualToString:@"人文"] || [flagString isEqualToString:@"娱乐"]) {
                
            } else {
                [historyTagArray addObject:flagString];
            }
        }
    }
    if (historyTagArray.count >= 5) {
        historyTagArray = [[NSMutableArray alloc] initWithArray:[historyTagArray subarrayWithRange:NSMakeRange(0, 5)]];
    } else {
        
    }
    NSString *tagString = [historyTagArray componentsJoinedByString:@","];
    if (tagString && tagString.length) {
        [[NSUserDefaults standardUserDefaults] setObject:tagString forKey:@"HistoryTag"];
    } else {
        
    }
}

+ (NSMutableAttributedString *)createOCEmoji:(NSString *)flagString {
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:flagString ? flagString : @""];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [titleParagraphStyle setLineSpacing:9];
    titleParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [titleAttributedString addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, titleAttributedString.string.length)];
    [titleAttributedString addAttribute:NSBaselineOffsetAttributeName value:@(0) range:NSMakeRange(0, [titleAttributedString.string length])];
    return titleAttributedString;
}

+ (NSMutableAttributedString *)createProOCEmoji:(NSString *)flagString {
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:flagString ? flagString : @""];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [titleParagraphStyle setLineSpacing:7];
    titleParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [titleAttributedString addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(0, titleAttributedString.string.length)];
    return titleAttributedString;
}

+ (void)fixInterfaceOrientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

+ (void)addGPSToSavedVideByLocaltion:(CLLocation *)location callBack:(void (^)(BOOL isSucesss))block {
    //支持ios8以上的版本
    if ([PHAsset class]){
        // 获取相册里所有的视频，并按视频的创建时间排序
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        fetchOptions.fetchLimit = 1;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
        // 拿到最后一个视频资源 即最新的视频资源
        PHAsset *lastAsset = [fetchResult lastObject];
        
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            if ([info objectForKey:PHImageErrorKey] == nil && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                [lastAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                    NSURL *imageURL = contentEditingInput.fullSizeImageURL;
                    NSString *urlstring = [imageURL absoluteString];
                    DDLogInfo(@"Urlstring = %@",urlstring);
                }];
                
                //用坐标和日期创建新的location
//                double latitude = [[GlobalData sharedInstance].currentLat doubleValue];
//                double longitude = [[GlobalData sharedInstance].currentLng doubleValue];
//                CLLocationCoordinate2D locationNew = CLLocationCoordinate2DMake(latitude,longitude);
//                NSDate *nowDate = [NSDate date];
//                CLLocation *newLocation = [[CLLocation alloc ]initWithCoordinate:locationNew altitude:0.0 horizontalAccuracy:1.0 verticalAccuracy:1.0 timestamp:nowDate];
                
                //我们请求更改metadata，并插入新的location
                //当视频已经被保存的回调被触发时，将会把写的元数据写入视频
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    // 从要被修改元数据的Asset中创建修改请求
                    PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:lastAsset];
                    // 设置请求的属性来改变Asset
                    request.location = location;
                    
                } completionHandler:^(BOOL success, NSError *error) {
                    if (error) {
                        [KVNProgress showErrorWithStatus:@"保存视频失败"];
                        block(NO);
                    } else {
                        [KVNProgress showSuccessWithStatus:@"保存视频成功" completion:^{
                            block(YES);
                        }];
                    }
                    DDLogInfo(@"Finished updating asset. %@", (success ? @"Success." : error));
                }];
            }
        }];
        
        
    }else {
        //如果是iOS8之前的版本  暂时不支持添加位置信息
        DDLogInfo(@"Pre-iOS8 does not support adding GPS");
    }
}

+ (CGFloat)dynamicFont:(CGFloat)fontSize {
    // 375为基准
    if (kScreenWidth == 375) {
        
    } else {
        if (kScreenWidth >= 414) {
            fontSize = fontSize*414.0/375;
        } else {
            fontSize = fontSize*kScreenWidth/375.0;
        }
    }
    return fontSize;
}

+ (BOOL)judgeJanpanSystemLanguage {
    NSString *localeLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if ([localeLanguageCode isEqualToString:@"ja"]) {
        return YES;
    } else {
        return NO;
    }
    
}

+ (SystemLanguageType)judgeSystemLanguage {
    NSString *localeLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if ([localeLanguageCode isEqualToString:@"ja"]) {
        return SystemLanguageJapanType;
    } else if ([localeLanguageCode isEqualToString:@"en"]){
        return SystemLanguageEnglishType;
    } else {
        return SystemLanguageChinaType;
    }
    
}

@end
