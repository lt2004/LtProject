//
//  PublishMapSelectCell.h
//  vs
//
//  Created by Xie Shu on 2018/4/3.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>
#import <TZImagePickerController/TZImagePickerController.h>

@interface PublishMapSelectCell : UICollectionViewCell {

}

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UILabel *selectCountLabel;
@property (nonatomic, strong)  CALayer *shadowLayer;

- (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius byAsset:(PHAsset *)asset;

@end
