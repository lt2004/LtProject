//
//  TZSelectPublishTypeCell.m
//  vs
//
//  Created by Xie Shu on 2017/12/13.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "TZSelectPublishTypeCell.h"

@implementation TZSelectPublishTypeCell
@synthesize selectTypeButton = _selectTypeButton;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSelectPublishTypeCellUI];
    }
    return self;
}

- (void)createSelectPublishTypeCellUI {
    _selectTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectTypeButton.frame = CGRectMake(0, 0, 42, 42);
    _selectTypeButton.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_selectTypeButton];
    
    _selectTypeButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _selectTypeButton.enabled = NO;
}

- (void)loadByIndex:(NSInteger)selectIndex isHaveDraft:(BOOL)isDraft bySelectType:(SelectPublishTypeEnum)selectType {
    if ([[GlobalData sharedInstance].userModel.level intValue] < 4) {
        switch (selectIndex) {
            case 0: {
                if (selectType == SelectPublishTypePhotoEnum) {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_photo"] forState:UIControlStateDisabled];
                } else {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_photo_unselect"] forState:UIControlStateDisabled];
                }
                
                self.selectPublishTypeEnum = SelectPublishTypePhotoEnum;
            }
                break;
            case 1: {
                if (selectType == SelectPublishTypeVideoEnum) {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_video"] forState:UIControlStateDisabled];
                } else {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_video_unselect"] forState:UIControlStateDisabled];
                }
                _selectPublishTypeEnum = SelectPublishTypeVideoEnum;
            }
                break;
            case 2: {
                if (selectType == SelectPublishType720VREnum) {
                     [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_720vr"] forState:UIControlStateDisabled];
                } else {
                     [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_720vr_unselect"] forState:UIControlStateDisabled];
                }
                _selectPublishTypeEnum = SelectPublishType720VREnum;
            }
                break;
            case 3: {
                [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_travel"] forState:UIControlStateDisabled];
                _selectPublishTypeEnum = SelectPublishTypeTravelCameraEnum;
            }
                break;
            case 4: {
                [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_draft"] forState:UIControlStateDisabled];
                _selectPublishTypeEnum = SelectPublishTypeDraftEnum;
                
            }
                break;
            default:
                break;
        }
    } else {
        switch (selectIndex) {
            case 0: {
                if (selectType == SelectPublishTypePhotoEnum) {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_photo"] forState:UIControlStateDisabled];
                } else {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_photo_unselect"] forState:UIControlStateDisabled];
                }
                self.selectPublishTypeEnum = SelectPublishTypePhotoEnum;
            }
                break;
            case 1: {
                if (selectType == SelectPublishTypeVideoEnum) {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_video"] forState:UIControlStateDisabled];
                } else {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_video_unselect"] forState:UIControlStateDisabled];
                }
                _selectPublishTypeEnum = SelectPublishTypeVideoEnum;
            }
                break;
            case 2: {
                if (selectType == SelectPublishType720VREnum) {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_720vr"] forState:UIControlStateDisabled];
                } else {
                    [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_720vr_unselect"] forState:UIControlStateDisabled];
                }
                _selectPublishTypeEnum = SelectPublishType720VREnum;
            }
                break;
            case 3: {
                if (selectType == SelectPublishTypeProEnum) {
                     [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_pro"] forState:UIControlStateDisabled];
                } else {
                     [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_pro_unselect"] forState:UIControlStateDisabled];
                }
                _selectPublishTypeEnum = SelectPublishTypeProEnum;
            }
                break;
            case 4: {
                [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_travel"] forState:UIControlStateDisabled];
                _selectPublishTypeEnum = SelectPublishTypeTravelCameraEnum;
                
            }
                break;
            case 5: {
                [_selectTypeButton setImage:[UIImage imageNamed:@"xtc_publish_draft"] forState:UIControlStateDisabled];
                _selectPublishTypeEnum = SelectPublishTypeDraftEnum;
            }
                break;
            default:
                break;
        }
    }
    
}


@end
