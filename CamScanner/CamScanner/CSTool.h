//
//  CSTool.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/26.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSTool : NSObject

+ (void)saveToAlbumWithData:(NSData *)data;
+ (void)loadImageFinished:(UIImage *)image;

@end
