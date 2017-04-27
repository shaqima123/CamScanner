//
//  MACaptureSession.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "MAConstants.h"

@interface MACaptureSession : NSObject
{
    BOOL flashOn;
}

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)addVideoInputFromCamera;

- (void)setFlashOn:(BOOL)boolWantsFlash;
- (void)focusDisdanceWithSliderValue:(float)sliderValue;

@end
