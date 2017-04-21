//
//  FileModel+CoreDataProperties.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/21.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "FileModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FileModel (CoreDataProperties)

+ (NSFetchRequest<FileModel *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *fileAdjustImage;
@property (nullable, nonatomic, retain) NSData *fileContent;
@property (nullable, nonatomic, copy) NSDate *fileCreatedTime;
@property (nullable, nonatomic, copy) NSString *fileLabel;
@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, retain) NSData *fileOriginImage;
@property (nullable, nonatomic, copy) NSString *fileSize;
@property (nullable, nonatomic, copy) NSString *fileType;
@property (nullable, nonatomic, copy) NSString *fileUrlPath;

@end

NS_ASSUME_NONNULL_END
