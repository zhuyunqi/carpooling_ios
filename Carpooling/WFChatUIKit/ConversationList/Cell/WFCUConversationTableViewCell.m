//
//  ConversationTableViewCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationTableViewCell.h"
#import "WFCUUtilities.h"
#import <WFChatClient/WFCChatClient.h>
#import "SDWebImage.h"
#import "SAMKeychain.h"


@implementation WFCUConversationTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
  
- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
  [self.potraitView sd_setImageWithURL:[NSURL URLWithString:userInfo.portrait] placeholderImage: [UIImage imageNamed:@"messege_no_icon"]];
  
    if (userInfo.friendAlias.length) {
        self.targetView.text = userInfo.friendAlias;
    } else if(userInfo.displayName.length > 0) {
        if (userInfo.extra.length > 0) {
            self.targetView.text = userInfo.extra;
        }
        else {
            if ([[WFCCIMService sharedWFCIMService] isMyFriend:userInfo.userId]) {
                self.targetView.text = userInfo.displayName;
            }
            else {
                if ([userInfo.displayName containsString:@"stranger"]) {
                    self.targetView.text = userInfo.displayName;
                }
                else {
                    NSString *displayName = [userInfo.displayName substringToIndex:3];
                    self.targetView.text = [NSString stringWithFormat:@"%@...", displayName];
                }
            }
        }
        
    } else {
        self.targetView.text = [NSString stringWithFormat:@"user<%@>", self.info.conversation.target];
    }
}

- (void)updateChannelInfo:(WFCCChannelInfo *)channelInfo {
    [self.potraitView sd_setImageWithURL:[NSURL URLWithString:channelInfo.portrait] placeholderImage:[UIImage imageNamed:@"channel_default_portrait"]];
    
    if(channelInfo.name.length > 0) {
        self.targetView.text = channelInfo.name;
    } else {
        self.targetView.text = [NSString stringWithFormat:@"Channel<%@>", self.info.conversation.target];
    }
}

- (void)updateGroupInfo:(WFCCGroupInfo *)groupInfo {
  [self.potraitView sd_setImageWithURL:[NSURL URLWithString:groupInfo.portrait] placeholderImage:[UIImage imageNamed:@"group_default_portrait"]];
  
  if(groupInfo.name.length > 0) {
    self.targetView.text = groupInfo.name;
  } else {
    self.targetView.text = [NSString stringWithFormat:@"group<%@>", self.info.conversation.target];
  }
}

- (void)setSearchInfo:(WFCCConversationSearchInfo *)searchInfo {
    _searchInfo = searchInfo;
    self.bubbleView.hidden = YES;
    self.timeView.hidden = YES;
    [self update:searchInfo.conversation];
    if (searchInfo.marchedCount > 1) {
        self.digestView.text = [NSString stringWithFormat:@"%d%@", searchInfo.marchedCount, kLocalizedTableString(@"Message", @"CPLocalizable")];
    } else {
        NSString *strContent = searchInfo.marchedMessage.digest;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:strContent];
        NSRange range = [strContent rangeOfString:searchInfo.keyword options:NSCaseInsensitiveSearch];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
        self.digestView.attributedText = attrStr;
    }
    [self separator];
}

