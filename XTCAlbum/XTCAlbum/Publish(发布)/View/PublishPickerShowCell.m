//
//  PublishPickerShowCell.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/29.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "PublishPickerShowCell.h"

@implementation PublishPickerShowCell


- (XTCPublishPhotoShowView *)previewView {
    if (_previewView == nil) {
        XTCPublishPhotoShowView *previewView = [[XTCPublishPhotoShowView alloc] initWithFrame:self.contentView.bounds];
        previewView.contentMode = UIViewContentModeScaleAspectFit;
        previewView.clipsToBounds = YES;
        [self.contentView addSubview:previewView];
        _previewView = previewView;
    }
    return _previewView;
}


@end
