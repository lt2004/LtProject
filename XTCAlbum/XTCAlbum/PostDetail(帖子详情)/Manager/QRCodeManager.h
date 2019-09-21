//
//  QRCodeManager.h
//  vs
//
//  Created by Mac on 2018/12/15.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncryptionQRCode.h"
#import "SGQRCodeObtain.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeManager : NSObject

+ (UIImage *)createQRCodeByType:(NSString *)type byTypeId:(NSString *)typeId;
+ (UIImage *)createQRCodeByDict:(NSMutableDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
