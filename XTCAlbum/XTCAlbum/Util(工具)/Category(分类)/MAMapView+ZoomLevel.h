//
//  MAMapView+ZoomLevel.h
//  vs
//
//  Created by Xie Shu on 2018/2/24.
//  Copyright © 2018年 Xiaotangcai. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface MAMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
