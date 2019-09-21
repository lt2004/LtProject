//
//  PublishPostDataBase.h
//  vs
//
//  Created by Xie Shu on 2017/10/16.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "XTCPrivateAlbumModel.h"

@interface PublishPostDataBase : NSObject <NSCopying,NSMutableCopying>{
    FMDatabase *_db;
    
}

+ (instancetype)sharedDataBase;


- (void)queryCurrentPrivateAlbumCallBack:(void (^)(NSMutableArray *privateAlbumArray))block;
- (void)insertPrivateAlbumByFileName:(NSString *)fileName byPassword:(NSString *)password callBack:(void (^)(BOOL isSuccess))block;
- (void)queryCurrentPrivateAlbumByPassword:(NSString *)password CallBack:(void (^)(NSMutableArray *privateAlbumArray))block;

- (void)updateCurrentPrivateAlbumPasswordByAlbum:(XTCPrivateAlbumModel *)albumModel CallBack:(void (^)(BOOL isSuccess))block;

- (void)openDataBase;
- (void)closeDataBase;

@end
