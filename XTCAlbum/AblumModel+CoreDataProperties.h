//
//  AblumModel+CoreDataProperties.h
//  
//
//  Created by Mac on 2019/4/28.
//
//

#import "AblumModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AblumModel (CoreDataProperties)

+ (NSFetchRequest<AblumModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *ablum_date;
@property (nullable, nonatomic, copy) NSString *ablum_source_paths;
@property (nullable, nonatomic, copy) NSString *ablum_name;

@end

NS_ASSUME_NONNULL_END