- (void)setInfo:(WFCCConversationInfo *)info {
    _info = info;
    if (info.unreadCount.unread == 0) {
        self.bubbleView.hidden = YES;
    } else {
        self.bubbleView.hidden = NO;
        if (info.isSilent) {
            self.bubbleView.isShowNotificationNumber = NO;
        } else {
            self.bubbleView.isShowNotificationNumber = YES;
        }
        [self.bubbleView setBubbleTipNumber:info.unreadCount.unread];
    }
    
    if (info.isSilent) {
        self.silentView.hidden = NO;
    } else {
        _silentView.hidden = YES;
    }
  
    [self update:info.conversation];
    self.timeView.hidden = NO;
    self.timeView.text = [WFCUUtilities formatTimeLabel:info.timestamp];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        if (info.isTop) {
            UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f];
                }
                else {
                    return [UIColor tertiarySystemBackgroundColor];
                }
            }];
            [self.contentView setBackgroundColor:dyColor2];
        } else {
            [self.contentView setBackgroundColor:dyColor];
        }
        
    } else {
        // Fallback on earlier versions
        if (info.isTop) {
            [self.contentView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.f]];
        } else {
            [self.contentView setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    
    if (info.lastMessage && info.lastMessage.direction == MessageDirection_Send) {
        if (info.lastMessage.status == Message_Status_Sending) {
            self.statusView.image = [UIImage imageNamed:@"conversation_message_sending"];
            self.statusView.hidden = NO;
        } else if(info.lastMessage.status == Message_Status_Send_Failure) {
            self.statusView.image = [UIImage imageNamed:@"MessageSendError"];
            self.statusView.hidden = NO;
        } else {
            self.statusView.hidden = YES;
        }
    } else {
        self.statusView.hidden = YES;
    }
    [self updateDigestFrame:!self.statusView.hidden];
    
    [self separator];
}

- (void)updateDigestFrame:(BOOL)isSending {
    if (isSending) {
        _digestView.frame = CGRectMake(16 + 48 + 12 + 18, 40, [UIScreen mainScreen].bounds.size.width - 76 - 16 - 16 - 18, 19);
    } else {
        _digestView.frame = CGRectMake(16 + 48 + 12, 40, [UIScreen mainScreen].bounds.size.width - 76 - 16 - 16, 19);
    }
}
- (void)update:(WFCCConversation *)conversation {
    if(conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:conversation.target refresh:NO];
        if(userInfo.userId.length == 0) {
            userInfo = [[WFCCUserInfo alloc] init];
            userInfo.userId = conversation.target;
        }
        [self updateUserInfo:userInfo];
    } else if (conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:conversation.target refresh:NO];
        if(groupInfo.target.length == 0) {
            groupInfo = [[WFCCGroupInfo alloc] init];
            groupInfo.target = conversation.target;
        }
        [self updateGroupInfo:groupInfo];
        
    } else if(conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:conversation.target refresh:NO];
        if (channelInfo.channelId.length == 0) {
            channelInfo = [[WFCCChannelInfo alloc] init];
            channelInfo.channelId = conversation.target;
        }
        [self updateChannelInfo:channelInfo];
    } else {
        self.targetView.text = [NSString stringWithFormat:@"chatroom<%@>", conversation.target];
    }
    
    self.potraitView.layer.cornerRadius = 4.f;
    
    if (_info.draft.length) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"[草稿]" attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
        
        NSError *__error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[_info.draft dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:kNilOptions
                                                                     error:&__error];
        
        BOOL hasMentionInfo = NO;
        NSString *text = nil;
        if (!__error) {
            if (dictionary[@"text"] != nil && [dictionary[@"mentions"] isKindOfClass:[NSArray class]]) {
                hasMentionInfo = YES;
                text = dictionary[@"text"];
            }
        }
        if (text != nil) {
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
        } else {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:_info.draft]];
        }
        self.digestView.attributedText = attString;
    } else if (_info.lastMessage.direction == MessageDirection_Receive && (_info.conversation.type == Group_Type || _info.conversation.type == Channel_Type)) {
        NSString *groupId = nil;
        if (_info.conversation.type == Group_Type) {
            groupId = _info.conversation.target;
        }
        WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:_info.lastMessage.fromUser inGroup:groupId refresh:NO];
        if (sender.friendAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.friendAlias, _info.lastMessage.digest];
        } else if (sender.groupAlias.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.groupAlias, _info.lastMessage.digest];
        } else if (sender.displayName.length && ![_info.lastMessage.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
            self.digestView.text = [NSString stringWithFormat:@"%@:%@", sender.displayName, _info.lastMessage.digest];
        } else {
            self.digestView.text = _info.lastMessage.digest;
        }
        
    } else {
        if ([[_info.lastMessage.content class] getContentType] == MESSAGE_CONTENT_TYPE_RIDING_STATUS_TIP) {
            WFCCRidingStatusNotificationMessageContent *carriageContent = (WFCCRidingStatusNotificationMessageContent *)_info.lastMessage.content;
            if (carriageContent.carriageStatus == 0) {
                //
            }
            else if (carriageContent.carriageStatus == 1) {
                self.digestView.text = kLocalizedTableString(@"Already On Car", @"CPLocalizable");
            }
            else if (carriageContent.carriageStatus == 2) {
                if (_info.lastMessage.direction == MessageDirection_Send) {
                    self.digestView.text = kLocalizedTableString(@"Me Already Arrive", @"CPLocalizable");
                }
                else if (_info.lastMessage.direction == MessageDirection_Receive) {
                    self.digestView.text = kLocalizedTableString(@"Other Already Arrive", @"CPLocalizable");
                }
            }
        }
        
        else if ([[_info.lastMessage.content class] getContentType] == MESSAGE_CONTENT_TYPE_CONTRACT_ATTITUDE_TIP) {// contract attitude result
            WFCCContractAttitudeTipPushNotificationMessageContent *contractAttitudeContent = (WFCCContractAttitudeTipPushNotificationMessageContent *)_info.lastMessage.content;
            if (contractAttitudeContent.contractAttitude == 0) {
                //
                self.digestView.text = _info.lastMessage.digest;
            }
            else if (contractAttitudeContent.contractAttitude == 1) {
                self.digestView.text = kLocalizedTableString(@"Already Agree Contract", @"CPLocalizable");
            }
            else if (contractAttitudeContent.contractAttitude == 2) {
                self.digestView.text = kLocalizedTableString(@"Already Reject Contract", @"CPLocalizable");
            }
            
        }
        else if ([[_info.lastMessage.content class] getContentType] == MESSAGE_CONTENT_TYPE_CONTRACT || [[_info.lastMessage.content class] getContentType] == MESSAGE_CONTENT_TYPE_CONTRACTHASSEND_TIP) {
            if (_info.lastMessage.direction == MessageDirection_Send) {
                self.digestView.text = kLocalizedTableString(@"waitingforreply", @"CPLocalizable");
            }
            else if (_info.lastMessage.direction == MessageDirection_Receive) {
                self.digestView.text = kLocalizedTableString(@"MessageTypeSendContract", @"CPLocalizable");
            }

        }
        else if ([[_info.lastMessage.content class] getContentType] == MESSAGE_CONTENT_TYPE_ADDFRIEND) {
            self.digestView.text = kLocalizedTableString(@"MessageTypeAddFriend", @"CPLocalizable");
        }
        else if ([[_info.lastMessage.content class] getContentType] == MESSAGE_CONTENT_TYPE_REALTIMELOCATION_TIP) {
            WFCCRealtimeLocationNotificationMessageContent *realtimeLocationTipContent = (WFCCRealtimeLocationNotificationMessageContent *)_info.lastMessage.content;
            if (realtimeLocationTipContent.shareLocationStatus == 0) {
                //
                if (_info.lastMessage.direction == MessageDirection_Send) {
                    self.digestView.text = kLocalizedTableString(@"send Realtime Location Start tip", @"CPLocalizable");
                }
                else if (_info.lastMessage.direction == MessageDirection_Receive) {
                    self.digestView.text = kLocalizedTableString(@"receive Realtime Location Start tip", @"CPLocalizable");
                }
            }
            else if (realtimeLocationTipContent.shareLocationStatus == 1) {
                if (_info.lastMessage.direction == MessageDirection_Send) {
                    self.digestView.text = kLocalizedTableString(@"send Realtime Location End tip", @"CPLocalizable");
                }
                else if (_info.lastMessage.direction == MessageDirection_Receive) {
                    self.digestView.text = kLocalizedTableString(@"receive Realtime Location End tip", @"CPLocalizable");
                }
            }

        }
        else {
            NSString *str = _info.lastMessage.digest;
            if ([str containsString:@"That's the greeting message"]) {
                NSArray *languages = [NSLocale preferredLanguages];
                NSString *systemLanguage = @"";
                if (languages.count>0) {
                    systemLanguage = languages.firstObject;
                }
                NSString *currentLanguage = [[BWLocalizableHelper shareInstance] currentLanguage];
                
                if ([currentLanguage isEqualToString:systemLanguage]) {
                    self.digestView.text = kLocalizedTableString(@"greeting message", @"CPLocalizable");
                }
                else if ([currentLanguage isEqualToString:@"zh-Hans-CN"]) {
                    self.digestView.text = @"以上是打招呼消息";
                }
                else if ([currentLanguage isEqualToString:@"en-CN"]) {
                    self.digestView.text = @"That's the greeting message.";
                }
            }
            else if ([str containsString:@"You've become good friends"]) {
                NSArray *languages = [NSLocale preferredLanguages];
                NSString *systemLanguage = @"";
                if (languages.count>0) {
                    systemLanguage = languages.firstObject;
                }
                NSString *currentLanguage = [[BWLocalizableHelper shareInstance] currentLanguage];
                if ([currentLanguage isEqualToString:systemLanguage]) {
                    self.digestView.text = kLocalizedTableString(@"Addfriend Result agree", @"CPLocalizable");
                }
                else if ([currentLanguage isEqualToString:@"zh-Hans-CN"]) {
                    self.digestView.text = @"你们现在是好友啦";
                }
                else if ([currentLanguage isEqualToString:@"en-CN"]) {
                    self.digestView.text = @"You've become good friends";
                }
            }
            else {
                self.digestView.text = _info.lastMessage.digest;
            }
        }
    }
}

