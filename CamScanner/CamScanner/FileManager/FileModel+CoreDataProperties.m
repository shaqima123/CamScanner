//
//  FileModel+CoreDataProperties.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/21.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "FileModel+CoreDataProperties.h"

@implementation FileModel (CoreDataProperties)

+ (NSFetchRequest<FileModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"FileModel"];
}

@dynamic fileAdjustImage;
@dynamic fileContent;
@dynamic fileCreatedTime;
@dynamic fileLabel;
@dynamic fileName;
@dynamic fileOriginImage;
@dynamic fileSize;
@dynamic fileType;
@dynamic fileUrlPath;

@end
