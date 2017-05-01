//
//  CSFileShowViewController.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/29.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "CSFileShowViewController.h"
#import "MAOpenCV.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import "FileManageDataAPI.h"
#import <CoreData/CoreData.h>
#import "CSFile.h"
#import "AppDelegate.h"
#import "CSPDFMangager.h"

@interface CSFileShowViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *sourceImageButton;
@property (weak, nonatomic) IBOutlet UIButton *blackImageButton;
@property (weak, nonatomic) IBOutlet UIButton *grayImageButton;
@property (weak, nonatomic) IBOutlet UIButton *colorStrongerButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rotateButton;
@property (strong, nonatomic) UITextField *textfield;
@end

@implementation CSFileShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, 0, 100, 50)];
    [_textfield setDelegate:self];
    [self.navigationItem setTitleView:_textfield];
    [_textfield setText:_csfile.fileName];
    [_textfield setTextAlignment:NSTextAlignmentCenter];

    //  [self.navigationController setNavigationBarHidden:YES];
    [_imageView setImage:_adjustedImage];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be     recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)updateFile:(id)sender {
    CSFile * file = _csfile;
    NSData *adjustImageData = UIImageJPEGRepresentation(_adjustedImage, 1.0);
    NSData *originImageData = UIImageJPEGRepresentation(_sourceImage, 1.0);
    NSString * fileSize = [CSPDFMangager getFileSizeFromData:adjustImageData];
    NSData * fileContent = UIImagePNGRepresentation(_adjustedImage);
    NSData * fileAdjustImage = adjustImageData;
    NSData * fileOriginImage = originImageData;
    
    file.fileAdjustImage = fileAdjustImage;
    file.fileOriginImage = fileOriginImage;
    file.fileContent = fileContent;
    file.fileSize = fileSize;
//    file.fileName = _textfield.text;
    [self.navigationController popViewControllerAnimated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //需要删除之前的pdf，重新生成一个
        //[CSPDFMangager createPDFFileWithSrc:adjustImageData toDestFile:[NSString stringWithFormat:@"%@.pdf",fileName] withPassword:nil];
        
        [[FileManageDataAPI sharedInstance] updateDataWithFileModel:file success:^{
            NSLog(@"update successfully~\n\n\n");
        }fail:^(NSError *error){
            NSLog(@"fail to update!!\n\n\n");
        }];
    });
}
- (IBAction)rotate:(id)sender {
    switch (_adjustedImage.imageOrientation)
    {
        case UIImageOrientationRight:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationDown];
            break;
        case UIImageOrientationDown:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationLeft];
            break;
        case UIImageOrientationLeft:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationUp];
            break;
        case UIImageOrientationUp:
            _adjustedImage = [[UIImage alloc] initWithCGImage: _adjustedImage.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationRight];
            break;
        default:
            break;
    }
    [self updateImageViewAnimated];
}


- (void) updateImageViewAnimated
{
    UIView *view = [_rotateButton valueForKey:@"view"];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI ];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [UIView transitionWithView:_imageView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        _imageView.image = _adjustedImage;
                    } completion:NULL];
    
//    [_progressIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
}


- (IBAction)originFilter:(id)sender {
    _adjustedImage = _sourceImage;
    [_imageView setImage:_sourceImage];
}

- (IBAction)blackFilter:(id)sender {
    cv::Mat original;
    original = [MAOpenCV cvMatGrayFromUIImage:_sourceImage];
    
    cv::GaussianBlur(original, original, cvSize(11,11), 0);
    cv::adaptiveThreshold(original, original, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
    _adjustedImage = [MAOpenCV UIImageFromCVMat:original];
     original.release();
    [_imageView setNeedsDisplay];
    [_imageView setImage:_adjustedImage];
}

- (IBAction)grayFilter:(id)sender {
    cv::Mat original;
    original = [MAOpenCV cvMatGrayFromUIImage:_sourceImage];
    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
    original.convertTo(new_image, -1, 1.4, -50);
    _adjustedImage = [MAOpenCV UIImageFromCVMat:new_image];
    original.release();
    new_image.release();
    [_imageView setNeedsDisplay];
    [_imageView setImage:_adjustedImage];
}

- (IBAction)colorStrongerFilter:(id)sender {
    cv::Mat original;
    original = [MAOpenCV cvMatFromUIImage:_sourceImage];
    cv::Mat new_image = cv::Mat::zeros( original.size(), original.type() );
    
    original.convertTo(new_image, -1, 1.9, -80);
    
    original.release();
    
    _adjustedImage = [MAOpenCV UIImageFromCVMat:new_image];
    new_image.release();
    [_imageView setNeedsDisplay];
    [_imageView setImage:_adjustedImage];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //返回一个BOOL值，指明是否允许在按下回车键时结束编辑
    //如果允许要调用resignFirstResponder 方法，这回导致结束编辑，而键盘会被收起
    [textField resignFirstResponder];//查一下resign这个单词的意思就明白这个方法了
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
