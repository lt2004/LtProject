//
//  RSKeyChain.h
//  KeychainDemo
//
//  Created by 刘特 on 15/11/10.
//  Copyright © 2015年 刘特. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSKeyChain : NSObject

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)delete:(NSString *)service;

@end
