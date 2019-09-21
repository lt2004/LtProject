//
//  DetailNormalCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/8/19.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "DetailNormalCell.h"

@implementation DetailNormalCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)imageObjectByImageDict:(NSDictionary *)imageDict byLast:(BOOL)isLast {
    NSString *w_str = [imageDict[@"width"] description];
    NSString *h_str = [imageDict[@"height"] description];
    if (w_str == nil || h_str == nil) {
        NSLog(@"意外");
    } else {
        CGFloat w = [w_str floatValue];
        CGFloat h = [h_str floatValue];
        if (w <= 0) {
            w = 100;
        }
        if (h <= 0) {
            h = 100;
        }
        CGFloat width =kScreenWidth - 34;
        if (h > w) {
            width = kScreenWidth - kScreenWidth * 0.3;
        }
        _widthLayoutConstraint.constant = width;
        _heightLayoutConstraint.constant = h/w * width;
    }
    self.photoView.layer.cornerRadius = 3;
    self.photoView.layer.masksToBounds = true;
    if (imageDict[@"photodesc"] == nil) {
        self.descTopLayoutConstraint.constant = 10.0;
        self.descBottomLayoutConstraint.constant = 0.0;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        self.imageDescLabel.attributedText = attributedString;
        
    } else {
        self.imageDescLabel.numberOfLines = 0;
        NSString *descString = imageDict[@"photodesc"];
        if (descString.length > 0) {
            self.imageDescLabel.attributedText = [NBZUtil createProOCEmoji:descString];
            self.imageDescLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
            self.descTopLayoutConstraint.constant = 30.0;
            if (isLast) {
                self.descBottomLayoutConstraint.constant = 0.0;
            } else {
                self.descBottomLayoutConstraint.constant = 40.0;
            }
            
        } else {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
            self.imageDescLabel.attributedText = attributedString;
            self.descTopLayoutConstraint.constant = 0.0;
            if (isLast) {
                self.descBottomLayoutConstraint.constant = 0.0;
            } else {
                self.descBottomLayoutConstraint.constant = 20.0;
            }
            
        }
        
    }
}

@end
