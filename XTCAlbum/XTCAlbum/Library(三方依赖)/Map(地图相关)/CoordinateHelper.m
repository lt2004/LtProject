//
//  CoordinateHelper.m
//  ViewSpeaker
//
//  Created by Mac on 2019/6/22.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "CoordinateHelper.h"
#import "XTCPointAnnotation.h"

@implementation CoordinateHelper


+ (NSMutableArray *)screenShowCoor:(NSArray *)annotations {
    if (annotations.count == 1) {
        return [[NSMutableArray alloc] initWithArray:annotations];
    } else {
        // 获取基准大头针
        double currentDistance = 0;
        double distance = 0;
        XTCPointAnnotation *standardAnnotation;
        for (XTCPointAnnotation *annotation in annotations) {
            for (XTCPointAnnotation *flagAnnotation in annotations) {
                distance +=  [CoordinateHelper distanceBetweenOrderByCoordinate:annotation.coordinate byOtherCoordinate:flagAnnotation.coordinate];
            }
            if (currentDistance == 0) {
                currentDistance = distance;
                standardAnnotation = annotation;
            } else {
                if (distance < currentDistance) {
                   currentDistance = distance;
                   standardAnnotation = annotation;
                } else {
                    
                }
            }
            distance = 0;
        }
        
        // 大于400w米的不添加到显示的坐标点中
        NSMutableArray *showArray = [[NSMutableArray alloc] init];
        for (XTCPointAnnotation *annotation in annotations) {
            double flagDistance = [CoordinateHelper distanceBetweenOrderByCoordinate:annotation.coordinate byOtherCoordinate:standardAnnotation.coordinate];
            if (flagDistance < 4*1000*1000) {
                [showArray addObject:annotation];
            } else {
                
            }
        }
        return showArray;
    }
}

+ (NSMutableArray *)screenShowDiscoverCoor:(NSArray *)annotations {
    if (annotations.count == 1) {
        return [[NSMutableArray alloc] initWithArray:annotations];
    } else {
        // 获取基准大头针
        double currentDistance = 0;
        double distance = 0;
        XTCDiscoverPointAnnotation *standardAnnotation;
        for (XTCDiscoverPointAnnotation *annotation in annotations) {
            for (XTCDiscoverPointAnnotation *flagAnnotation in annotations) {
                distance +=  [CoordinateHelper distanceBetweenOrderByCoordinate:annotation.coordinate byOtherCoordinate:flagAnnotation.coordinate];
            }
            if (currentDistance == 0) {
                currentDistance = distance;
                standardAnnotation = annotation;
            } else {
                if (distance < currentDistance) {
                    currentDistance = distance;
                    standardAnnotation = annotation;
                } else {
                    
                }
            }
            distance = 0;
        }
        
        // 大于400w米的不添加到显示的坐标点中
        NSMutableArray *showArray = [[NSMutableArray alloc] init];
        for (XTCDiscoverPointAnnotation *annotation in annotations) {
            double flagDistance = [CoordinateHelper distanceBetweenOrderByCoordinate:annotation.coordinate byOtherCoordinate:standardAnnotation.coordinate];
            if (flagDistance < 4*1000*1000) {
                [showArray addObject:annotation];
            } else {
                
            }
        }
        return showArray;
    }
}

+ (double)distanceBetweenOrderByCoordinate:(CLLocationCoordinate2D)coor1 byOtherCoordinate:(CLLocationCoordinate2D)coor2 {
    
    CLLocation *currentLocation = [[CLLocation alloc ]initWithCoordinate:coor1 altitude:0.0 horizontalAccuracy:1.0 verticalAccuracy:1.0 timestamp:[NSDate date]];
    CLLocation *otherLocation = [[CLLocation alloc ]initWithCoordinate:coor2 altitude:0.0 horizontalAccuracy:1.0 verticalAccuracy:1.0 timestamp:[NSDate date]];
    double  distance  = [currentLocation distanceFromLocation:otherLocation];
    return  distance;
    
}


@end
