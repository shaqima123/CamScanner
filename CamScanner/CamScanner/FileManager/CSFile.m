//
//  CSFile.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/26.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "CSFile.h"

@implementation CSFile
- (instancetype _Nullable )initWithFile:(FileModel *_Nullable)file
{
    if ((self = [super init]))
    {
        _fileName = file.fileName;
        _fileSize = file.fileSize;
        _fileType = file.fileType;
        _fileLabel = file.fileLabel;
        _fileContent = file.fileContent;
        _fileUrlPath = file.fileUrlPath;
        _fileAdjustImage = file.fileAdjustImage;
        _fileOriginImage = file.fileOriginImage;
        _fileCreatedTime = file.fileCreatedTime;
        _fileNumber = file.fileNumber;
    }
    return self;
}
@end
