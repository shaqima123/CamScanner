//  AppDelegate.h
//  CamScanner
//
//  Created by zj－db0737 on 17/04/17.
//  Copyright © 2017年 sqm. All rights reserved.
//

#import "AppDelegate.h"

#import "MAViewController.h"
#import <CoreData/CoreData.h>
#import "FileManager/FileManageDataAPI.h"
#import "FileModel+CoreDataProperties.h"
#import "CSFile.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.fileArray = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        __weak typeof(self) weakSelf = self;
        [[FileManageDataAPI sharedInstance] readAllFileModel:^(NSArray *finishArray) {
            NSLog(@"%d",[finishArray count]);
            for(FileModel *file in finishArray)
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
                
                NSLog(@"name = %@,size = %@,label = %@,type = %@,url = %@,date = %@,",file.fileName,file.fileSize,file.fileLabel,file.fileType,file.fileUrlPath,[formatter stringFromDate:file.fileCreatedTime]);
                CSFile *csfile = [[CSFile alloc] initWithFile:file];
                [weakSelf.fileArray addObject:csfile];
            }
           // [weakSelf.fileArray addObjectsFromArray:finishArray];
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        } fail:^(NSError *error) {
            NSLog(@"fail to read");
        }];

    });
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
