//
//  MAViewController.m
//  CamScanner
//
//  Created by Maximilian Mackh on 11/5/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "MAViewController.h"
#import "CSFileCollectionViewCell.h"
#import "CSFileTableViewCellCollectionViewCell.h"

#import "MJRefresh.h"
//#import "FileModel+CoreDataClass.h"
//#import "FileModel+CoreDataProperties.h"
#import "AppDelegate.h"
#import "CSFile.h"
#import "FileManageDataAPI.h"
#import "MAImagePickerFinalViewController.h"
#import "CSFileShowViewController.h"

#import "CSMarco.h"
#import <MessageUI/MessageUI.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
// 自定义分享菜单栏需要导入的头文件
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>

#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "Constant.h"
#import "WechatAuthSDK.h"
#import "UIAlertView+WX.h"
#import "WXApi.h"
#import "CSTool.h"

@interface MAViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate,UISearchBarDelegate,MFMailComposeViewControllerDelegate,WechatAuthAPIDelegate,WXApiManagerDelegate,WXApiDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *fileCollectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_changeLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_select;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_sequence;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_search;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_delete;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_saveToAlbum;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_addLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_email;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_share;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic) BOOL isCollectionLayout;
@property (assign, nonatomic) BOOL isSelecting;

@property (strong, nonatomic) AppDelegate *mydelegate;

@property (nonatomic, strong) NSMutableIndexSet* selectedIndexSet;

@end

@implementation MAViewController

#pragma mark controller func
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self refreshData];
}


#pragma mark init func

- (void)initView{
    [self refreshLayout];
   // self.navigationController.navigationBar.backgroundColor = RGBAHEX(0xDBE5D5, 1.0);
    self.navigationController.navigationBar.barTintColor = RGBAHEX(0xDBE5D5, 1.0);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    _fileCollectionView.alwaysBounceVertical=YES;
    _fileCollectionView.dataSource = self;
    _fileCollectionView.delegate = self;
    _fileCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 增加数据
        [_fileCollectionView.mj_header beginRefreshing];
        
        //网络请求
        NSLog(@"下拉刷新");
        [self refreshData];
        [_fileCollectionView.mj_header endRefreshing];
        
    }];
    
    _fileCollectionView.mj_footer = [MJRefreshAutoNormalFooter  footerWithRefreshingBlock:^{
        [_fileCollectionView.mj_footer  beginRefreshing];
        NSLog(@"上拉加载");
        //网络请求
        // 结束刷新
        [_fileCollectionView.mj_footer  endRefreshing];
        
    }];
    
    NSLog(@"width: %f,height:%f",self.fileCollectionView.frame.size.width,self.fileCollectionView.frame.size.height);
    
    [_fileCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CSFileCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"FILECELL"];
    [_fileCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CSFileTableViewCellCollectionViewCell class]) bundle:nil]forCellWithReuseIdentifier:@"TFILECELL"];
    
    [_btn_changeLayout setAction:@selector(refreshLayout)];
    [_btn_select setAction:@selector(selectFile)];
    [_btn_sequence setAction:@selector(sequence)];
    [_btn_search setAction:@selector(search)];
    
    [_btn_delete setAction:@selector(checkDeletefile)];
    [_btn_saveToAlbum setAction:@selector(saveToAlbum)];
    [_btn_addLabel setAction:@selector(addLabel)];
    [_btn_email setAction:@selector(email)];
    [_btn_share setAction:@selector(shareFileToWX)];
    
    [_btn_share setEnabled:NO];
    [_btn_email setEnabled:NO];
    [_btn_delete setEnabled:NO];
    [_btn_addLabel setEnabled:NO];
    [_btn_saveToAlbum setEnabled:NO];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    [self.bottomToolbar setHidden:YES];
    [self.searchBar setHidden:YES];
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //
    //    // 注册collectionview底部的view,需要注意的是这里的view需要继承自UICollectionReusableView
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionFooterReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}



- (void)initData{
    _mydelegate = [[UIApplication sharedApplication] delegate];
    _fileArray = _mydelegate.fileArray;
    _selectedIndexSet = [[NSMutableIndexSet alloc] init];
    _searchBar.delegate = self;
    [WXApiManager sharedManager].delegate = self;
}


