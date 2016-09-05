//
//  CollectionReusableFooterView.m
//  CollectionViewDemo
//
//  Created by lizq on 16/9/5.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "CollectionReusableFooterView.h"

@interface CollectionReusableFooterView ()
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *topView;

@end

@implementation CollectionReusableFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
        self.bottomView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self addSubview:self.bottomView];

    }
    return self;
}
- (UIView *)topView {
    if (_topView == nil) {
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        self.topView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    return _topView;
}

- (void)setIsShowTopLine:(BOOL)isShowTopLine {
    if (isShowTopLine) {
        [self addSubview:self.topView];
    }else {
        [self.topView removeFromSuperview];
    }

}

@end
