//
//  MAImagePickerController.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "MAImagePickerController.h"
#import "MAImagePickerControllerAdjustViewController.h"

#import "UIImage+fixOrientation.h"


@interface MAImagePickerController ()
@property (nonatomic , assign) CGFloat beginGestureScale;//开始的缩放比例
@property (nonatomic , assign) CGFloat effectiveScale;//最后的缩放比例

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation MAImagePickerController
{
    BOOL volumeChangeOK;
}

@synthesize captureManager = _captureManager;
@synthesize cameraToolbar = _cameraToolbar;
@synthesize flashButton = _flashButton;
@synthesize pictureButton = _pictureButton;
@synthesize cameraPictureTakenFlash = _cameraPictureTakenFlash;

@synthesize invokeCamera = _invokeCamera;

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    
    if (_sourceType == MAImagePickerControllerSourceTypeCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MAImagePickerChosen:) name:@"MAIPCSuccessInternal" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
            AudioSessionInitialize(NULL, NULL, NULL, NULL);
            AudioSessionSetActive(YES);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
         {
             AudioSessionSetActive(NO);
         }];
        
        
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        AudioSessionSetActive(YES);
        
        // Volume View to hide System HUD
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 0)];
        [_volumeView sizeToFit];
        [self.view addSubview:_volumeView];
        
        [self setCaptureManager:[[MACaptureSession alloc] init]];
        [_captureManager addVideoInputFromCamera];
        [_captureManager addStillImageOutput];
        [_captureManager addVideoPreviewLayer];
        
        CGRect layerRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kCameraToolBarHeight);
        [[_captureManager previewLayer] setBounds:layerRect];
        [[_captureManager previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        [[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
        
        UIImage *gridImage;
        
        if ([[UIScreen mainScreen] bounds].size.height == 568.000000)
        {
            gridImage = [UIImage imageNamed:@"cs_camera_grid_1136@2x.png"];
        }
        else
        {
            gridImage = [UIImage imageNamed:@"cs_camera_grid@2x.png"];
        }
        
        UIImageView *gridCameraView = [[UIImageView alloc] initWithImage:gridImage];
        [gridCameraView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kCameraToolBarHeight)];
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMAImagePickerController)];
        [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.view addGestureRecognizer:swipeDown];
        
        [[self view] addSubview:gridCameraView];
        
        _cameraToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kCameraToolBarHeight, self.view.bounds.size.width, kCameraToolBarHeight)];
        [_cameraToolbar setBackgroundImage:[UIImage imageNamed:@"cs_camera_bottom_bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cs_camera_close_button"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissMAImagePickerController)];
        [cancelButton setTintColor:[UIColor whiteColor]];
        cancelButton.accessibilityLabel = @"Close Camera Viewer";
        
        UIImage *cameraButtonImage = [UIImage imageNamed:@"cs_camera_button"];
        UIImage *cameraButtonImagePressed = [UIImage imageNamed:@"cs_camera_button_press"];
        UIButton *pictureButtonRaw = [UIButton buttonWithType:UIButtonTypeCustom];
        [pictureButtonRaw setImage:cameraButtonImage forState:UIControlStateNormal];
        [pictureButtonRaw setImage:cameraButtonImagePressed forState:UIControlStateHighlighted];
        [pictureButtonRaw addTarget:self action:@selector(pictureMAIMagePickerController) forControlEvents:UIControlEventTouchUpInside];
        pictureButtonRaw.frame = CGRectMake(0.0, 0.0, cameraButtonImage.size.width, cameraButtonImage.size.height);
        _pictureButton = [[UIBarButtonItem alloc] initWithCustomView:pictureButtonRaw];
        _pictureButton.accessibilityLabel = @"Take Picture";
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kCameraFlashDefaultsKey] == nil)
        {
            [self storeFlashSettingWithBool:YES];
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kCameraFlashDefaultsKey])
        {
            _flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cs_camera_flash_on"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFlash)];
            [_flashButton setTintColor:[UIColor whiteColor]];
            _flashButton.accessibilityLabel = @"Disable Camera Flash";
            flashIsOn = YES;
            [_captureManager setFlashOn:YES];
        }
        else
        {
            _flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cs_camera_flash_off"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFlash)];
            [_flashButton setTintColor:[UIColor whiteColor]];
            _flashButton.accessibilityLabel = @"Enable Camera Flash";
            flashIsOn = NO;
            [_captureManager setFlashOn:NO];
        }
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [fixedSpace setWidth:10.0f];
        
        [_cameraToolbar setItems:[NSArray arrayWithObjects:fixedSpace,cancelButton,flexibleSpace,_pictureButton,flexibleSpace,_flashButton,fixedSpace, nil]];
        
        [self.view addSubview:_cameraToolbar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionToMAImagePickerControllerAdjustViewController) name:kImageCapturedSuccessfully object:nil];
        
        _cameraPictureTakenFlash = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height -kCameraToolBarHeight)];
        [_cameraPictureTakenFlash setBackgroundColor:[UIColor colorWithRed:0.99f green:0.99f blue:1.00f alpha:1.00f]];
        [_cameraPictureTakenFlash setUserInteractionEnabled:NO];
        [_cameraPictureTakenFlash setAlpha:0.0f];
        [self.view addSubview:_cameraPictureTakenFlash];
        [self addSliderBar];
    }
    else
    {
        self.view.layer.cornerRadius = 8;
        self.view.layer.masksToBounds = YES;
        
        _invokeCamera = [[UIImagePickerController alloc] init];
        _invokeCamera.delegate = self;
        _invokeCamera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _invokeCamera.allowsEditing = NO;
        [self.view addSubview:_invokeCamera.view];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_sourceType == MAImagePickerControllerSourceTypeCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pictureMAIMagePickerController)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
        
        [_pictureButton setEnabled:YES];
        [[_captureManager captureSession] startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_sourceType == MAImagePickerControllerSourceTypeCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        
        [[_captureManager captureSession] stopRunning];
    }
}

