
//
//  Cell.m
//  PanCollectionView
//
//  Created by lizq on 16/8/31.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "Cell.h"
#import "DataManager.h"

@interface Cell ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (nonatomic, strong) NSIndexPath *indexPath;


@end

@implementation Cell

- (void)resetModel:(CellModel *)data :(NSIndexPath *)indexPath {
    self.layer.borderColor = [UIColor colorWithWhite:0.95 alpha:1].CGColor;
    self.layer.borderWidth =  1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeButtonState:) name:notification_CellBeganEditing object:nil];
    self.data = data;
    self.label.text = data.title;
    self.indexPath = indexPath;
    self.backgroundColor = data.backGroundColor;
    if ([DataManager shareDataManager].isEditing) {
        self.stateButton.hidden = NO;
        [self showStateButton];
    }else{
        self.stateButton.hidden = YES;
    }
}


- (void)showStateButton {
    switch (self.data.state) {
        case ServeAdd:
            self.stateButton.enabled = YES;
            [self.stateButton setImage:[UIImage imageNamed:@"app_add"] forState:UIControlStateNormal];
            break;
        case ServeSelected:
            if (self.indexPath.section == 0) {
                self.stateButton.enabled = YES;
                [self.stateButton setImage:[UIImage imageNamed:@"app_del"] forState:UIControlStateNormal];

            }else {
                if ([[DataManager shareDataManager].headArray containsObject:self.data]) {
                    self.stateButton.enabled = NO;
                    [self.stateButton setImage:[UIImage imageNamed:@"app_ok"] forState:UIControlStateNormal];

                }else{
                    self.stateButton.enabled = YES;
                    [self.stateButton setImage:[UIImage imageNamed:@"app_add"] forState:UIControlStateNormal];
                }
            }
            break;
    }
}


- (void)changeButtonState:(NSNotification *)notification {
    NSString *string = notification.object;
    if ([string isEqualToString:@"yes"]) {
        self.stateButton.hidden = NO;
        [self showStateButton];
        self.stateButton.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:0.1 animations:^{
            self.stateButton.transform = CGAffineTransformIdentity;
        }];
    }else{

        [UIView animateWithDuration:0.1 animations:^{
            self.stateButton.transform = CGAffineTransformMakeScale(0.001, 0.001);
        } completion:^(BOOL finished) {
            self.stateButton.transform = CGAffineTransformIdentity;
            self.stateButton.hidden = YES;
        }];
    }
}


- (IBAction)buttonClick:(UIButton *)sender {
    sender.enabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:notification_CellStateChange object:self];

}

@end