- (UIImageView *)potraitView {
    if (!_potraitView) {
        _potraitView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 48, 48)];
        _potraitView.clipsToBounds = YES;
        _potraitView.layer.cornerRadius = 8.f;
        [self.contentView addSubview:_potraitView];
    }
    return _potraitView;
}

- (UIImageView *)statusView {
    if (!_statusView) {
        _statusView = [[UIImageView alloc] initWithFrame:CGRectMake(16 + 48 + 12, 42, 16, 16)];
        _statusView.image = [UIImage imageNamed:@"conversation_message_sending"];
        [self.contentView addSubview:_statusView];
    }
    return _statusView;
}

- (UILabel *)targetView {
    if (!_targetView) {
        _targetView = [[UILabel alloc] initWithFrame:CGRectMake(16 + 48 + 12, 16, [UIScreen mainScreen].bounds.size.width - 76  - 68, 20)];
        _targetView.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_targetView];
    }
    return _targetView;
}

- (UILabel *)digestView {
    if (!_digestView) {
        _digestView = [[UILabel alloc] initWithFrame:CGRectMake(16 + 48 + 12, 40, [UIScreen mainScreen].bounds.size.width - 76  - 16 - 16, 19)];
        _digestView.font = [UIFont systemFontOfSize:14];
        _digestView.lineBreakMode = NSLineBreakByTruncatingTail;
        _digestView.textColor = [UIColor grayColor];
        [self.contentView addSubview:_digestView];
    }
    return _digestView;
}