- (void)pictureMAIMagePickerController
{
    if (![[_captureManager captureSession] isRunning]) {
        return;
    }
    
    [_pictureButton setEnabled:NO];
    [_captureManager captureStillImage];
}

- (void)toggleFlash
{
    if (flashIsOn)
    {
        flashIsOn = NO;
        [_captureManager setFlashOn:NO];
        [_flashButton setImage:[UIImage imageNamed:@"cs_camera_flash_off"]];
        [_flashButton setTintColor:[UIColor whiteColor]];
        _flashButton.accessibilityLabel = @"Enable Camera Flash";
        [self storeFlashSettingWithBool:NO];
    }
    else
    {
        flashIsOn = YES;
        [_captureManager setFlashOn:YES];
        [_flashButton setImage:[UIImage imageNamed:@"cs_camera_flash_on"]];
        [_flashButton setTintColor:[UIColor whiteColor]];
        _flashButton.accessibilityLabel = @"Disable Camera Flash";
        [self storeFlashSettingWithBool:YES];
    }
}

- (void)storeFlashSettingWithBool:(BOOL)flashSetting
{
    [[NSUserDefaults standardUserDefaults] setBool:flashSetting forKey:kCameraFlashDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)transitionToMAImagePickerControllerAdjustViewController
{
    [[_captureManager captureSession] stopRunning];
    
    MAImagePickerControllerAdjustViewController *adjustViewController = [[MAImagePickerControllerAdjustViewController alloc] init];
    adjustViewController.sourceImage = [[self captureManager] stillImage];
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         _cameraPictureTakenFlash.alpha = 0.5f;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
          {
              _cameraPictureTakenFlash.alpha = 0.0f;
          }
                          completion:^(BOOL finished)
          {
              CATransition* transition = [CATransition animation];
              transition.duration = 0.4;
              transition.type = kCATransitionFade;
              transition.subtype = kCATransitionFromBottom;
              [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
              [self.navigationController pushViewController:adjustViewController animated:NO];
          }];
     }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissMAImagePickerController];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_invokeCamera removeFromParentViewController];
    imagePickerDismissed = YES;
    [self.navigationController popViewControllerAnimated:NO];
    
    MAImagePickerControllerAdjustViewController *adjustViewController = [[MAImagePickerControllerAdjustViewController alloc] init];
    adjustViewController.sourceImage = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:adjustViewController animated:NO];
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _captureManager = nil;
}

- (void)dismissMAImagePickerController
{
    [self removeNotificationObservers];
    if (_sourceType == MAImagePickerControllerSourceTypeCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [[_captureManager captureSession] stopRunning];
        AudioSessionSetActive(NO);
    }
    else
    {
        [_invokeCamera removeFromParentViewController];
    }
    
    [_delegate imagePickerDidCancel];
}

- (void) MAImagePickerChosen:(NSNotification *)notification
{
    AudioSessionSetActive(NO);
    
    [self removeNotificationObservers];
    [_delegate imagePickerDidChooseImageWithPath:[notification object]];
}

- (void)removeNotificationObservers
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}


//添加sliderbar到主视图上
- (void)addSliderBar{
    _enlargeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 30, self.view.bounds.size.height/2 - 105, 40, 20)];
    [_enlargeLabel setFont:[UIFont systemFontOfSize:9]];
    [self.view addSubview:_enlargeLabel];
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 120,self.view.bounds.size.height/2, 200, 20)];
    //UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 450, 200, 20)];
    _slider.minimumValue = 1.0;
    _slider.maximumValue = 6.0;
    _slider.value = 1.0;
    _slider.transform =CGAffineTransformMakeRotation(3*M_PI/2);
    
    [_enlargeLabel setText:[NSString stringWithFormat:@"%.1fX",_slider.value]];
    [_slider addTarget:self action:@selector(focusDisdance) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_slider];
    
}
#pragma mark 调整焦距

- (void)focusDisdance{
    [_enlargeLabel setText:[NSString stringWithFormat:@"%.1fX",_slider.value]];
    [_captureManager focusDisdanceWithSliderValue:_slider.value];
}


@end