#pragma refresh funcs
- (void)refreshData{
    if (_isSelecting) {
        return;
    }
    _fileArray = _mydelegate.fileArray;
    NSLog(@"XxXXXXXXX%d",[_fileArray count]);
    [_fileCollectionView reloadData];
}

- (void)refreshLayout{
    UICollectionViewFlowLayout *layout = [self setCollectionLayout];
    [_fileCollectionView setCollectionViewLayout:layout];
    [_fileCollectionView reloadData];
}


- (UICollectionViewFlowLayout *)setCollectionLayout{
    if (_isCollectionLayout) {
        _isCollectionLayout = NO;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        float itemWidth = 375.0;
        float itemHeight = 80.0;
        
        layout.minimumInteritemSpacing = 0.f;// 垂直方向的间距
        layout.minimumLineSpacing = 1; // 水平方向的间距
        
        layout.itemSize = CGSizeMake(itemWidth,itemHeight);
        return layout;
    }
    else{
        _isCollectionLayout = YES;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        float itemWidth = 111.0;
        float itemHeight = 150.0;
        
        layout.minimumInteritemSpacing = 5.f;// 垂直方向的间距
        layout.minimumLineSpacing = (self.fileCollectionView.frame.size.width - itemWidth * 3)/2; // 水平方向的间距
        
        layout.itemSize = CGSizeMake(itemWidth,itemHeight);
        return layout;
    }
}

#pragma mark select funcs

- (void)selectFile{
    _isSelecting = YES;
    _fileCollectionView.allowsMultipleSelection = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(selectCancel)];

    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(animationDidStart:)];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:)];
    
    [UIView setAnimationDelay:0.0f];
    [UIView setAnimationDuration:0.5f];
    [_toolbar setFrame:CGRectMake(_toolbar.frame.origin.x ,_toolbar.frame.origin.y - 44.f ,_toolbar.frame.size.width, _toolbar.frame.size.height)];
    [_fileCollectionView setFrame:CGRectMake(_fileCollectionView.frame.origin.x ,_fileCollectionView.frame.origin.y - 44.f , _fileCollectionView.frame.size.width, _fileCollectionView.frame.size.height)];
    [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, self.view.frame.size.height, _bottomView.frame.size.width, _bottomView.frame.size.height)];
    
    [_bottomToolbar setFrame:CGRectMake(_bottomToolbar.frame.origin.x, _bottomToolbar.frame.origin.y - 44.f, _bottomToolbar.frame.size.width, _bottomToolbar.frame.size.height)];
    
    [UIView commitAnimations];
    [_fileCollectionView reloadData];
}

-(void)animationDidStart:(CAAnimation *)anim
{
    [_bottomToolbar setHidden:NO];
}

-(void)animationDidStop:(CAAnimation *)anim
{
    [_toolbar setHidden:YES];
    [_bottomView setHidden:YES];
}

- (void)selectAll{
    [self.navigationItem.leftBarButtonItem setTitle:@"取消全选"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(removeAll)];
    
    for (NSUInteger i = 0; i < [_fileArray count]; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [_selectedIndexSet addIndex:i];
        [self collectionView:_fileCollectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)removeAll{
    [self.navigationItem.leftBarButtonItem setTitle:@"全选"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(selectAll)];
    
    for (NSUInteger i = 0; i < [_fileArray count]; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [_selectedIndexSet removeIndex:i];
        [self collectionView:_fileCollectionView didDeselectItemAtIndexPath:indexPath];
    }
}
- (void)selectCancel{
    _isSelecting = NO;
    _fileCollectionView.allowsMultipleSelection = NO;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDelay:0.0f];
    [UIView setAnimationDuration:0.5f];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(animationCancelDidStart:)];
    [UIView setAnimationDidStopSelector:@selector(animationCancelDidStop:)];
    
    [_toolbar setFrame:CGRectMake(_toolbar.frame.origin.x ,_toolbar.frame.origin.y + 44.f ,_toolbar.frame.size.width, _toolbar.frame.size.height)];
    [_fileCollectionView setFrame:CGRectMake(_fileCollectionView.frame.origin.x ,_fileCollectionView.frame.origin.y + 44.f , _fileCollectionView.frame.size.width, _fileCollectionView.frame.size.height)];
    [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, self.view.frame.size.height - _bottomView.frame.size.height, _bottomView.frame.size.width, _bottomView.frame.size.height)];
    
    [_bottomToolbar setFrame:CGRectMake(_bottomToolbar.frame.origin.x, _bottomToolbar.frame.origin.y + 44.f, _bottomToolbar.frame.size.width, _bottomToolbar.frame.size.height)];
    
    [UIView commitAnimations];
    
    for (NSUInteger i = 0; i < [_fileArray count]; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [_selectedIndexSet removeIndex:i];
        [self collectionView:_fileCollectionView didDeselectItemAtIndexPath:indexPath];
    }
 
    [_fileCollectionView reloadData];
}

