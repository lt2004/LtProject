//
//  XTCMapView.h
//  vs
//
//  Created by Xie Shu on 2018/2/23.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <SMCalloutView/SMCalloutView.h>

@interface XTCMapView : MAMapView

@property (nonatomic, strong) SMCalloutView *calloutView;

@end
