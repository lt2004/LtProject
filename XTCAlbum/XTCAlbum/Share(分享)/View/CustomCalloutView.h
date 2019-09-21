//
//  CustomCalloutView.h
//  loveSport
//
//  Created by mac on 2017/6/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

@interface CustomCalloutView : MACustomCalloutView

@property (weak, nonatomic) IBOutlet UIImageView *showImageView;

+ (instancetype)calloutView;
@end
