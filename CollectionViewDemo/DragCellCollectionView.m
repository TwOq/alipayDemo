//
//  XWDragCellCollectionView.m
//  PanCollectionView
//
//  Created by lizq on 16/8/31.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "DragCellCollectionView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Cell.h"
#import "DataManager.h"
#import "ExternStringDefine.h"

#define angelToRandian(x)  ((x)/180.0*M_PI)

@interface DragCellCollectionView ()
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) UICollectionViewCell *dragCell;
@property (nonatomic, assign) BOOL isDeleteItem;


@end

@implementation DragCellCollectionView

@dynamic delegate;
@dynamic dataSource;

#pragma mark - initailize methods

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initializeProperty];
        [self addGesture];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handelCellClick:) name:notification_CellStateChange object:nil];

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeProperty];
        [self addGesture];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handelCellClick:) name:notification_CellStateChange object:nil];
    }
    return self;
}

- (void)initializeProperty{
    _minimumPressDuration = 1;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

#pragma mark - longPressGesture methods

/**
 *  添加一个自定义的滑动手势
 */
- (void)addGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    _longPressGesture = longPress;
    longPress.minimumPressDuration = _minimumPressDuration;
    [self addGestureRecognizer:longPress];
}

/**
 *  监听手势的改变
 */
- (void)longPressed:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        self.isDeleteItem = NO;
        if (!self.beginEditing) {
            self.beginEditing = YES;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.11 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self gestureBegan:longPressGesture];
        });
    }
    if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        if (_originalIndexPath.section != 0) {
            return;
        }
        [self gestureChange:longPressGesture];
        [self moveCell];
    }
    if (longPressGesture.state == UIGestureRecognizerStateCancelled ||
        longPressGesture.state == UIGestureRecognizerStateEnded){
            [self handelItemInSpace];
        if (!self.isDeleteItem) {
            [self gestureEndOrCancle:longPressGesture];
        }
    }
}

/**
 *  手势开始
 */
- (void)gestureBegan:(UILongPressGestureRecognizer *)longPressGesture{

    _originalIndexPath = [self indexPathForItemAtPoint:[longPressGesture locationOfTouch:0 inView:longPressGesture.view]];
    if (_originalIndexPath.section == 0) {
        //获取手指所在的cell
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
        self.dragCell = cell;
        UIView *tempMoveCell = [cell snapshotViewAfterScreenUpdates:NO];
        cell.hidden = YES;
        _tempMoveCell = tempMoveCell;
        _tempMoveCell.frame = cell.frame;
        _tempMoveCell.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [self addSubview:_tempMoveCell];
        _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];

    }

    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:cellWillBeginMoveAtIndexPath:)]) {
        [self.delegate dragCellCollectionView:self cellWillBeginMoveAtIndexPath:_originalIndexPath];
    }
}
/**
 *  手势拖动
 */
- (void)gestureChange:(UILongPressGestureRecognizer *)longPressGesture{
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellisMoving:)]) {
        [self.delegate dragCellCollectionViewCellisMoving:self];
    }
    CGFloat tranX = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].x - _lastPoint.x;
    CGFloat tranY = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].y - _lastPoint.y;
    _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
}

/**
 *  手势取消或者结束
 */
- (void)gestureEndOrCancle:(UILongPressGestureRecognizer *)longPressGesture{
    self.userInteractionEnabled = NO;
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellEndMoving:)]) {
        [self.delegate dragCellCollectionViewCellEndMoving:self];
    }
    [UIView animateWithDuration:0.25 animations:^{
        _tempMoveCell.center = self.dragCell.center;
    } completion:^(BOOL finished) {
        [_tempMoveCell removeFromSuperview];
        self.dragCell.hidden = NO;
        self.userInteractionEnabled = YES;
    }];
}

#pragma mark - setter methods

- (void)setMinimumPressDuration:(NSTimeInterval)minimumPressDuration{
    _minimumPressDuration = minimumPressDuration;
    _longPressGesture.minimumPressDuration = minimumPressDuration;
}



#pragma mark - private methods

- (void)moveCell{


    for (UICollectionViewCell *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == _originalIndexPath) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            _moveIndexPath = [self indexPathForCell:cell];
            if (_moveIndexPath.section != 0) {
                return;
            }
            //更新数据源
            [self updateDataSource];
            //移动
            [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            //通知代理
            if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:moveCellFromIndexPath:toIndexPath:)]) {
                [self.delegate dragCellCollectionView:self moveCellFromIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            }
            //设置移动后的起始indexPath
            _originalIndexPath = _moveIndexPath;
        }
    }
}

