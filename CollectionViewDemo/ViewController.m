//
//  ViewController.m
//  PanCollectionView
//
//  Created by lizq on 16/8/31.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "ViewController.h"
#import "Cell.h"
#import "CellModel.h"
#import "DragCellCollectionView.h"
#import "DataManager.h"
#import "CollectionReusableHeaderView.h"
#import "CollectionReusableFooterView.h"

@interface ViewController ()<DragCellCollectionViewDataSource, DragCellCollectionViewDelegate>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, weak) DragCellCollectionView *mainView;
@property (nonatomic, assign) UIBarButtonItem *editButton;
@property (nonatomic, strong) DataManager *sourceManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付宝";
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];

    float cellWidth = floor((self.view.bounds.size.width - 50)/4.0);
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    DragCellCollectionView *mainView = [[DragCellCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _mainView = mainView;
    mainView.delegate = self;
    mainView.dataSource = self;
    mainView.backgroundColor = [UIColor whiteColor];
    [mainView registerNib:[UINib nibWithNibName:@"Cell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    [mainView registerClass:[CollectionReusableHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [mainView registerClass:[CollectionReusableFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];

    [self.view addSubview:mainView];
    self.sourceManager = [DataManager shareDataManager];

    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStylePlain target:self action:@selector(baginEditing:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baginEditing:) name:notification_CellBeganEditing object:nil];

}

- (void)baginEditing:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        _mainView.beginEditing = !_mainView.beginEditing;
    }
    if (_mainView.beginEditing) {
        self.navigationItem.rightBarButtonItem.title = @"完成";
    }else {
        self.navigationItem.rightBarButtonItem.title = @"管理";
    }
}


#pragma mark - <DragCellCollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.sourceManager.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *sec = self.sourceManager.dataArray[section];
    return sec.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell resetModel:self.sourceManager.dataArray[indexPath.section][indexPath.item] :indexPath];
    return cell;
}

- (NSArray *)dataSourceArrayOfCollectionView:(DragCellCollectionView *)collectionView{
    return self.sourceManager.dataArray;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size;
    if (section == 0&&[DataManager shareDataManager].isShowHeaderMessage) {
        size= CGSizeMake(self.view.bounds.size.width, 60);
    }else {
        size= CGSizeMake(self.view.bounds.size.width, 25);
    }
    return size;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize size= CGSizeMake(self.view.bounds.size.width, 15);
    return size;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader){

        CollectionReusableHeaderView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headView.title = [DataManager shareDataManager].titleArray[indexPath.section];
        if (indexPath.section == 0&&[DataManager shareDataManager].isShowHeaderMessage) {
            headView.isShowMessage = YES;
        }else if(indexPath.section == 0&& ![DataManager shareDataManager].isShowHeaderMessage) {
            headView.isShowMessage = NO;
        }else {
            headView.isShowMessage = NO;
        }

        reusableView = headView;
        
    }else if (kind == UICollectionElementKindSectionFooter){
        CollectionReusableFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        if (indexPath.section == 0) {
            footerView.isShowTopLine = YES;
            footerView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
        }else {
            footerView.backgroundColor = [UIColor whiteColor];
            footerView.isShowTopLine = NO;

        }
        reusableView = footerView;
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(Cell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    if (cell.data.isNewAdd &&indexPath.section == 0) {
        cell.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView animateWithDuration:0.2 animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            cell.data.isNewAdd = NO;
        }];
    }
}

#pragma mark - <DragCellCollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    

}

- (void)dragCellCollectionView:(DragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    self.sourceManager.dataArray = newDataArray.mutableCopy;
}

- (void)dragCellCollectionView:(DragCellCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath{
    //拖动时候最后禁用掉编辑按钮的点击
    _editButton.enabled = NO;
}

- (void)dragCellCollectionViewCellEndMoving:(DragCellCollectionView *)collectionView{
    _editButton.enabled = YES;
}




@end
