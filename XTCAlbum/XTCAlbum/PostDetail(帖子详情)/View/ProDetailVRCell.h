//
//  ProDetailVRCell.h
//  vs
//
//  Created by Mac on 2018/9/6.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVRPanoramaView.h"
#import "BSPanoramaView.h"

@interface ProDetailVRCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vrBgImageView;
@property (weak, nonatomic) IBOutlet UIView *vrBgView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (nonatomic, strong) BSPanoramaView *panoramaView;

- (void)insertDataToVRCell:(NSDictionary *)dict;
- (void)willBeDisplayed:(NSUInteger)index;
- (void)didStopDisplayed:(NSUInteger)index;

@end
