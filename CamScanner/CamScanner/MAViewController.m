//
//  MAViewController.m
//  CamScanner
//
//  Created by Maximilian Mackh on 11/5/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "MAViewController.h"
#import "CSFileCollectionViewCell.h"
#import "MAAppDelegate.h"
#import "MJRefresh.h"
#import "FileModel+CoreDataClass.h"
#import "FileModel+CoreDataProperties.h"

@interface MAViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *fileCollectionView;
@end

@implementation MAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)initView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    float itemWidth = 111.0;
    float itemHeight = 150.0;
    
    layout.minimumInteritemSpacing = 5.f;// 垂直方向的间距
    layout.minimumLineSpacing = (self.fileCollectionView.frame.size.width - itemWidth * 3)/2; // 水平方向的间距
   
    layout.itemSize = CGSizeMake(itemWidth,itemHeight);
    [_fileCollectionView setCollectionViewLayout:layout];
    _fileCollectionView.backgroundColor = [UIColor whiteColor];
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
    
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //
    //    // 注册collectionview底部的view,需要注意的是这里的view需要继承自UICollectionReusableView
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionFooterReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}

- (void)initData{
    MAAppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    _fileArray = myDelegate.fileArray;
    
}


- (void)refreshData{
    NSLog(@"XxXXXXXXX%d",[_fileArray count]);
    [_fileCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_fileArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSFileCollectionViewCell *cell = (CSFileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FILECELL" forIndexPath:indexPath];
    if (cell) {
        FileModel *fileModel = [_fileArray objectAtIndex:[indexPath row]];
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
        cell.backgroundColor = [UIColor yellowColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)initButton:(id)sender
{
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
   
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:MAImagePickerControllerSourceTypeCamera];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)imagePickerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerDidChooseImageWithPath:(NSString *)path
{
   // [self dismissViewControllerAnimated:YES completion:nil];
    
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

@end
