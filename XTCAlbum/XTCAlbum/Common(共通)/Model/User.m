//
//  User.m
//  vsPhotoAlbum
//
//  Created by 邵帅 on 2017/4/18.
//  Copyright © 2017年 邵帅. All rights reserved.
//

#import "User.h"
@implementation User

+ (NSArray *)compressed:(NSArray *)images {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray * writeFileOps = [NSMutableArray array];
    NSMutableArray * localFiles = [NSMutableArray array];
    for (UIImage *img in images) {
        NSBlockOperation * wop = [NSBlockOperation blockOperationWithBlock:^{
            
            CGFloat compress_level = 0.75;
            NSData *fileData = UIImageJPEGRepresentation(img, compress_level);
            while (fileData.length > 2000 * 1024) {
                compress_level -= 0.1;
                if (compress_level <= 0.1) {
                    break;
                }
                fileData = UIImageJPEGRepresentation(img, compress_level);
            }
            NSString *name = [User sam_stringWithUUID];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", name];
            NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
            
            [fileData writeToFile:filePath atomically:NO];
            [localFiles addObject:filePath];
            fileData = nil;
        }];
        
        [writeFileOps addObject:wop];
    }
    
    NSOperationQueue *writeQueue = [[NSOperationQueue alloc] init];
    [writeQueue setMaxConcurrentOperationCount:1];
    [writeQueue addOperations:writeFileOps waitUntilFinished:YES];
    DDLogInfo(@"all image file resized and saved to local");
    
    return localFiles;
}

+ (NSString *)sam_stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

@end
