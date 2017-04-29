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

@interface MAViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *fileCollectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_changeLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_select;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_delete;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn_saveToAlbum;




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
    _fileCollectionView.backgroundColor = [UIColor lightGrayColor];
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
    [_btn_delete setAction:@selector(checkDeletefile)];
    [_btn_saveToAlbum setAction:@selector(saveToAlbum)];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    [self.bottomToolbar setHidden:YES];
    
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //
    //    // 注册collectionview底部的view,需要注意的是这里的view需要继承自UICollectionReusableView
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionFooterReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}



- (void)initData{
    _mydelegate = [[UIApplication sharedApplication] delegate];
    _fileArray = _mydelegate.fileArray;
    _selectedIndexSet = [[NSMutableIndexSet alloc] init];
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
    [_toolbar setHidden:YES];
    [_bottomView setHidden:YES];
    [_bottomToolbar setHidden:NO];
    
    [_fileCollectionView reloadData];
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
    [_bottomToolbar setHidden:YES];
    
    for (NSUInteger i = 0; i < [_fileArray count]; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [_selectedIndexSet removeIndex:i];
        [self collectionView:_fileCollectionView didDeselectItemAtIndexPath:indexPath];
    }
    [_toolbar setHidden:NO];
    [_bottomView setHidden:NO];
    [_fileCollectionView reloadData];
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
        
        [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%lu", (unsigned long)idx);
            CSFile * file = [_fileArray objectAtIndex:idx];
            [keyArray addObject:file.fileName];
        }];
        [[FileManageDataAPI sharedInstance] deletefileModelWithKeyArray:keyArray success:^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"删除成功" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            //显示alertView
            [alertView show];
            [_selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                [_fileArray removeObjectAtIndex:idx];
            }];
            [self selectCancel];
        } fail:^(NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"删除失败" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            //显示alertView
            [alertView show];
            [self selectCancel];
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
            cell.backgroundColor = [UIColor yellowColor];
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
            cell.backgroundColor = [UIColor yellowColor];
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
