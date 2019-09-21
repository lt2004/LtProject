//
//  XTCPublishMainModel+CoreDataProperties.h
//  
//
//  Created by Mac on 2019/8/6.
//
//

#import "XTCPublishMainModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishMainModel (CoreDataProperties)

+ (NSFetchRequest<XTCPublishMainModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *art_link;
@property (nullable, nonatomic, copy) NSString *chat_id;
@property (nullable, nonatomic, copy) NSString *chat_type;
@property (nullable, nonatomic, copy) NSString *current_lat;
@property (nullable, nonatomic, copy) NSString *current_lng;
@property (nullable, nonatomic, copy) NSString *draft_cover;
@property (nullable, nonatomic, copy) NSString *is_bus;
@property (nonatomic) BOOL is_bus_show;
@property (nullable, nonatomic, copy) NSString *is_personal;
@property (nullable, nonatomic, copy) NSString *post_content;
@property (nullable, nonatomic, copy) NSString *post_title;
@property (nullable, nonatomic, copy) NSString *pubish_date;
@property (nonatomic) int16_t pubish_type;
@property (nullable, nonatomic, copy) NSDate *publish_sort_date;
@property (nullable, nonatomic, copy) NSString *publish_tour_time;
@property (nullable, nonatomic, copy) NSString *share_location;
@property (nullable, nonatomic, copy) NSString *sub_post_id;
@property (nullable, nonatomic, copy) NSString *tags;
@property (nullable, nonatomic, copy) NSString *tk;
@property (nullable, nonatomic, copy) NSString *ending_desc;
@property (nullable, nonatomic, copy) NSString *ending_title;
@property (nullable, nonatomic, retain) NSSet<XTCPublishSubUploadModel *> *uploads;

@end

@interface XTCPublishMainModel (CoreDataGeneratedAccessors)

- (void)addUploadsObject:(XTCPublishSubUploadModel *)value;
- (void)removeUploadsObject:(XTCPublishSubUploadModel *)value;
- (void)addUploads:(NSSet<XTCPublishSubUploadModel *> *)values;
- (void)removeUploads:(NSSet<XTCPublishSubUploadModel *> *)values;

@end

NS_ASSUME_NONNULL_END