- (UIImageView *)silentView {
    if (!_silentView) {
        _silentView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 12  - 20, 45, 12, 12)];
        _silentView.image = [UIImage imageNamed:@"conversation_mute"];
        [self.contentView addSubview:_silentView];
    }
    return _silentView;
}

- (UILabel *)timeView {
    if (!_timeView) {
        _timeView = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 52  - 16, 20, 52, 12)];
        _timeView.font = [UIFont systemFontOfSize:11];
        _timeView.textAlignment = NSTextAlignmentRight;
        _timeView.textColor = [UIColor grayColor];
        [self.contentView addSubview:_timeView];
    }

    return _timeView;
}

- (BubbleTipView *)bubbleView {
    if (!_bubbleView) {
        if(self.potraitView) {
            _bubbleView = [[BubbleTipView alloc] initWithParentView:self.contentView];
            _bubbleView.hidden = YES;
        }
    }
    return _bubbleView;
}

- (UIView *)separator {
    if (!_separator) {
        _separator = [[UIView alloc] initWithFrame:CGRectMake(76, 71.5, [UIScreen mainScreen].bounds.size.width-76, 0.5)];
        
        if (@available(iOS 13.0, *)) {
            UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1];
                }
                else {
                    return [UIColor systemBackgroundColor];
                }
            }];
            [_separator setBackgroundColor:dyColor];
            
        } else {
            // Fallback on earlier versions
            [_separator setBackgroundColor:[UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1]];
        }
        
        
        [self.contentView addSubview:_separator];
    }
    return _separator;
}
@end