- (void)animationCancelDidStart:(CAAnimation *)anim{
    [_toolbar setHidden:NO];
    [_bottomView setHidden:NO];
}

- (void)animationCancelDidStop:(CAAnimation *)anim
{
    [_bottomToolbar setHidden:YES];
}

#pragma mark delete funcs
- (void)checkDeletefile{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"确认要删除选中的文件吗" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击取消");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"是的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteFile];
    }]];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteFile{
    if (_selectedIndexSet != NULL) {
        NSMutableArray * keyArray = [NSMutableArray array];
        __weak typeof(self) weakSelf = self;
        [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%lu", (unsigned long)idx);
            CSFile * file = [_fileArray objectAtIndex:idx];
            NSNumber *fileNumber = [NSNumber numberWithInt:file.fileNumber];
            [keyArray addObject:fileNumber];
        }];
        
        [[FileManageDataAPI sharedInstance] deletefileModelWithKeyArray:keyArray success:^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"删除成功" delegate:weakSelf cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            //显示alertView
            [alertView show];
           
            [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                
                [_fileArray enumerateObjectsUsingBlock:^(CSFile *file, NSUInteger idx, BOOL *stop) {
                    for (NSNumber * number in keyArray) {
                        if (file.fileNumber == [number intValue]) {
                            [_fileArray removeObject:file];
                            [_mydelegate.fileArray removeObject:file];
                            *stop = YES; // 相当于break ; stop控制跳出枚举器.
                        }
                    }
                }];
            }];
            
            [weakSelf selectCancel];
        } fail:^(NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"删除失败" delegate:weakSelf cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            //显示alertView
            [alertView show];
            [weakSelf selectCancel];
        }];
    }
}

#pragma mark save to album func
- (void)saveToAlbum{
    if (_selectedIndexSet != NULL) {
        [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%lu", (unsigned long)idx);
            CSFile * file = [_fileArray objectAtIndex:idx];
            UIImage * img = [UIImage imageWithData:file.fileAdjustImage];
            [self loadImageFinished:img];
        }];
    }
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
#pragma mark addLabel func

- (BOOL)addLabel{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"标签" message:@"请输入标签" preferredStyle:UIAlertControllerStyleAlert];
   
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // 可以在这里对textfield进行定制，例如改变背景色
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击取消");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%lu", (unsigned long)idx);
            CSFile * file = [_fileArray objectAtIndex:idx];
            UITextField *label = alertController.textFields.firstObject;
            file.fileLabel = label.text;
            if (!label.text) {
                file.fileLabel = @"无";
            }
            [_fileArray replaceObjectAtIndex:idx withObject:file];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [[FileManageDataAPI sharedInstance] updateDataWithFileModel:file success:^{
                    dispatch_semaphore_signal(semaphore);
                    NSLog(@"update successfully~\n\n\n");
                }fail:^(NSError *error){
                    dispatch_semaphore_signal(semaphore);
                    NSLog(@"fail to update!!\n\n\n");
                }];
            });
        }];
        [self selectCancel];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark email
- (void)email{
    if ([MFMailComposeViewController canSendMail]) {
        [self sendEmailAction]; // 调用发送邮件的代码
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:[NSString stringWithFormat:@"未设置邮箱账户，请到系统设置中设置"] delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //显示alertView
        [alertView show];
    }
}

