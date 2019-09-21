//
//  QRCodeManager.m
//  vs
//
//  Created by Mac on 2018/12/15.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "QRCodeManager.h"

@implementation QRCodeManager

+ (UIImage *)createQRCodeByType:(NSString *)type byTypeId:(NSString *)typeId {
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:typeId forKey:@"type_id"];
    [jsonDict setObject:@"viewspeaker" forKey:@"sign"];
    [jsonDict setObject:type forKey:@"type"];
    NSString *requestStr = [QRCodeManager convertToJsonData:jsonDict];
    NSString *encryptionStr = [EncryptionQRCode encryptStr:requestStr];
    NSString *jsonStr = [NSString stringWithFormat:@"http://www.viewspeaker.com/index/index?parm=%@", encryptionStr];
    //    NSString *finishStr = [EncryptionQRCode decode:encryptionStr key:@"123578"];
    UIImage *codeImage = [SGQRCodeObtain generateQRCodeWithData:jsonStr size:1024 logoImage:[UIImage imageNamed:@"launch_logo"] ratio:0.25 logoImageCornerRadius:4 logoImageBorderWidth:1 logoImageBorderColor:[UIColor clearColor]];
    return codeImage;
}

+ (UIImage *)createQRCodeByDict:(NSMutableDictionary *)dictionary {
    NSString *requestStr = [QRCodeManager convertToJsonData:dictionary];
    NSString *encryptionStr = [EncryptionQRCode encryptStr:requestStr];
    NSString *jsonStr = [NSString stringWithFormat:@"http://www.viewspeaker.com/index/index?parm=%@", encryptionStr];
    UIImage *codeImage = [SGQRCodeObtain generateQRCodeWithData:jsonStr size:1024 logoImage:[UIImage imageNamed:@"launch_logo"] ratio:0.25 logoImageCornerRadius:4 logoImageBorderWidth:1 logoImageBorderColor:[UIColor clearColor]];
    return codeImage;
}


// 字典转json字符串方法

+ (NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

@end