#pragma mark 处理当手势停止在空白处

- (void)handelItemInSpace {

    NSArray *totalArray = [self findAllLastIndexPathInVisibleSection];
    //找到目标空白区域
    CGRect rect;
    _moveIndexPath = nil;
    for (NSIndexPath *indexPath in totalArray) {
        UICollectionViewCell *sectionLastCell = [self cellForItemAtIndexPath:indexPath];

        CGRect tempRect = CGRectMake(CGRectGetMaxX(sectionLastCell.frame),
                                     CGRectGetMinY(sectionLastCell.frame),
                                     self.frame.size.width - CGRectGetMaxX(sectionLastCell.frame),
                                     CGRectGetHeight(sectionLastCell.frame));
        //空白区域小于item款度(实际是item的列间隙)
        if (CGRectGetWidth(tempRect) < CGRectGetWidth(sectionLastCell.frame)) {
            continue;
        }
        if (CGRectContainsPoint(tempRect, _tempMoveCell.center)) {
            rect = tempRect;
            _moveIndexPath = indexPath;
            break;
        }
    }

    NSMutableArray *sourceArray = nil;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        sourceArray = [NSMutableArray arrayWithArray:[self.dataSource dataSourceArrayOfCollectionView:self]];
    }
    if (_moveIndexPath != nil) {
        [self moveItemToIndexPath:_moveIndexPath withSource:sourceArray];
    }else{
        _moveIndexPath = totalArray.lastObject;
        UICollectionViewCell *sectionLastCell = [self cellForItemAtIndexPath:_moveIndexPath];
        float spaceHeight =    (self.frame.size.height - CGRectGetMaxY(sectionLastCell.frame)) > CGRectGetHeight(sectionLastCell.frame)?
        (self.frame.size.height - CGRectGetMaxY(sectionLastCell.frame)):0;

        CGRect spaceRect = CGRectMake(0,
                                      CGRectGetMaxY(sectionLastCell.frame),
                                      self.frame.size.width,
                                      spaceHeight);

        if (spaceHeight != 0 && CGRectContainsPoint(spaceRect, _tempMoveCell.center)) {
            [self moveItemToIndexPath:_moveIndexPath withSource:sourceArray];
        }
    }
}

- (void)moveItemToIndexPath:(NSIndexPath *)indexPath withSource:(NSMutableArray *)array{
    if (_originalIndexPath.section == indexPath.section ){
        //同一分组
        if (_originalIndexPath.row != indexPath.row) {
            [self exchangeItemInSection:indexPath withSource:array];
        }else if (_originalIndexPath.row == indexPath.row){
            return;
        }
    }
}

//找出所有可视分组中最有一个item的位置

- (NSArray *)findAllLastIndexPathInVisibleSection {

    NSArray *array = [self indexPathsForVisibleItems];
    array = [array sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return obj1.section > obj2.section;
    }];
    NSMutableArray *totalArray = [NSMutableArray arrayWithCapacity:0];
    NSInteger tempSection = -1;
    NSMutableArray *tempArray = nil;

    for (NSIndexPath *indexPath in array) {
        if (tempSection != indexPath.section) {
            tempSection = indexPath.section;
            if (tempArray) {
                NSArray *temp = [tempArray sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
                    return obj1.row > obj2.row;
                }];
                [totalArray addObject:temp.lastObject];
            }
            tempArray = [NSMutableArray arrayWithCapacity:0];
        }
        [tempArray addObject:indexPath];
    }

    NSArray *temp = [tempArray sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return obj1.row > obj2.row;
    }];
    [totalArray addObject:temp.lastObject];
    return totalArray.copy;
}

#pragma mark 当选中item移动中被复用时，实时改变显示状态
- (void)refushOriginalCellHidenState {

    NSIndexPath *newIndexPath = [self indexPathForCell:self.dragCell];
    if (newIndexPath.section == _originalIndexPath.section ) {
        self.dragCell.hidden = YES;
    }else {
        self.dragCell.hidden = NO;
    }
}


#pragma mark 源item和目标位置在同一分组区域内
- (void)exchangeItemInSection:(NSIndexPath *)indexPath withSource:(NSMutableArray *)sourceArray{

    NSMutableArray *orignalSection = [NSMutableArray arrayWithArray:sourceArray[_originalIndexPath.section]];
    NSInteger currentRow = _originalIndexPath.row;
    NSInteger toRow = indexPath.row;
    [orignalSection exchangeObjectAtIndex:currentRow withObjectAtIndex:toRow];
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:newDataArrayAfterMove:)]) {
        [self.delegate dragCellCollectionView:self newDataArrayAfterMove:sourceArray.copy];
    }
    [self moveItemAtIndexPath:_originalIndexPath toIndexPath:indexPath];
}


