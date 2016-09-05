//
//  XWCellModel.h
//  PanCollectionView
//
//  Created by lizq on 16/8/31.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,ServeButtonStates) {
    ServeAdd = 0,
    ServeSelected
};


@interface CellModel : NSObject
@property (nonatomic, strong) UIColor *backGroundColor;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) ServeButtonStates state;
@property (nonatomic, assign) BOOL isSectionOne;
@property (nonatomic, assign) BOOL isNewAdd;




@end
