//
//  HomePageSearchResponseModel.h
//  XTCAlbum
//
//  Created by Mac on 2019/7/30.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomePageSearchResponseModel : NSObject

@property (nonatomic, strong) NSMutableArray *hotTagArray;
@property (nonatomic, strong) NSMutableArray *remTagsArray;
@property (nonatomic, strong) NSMutableArray *identArray;
@property (nonatomic, strong) NSMutableArray *serviceArray;
@property (nonatomic, strong) NSMutableArray *postArray;
@property (nonatomic, strong) NSMutableArray *usertagsArray;
@property (nonatomic, strong) NSMutableArray *commonArray;
@property (nonatomic, strong) NSMutableArray *hotSearchCityArray; // 热门搜索
@property (nonatomic, strong) NSSet *hotSearchCityName; // 热门搜索
@property (nonatomic, strong) NSMutableArray *hotSearchCountryArray; // 热门搜索
@property (nonatomic, strong) NSSet *hotSearchCountryName; // 热门搜索
@property (nonatomic, strong) NSString *searchType;
@property (nonatomic, strong) NSString *identName;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) NSString *postName;
@property (nonatomic, strong) NSString *commonName;

@end

NS_ASSUME_NONNULL_END
