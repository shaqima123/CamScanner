//
//  MAImagePickerControllerAdjustViewController.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

//Dedected Points

#import <UIKit/UIKit.h>

#import "MAConstants.h"
#import "MADrawRect.h"

#import <opencv2/core/core.hpp>
#import <opencv2/imgproc/imgproc.hpp>

@interface MAImagePickerControllerAdjustViewController : UIViewController
{
    BOOL isGray;
}

@property (strong, nonatomic) UIImageView *sourceImageView;
@property (strong, nonatomic) UIToolbar *adjustToolBar;
@property (strong, nonatomic) UIImage *sourceImage;
@property (strong, nonatomic) UIImage *adjustedImage;
@property (strong, nonatomic) MADrawRect *adjustRect;

@end
