//
//  XTCShareHelper.m
//  vs
//
//  Created by Xie Shu on 2017/12/16.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "XTCShareHelper.h"
//#import "SharedItem.h"
#import "MWPhotoBrowser.h"
#import "XTCSourceDetailVRViewController.h"

@implementation XTCShareHelper

static XTCShareHelper *_shareHelper;

+ (instancetype)sharedXTCShareHelper {
    if (_shareHelper == nil) {
        _shareHelper = [[XTCShareHelper alloc] init];
    }
    return _shareHelper;
}

#pragma mark - 分享多张照片或视频
- (void)shareMoreImageOrVideo:(NSMutableArray *)imageOrVideoArray byVC:(UIViewController *)showVC completion:(void (^ __nullable)(void))completion {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:imageOrVideoArray applicationActivities:nil];
    activityViewController.excludedActivityTypes = [NSArray arrayWithObjects: UIActivityTypeSaveToCameraRoll, nil];
    activityViewController.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        if (completed) {
            
        } else {
            
        }
        NSLog(@"%@", activityError);
    };
    [showVC presentViewController:activityViewController animated:YES completion:^{
        completion();
    }];
}

#pragma mark - 分享视频
- (void)shareVideo:(NSString *)shareURL byVC:(UIViewController *)showVC byiPadView:(UIView *)iPadView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:shareURL]] applicationActivities:nil];
        
        
        activityViewController.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
            if (completed) {
                
            } else {
                
            }
            NSLog(@"%@", activityError);
        };
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            UIPopoverPresentationController *popPresenter = [activityViewController popoverPresentationController];
            popPresenter.sourceView = iPadView;
            popPresenter.sourceRect = iPadView.bounds;
            [showVC presentViewController:activityViewController animated:YES completion:nil];
        } else {
            [showVC presentViewController:activityViewController animated:YES completion:nil];
        }
    });
}


#pragma mark - 分享纯照片
- (void)shreDataByImages:(NSArray *)shareImageArray byVC:(UIViewController *)showVC byiPadView:(UIView *)iPadView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:shareImageArray applicationActivities:nil];
        activityViewController.excludedActivityTypes = [NSArray arrayWithObjects: UIActivityTypeSaveToCameraRoll, nil];
        
        activityViewController.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
            if (completed) {
                
            } else {
                
            }
            NSLog(@"%@", activityError);
        };
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            UIPopoverPresentationController *popPresenter = [activityViewController popoverPresentationController];
            popPresenter.sourceView = iPadView;
            popPresenter.sourceRect = iPadView.bounds;
            [showVC presentViewController:activityViewController animated:YES completion:nil];
        } else {
            [showVC presentViewController:activityViewController animated:YES completion:nil];
        }
    });
}

- (void)shreDataByTitle:(NSString *)title byDesc:(NSString *)desc byThumbnailImage:(UIImage *)shareImage byMedia:(NSString *)shareURL byVC:(UIViewController *)showVC byiPadView:(UIView *)iPadView {
    NSMutableArray *shareActivityArray = [[NSMutableArray alloc] init];
    NSString *textToShare;
    UIImage *imageToShare;
    NSURL *urlToShare;
    if ([shareURL hasSuffix:@".mp4"]) {
        
    } else {
        
    }
    textToShare = title;
    imageToShare = shareImage;
    urlToShare = [NSURL URLWithString:shareURL];
    
    
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:[shareURL hasSuffix:@".mp4"] ? @[[NSURL fileURLWithPath:shareURL], @""] : @[urlToShare, textToShare, imageToShare] applicationActivities:[shareURL hasSuffix:@".mp4"] ? nil :shareActivityArray];
    activityViewController.excludedActivityTypes = [NSArray arrayWithObjects: UIActivityTypeSaveToCameraRoll, nil];
    
    activityViewController.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        if (completed) {
            
        } else {
            
        }
        NSLog(@"%@", activityError);
    };
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popPresenter = [activityViewController popoverPresentationController];
        popPresenter.sourceView = iPadView;
        popPresenter.sourceRect = iPadView.bounds;
        [showVC presentViewController:activityViewController animated:YES completion:nil];
    } else {
        [showVC presentViewController:activityViewController animated:YES completion:nil];
    }
}

@end
