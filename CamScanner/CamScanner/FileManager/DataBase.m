//
//  DataBase.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/19.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "DataBase.h"

@interface DataBase()

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (strong, nonatomic) NSCondition * condition;

@end
@implementation DataBase

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (instancetype)initWithCoreData:(NSString *)entityName modelName:(NSString *)modelName sqlPath:(NSString *)sqlPath success:(void(^)(void))success fail:(void(^)(NSError *error))fail{
    if (self = [super init]) {
        _entityName = entityName;
        _modelName = modelName;
        _entityName = entityName;
        _condition = [[NSCondition alloc] init];
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        if (modelName) {
            //获取模型路径
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
            //根据模型文件创建模型对象
            self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        } else { // 从应用程序包中加载模型文件
            self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        }
        
        // 以传入模型方式初始化持久化存储库
        self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error = nil;
        
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlPath] options:nil error:&error];
        if (error) {
            NSLog(@"添加数据库失败:%@",error);
            if (fail) {
                fail(error);
            }
        }else{
            NSLog(@"添加数据库成功");
            // 设置上下文所要关联的持久化存储库
            self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
            if (success) {
                success();
            }
        }
        
    }
    
    return self;
}

- (void)saveContext{
    NSError * error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@,%@",error,[error userInfo]);
            abort();
        }
    }
}
//
//- (NSManagedObjectContext *)managedObjectContext{
//    if (_managedObjectContext != nil) {
//        return  _managedObjectContext;
//    }
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return _managedObjectContext;
//}
//
//- (NSManagedObjectModel *)managedObjectModel{
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FileModel" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return _managedObjectModel;
//}
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
//    if (_persistentStoreCoordinator != nil) {
//        return  _persistentStoreCoordinator;
//    }
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FileModel.sqlite"];
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        NSLog(@"Unresolved error %@,%@",error,[error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}

- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

////插入数据
//
//- (void)insertCoreData:(NSMutableArray *)dataArray{
//    NSManagedObjectContext *context = [self managedObjectContext];
//    for (FileModel *file in dataArray) {
//        FileModel *fileInfo = [NSEntityDescription insertNewObjectForEntityForName:TableName inManagedObjectContext:context];
//        fileInfo.fileName = file.fileName;
//        fileInfo.fileSize = file.fileSize;
//        fileInfo.fileType = file.fileType;
//        fileInfo.fileLabel = file.fileLabel;
//        fileInfo.fileContent = file.fileContent;
//        fileInfo.fileUrlPath = file.fileUrlPath;
//        fileInfo.fileAdjustImage = file.fileAdjustImage;
//        fileInfo.fileCreatedTime = file.fileCreatedTime;
//        fileInfo.fileOriginImage = file.fileOriginImage;
//        
//        NSError * error;
//        if(![context save:&error])
//        {
//            NSLog(@"不能保存:%@",[error localizedDescription]);
//        }
//    }
//}

// 添加数据
- (void)insertNewEntity:(NSDictionary *)dict success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    if (!dict||dict.allKeys.count == 0) return;
    // 通过传入上下文和实体名称，创建一个名称对应的实体对象（相当于数据库一组数据，其中含有多个字段）
    NSManagedObject *newEntity = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    // 实体对象存储属性值（相当于数据库中将一个值存入对应字段)
    for (NSString *key in [dict allKeys]) {
        [newEntity setValue:[dict objectForKey:key] forKey:key];
    }
    // 保存信息，同步数据
    NSError *error = nil;
    BOOL result = [self.managedObjectContext save:&error];
    if (!result) {
        NSLog(@"添加数据失败：%@",error);
        if (fail) {
            fail(error);
        }
    } else {
        NSLog(@"添加数据成功");
        if (success) {
            success();
        }
    }
}

//查询

