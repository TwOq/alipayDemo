//
//  CollectionReusableHeaderView.m
//  CollectionViewDemo
//
//  Created by lizq on 16/9/5.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "CollectionReusableHeaderView.h"

@interface CollectionReusableHeaderView ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *messageView;
@end

@implementation CollectionReusableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
           self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.bounds.size.width, 20)];
            self.label.font = [UIFont systemFontOfSize:15];
            self.label.tag = 200;
            [self addSubview:self.label];
            self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)setTitle:(NSString *)title {
    self.label.text = title;
}


- (void)setIsShowMessage:(BOOL)isShowMessage {
    if (isShowMessage) {
        [self addSubview:self.messageView];

        NSLog(@"添加");

    }else {
        [self.messageView removeFromSuperview];
        NSLog(@"移除");
    }

}

- (UITextView *)messageView {
    if (_messageView == nil) {
        self.messageView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.label.frame), self.bounds.size.width, 40)];
        self.messageView.textAlignment = NSTextAlignmentCenter;
        self.messageView.text = @"您还为添加任何应用\n长按下面的应用可以添加";
        self.messageView.font = [UIFont systemFontOfSize:12];

    }
    return _messageView;
}

@end
