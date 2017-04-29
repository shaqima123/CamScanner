//
//  CSFileShowViewController.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/29.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSFile.h"

@interface CSFileShowViewController : UIViewController
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImage *adjustedImage;
@property (nonatomic, strong) CSFile *csfile;

@end