// 查询数据
- (void)readEntity:(NSArray *)sequenceKeys
         ascending:(BOOL)isAscending
         filterStr:(NSString *)filterStr
           success:(void(^)(NSArray * results))success
              fail:(void(^)(NSError *error))fail
{
    // 1.初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 2.设置要查询的实体
    NSEntityDescription *desc = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    request.entity = desc;
    // 3.设置查询结果排序
    if (sequenceKeys&&sequenceKeys.count>0) { // 如果进行了设置排序
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *key in sequenceKeys) {
            /**
             *  设置查询结果排序
             *  sequenceKey:根据某个属性（相当于数据库某个字段）来排序
             *  isAscending:是否升序
             */
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:isAscending];
            [array addObject:sort];
        }
        if (array.count>0) {
            request.sortDescriptors = array;// 可以添加多个排序描述器，然后按顺序放进数组即可
        }
    }
    // 4.设置条件过滤
    if (filterStr) { // 如果设置了过滤语句
        NSPredicate *predicate = [NSPredicate predicateWithFormat:filterStr];
        request.predicate = predicate;
    }
    // 5.执行请求
    NSError *error = nil;
    NSArray *objs = [self.managedObjectContext executeFetchRequest:request error:&error]; // 获得查询数据数据集合
    if (error) {
        if (fail) {
            fail(error);
        }
    } else{
        if (success) {
            success(objs);
        }
    }
}

// 更新数据
- (void)updateEntity:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"删除失败：%@",error);
        if (fail) {
            fail(error);
        }
    } else {
        if (success) {
            success();
        }
    }
    
}
//修改数据

- (void)updateDataWithFileModel:(CSFile *)file success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *filterStr = [NSString stringWithFormat:@"fileNumber = '%d'",file.fileNumber];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterStr];
    
    //首先你需要建立一个request
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:TableName inManagedObjectContext:context]];
    [request setPredicate:predicate];//这里相当于sqlite中的查询条件，具体格式参考苹果文档
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
    for (FileModel *fileModel in result) {
        if (file.fileName) {
            fileModel.fileName = file.fileName;
        }
        if (file.fileSize) {
            fileModel.fileSize = file.fileSize;
        }
        if (file.fileType) {
            fileModel.fileType = file.fileType;
        }
        if (file.fileLabel) {
            fileModel.fileLabel = file.fileLabel;
        }
        if (file.fileContent) {
            fileModel.fileContent = file.fileContent;
        }
        if (file.fileUrlPath) {
            fileModel.fileUrlPath = file.fileUrlPath;
        }
        if (file.fileCreatedTime) {
            fileModel.fileCreatedTime = file.fileCreatedTime;
        }
        if (file.fileAdjustImage) {
            fileModel.fileAdjustImage = file.fileAdjustImage;
        }
        if (file.fileOriginImage) {
            fileModel.fileOriginImage = file.fileOriginImage;
        }
        if (file.fileIsEdited){
            fileModel.fileIsEdited = file.fileIsEdited;
        }
    }
    
    [context save:&error];
    //保存
    if (error) {
        NSLog(@"修改数据失败：%@",error);
        if (fail) {
            fail(error);
        }
    } else {
        if (success) {
            success();
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
// 删除数据
- (void)deleteEntity:(NSManagedObject *)entity success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    // 传入需要删除的实体对象
    [self.managedObjectContext deleteObject:entity];
    // 同步到数据库
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"删除失败：%@",error);
        if (fail) {
            [_condition unlock];
            fail(error);
        }
    } else {
        if (success) {
            success();
        }
    }
}


//- (NSMutableArray *)selectData:(int)pageSize andOffset:(int)currentPage{
//    NSManagedObjectContext * context = [self managedObjectContext];
//    NSFetchRequest * request = [[NSFetchRequest alloc] init];
//    [request setFetchLimit:pageSize];
//    [request setFetchOffset:currentPage];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
//    [request setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
//    NSMutableArray * resultArray = [NSMutableArray array];
//    
//    for (FileModel *file in fetchedObjects) {
//        NSLog(@"Filename: %@",file.fileName);
//        [resultArray addObject:file];
//    }
//    
//    return resultArray;
//}
//
//
////删除
//
//- (void)deleteData{
//    NSManagedObjectContext * context = [self managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
//    NSFetchRequest * request = [[NSFetchRequest alloc] init];
//    [request setIncludesSubentities:NO];
//    [request setEntity:entity];
//    NSError *error = nil;
//    NSArray *datas = [context executeFetchRequest:request error:&error];
//    if (!error && datas && [datas count] > 0) {
//        for (NSManagedObject *obj in datas) {
//            [context deleteObject:obj];
//        }
//        if (![context save:&error]) {
//            NSLog(@"error:%@",error);
//        }
//        
//    }
//}


@end
