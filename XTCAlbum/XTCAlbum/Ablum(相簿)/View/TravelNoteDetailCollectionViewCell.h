//
//  TravelNoteDetailCollectionViewCell.h
//  ViewSpeaker
//
//  Created by Mac on 2019/3/16.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TravelNoteDetailCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *defaultImageView;
@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *deleteButton;
//@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

NS_ASSUME_NONNULL_END
