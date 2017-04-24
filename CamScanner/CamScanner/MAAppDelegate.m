//
//  MAAppDelegate.m
//  CamScanner
//
//  Created by Maximilian Mackh on 11/5/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "MAAppDelegate.h"

#import "MAViewController.h"
#import <CoreData/CoreData.h>
#import "FileManager/FileManageDataAPI.h"
#import "FileModel+CoreDataProperties.h"

@implementation MAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MAViewController alloc] initWithNibName:@"MAViewController" bundle:nil];
    self.fileArray = [NSMutableArray array];
    
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        __weak typeof(self) weakSelf = self;
        [[FileManageDataAPI sharedInstance] readAllFileModel:^(NSArray *finishArray) {
//            NSLog(@"%d",[finishArray count]);
//            for(FileModel *file in finishArray)
//            {
//                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
//                
//                NSLog(@"name = %@,size = %@,label = %@,type = %@,url = %@,date = %@,",file.fileName,file.fileSize,file.fileLabel,file.fileType,file.fileUrlPath,[formatter stringFromDate:file.fileCreatedTime]);
//            }
            [weakSelf.fileArray addObjectsFromArray:finishArray];
            [self.viewController.fileArray addObjectsFromArray:finishArray];
        } fail:^(NSError *error) {
            NSLog(@"fail to read");
        }];
    });
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
