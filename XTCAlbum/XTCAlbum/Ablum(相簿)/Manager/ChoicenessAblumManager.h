//
//  ChoicenessAblumManager.h
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AblumModel+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChoicenessAblumManager : NSObject

+ (void)createAblumByName:(NSString *)ablumName;
+ (NSArray *)findAllChoicenessAblum;
+ (BOOL)isExist:(NSString *)ablumName;
+ (void)inserDataToAlbum:(NSMutableArray *)daaArray byAlbumName:(NSString *)albumName;
+ (void)updateDataToAlbum:(NSMutableArray *)daaArray byAlbumName:(NSString *)albumName;
+ (BOOL)deleteAlbum:(NSString *)albumName;
+ (void)updateAbbumNameByOld:(NSString *)oldName byNewName:(NSString *)newName;

@end

NS_ASSUME_NONNULL_END
