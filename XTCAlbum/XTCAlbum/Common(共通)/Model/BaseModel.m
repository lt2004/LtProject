//
//  BaseModel.m
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/18.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import "BaseModel.h"
#import "MTLJSONAdapter.h"

@implementation BaseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // override this in the model if property names in JSON don't match model
    NSDictionary * pk = [NSDictionary mtl_identityPropertyMapWithModel:[self class]];
    //NSLog(@"PK:%@", pk);
    return pk;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    // NSLog(@"undefined key:%@", key);
}

@end
