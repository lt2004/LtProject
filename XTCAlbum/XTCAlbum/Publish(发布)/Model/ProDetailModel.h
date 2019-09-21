//
//  ProDetailModel.h
//  vs
//
//  Created by 邵帅 on 2016/12/21.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface ProDetailModel : NSObject

@property (strong, nonatomic) NSString *vrUrl;
@property (strong, nonatomic) PHAsset *vrImage;
@property (strong, nonatomic) NSString *firstUrl;
@property (strong, nonatomic) PHAsset *firstImage;
@property (strong, nonatomic) NSString *firstText;
@property (strong, nonatomic) NSString *secondUrl;
@property (strong, nonatomic) PHAsset *secondImage;
@property (strong, nonatomic) NSString *secondText;
@property (strong, nonatomic) NSString *thirdUrl;
@property (strong, nonatomic) PHAsset *thirdImage;
@property (strong, nonatomic) NSString *thirdText;
@property (strong, nonatomic) NSString *voiceUrl;
@property (strong, nonatomic) NSString *voiceFile;
@property (strong, nonatomic) NSString *voiceTime;
@property (strong, nonatomic) NSString *vrTitle;

@property (nonatomic) int vrFlag;
@property (nonatomic) int firstFlag;
@property (nonatomic) int secondFlag;
@property (nonatomic) int thirdFlag;
@property (nonatomic) int voiceFlag;
@end
