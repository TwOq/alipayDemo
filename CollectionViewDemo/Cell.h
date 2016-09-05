//
//  XWCell.h
//  PanCollectionView
//
//  Created by lizq on 16/8/31.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellModel.h"
#import "ExternStringDefine.h"

@class CellModel;

@interface Cell : UICollectionViewCell

@property (nonatomic, strong) CellModel *data;

- (void)resetModel:(CellModel *)data :(NSIndexPath *)indexPath;

@end
