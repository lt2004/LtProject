//
//  PublishDraftCell.m
//  vs
//
//  Created by Xie Shu on 2017/10/18.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishDraftCell.h"
#import "PublishUploadFileModel.h"
#import "WAFileUtil.h"

@implementation PublishDraftCell
@synthesize contentImageView = _contentImageView;
@synthesize titleLabel = _titleLabel;
@synthesize timeLabel = _timeLabel;
@synthesize circleProgress = _circleProgress;
@synthesize publishTypeLabel = _publishTypeLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    _circleProgress = [[ZZCircleProgress alloc] initWithFrame:CGRectMake(kScreenWidth-60, 20, 45, 45) pathBackColor:kTableviewCellColor pathFillColor:HEX_RGB(0x8FDA3C) startAngle:0 strokeWidth:3];
    _circleProgress.progress = 0.0;
    _circleProgress.increaseFromLast = YES;
    _circleProgress.showPoint = NO;
//    _circleProgress.progressLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:_circleProgress];
}

- (void)insertDataToCell:(XTCDraftPublishModel *)postModel {
    _titleLabel.text = postModel.publishMainModel.post_title;
    _timeLabel.text = postModel.publishMainModel.pubish_date;
    self.contentImageView.image = nil;
    if (postModel.showImage) {
        self.contentImageView.image = postModel.showImage;
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *path = [CWAFileUtil getDocumentPath];
            NSString *filePath = [[postModel.publishMainModel.draft_cover componentsSeparatedByString:@"/"] lastObject];
            UIImage *flagImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, filePath]];
            
            CGSize targetSize = CGSizeMake(200, 1.0*200*flagImage.size.height/flagImage.size.width);
            UIGraphicsBeginImageContext(targetSize);
            [flagImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
            UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.contentImageView.image = targetImage;
                postModel.showImage = targetImage;
            });
        });
    }
    _contentImageView.layer.cornerRadius = 4;
    _contentImageView.layer.masksToBounds = YES;
    _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSSet *uploadSet = postModel.publishMainModel.uploads;
    
    // 上传进度
    int uploadCurrentFlag = 0;
    for (XTCPublishSubUploadModel *uploadModel in uploadSet) {
        if (uploadModel.temp_id && uploadModel.temp_id.length) {
            uploadCurrentFlag++;
        } else {

        }
    }
    float progress;
    if (uploadSet.count) {
        progress = ((float)uploadCurrentFlag)/uploadSet.count;
        _circleProgress.progress = progress;
    } else {
     
    }
    
    if (postModel.publishMainModel.pubish_type == PublishPhotoTypeEnum) {
        _publishTypeLabel.text = @"照片";
    } else if (postModel.publishMainModel.pubish_type == PublishVRTypeEnum) {
         _publishTypeLabel.text = @"720全景";
    } else if (postModel.publishMainModel.pubish_type == PublishVideoTypeEnum) {
         _publishTypeLabel.text = @"视频";
    } else if (postModel.publishMainModel.pubish_type == PublishPhotoVideoTypeEnum) {
         _publishTypeLabel.text = @"多媒体";
    } else {
         _publishTypeLabel.text = @"PRO专享";
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
