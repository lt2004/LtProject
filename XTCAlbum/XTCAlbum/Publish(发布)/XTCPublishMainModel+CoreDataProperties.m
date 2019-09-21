//
//  XTCPublishMainModel+CoreDataProperties.m
//  
//
//  Created by Mac on 2019/8/6.
//
//

#import "XTCPublishMainModel+CoreDataProperties.h"

@implementation XTCPublishMainModel (CoreDataProperties)

+ (NSFetchRequest<XTCPublishMainModel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"XTCPublishMainModel"];
}

@dynamic art_link;
@dynamic chat_id;
@dynamic chat_type;
@dynamic current_lat;
@dynamic current_lng;
@dynamic draft_cover;
@dynamic is_bus;
@dynamic is_bus_show;
@dynamic is_personal;
@dynamic post_content;
@dynamic post_title;
@dynamic pubish_date;
@dynamic pubish_type;
@dynamic publish_sort_date;
@dynamic publish_tour_time;
@dynamic share_location;
@dynamic sub_post_id;
@dynamic tags;
@dynamic tk;
@dynamic ending_desc;
@dynamic ending_title;
@dynamic uploads;

@end
