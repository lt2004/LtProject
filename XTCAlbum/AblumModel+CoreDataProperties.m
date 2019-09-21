//
//  AblumModel+CoreDataProperties.m
//  
//
//  Created by Mac on 2019/4/28.
//
//

#import "AblumModel+CoreDataProperties.h"

@implementation AblumModel (CoreDataProperties)

+ (NSFetchRequest<AblumModel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AblumModel"];
}

@dynamic ablum_date;
@dynamic ablum_source_paths;
@dynamic ablum_name;

@end