-(void)sendEmailAction{
    NSMutableArray *fileArray = [NSMutableArray array];
    [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%lu", (unsigned long)idx);
        CSFile * file = [_fileArray objectAtIndex:idx];
        [fileArray addObject:file];
    }];
    
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
    CSFile * file = [fileArray firstObject];
    [mailCompose setSubject:file.fileName];
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
    for (CSFile * file in fileArray) {
        NSFileManager* fm=[NSFileManager defaultManager];
        NSData *pdf = [NSData data];
        NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString *fileName = file.fileUrlPath;
        NSString *createPath = [NSString stringWithFormat:@"%@/%@",pathDocuments,fileName];
        
        pdf = [fm contentsAtPath:createPath];
        NSLog(@"\n\n%@",createPath);
        NSLog(@"\n\n%@",file.fileUrlPath);
        if (!pdf) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:[NSString stringWithFormat:@"未读取到文件！"] delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            //显示alertView
            [alertView show];
        }else{
            // NSData *pdf = [fileManager contentsAtPath:_csfile.fileUrlPath];
            [mailCompose addAttachmentData:pdf mimeType:@"application/pdf" fileName:fileName];
        }

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
    [self selectCancel];
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark share

- (void)shareFileToWX{
    
    NSMutableArray* imageArray = [NSMutableArray array];
    NSMutableArray *fileArray = [NSMutableArray array];
    [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%lu", (unsigned long)idx);
        CSFile * file = [_fileArray objectAtIndex:idx];
        [imageArray addObject:file.fileAdjustImage];
        [fileArray addObject:file];
    }];
    CSFile * file = [_fileArray firstObject];
    UIImage *thumbImg = [CSTool compressImage:[UIImage imageWithData:file.fileAdjustImage] toByte:30000];
    
    [WXApiRequestHandler sendImageData:file.fileAdjustImage
                               TagName:kImageTagName
                            MessageExt:kMessageExt
                                Action:kMessageAction
                            ThumbImage:thumbImg
                               InScene:WXSceneSession];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res1" ofType:@"jpg"];
//    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
//    
//    UIImage *thumbImage = [UIImage imageNamed:@"res1thumb.png"];
//    [WXApiRequestHandler sendImageData:imageData
//                               TagName:kImageTagName
//                            MessageExt:kMessageExt
//                                Action:kMessageAction
//                            ThumbImage:thumbImage
//                               InScene:WXSceneSession];
    
}

- (void)shareFile{
    //1、创建分享参数
    NSMutableArray* imageArray = [NSMutableArray array];
    NSMutableArray *fileArray = [NSMutableArray array];
    [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%lu", (unsigned long)idx);
        CSFile * file = [_fileArray objectAtIndex:idx];
        [imageArray addObject:file.fileAdjustImage];
        [fileArray addObject:file];
    }];
    CSFile * file = [_fileArray firstObject];
    NSString * fileText = file.fileName;
    
    if (imageArray) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"您的好友给你分享了%@等文件",fileText]
                                         images:imageArray
                                            url:[NSURL URLWithString:@"http://mob.com"]
                                          title:@"来自CamScanner的分享"
                                           type:SSDKContentTypeAuto];
        [shareParams SSDKEnableUseClientShare];
        
        
       SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];
        
    [sheet.directSharePlatforms removeObject:@(SSDKPlatformTypeWechat)];
    }
}


#pragma mark sequence
- (void)sequence{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"排序" message:@"选择需要的排序方法" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击取消");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"创建时间逆序" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *fileArray = [_fileArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CSFile * file1 = (CSFile *)obj1;
            CSFile * file2 = (CSFile *)obj2;
            NSDate *date1 = file1.fileCreatedTime;
            NSDate *date2 = file2.fileCreatedTime;
            NSComparisonResult result = [date1 compare:date2];
            return result == NSOrderedAscending;
        }];
        _fileArray = [fileArray mutableCopy];
        [_fileCollectionView reloadData];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"创建时间正序" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *fileArray = [_fileArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CSFile * file1 = (CSFile *)obj1;
            CSFile * file2 = (CSFile *)obj2;
            NSDate *date1 = file1.fileCreatedTime;
            NSDate *date2 = file2.fileCreatedTime;
            NSComparisonResult result = [date1 compare:date2];
            return result == NSOrderedDescending;
        }];
        _fileArray = [fileArray mutableCopy];
        [_fileCollectionView reloadData];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark search

