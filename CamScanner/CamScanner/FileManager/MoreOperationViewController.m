//
//  MoreOperationViewController.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/5/2.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "MoreOperationViewController.h"
#import "CSFilePropertyTableViewController.h"
#import <MessageUI/MessageUI.h>

@interface MoreOperationViewController ()<MFMailComposeViewControllerDelegate>


@end

@implementation MoreOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)toFileProperty:(id)sender {
    [self performSegueWithIdentifier:@"ToCSFileProperty" sender:nil];
}
- (IBAction)saveToAlbum:(id)sender {
    UIImage * img = [UIImage imageWithData:_csfile.fileAdjustImage];
    [self loadImageFinished:img];
}
- (IBAction)sendEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        [self sendEmailAction]; // 调用发送邮件的代码
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:[NSString stringWithFormat:@"未设置邮箱账户，请到系统设置中设置"] delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //显示alertView
        [alertView show];
    }
}

-(void)sendEmailAction{
    // 创建邮件发送界面
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setTitle:@"发送邮件"];
    
    [mailCompose setMailComposeDelegate:self];
    // 设置收件人
    [mailCompose setToRecipients:@[@"735042473@qq.com"]];
    // 设置抄送人
    [mailCompose setCcRecipients:@[@""]];
    // 设置密送人
    [mailCompose setBccRecipients:@[@""]];
    // 设置邮件主题
    [mailCompose setSubject:_csfile.fileName];
    //设置邮件的正文内容
    NSString *emailContent = @"我是来自CamScanner的扫描文档，请多多关照";
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    // [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
//    //添加附件
//    UIImage *image = [UIImage imageNamed:@"qq"];
//    NSData *imageData = UIImagePNGRepresentation(image);
//    [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"qq.png"];

    // NSString *file = [[NSBundle mainBundle] pathForResource:@"EmptyPDF" ofType:@"pdf"];
    NSFileManager* fm=[NSFileManager defaultManager];
    NSData *pdf = [NSData data];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *fileName = _csfile.fileUrlPath;
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",pathDocuments,fileName];
    
    pdf = [fm contentsAtPath:createPath];
    NSLog(@"\n\n%@",createPath);
    NSLog(@"\n\n%@",_csfile.fileUrlPath);
    if (!pdf) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:[NSString stringWithFormat:@"未读取到文件！"] delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //显示alertView
        [alertView show];
    }else{
        // NSData *pdf = [fileManager contentsAtPath:_csfile.fileUrlPath];
        [mailCompose addAttachmentData:pdf mimeType:@"application/pdf" fileName:fileName];
    }
     // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled: 用户取消编辑");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: 用户保存邮件");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent: 用户点击发送");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]);
            break;
    }
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:[NSString stringWithFormat:@"保存到相册失败 error:%@",error] delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //显示alertView
        [alertView show];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"保存成功" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //显示alertView
        [alertView show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ToCSFileProperty"]){
        CSFilePropertyTableViewController *vc = segue.destinationViewController;
        vc.csfile = _csfile;
    }
}

@end
