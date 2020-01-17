//
//  WFCUAddFriendCell.m
//  Carpooling
//
//  Created by bw on 2019/7/5.
//  Copyright © 2019 bw. All rights reserved.
//

#import "WFCUAddFriendCell.h"

@implementation WFCUAddFriendCell

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    WFCCAddFriendMessageContent *content = (WFCCAddFriendMessageContent *)msgModel.message.content;
    
    if (msgModel.message.direction == MessageDirection_Send) {
        return CGSizeMake(width*4/5+17, 50);
    }
    else if (msgModel.message.direction == MessageDirection_Receive) {
        if (content.status != 0) {
            return CGSizeMake(width*4/5+17, 50);
        }
        return CGSizeMake(width*4/5+17, 100);
    }
    return CGSizeMake(width*4/5+17, 100);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    WFCCAddFriendMessageContent *content = (WFCCAddFriendMessageContent *)model.message.content;
    CGRect rect = self.contentArea.bounds;
    rect.size.height -= 30;
    self.titleLbl.frame = rect;
    
    if (model.message.direction == MessageDirection_Send) {
        self.titleLbl.text = kLocalizedTableString(@"Add Friend Request send", @"CPLocalizable");
        self.ignoreButton.hidden = YES;
        self.agreeButton.hidden = YES;
        self.infoLabel.hidden = YES;

    }
    else if (model.message.direction == MessageDirection_Receive) {
//        self.titleLbl.text = content.desc;
        self.titleLbl.text = kLocalizedTableString(@"Other Request Add Friend", @"CPLocalizable");
        
        if (content.status != 0) {
            self.ignoreButton.hidden = YES;
            self.agreeButton.hidden = YES;
            
            if (content.status == 2) {
                self.infoLabel.frame = CGRectMake(self.contentArea.width/2, 20, 80, 28);
                self.infoLabel.text = kLocalizedTableString(@"Ignore", @"CPLocalizable");
            }
            
        }
        else {
            [self.ignoreButton setTitle:kLocalizedTableString(@"Attitude Ignore", @"CPLocalizable") forState:UIControlStateNormal];
            [self.agreeButton setTitle:kLocalizedTableString(@"Attitude Agree", @"CPLocalizable") forState:UIControlStateNormal];
            
            self.ignoreButton.hidden = NO;
            self.agreeButton.hidden = NO;
        }
    }
    
    [self.titleLbl sizeToFit];
}

- (UILabel *)titleLbl{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [UIFont systemFontOfSize:17.f];
        _titleLbl.numberOfLines = 0;
        _titleLbl.textAlignment = NSTextAlignmentLeft;
        _titleLbl.textColor = [UIColor blackColor];
        [self.contentArea addSubview:_titleLbl];
    }
    return _titleLbl;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.numberOfLines = 0;
        _infoLabel.font = [UIFont systemFontOfSize:14];
        
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.numberOfLines = 0;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = [UIFont systemFontOfSize:14.f];
        _infoLabel.layer.masksToBounds = YES;
        _infoLabel.layer.cornerRadius = 5.f;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.backgroundColor = [UIColor colorWithRed:201/255.f green:201/255.f blue:201/255.f alpha:1.f];
        
        [self.contentArea addSubview:_infoLabel];
    }
    return _infoLabel;
}

- (UIButton *)ignoreButton{
    if (!_ignoreButton) {
        _ignoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _ignoreButton.frame = CGRectMake(5, 50, 70, 40);
        _ignoreButton.backgroundColor = [UIColor colorWithRed:240/255.f green:72/255.f blue:117/255.f alpha:1];
        _ignoreButton.layer.cornerRadius = 10;
        _ignoreButton.layer.masksToBounds = YES;
        _ignoreButton.tag = 10000;
        [_ignoreButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentArea addSubview:_ignoreButton];
    }
    return _ignoreButton;
}


- (UIButton *)agreeButton{
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.frame = CGRectMake(CGRectGetMaxX(_ignoreButton.frame)+30, 50, 70, 40);
        _agreeButton.backgroundColor = [UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1];
        _agreeButton.layer.cornerRadius = 10;
        _agreeButton.layer.masksToBounds = YES;
        _agreeButton.tag = 10001;
        [_agreeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentArea addSubview:_agreeButton];
    }
    return _agreeButton;
}

-(void)buttonPressed:(UIButton *)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didAddFriend:withModel:withAgree:)]){
        BOOL agree = NO;
        if (sender.tag == 10001) {
            agree = YES;
        }
        [self.delegate didAddFriend:self withModel:self.model withAgree:agree];
    }
}

@end
