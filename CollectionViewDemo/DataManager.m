//
//  DataManager.m
//  PanCollectionView
//
//  Created by lizq on 16/8/31.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "DataManager.h"
#import <UIKit/UIKit.h>
#import "CellModel.h"
static DataManager *data = nil;
@implementation DataManager


+(DataManager *)shareDataManager {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[DataManager alloc] init];
    });
    return data;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isEditing = NO;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TitleList" ofType:@"plist"];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];

        NSMutableArray *temp = @[].mutableCopy;
        self.titleArray = @[].mutableCopy;
        [self.titleArray addObject:@"我的应用"];
        for (int i = 0; i < array.count; i ++) {
            NSMutableArray *tempSection = @[].mutableCopy;
            NSDictionary *dic = array[i];
            NSArray *listArray = dic[@"list"];
            [self.titleArray addObject:dic[@"title"]];
            for (int j = 0; j < listArray.count; j ++) {
                CellModel *model = [CellModel new];
                model.state = ServeAdd;
                model.isNewAdd = NO;
                model.backGroundColor = [UIColor whiteColor];
                model.title = listArray[j];
                [tempSection addObject:model];
            }
            [temp addObject:tempSection.copy];
        }
        NSMutableArray *sectionOne = @[].mutableCopy;
        for (int i = 0; i < 3; i++) {
            CellModel *model = temp[0][i];
            model.state = ServeSelected;
            [sectionOne addObject:model];
        }

        [temp insertObject:sectionOne atIndex:0];
        self.headArray = [NSMutableArray arrayWithArray:temp[0]];
        self.dataArray = temp.mutableCopy;
    }

    return self;
}

@end
