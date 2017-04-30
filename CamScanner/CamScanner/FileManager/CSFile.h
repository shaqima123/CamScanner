//
//  CSFile.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/26.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileModel+CoreDataProperties.h"

@interface CSFile : NSObject
@property (nullable, nonatomic, retain) NSData *fileAdjustImage;
@property (nullable, nonatomic, retain) NSData *fileContent;
@property (nullable, nonatomic, copy) NSDate *fileCreatedTime;
@property (nullable, nonatomic, copy) NSString *fileLabel;
@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, retain) NSData *fileOriginImage;
@property (nullable, nonatomic, copy) NSString *fileSize;
@property (nullable, nonatomic, copy) NSString *fileType;
@property (nullable, nonatomic, copy) NSString *fileUrlPath;
@property (nonatomic) int16_t fileNumber;
- (instancetype _Nullable )initWithFile:(FileModel *_Nullable)file;
@end
