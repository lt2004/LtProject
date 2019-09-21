//
//  XTCPublishSubUploadModel+CoreDataProperties.m
//  
//
//  Created by Mac on 2019/8/6.
//
//

#import "XTCPublishSubUploadModel+CoreDataProperties.h"

@implementation XTCPublishSubUploadModel (CoreDataProperties)

+ (NSFetchRequest<XTCPublishSubUploadModel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"XTCPublishSubUploadModel"];
}

@dynamic date_time_original;
@dynamic file_desc;
@dynamic file_index;
@dynamic file_title;
@dynamic file_type;
@dynamic lat;
@dynamic lng;
@dynamic make;
@dynamic model;
@dynamic post_type;
@dynamic pro_index;
@dynamic source_path;
@dynamic temp_id;
@dynamic mains;

@end
