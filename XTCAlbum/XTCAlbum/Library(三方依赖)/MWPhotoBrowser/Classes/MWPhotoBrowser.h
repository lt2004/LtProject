//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWPhotoProtocol.h"
#import "MWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) DDLogInfo(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif

@class MWPhotoBrowser;

@protocol MWPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;

@end

typedef void (^ImageDescArrayCallback)(NSMutableArray *imageDescArray);
typedef void (^ImageArrayDeleteCallback)(NSInteger deleteFlag);

@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet id<MWPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableGrid;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL startOnGrid;
@property (nonatomic) BOOL autoPlayOnAppear;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;

// Customise image selection icons as they are the only icons with a colour tint
// Icon should be located in the app's main bundle
@property (nonatomic, strong) NSString *customImageSelectedIconName;
@property (nonatomic, strong) NSString *customImageSelectedSmallIconName;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@property (nonatomic, assign) BOOL isEdit; // 是否为发布编辑
@property (nonatomic, assign) BOOL isLS; // 是否为路书
@property (nonatomic, strong) UITextView *imageDescTextView;
@property (nonatomic, strong) UITextView *imageDescBgView;
@property (nonatomic, strong) UIButton *imageDescButton;
@property (nonatomic, strong) NSString *postUserId; // 图片所有人id
@property (nonatomic, strong) ImageDescArrayCallback imageDescArrayCallback;
@property (nonatomic, strong) ImageArrayDeleteCallback imageArrayDeleteCallback;
@property (nonatomic, strong) NSMutableArray *publishSourceModelArray;

@end
