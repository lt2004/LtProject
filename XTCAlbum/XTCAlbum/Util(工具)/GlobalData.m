//
//  GlobalData.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/3.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "GlobalData.h"
#import <sys/utsname.h>

@implementation GlobalData

+ (GlobalData *)sharedInstance {
    static GlobalData *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GlobalData alloc] init];
        _sharedInstance.homeAdvertArray = [[NSMutableArray alloc] init];
        _sharedInstance.monthLineArray = [[NSMutableArray alloc] init];
        _sharedInstance.dayLineArray = [[NSMutableArray alloc] init];
        NSString *getDeviceString = [RSKeyChain load:XTCDeviceId];
        if (getDeviceString == nil) {
            NSString *deviceIdString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [RSKeyChain save:XTCDeviceId data:deviceIdString];
            _sharedInstance.deviceId = [RSKeyChain load:XTCDeviceId];
        }
    });
    
    return _sharedInstance;
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

- (void)cleanCache {
    // 删除发布时无用文件
    NSMutableArray *findArray = [self getAllFileNames];
    NSArray *pathArray = [[XTCPublishManager sharePublishManager] queryAllPublishMainData];
    for (XTCPublishMainModel *publishMainModel in pathArray) {
        for (XTCPublishSubUploadModel *publishSubUploadModel in publishMainModel.uploads) {
            NSString *flagPath = [publishSubUploadModel.source_path componentsSeparatedByString:@"/"].lastObject;
            [findArray removeObject:flagPath];
        }
    }
    NSString *mayDeleteOutputURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    for (NSString *deletePath in findArray) {
        NSURL *deletePathUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", mayDeleteOutputURL, deletePath]];
        // 清除文件了
        DDLogInfo(@"清除文件了:%@", deletePath);
        [[NSFileManager defaultManager] removeItemAtURL:deletePathUrl error:nil];
    }
}

- (NSMutableArray *)getAllFileNames {
    // 获得沙盒下所有jpg，mp4，mp3文件
    NSMutableArray *queryFileArray = [[NSMutableArray alloc] init];
    NSArray *patchs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [patchs objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString *fileStr in files) {
        if ([fileStr hasSuffix:@".mp4"] || [fileStr hasSuffix:@".mp3"] || [fileStr hasSuffix:@".jpg"]) {
            if ([fileStr componentsSeparatedByString:@"/"].count > 1) {
                
            } else {
                [queryFileArray addObject:fileStr];
            }
        } else {
            
        }
    }
    return queryFileArray;
}

// 获取设备型号然后手动转化为对应名称
- (NSString *)getDeviceName
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}

@end
