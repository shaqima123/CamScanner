//
//  MAImagePickerFinalViewController.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAConstants.h"

@interface MAImagePickerFinalViewController : UIViewController <UIScrollViewDelegate>
{
    int currentlySelected;
    UIImageOrientation sourceImageOrientation;
}

@property BOOL imageFrameEdited;

@property (strong, nonatomic) UIImage *sourceImage;
@property (strong, nonatomic) UIImage *adjustedImage;

@property (strong, nonatomic) UIButton *firstSettingIcon;
@property (strong, nonatomic) UIButton *secondSettingIcon;
@property (strong, nonatomic) UIButton *thirdSettingIcon;
@property (strong, nonatomic) UIButton *fourthSettingIcon;

@property (strong, nonatomic) UIBarButtonItem *rotateButton;

@property (strong, nonatomic) UIImageView *activityIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *progressIndicator;

@property (strong, nonatomic) UIImageView *finalImageView;

@end
