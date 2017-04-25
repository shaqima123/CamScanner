//
//  MAViewController.h
//  CamScanner
//
//  Created by Maximilian Mackh on 11/5/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MAImagePickerController.h"

@interface MAViewController : UIViewController <MAImagePickerControllerDelegate>
@property (strong, nonatomic) NSMutableArray * fileArray;

- (IBAction)initButton:(id)sender;

- (void)refreshData;

@end