- (void)search{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:searchBar];
    [_searchBar setHidden:NO];
    _searchBar.showsCancelButton = YES;
    _searchBar.placeholder = @"搜索文件名或者标签";
    
    [_toolbar setHidden:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString * searchStr = searchBar.text;
    NSMutableArray * searchArray = [NSMutableArray array];
    for (CSFile * file in _fileArray) {
        if (([file.fileName rangeOfString:searchStr].location != NSNotFound) ||([file.fileLabel rangeOfString:searchStr].location != NSNotFound)) {
            [searchArray addObject:file];
        }
    }
    _fileArray = [searchArray mutableCopy];
    [_fileCollectionView reloadData];
    [_searchBar resignFirstResponder];
    [_searchBar setHidden:YES];
    [_toolbar setHidden:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [_searchBar setHidden:YES];
    [_toolbar setHidden:NO];
    [_searchBar resignFirstResponder];
}
#pragma mark collection delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

/**
 * Cell选中调用该方法
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSelecting) {
        if (_isCollectionLayout) {
            CSFileCollectionViewCell * cell = (CSFileCollectionViewCell *)[self.fileCollectionView cellForItemAtIndexPath:indexPath];
            cell.selected = YES;
            [self changeSelectStateWithCell:cell];
        }
        else{
            CSFileTableViewCellCollectionViewCell * cell = (CSFileTableViewCellCollectionViewCell *)[self.fileCollectionView cellForItemAtIndexPath:indexPath];
            cell.selected = YES;
            [self changeSelectStateWithTableCell:cell];
        }
        [_selectedIndexSet addIndex:indexPath.item];
        if ([_selectedIndexSet count] > 0) {
            [_btn_email setEnabled:YES];
            [_btn_delete setEnabled:YES];
            [_btn_addLabel setEnabled:YES];
            [_btn_saveToAlbum setEnabled:YES];
            if ([_selectedIndexSet count] == 1)
            {
                [_btn_share setEnabled:YES];
            }
            else
                [_btn_share setEnabled:NO];
            
            [_bottomToolbar setNeedsDisplay];
        }
      
    }
    else{
        [self performSegueWithIdentifier:@"ShowDetail" sender:indexPath];
        
//        CATransition* transition = [CATransition animation];
//        transition.duration = 0.4;
//        transition.type = kCATransitionFade;
//        transition.subtype = kCATransitionFromBottom;
//        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//        [self.navigationController pushViewController:finalView animated:NO];
    }
}

/**
 * Cell取消选中调用该方法
 */
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isCollectionLayout) {
        CSFileCollectionViewCell * cell = (CSFileCollectionViewCell *)[self.fileCollectionView cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
        [self changeSelectStateWithCell:cell];
    }
    else{
        CSFileTableViewCellCollectionViewCell * cell = (CSFileTableViewCellCollectionViewCell *)[self.fileCollectionView cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
        [self changeSelectStateWithTableCell:cell];
    }
    [_selectedIndexSet removeIndex:indexPath.item];
    if ([_selectedIndexSet count] == 0) {
        [_btn_email setEnabled:NO];
        [_btn_delete setEnabled:NO];
        [_btn_addLabel setEnabled:NO];
        [_btn_saveToAlbum setEnabled:NO];
    }
    if ([_selectedIndexSet count] == 1)
    {
        [_btn_share setEnabled:YES];
    }
    else
        [_btn_share setEnabled:NO];
    [_bottomToolbar setNeedsDisplay];
}

/**
 * Cell根据Cell选中状态来改变Cell上Button按钮的状态
 */
- (void) changeSelectStateWithCell: (CSFileCollectionViewCell *) currentSelectCell{
    
    currentSelectCell.selectButton.selected = currentSelectCell.selected;
    
    if (currentSelectCell.selected == YES){
        //NSLog(@"第%ld个Section上第%ld个Cell被选中了",indexPath.section ,indexPath.row);
        
    }
    
    if (currentSelectCell.selected == NO){
        //NSLog(@"第%ld个Section上第%ld个Cell取消选中",indexPath.section ,indexPath.row);
    }
}

- (void) changeSelectStateWithTableCell:(CSFileTableViewCellCollectionViewCell *)currentSelectCell{
    currentSelectCell.selectButton.selected = currentSelectCell.selected;
    
    if (currentSelectCell.selected == YES){
        //NSLog(@"第%ld个Section上第%ld个Cell被选中了",indexPath.section ,indexPath.row);
        
    }
    
    if (currentSelectCell.selected == NO){
        //NSLog(@"第%ld个Section上第%ld个Cell取消选中",indexPath.section ,indexPath.row);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_fileArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isCollectionLayout) {
         CSFileCollectionViewCell *cell = (CSFileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FILECELL" forIndexPath:indexPath];
        if (cell) {
            //FileModel *fileModel = [_fileArray objectAtIndex:[indexPath row]];
            CSFile* fileModel = [_fileArray objectAtIndex:[indexPath row]];
            //        for(FileModel *file in finishArray)
            //        {
            //            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
            //
            //            NSLog(@"name = %@,size = %@,label = %@,type = %@,url = %@,date = %@,",file.fileName,file.fileSize,file.fileLabel,file.fileType,file.fileUrlPath,[formatter stringFromDate:file.fileCreatedTime]);
            //        }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
            UIImage *img = [UIImage imageWithData:fileModel.fileAdjustImage];
            
            cell.fileName.text = fileModel.fileName;
            cell.fileLabel.text = fileModel.fileLabel;
            cell.fileCreateTime.text = [formatter stringFromDate:fileModel.fileCreatedTime];
            cell.fileImage.image = img;
            cell.backgroundColor = [UIColor whiteColor];
            if (_isSelecting) {
                [cell.selectButton setHidden:NO];
            }
            else{
                [cell.selectButton setHidden:YES];
            }
        }
        return cell;
    }
    else{
        CSFileTableViewCellCollectionViewCell *cell = (CSFileTableViewCellCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TFILECELL" forIndexPath:indexPath];
        if (cell) {
          //  FileModel *fileModel = [_fileArray objectAtIndex:[indexPath row]];
            CSFile* fileModel = [_fileArray objectAtIndex:[indexPath row]];
            //        for(FileModel *file in finishArray)
            //        {
            //            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
            //
            //            NSLog(@"name = %@,size = %@,label = %@,type = %@,url = %@,date = %@,",file.fileName,file.fileSize,file.fileLabel,file.fileType,file.fileUrlPath,[formatter stringFromDate:file.fileCreatedTime]);
            //        }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
            UIImage *img = [UIImage imageWithData:fileModel.fileAdjustImage];
            
            cell.fileName.text = fileModel.fileName;
            cell.fileLabel.text = fileModel.fileLabel;
            cell.fileCreateTime.text = [formatter stringFromDate:fileModel.fileCreatedTime];
            cell.fileImage.image = img;
            cell.backgroundColor = [UIColor whiteColor];
            if (_isSelecting) {
                [cell.selectButton setHidden:NO];
            }
        }
        return cell;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark jump to camera
- (IBAction)initButton:(id)sender
{
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
   
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:MAImagePickerControllerSourceTypeCamera];
    
   // UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    [self.navigationController pushViewController:imagePicker animated:YES];
    //[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)imagePickerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerDidChooseImageWithPath:(NSString *)path
{
   // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"File Found at %@", path);
        
    }
    else
    {
        NSLog(@"No File Found at %@", path);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ShowDetail"]){
        CSFileShowViewController *vc = segue.destinationViewController;
        CSFile* fileModel = [_fileArray objectAtIndex:[(NSIndexPath *)sender row]];
        UIImage *sourceImage = [UIImage imageWithData:fileModel.fileOriginImage];
        UIImage *adjustImage = [UIImage imageWithData:fileModel.fileAdjustImage];
        vc.sourceImage = sourceImage;
        vc.adjustedImage = adjustImage;
        vc.csfile = fileModel;
    }
}
@end
