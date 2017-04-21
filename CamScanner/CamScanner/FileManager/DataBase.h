//
//  DataBase.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/19.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FileModel+CoreDataClass.h"
#define TableName @"FileModel"

@interface DataBase : NSObject

@property (nonatomic,copy,readonly) NSString *sqlPath;
@property (nonatomic,copy,readonly) NSString *modelName;
@property (nonatomic,copy,readonly) NSString *entityName;

- (instancetype)initWithCoreData:(NSString *)entityName modelName:(NSString *)modelName sqlPath:(NSString *)sqlPath success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)insertNewEntity:(NSDictionary *)dict success: (void(^)(void))success fail:(void(^)(NSError *error))fail;

- (void)readEntity:(NSArray *)sequenceKeys
         ascending:(BOOL)isAscending
         filterStr:(NSString *)filterStr
           success:(void(^)(NSArray * results))success
              fail:(void(^)(NSError *error))fail;
- (void)deleteEntity:(NSManagedObject *)entity success: (void(^)(void))success fail:(void(^)(NSError *error))fail;

- (void)updateEntitySuccess: (void(^)(void))success fail:(void(^)(NSError *error))fail;

@end
