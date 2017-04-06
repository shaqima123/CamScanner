//
//  ToolBox.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/6.
//  Copyright © 2017年 沙琪玛. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ToolBox : NSObject
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
