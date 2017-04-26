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

@interface MAViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *fileCollectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_changeLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_select;


@property (assign, nonatomic) BOOL isCollectionLayout;
@property (strong, nonatomic) AppDelegate *mydelegate;
@end

@implementation MAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
}
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self refreshData];
//}
- (void)initView{
    [self refreshLayout];
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
    [_fileCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CSFileTableViewCellCollectionViewCell class]) bundle:nil]forCellWithReuseIdentifier:@"TFILECELL"];
    
    [_btn_changeLayout setAction:@selector(refreshLayout)];
    
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //
    //    // 注册collectionview底部的view,需要注意的是这里的view需要继承自UICollectionReusableView
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionFooterReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}



- (void)initData{
    _mydelegate = [[UIApplication sharedApplication] delegate];
    _fileArray = _mydelegate.fileArray;
}


- (void)refreshData{
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
            cell.backgroundColor = [UIColor yellowColor];
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
            cell.backgroundColor = [UIColor yellowColor];
        }
        return cell;
    }
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
