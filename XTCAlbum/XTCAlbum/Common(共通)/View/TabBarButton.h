//
//  CustomButton.h
//  BakeGlobalVillage
//
//  Created by zzy on 15/7/4.
//  Copyright © 2015年 zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"

@interface TabBarButton : UIControl

@property (nonatomic,strong) UIImageView *imageView;/**< 按钮图片*/
@property (nonatomic,strong) UILabel *label; /**< 按钮文字*/

/**
 *  创建按钮
 *
 *  @param title         标题
 *  @param imageName     普通状态图片名
 *  @param selectedImage 徐泽状态图片名
 *
 *  @return 按钮
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)imageName selectedImage:(NSString *)selectedImage;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)imageName;

@end
