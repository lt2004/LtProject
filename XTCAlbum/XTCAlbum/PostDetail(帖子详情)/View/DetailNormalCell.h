//
//  DetailNormalCell.h
//  XTCAlbum
//
//  Created by Mac on 2019/8/19.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailNormalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *imageDescLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;

- (void)imageObjectByImageDict:(NSDictionary *)imageDict byLast:(BOOL)isLast;

@end

NS_ASSUME_NONNULL_END
