//
//  XTCShareHelper.h
//  vs
//
//  Created by Xie Shu on 2017/12/16.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UMSocialCore/UMSocialCore.h>

typedef void (^ShareBlock)(BOOL shareFlag);

@interface XTCShareHelper : NSObject

@property (nonatomic, strong) ShareBlock _Nullable shareBlock;

+ (instancetype)sharedXTCShareHelper;

- (void)shreDataByImages:(NSArray *_Nullable)shareImageArray byVC:(UIViewController *_Nullable)showVC byiPadView:(UIView *_Nullable)iPadView;
- (void)shareVideo:(NSString *_Nullable)shareURL byVC:(UIViewController *_Nullable)showVC byiPadView:(UIView *_Nullable)iPadView;
- (void)shreDataByTitle:(NSString *_Nullable)title byDesc:(NSString *_Nullable)desc byThumbnailImage:(UIImage *_Nullable)shareImage byMedia:(NSString *_Nullable)shareURL byVC:(UIViewController *_Nullable)showVC byiPadView:(UIView *_Nullable)iPadView;

@end
