//
//  MAOpenCV.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAOpenCV : NSObject

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

+ (cv::Mat)cvMatFromAdjustedUIImage:(UIImage *)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromAdjustedUIImage:(UIImage *)image;

@end