- (void)handelCellClick:(NSNotification *)notification {

    Cell *cell = notification.object;
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    DataManager *manager = [DataManager shareDataManager];

    NSMutableArray *sourceArray = nil;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        sourceArray = [NSMutableArray arrayWithArray:[self.dataSource dataSourceArrayOfCollectionView:self]];
    }

    if (indexPath.section == 0) {
        NSMutableArray *orignalSection = [NSMutableArray arrayWithArray:sourceArray[indexPath.section]];
        [orignalSection removeObjectAtIndex:indexPath.row];
        sourceArray[indexPath.section] = orignalSection;

        [UIView animateWithDuration:0.2 animations:^{
            cell.transform = CGAffineTransformMakeScale(0.001, 0.001);

        } completion:^(BOOL finished) {
            [cell removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:newDataArrayAfterMove:)]) {
                [self.delegate dragCellCollectionView:self newDataArrayAfterMove:sourceArray];
                [self deleteItemsAtIndexPaths:@[indexPath]];
            }
            [manager.headArray removeObject:cell.data];
            if (manager.headArray.count == 0) {
                manager.isShowHeaderMessage = YES;
            }else {
                manager.isShowHeaderMessage = NO;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        }];

    }else{
        NSMutableArray *array = [NSMutableArray arrayWithArray:manager.dataArray[0]];
        [array addObject:cell.data];
        cell.data.state =  ServeSelected;
        cell.data.isNewAdd = YES;
        manager.dataArray[0] = array;
        [manager.headArray addObject:cell.data];

        if (manager.headArray.count == 0) {
            manager.isShowHeaderMessage = YES;
        }else {
            manager.isShowHeaderMessage = NO;
        }

        NSArray *indexPathArray = [self findAllLastIndexPathInVisibleSection];
        NSIndexPath *headLastIndexPath = nil;
        for (NSIndexPath *indexPath in indexPathArray) {
            if (indexPath.section == 0) {
                headLastIndexPath = indexPath;
            }
        }

        NSInteger num = array.count - 1;
        //假定每行显示4个cell
        NSInteger rowNumber = num %4;
        UIView *tempMoveCell = [cell snapshotViewAfterScreenUpdates:NO];
        tempMoveCell.center = cell.center;
        [self addSubview:tempMoveCell];

        UICollectionViewCell *lastCell = [self cellForItemAtIndexPath:headLastIndexPath];
        float width = self.frame.size.width / 4;
        CGPoint center = CGPointMake(width * rowNumber + width/2, CGRectGetMaxY(lastCell.frame));


        [UIView animateWithDuration:0.25 animations:^{
            tempMoveCell.center = center;
            tempMoveCell.transform = CGAffineTransformMakeScale(0.3, 0.3);
            tempMoveCell.alpha = 0.01;
        } completion:^(BOOL finished) {
            [tempMoveCell removeFromSuperview];
            [self reloadData];

        }];
    }
}


/**
 *  更新数据源
 */
- (void)updateDataSource{
    NSMutableArray *temp = @[].mutableCopy;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        [temp addObjectsFromArray:[self.dataSource dataSourceArrayOfCollectionView:self]];
    }
    //判断数据源是单个数组还是数组套数组的多section形式，YES表示数组套数组
    BOOL dataTypeCheck = ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    if (_moveIndexPath.section == _originalIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? temp[_originalIndexPath.section] : temp;
        if (_moveIndexPath.item > _originalIndexPath.item) {
            for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i ++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        }else{
            for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i --) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }

    }else{
        NSMutableArray *orignalSection = temp[_originalIndexPath.section];
        NSMutableArray *currentSection = temp[_moveIndexPath.section];
        [currentSection insertObject:orignalSection[_originalIndexPath.item] atIndex:_moveIndexPath.item];
        [orignalSection removeObject:orignalSection[_originalIndexPath.item]];
    }
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:newDataArrayAfterMove:)]) {
        [self.delegate dragCellCollectionView:self newDataArrayAfterMove:temp.copy];
    }
}



#pragma mark getter or setter 

- (void)setBeginEditing:(BOOL)beginEditing {

    [DataManager shareDataManager].isEditing = beginEditing;
    if (_beginEditing == beginEditing) {
        return;
    }
    _beginEditing = beginEditing;
    if (beginEditing) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notification_CellBeganEditing object:@"yes"];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:notification_CellBeganEditing object:@"no"];
    }
}



@end
