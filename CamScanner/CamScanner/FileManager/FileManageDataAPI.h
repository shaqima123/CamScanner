//
//  FileManageDataAPI.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/20.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FileModel;
@class CSFile;
@interface FileManageDataAPI : NSObject
@property (nonatomic,copy,readonly) NSString *coreDataModelName;
/**
 *  上传数据库实体名称
 */
@property (nonatomic,copy,readonly) NSString *coreDataEntityName;
/**
 *  上传数据库存储路径
 */
@property (nonatomic,copy,readonly) NSString *coreDataSqlPath;

+ (instancetype)sharedInstance;
/**
 *  插入上传记录
 *
 *  @param model   数据模型
 *  @param success 成功回调
 *  @param fail    失败回调
 */
- (void)insertFileModel:(NSDictionary *)dict success:(void(^)(void))success fail:(void(^)(NSError *error))fail;



- (void)updateFileModel:(FileModel *)file success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
- (void)updateDataWithFileModel:(CSFile *)file success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/**
 *  删除一条上传记录
 *
 *  @param model   数据模型
 *  @param success 成功回调
 *  @param fail    失败回调
 */
- (void)deleteFileModel:(FileModel *)file success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

- (void)deletefileModelWithKeyArray:(NSMutableArray *)keyArray success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
/**
 *  删除所有上传记录
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
- (void)deleteAllFileModel:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/**
 *  查询上传数据库所有数据
 *
 *  @param success 成功回调（finishArray：已完成（DownLoadModel对象数组） unfinishedArray：未完成（DownLoadModel对象数组））
 *  @param fail    失败回调
 */
- (void)readAllFileModel:(void(^)(NSArray *finishArray))success fail:(void(^)(NSError *error))fail;

@end
