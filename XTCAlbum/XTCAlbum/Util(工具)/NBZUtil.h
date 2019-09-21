//
//  NBUtil.h
//  Podbean
//
//  Created by Jacky on 11/12/14.
//  Copyright (c) 2014 Podbean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APIClient.h"
#import "XTCBaseNavigationController.h"
#import <CoreLocation/CoreLocation.h>
#import <sys/utsname.h>
#import "AppDelegate.h"
#import "PublishNormalPostModel.h"

@interface NBZUtil : NSObject

+ (SystemLanguageType)judgeSystemLanguage;

+ (NSInteger)gainStringNumber;
+ (void)setStreamNumber:(NSInteger)number;

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title inVC:(UIViewController *)vc;

+ (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius;

+ (NSString *)iphoneType;
+ (UIImage *)createImageWithColor:(UIColor *)color;
+ (void)saveHistoryTag:(PublishNormalPostModel *)flagModel;
+ (BOOL)checkIphoneX;
+ (NSMutableAttributedString *)createOCEmoji:(NSString *)flagString;
+ (NSMutableAttributedString *)createProOCEmoji:(NSString *)flagString;
+ (void)fixInterfaceOrientation;
+ (void)addGPSToSavedVideByLocaltion:(CLLocation *)location callBack:(void (^)(BOOL isSucesss))block;
+ (CGFloat)dynamicFont:(CGFloat)fontSize;

@end
