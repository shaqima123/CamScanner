//
//  MAAppDelegate.h
//  CamScanner
//
//  Created by Maximilian Mackh on 11/5/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAViewController;

@interface MAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *fileArray;
@property (strong, nonatomic) MAViewController *viewController;

@end
