//
//  MACaptureSession.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "MACaptureSession.h"
#import <ImageIO/ImageIO.h>
@interface MACaptureSession ()

@property (nonatomic , assign) CGFloat beginGestureScale;//开始的缩放比例
@property (nonatomic , assign) CGFloat effectiveScale;//最后的缩放比例

@end


@implementation MACaptureSession

@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize stillImage = _stillImage;

- (id)init
{
	if ((self = [super init]))
    {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
        self.beginGestureScale = 1.0f;
        self.effectiveScale = 1.0f;
	}
	return self;
}

- (void)addVideoPreviewLayer
{
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

- (void)addVideoInputFromCamera
{
    AVCaptureDevice *backCamera;
    
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionBack)
            {
                backCamera = device;
                [self toggleFlash];
            }
        }
    }
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    
    if (!error)
    {
        if ([_captureSession canAddInput:backFacingCameraDeviceInput])
        {
            [_captureSession addInput:backFacingCameraDeviceInput];
        }
    }
}

- (void)setFlashOn:(BOOL)boolWantsFlash
{
    flashOn = boolWantsFlash;
    [self toggleFlash];
}

- (void)toggleFlash
{
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.flashAvailable) {
            if (flashOn)
            {
                [device lockForConfiguration:nil];
                device.flashMode = AVCaptureFlashModeOn;
                [device unlockForConfiguration];
            }
            else
            {
                [device lockForConfiguration:nil];
                device.flashMode = AVCaptureFlashModeOff;
                [device unlockForConfiguration];
            }
        }
    }
}

- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in [_stillImageOutput connections])
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    [_captureSession addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections])
    {
		for (AVCaptureInputPort *port in [connection inputPorts])
        {
			if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
				videoConnection = connection;
				break;
			}
		}
        
		if (videoConnection)
        {
            break;
        }
	}
    
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         if (imageSampleBuffer)
         {
             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments)
             {
                 //NSLog(@"attachements: %@", exifAttachments);
             } else
             {
                 //NSLog(@"no attachments");
             }
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self setStillImage:image];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
         }
     }];
}

#pragma mark 调整焦距
/** 调整焦距 */
- (void)focusDisdanceWithSliderValue:(float)sliderValue{
    self.effectiveScale = self.beginGestureScale * sliderValue;
    if (self.effectiveScale < 1.0f) {
        self.effectiveScale = 1.0f;
    }
    CGFloat maxScaleAndCropFactor = 6.0f;
    if (self.effectiveScale > maxScaleAndCropFactor)
        self.effectiveScale = maxScaleAndCropFactor;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    NSError *error;
    
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionBack)
            {
                if([device lockForConfiguration:&error]){
                    [device setVideoZoomFactor:self.effectiveScale];
                    [device unlockForConfiguration];
                }
                else {
                    NSLog(@"ERROR = %@", error);
                }
                [CATransaction commit];
            }
        }
    }
}


- (void)dealloc {
    
	[[self captureSession] stopRunning];
    
	_previewLayer = nil;
	_captureSession = nil;
    _stillImageOutput = nil;
    _stillImage = nil;
}

@end
