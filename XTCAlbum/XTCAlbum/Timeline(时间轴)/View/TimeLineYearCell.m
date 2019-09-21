//
//  TimeLineYearCell.m
//  XTCAlbum
//
//  Created by Mac on 2019/5/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "TimeLineYearCell.h"

@implementation TimeLineYearCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth-16)/16.0, (kScreenWidth-16)/16.0)];
        [self.contentView addSubview:self.coverImageView];
    }
    return self;
}

@end
