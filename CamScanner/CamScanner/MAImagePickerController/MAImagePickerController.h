//
//  MAImagePickerController.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACaptureSession.h"
#import "MAConstants.h"
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, MAImagePickerControllerSourceType)
{
    MAImagePickerControllerSourceTypeCamera,
    MAImagePickerControllerSourceTypePhotoLibrary
};

@protocol MAImagePickerControllerDelegate <NSObject>

@required
- (void)imagePickerDidCancel;
- (void)imagePickerDidChooseImageWithPath:(NSString *)path;

@end

@interface MAImagePickerController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL flashIsOn;
    BOOL imagePickerDismissed;
}

@property (nonatomic,assign) id<MAImagePickerControllerDelegate> delegate;

@property (strong, nonatomic) MACaptureSession *captureManager;
@property (strong, nonatomic) UIToolbar *cameraToolbar;
@property (strong, nonatomic) UIBarButtonItem *flashButton;
@property (strong, nonatomic) UIBarButtonItem *pictureButton;
@property (strong, nonatomic) UIView *cameraPictureTakenFlash;
@property (strong ,nonatomic) UISlider *slider;//焦距调整条
@property (strong ,nonatomic) UILabel *enlargeLabel;//放大倍数


@property (strong ,nonatomic) UIImagePickerController *invokeCamera;

@property MAImagePickerControllerSourceType *sourceType;

@property (strong, nonatomic) MPVolumeView *volumeView;

@end
