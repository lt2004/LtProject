//
//  ChoicenessAblumManager.m
//  XTCAlbum
//
//  Created by Mac on 2019/4/28.
//  Copyright © 2019 漫漫. All rights reserved.
//

#import "ChoicenessAblumManager.h"
#import "XTCHomePageViewController.h"

@implementation ChoicenessAblumManager


+ (void)createAblumByName:(NSString *)ablumName {
    AblumModel *ablumModel = [AblumModel MR_createEntity];
    ablumModel.ablum_name = ablumName;
    ablumModel.ablum_date = [NSDate date];
    ablumModel.ablum_source_paths = @"";
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (NSArray *)findAllChoicenessAblum {
    NSArray *findArray = [AblumModel MR_findAllSortedBy:@"ablum_date" ascending:NO];
    XTCHomePageViewController *homePageViewController = (XTCHomePageViewController *)[StaticCommonUtil rootNavigationController].viewControllers.firstObject;
    
    NSMutableArray *allAssetArray = [[NSMutableArray alloc] init];
    for (TZAssetModel *flagAssetModel in homePageViewController.homePageDataArray) {
        [allAssetArray addObject:flagAssetModel.asset.localIdentifier];
    }
    for (AblumModel *ablumModel in findArray) {
        NSArray *ablumSourcePathArray = [ablumModel.ablum_source_paths componentsSeparatedByString:@","];
        NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@", allAssetArray];
        NSArray *filterSameArray = [ablumSourcePathArray filteredArrayUsingPredicate:filterPredicate_same];
        ablumModel.ablum_source_paths = [filterSameArray componentsJoinedByString:@","];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    return findArray;
}

+ (BOOL)isExist:(NSString *)ablumName {
    NSArray *findArray = [AblumModel MR_findByAttribute:@"ablum_name" withValue:ablumName];
    if (findArray.count) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 向已存在的精选添加数据
+ (void)inserDataToAlbum:(NSMutableArray *)dataArray byAlbumName:(NSString *)albumName {
    NSArray *findArray = [AblumModel MR_findByAttribute:@"ablum_name" withValue:albumName];
    if (findArray.count > 0) {
        AblumModel *ablumModel = findArray.firstObject;
        NSArray *flagPathArray = [ablumModel.ablum_source_paths componentsSeparatedByString:@","];
        NSMutableArray *flagInsertArray = [[NSMutableArray alloc] init];
        for (TZAssetModel *flagAssetModel in dataArray) {
            if ([flagPathArray containsObject:flagAssetModel.asset.localIdentifier]) {
                
            } else {
                [flagInsertArray addObject:flagAssetModel.asset.localIdentifier];
            }
        }
        if (flagPathArray.count > 0) {
            [flagInsertArray addObjectsFromArray:flagPathArray];
        } else {
            
        }
        ablumModel.ablum_source_paths = [flagInsertArray componentsJoinedByString:@","];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } else {
        
    }
    
}

+ (void)updateDataToAlbum:(NSMutableArray *)dataArray byAlbumName:(NSString *)albumName {
    NSArray *findArray = [AblumModel MR_findByAttribute:@"ablum_name" withValue:albumName];
    if (findArray.count > 0) {
        AblumModel *ablumModel = findArray.firstObject;
        NSMutableArray *flagInsertArray = [[NSMutableArray alloc] init];
        for (TZAssetModel *flagAssetModel in dataArray) {
            [flagInsertArray addObject:flagAssetModel.asset.localIdentifier];
        }
        ablumModel.ablum_source_paths = [flagInsertArray componentsJoinedByString:@","];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } else {
        
    }
}

#pragma mark - 修改影集名称
+ (void)updateAbbumNameByOld:(NSString *)oldName byNewName:(NSString *)newName {
    NSArray *findArray = [AblumModel MR_findByAttribute:@"ablum_name" withValue:oldName];
    if (findArray.count > 0) {
        AblumModel *ablumModel = findArray.firstObject;
        ablumModel.ablum_name = newName;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } else {
        
    }
}

#pragma mark - 删除精选
+ (BOOL)deleteAlbum:(NSString *)albumName {
    NSArray *findArray = [AblumModel MR_findByAttribute:@"ablum_name" withValue:albumName];
    if (findArray.count) {
        AblumModel *deleteAlbum = findArray.firstObject;
        [deleteAlbum MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return YES;
    } else {
        return NO;
    }
}

@end
