//
//  EncryptionQRCode.h
//  vs
//
//  Created by Mac on 2018/12/11.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface EncryptionQRCode : NSObject

//+ (NSString *) udid;
+ (NSString *) md5:(NSString *)str;
+ (NSString *) doCipher:(NSString *)sTextIn key:(NSString *)sKey context:(CCOperation)encryptOrDecrypt;
+ (NSString *) encryptStr:(NSString *) str;
+ (NSString *) decryptStr:(NSString    *) str;

#pragma mark Based64
+ (NSString *) encodeBase64WithString:(NSString *)strData;
+ (NSString *) encodeBase64WithData:(NSData *)objData;
+ (NSData *) decodeBase64WithString:(NSString *)strBase64;

@end

NS_ASSUME_NONNULL_END
