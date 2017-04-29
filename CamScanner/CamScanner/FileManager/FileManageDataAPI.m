//
//  FileManageDataAPI.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/20.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "FileManageDataAPI.h"
#import "DataBase.h"
#import "FileModel+CoreDataProperties.h"
#import "CSFile.h"
static NSString * const modelName = @"FileModel";
static NSString * const entityName = @"FileModel";
static NSString * const sqliteName = @"FileModel.sqlite";

@interface FileManageDataAPI()

@property(nonatomic, strong) DataBase *uploadData;

@end
@implementation FileManageDataAPI
static FileManageDataAPI *uploadCoreData = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadCoreData = [[FileManageDataAPI alloc] init];
    });
    
    return uploadCoreData;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (uploadCoreData == nil) {
            uploadCoreData = [super allocWithZone:zone];
        }
    });
    
    return uploadCoreData;
}


- (instancetype)init
{
    if (self = [super init]) {
        [self initUploadCoreData];
    }
    return self;
}

- (void)initUploadCoreData
{
    _coreDataEntityName = entityName;
    _coreDataModelName = modelName;
    _coreDataSqlPath = [[self getDocumentsPath] stringByAppendingPathComponent:sqliteName];
    self.uploadData = [[DataBase alloc] initWithCoreData:self.coreDataEntityName modelName:self.coreDataModelName sqlPath:self.coreDataSqlPath success:^{
        NSLog(@"initUploadCoreData success");
    } fail:^(NSError *error) {
        NSLog(@"initUploadCoreData fail");
    }];
    
}



- (void)insertFileModel:(NSDictionary *)dict success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
//    NSString *fileName = model.fileName;
//    NSString *fileSize = [NSString stringWithFormat:@"%.2lf",model.size];
//    NSString *urlPath = model.path;
//    NSNumber *time = [NSNumber numberWithInt:[[DateManager sharedInstance] getSecondsSince1970]];
//    NSNumber *fileType = [NSNumber numberWithInt:model.fileType];
//    NSNumber *finishStatus = [NSNumber numberWithBool:NO];
//    NSDictionary *dict = NSDictionaryOfVariableBindings(fileName,fileSize,urlPath,time,fileType,finishStatus);
    
//    NSString * fileName = [dict valueForKey:@"fileName"];
//    NSString * fileSize = [dict valueForKey:@"fileSize"];
//    NSString * fileType = file.fileType;
//    NSString * fileLabel = file.fileLabel;
//    NSData * fileContent = file.fileContent;
//    NSString * fileUrlPath = file.fileUrlPath;
//    NSData * fileAdjustImage = file.fileAdjustImage;
//    NSDate * fileCreatedTime = file.fileCreatedTime;
//    NSData * fileOriginImage = file.fileOriginImage;
//    NSDictionary *dict = NSDictionaryOfVariableBindings(fileName,fileSize,fileType,fileLabel,fileType,fileContent,fileUrlPath,fileAdjustImage,fileCreatedTime,fileOriginImage);

    [self.uploadData insertNewEntity:dict success:^{
        if (success) {
            success();
        }
    } fail:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

#pragma mark - -- 更新上传记录
//- (void)updateFileModel:(FileModel *)file success:(void(^)(void))success fail:(void(^)(NSError *error))fail
//{
//    NSString *filterStr = [NSString stringWithFormat:@"fileName = '%@'",file.fileName];
//    __weak typeof(self) weakSelf = self;
//    [self.uploadData readEntity:nil ascending:YES filterStr:filterStr success:^(NSArray *results) {
//        if (results.count>0) {
//            NSManagedObject *obj = [results firstObject];
//            [obj setValue:[NSNumber numberWithBool:model.finishStatus] forKey:@"finishStatus"];
//            [weakSelf.uploadData updateEntity:^{
//                if (success) {
//                    success();
//                }
//            } fail:^(NSError *error) {
//                if (fail) {
//                    fail(error);
//                }
//            }];
//        }
//    } fail:^(NSError *error) {
//        if (fail) {
//            fail(error);
//        }
//    }];
//}

- (void)updateDataWithFileModel:(CSFile *)file success:(void(^)(void))success fail:(void(^)(NSError *error))fail{
    [self.uploadData updateDataWithFileModel:file success:^{
        success();
    } fail:^(NSError *error) {
        fail(error);
    }];
}
#pragma mark - -- 删除一条上传记录
- (void)deleteFileModel:(FileModel *)file success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    NSString *filterStr = [NSString stringWithFormat:@"fileName = '%@'",file.fileName];
    [self.uploadData readEntity:nil ascending:YES filterStr:filterStr success:^(NSArray *results) {
        if (results.count>0) {
            NSManagedObject *obj = [results firstObject];
            [self.uploadData deleteEntity:obj success:^{
                if (success) {
                    success();
                }
            } fail:^(NSError *error) {
                if (fail) {
                    fail(error);
                }
            }];
        }
    } fail:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

- (void)deletefileModelWithKeyArray:(NSMutableArray *)keyArray success:(void(^)(void))success fail:(void(^)(NSError *error))fail{
    for (NSString *str in keyArray) {
         NSString *filterStr = [NSString stringWithFormat:@"fileName = '%@'",str];
        [self.uploadData readEntity:nil ascending:YES filterStr:filterStr success:^(NSArray *results) {
            if (results.count>0) {
                NSManagedObject *obj = [results firstObject];
                [self.uploadData deleteEntity:obj success:^{
                    if (success) {
                        success();
                    }
                } fail:^(NSError *error) {
                    if (fail) {
                        fail(error);
                    }
                }];
            }
        } fail:^(NSError *error) {
            if (fail) {
                fail(error);
            }
        }];
    }
}
#pragma mark - -- 删除所有上传记录
- (void)deleteAllFileModel:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    [self.uploadData readEntity:nil ascending:YES filterStr:nil success:^(NSArray *results) {
        for (NSManagedObject *obj in results){
            [self.uploadData deleteEntity:obj success:^{
                if (success) {
                    success();
                }
            } fail:^(NSError *error) {
                if (fail) {
                    fail(error);
                }
            }];
        }
    } fail:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

#pragma mark - -- 查询所有上传记录
- (void)readAllFileModel:(void(^)(NSArray *finishArray))success fail:(void(^)(NSError *error))fail
{
    [self.uploadData readEntity:nil ascending:YES filterStr:nil success:^(NSArray *results) {
//        NSMutableArray *finishArray = [NSMutableArray array];
//        for (NSManagedObject *obj in results) {
//            FileModel *model = [[FileModel alloc] init];
//            // 获取数据库中各个键值的值
//            
//            model.fileName = [obj valueForKey:@"fileName"];
//            model.fileSize = [obj valueForKey:@"fileSize"];
//            model.fileType = [obj valueForKey:@"fileType"];
//            model.fileLabel = [obj valueForKey:@"fileLabel"];
//            model.fileContent = [obj valueForKey:@"fileContent"];
//            model.fileUrlPath = [obj valueForKey:@"fileUrlPath"];
//            model.fileAdjustImage = [obj valueForKey:@"fileAdjustImage"];
//            model.fileCreatedTime = [obj valueForKey:@"fileCreatedTime"];
//            model.fileOriginImage = [obj valueForKey:@"fileOriginImage"];
//            
//            [finishArray addObject:model];
//            
//        }
        if (success) {
            success(results);
        }
    } fail:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

-(NSString*)getDocumentsPath
{
    //获取Documents路径
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString*path=[paths objectAtIndex:0];
    NSLog(@"path:%@",path);
    return path;
}

@end
