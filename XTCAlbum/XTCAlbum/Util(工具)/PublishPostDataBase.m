//
//  PublishPostDataBase.m
//  vs
//
//  Created by Xie Shu on 2017/10/16.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishPostDataBase.h"
#import "WAFileUtil.h"

@implementation PublishPostDataBase

static PublishPostDataBase *_dataBase;

+ (instancetype)sharedDataBase {
    
    if (_dataBase == nil) {
        
        _dataBase = [[PublishPostDataBase alloc] init];
        
        [_dataBase initDataBase];
        
    }
    
    return _dataBase;
    
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    if (_dataBase == nil) {
        
        _dataBase = [super allocWithZone:zone];
        
    }
    
    return _dataBase;
    
}

-(id)copy{
    
    return self;
    
}

-(id)mutableCopy{
    
    return self;
    
}

-(id)copyWithZone:(NSZone *)zone{
    
    return self;
    
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    
    return self;
    
}


-(void)initDataBase {
    // 获得Documents目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"xtc_vs_publish.sqlite"];
    // 实例化FMDataBase对象
    _db = [FMDatabase databaseWithPath:filePath];
    [_db open];

    // 私密相册账号
    NSString *privateAlbumSql = @"CREATE TABLE 'PrivateAlbumTable' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'user_id' VARCHAR(255),'file_path' VARCHAR(255),'password' VARCHAR(255))";
    BOOL isPrivateAlbumSuccess = [_db executeUpdate:privateAlbumSql];
    if (isPrivateAlbumSuccess) {
        // 私密相册表
    } else {
        
    }
    
}

#pragma mark - 查询私密相册
- (void)queryCurrentPrivateAlbumCallBack:(void (^)(NSMutableArray *privateAlbumArray))block {
    NSMutableArray *queryArray = [[NSMutableArray alloc] init];
    NSString *querySql = [NSString stringWithFormat:@"select * from PrivateAlbumTable where user_id = '%@'", [GlobalData sharedInstance].userModel.user_id];
    FMResultSet *resultSet = [_db executeQuery:querySql];
    while ([resultSet next]) {
        NSDictionary *dict = [resultSet resultDictionary];
        XTCPrivateAlbumModel *albumModel = [[XTCPrivateAlbumModel alloc] init];
        albumModel.fileName = [dict[@"file_path"] description];
         albumModel.password = [dict[@"password"] description];
         albumModel.userId = [dict[@"user_id"] description];
        albumModel.privateId = [dict[@"id"] description];
        [queryArray addObject:albumModel];
    }
    block(queryArray);
}

#pragma mark - 查询指定的私密相册
- (void)queryCurrentPrivateAlbumByPassword:(NSString *)password CallBack:(void (^)(NSMutableArray *privateAlbumArray))block {
    NSMutableArray *queryArray = [[NSMutableArray alloc] init];
    NSString *querySql = [NSString stringWithFormat:@"select * from PrivateAlbumTable where user_id = '%@' and password = '%@'", [GlobalData sharedInstance].userModel.user_id, password];
    FMResultSet *resultSet = [_db executeQuery:querySql];
    if ([resultSet next]) {
        NSDictionary *dict = [resultSet resultDictionary];
        XTCPrivateAlbumModel *albumModel = [[XTCPrivateAlbumModel alloc] init];
        albumModel.fileName = [dict[@"file_path"] description];
        albumModel.password = [dict[@"password"] description];
        albumModel.userId = [dict[@"user_id"] description];
        albumModel.privateId = [dict[@"id"] description];
        [queryArray addObject:albumModel];
    }
    block(queryArray);
}

#pragma mark - 创建私密相册
- (void)insertPrivateAlbumByFileName:(NSString *)fileName byPassword:(NSString *)password callBack:(void (^)(BOOL isSuccess))block {
    NSString *sourceKeys = @"user_id, file_path, password";
    NSString *sourceValues = [NSString stringWithFormat:@"'%@','%@','%@'",[GlobalData sharedInstance].userModel.user_id, fileName, password];
    BOOL isUploadSuccess = [_db executeUpdate:[NSString stringWithFormat:@"INSERT INTO PrivateAlbumTable(%@)VALUES(%@)",sourceKeys,sourceValues]];
    if (isUploadSuccess) {
        // 插入上传文件数据成功
        NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataFilePath = [docsdir stringByAppendingPathComponent:[[GlobalData sharedInstance].userModel.user_id description]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
        // 加密userId文件夹创建
        if ( !(isDir == YES && existed == YES) ) {
            [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            
        }
        // 私密相册创建
        BOOL isFilePath = NO;
        NSString *dataFileNamePath = [dataFilePath stringByAppendingPathComponent:fileName];
        BOOL fileNameExisted = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
        if (!(isFilePath == YES && fileNameExisted == YES) ) {
            // 创建文件夹
            [fileManager createDirectoryAtPath:dataFileNamePath withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            
        }
    } else {
        
    }
    block(isUploadSuccess);
}


#pragma mark - 修改加密密码
- (void)updateCurrentPrivateAlbumPasswordByAlbum:(XTCPrivateAlbumModel *)albumModel CallBack:(void (^)(BOOL isSuccess))block {
    BOOL isUploadSuccess = [_db executeUpdate:[NSString stringWithFormat:@"UPDATE PrivateAlbumTable SET password = %@ WHERE id = %d", albumModel.password, [albumModel.privateId intValue]]];
    if (isUploadSuccess) {
        block(YES);
    } else {
        block(NO);
    }
}

- (void)openDataBase {
    [_db open];
}

- (void)closeDataBase {
    [_db close];
}



@end
