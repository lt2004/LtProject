//
//  
//    ___  _____   ______  __ _   _________ 
//   / _ \/ __/ | / / __ \/ /| | / / __/ _ \
//  / , _/ _/ | |/ / /_/ / /_| |/ / _// , _/
// /_/|_/___/ |___/\____/____/___/___/_/|_| 
//
//  Created by Bart Claessens. bart (at) revolver . be
// revolver

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface REVClusterAnnotationView : MKAnnotationView <MKAnnotation> {
   
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) PHAsset *sourceAsset;

@end
