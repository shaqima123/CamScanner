//
//  AppDelegate.h
//  CamScanner
//
//  Created by zj－db0737 on 17/04/17.
//  Copyright © 2017年 sqm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@class MAViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *fileArray;

@end

