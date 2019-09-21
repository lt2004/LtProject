//
//  XTCPublishSubUploadModel+CoreDataProperties.h
//  
//
//  Created by Mac on 2019/8/6.
//
//

#import "XTCPublishSubUploadModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface XTCPublishSubUploadModel (CoreDataProperties)

+ (NSFetchRequest<XTCPublishSubUploadModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *date_time_original;
@property (nullable, nonatomic, copy) NSString *file_desc;
@property (nonatomic) int16_t file_index;
@property (nullable, nonatomic, copy) NSString *file_title;
@property (nullable, nonatomic, copy) NSString *file_type;
@property (nullable, nonatomic, copy) NSString *lat;
@property (nullable, nonatomic, copy) NSString *lng;
@property (nullable, nonatomic, copy) NSString *make;
@property (nullable, nonatomic, copy) NSString *model;
@property (nullable, nonatomic, copy) NSString *post_type;
@property (nonatomic) int16_t pro_index;
@property (nullable, nonatomic, copy) NSString *source_path;
@property (nullable, nonatomic, copy) NSString *temp_id;
@property (nullable, nonatomic, retain) XTCPublishMainModel *mains;

@end

NS_ASSUME_NONNULL_END
