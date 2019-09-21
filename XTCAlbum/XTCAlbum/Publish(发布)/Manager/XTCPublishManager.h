//
//  XTCPublishManager.h
//  ViewSpeaker
//
//  Created by Mac on 2019/6/3.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTCPublishMainModel+CoreDataClass.h"
#import "XTCPublishSubUploadModel+CoreDataClass.h"
#import "PublishNormalPostModel.h"
#import "PublishUploadFileModel.h"
#import <MagicalRecord/MagicalRecord.h>
#import "ApiUploadClient.h"
#import "WAFileUtil.h"
#import "XTCSourceCompressManager.h"
#import "SDAVAssetExportSession.h"
#import <AssetsLibrary/ALAsset.h>
#import "PublishSourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishManager : NSObject

+ (instancetype)sharePublishManager;

@property (nonatomic, assign) BOOL isPubishLoading;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, strong) NSMutableURLRequest *uploadRequest;
@property (nonatomic, assign) float uploadProgress;
@property (nonatomic, assign) NSInteger uploadCurrentFlag;
@property (nonatomic, assign) BOOL isCanPublish;
@property (nonatomic, strong) NSString *__nullable publishDraftCoverPath; // 发布中的model唯一标识


// 照片视频VR混编发布处理
- (void)createPublishModel:(PublishNormalPostModel *)mainModel byUploadModel:(NSMutableArray *)uploadArray byIsPublish:(BOOL)isPublish;
// Pro发布处理
- (void)createPublishProModel:(PublishNormalPostModel *)mainModel;


- (NSArray *)queryAllPublishMainData;
- (NSArray *)exportImages:(NSArray *)assetArray; // 导出照片放到本地沙盒中
- (NSArray *)writeImageToFilePath:(UIImage *)corverImage; // 直接将图片放到沙盒路径下

- (BOOL)queryIsHaveDraft;
- (void)publishPost:(XTCPublishMainModel *)publishMainModel;


@end

NS_ASSUME_NONNULL_END
