//
//  CollectionReusableHeaderView.h
//  CollectionViewDemo
//
//  Created by lizq on 16/9/5.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionReusableHeaderView : UICollectionReusableView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL isShowMessage;


@end
