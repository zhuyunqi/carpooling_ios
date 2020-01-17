//
//  InformationCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUInformationCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUUtilities.h"


#define TEXT_TOP_PADDING 6
#define TEXT_BUTTOM_PADDING 6
#define TEXT_LEFT_PADDING 8
#define TEXT_RIGHT_PADDING 8


#define TEXT_LABEL_TOP_PADDING TEXT_TOP_PADDING + 4
#define TEXT_LABEL_BUTTOM_PADDING TEXT_BUTTOM_PADDING + 4
#define TEXT_LABEL_LEFT_PADDING 30
#define TEXT_LABEL_RIGHT_PADDING 30

@implementation WFCUInformationCell

+ (CGSize)sizeForCell:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    CGFloat height = [super hightForTimeLabel:msgModel];
    NSString *infoText;
    if ([msgModel.message.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
        WFCCNotificationMessageContent *content = (WFCCNotificationMessageContent *)msgModel.message.content;
        infoText = [content formatNotification:msgModel.message];
    } else {
        infoText = [msgModel.message digest];
    }
    CGSize size = [WFCUUtilities getTextDrawingSize:infoText font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width - TEXT_LABEL_LEFT_PADDING - TEXT_LABEL_RIGHT_PADDING - TEXT_LEFT_PADDING - TEXT_RIGHT_PADDING, 8000)];
    size.height += TEXT_LABEL_TOP_PADDING + TEXT_LABEL_BUTTOM_PADDING + TEXT_TOP_PADDING + TEXT_BUTTOM_PADDING;
    size.height += height;
    if ([[msgModel.message.content class] getContentType] == MESSAGE_CONTENT_TYPE_CONTRACTHASSEND_TIP) {
        if (msgModel.message.direction == MessageDirection_Receive) {
            return CGSizeMake(width, 0);
        }
    }
    
    return CGSizeMake(width, size.height);
}

- (void)setModel:(WFCUMessageModel *)model {
    [super setModel:model];
    
    NSString *infoText;
    if ([model.message.content isKindOfClass:[WFCCNotificationMessageContent class]]) {
        WFCCNotificationMessageContent *content = (WFCCNotificationMessageContent *)model.message.content;
        
        if ([[content class] getContentType] == MESSAGE_CONTENT_TYPE_RIDING_STATUS_TIP) {
            WFCCRidingStatusNotificationMessageContent *carriageContent = (WFCCRidingStatusNotificationMessageContent *)content;
            if (carriageContent.carriageStatus == 0) {
                //
            }
            else if (carriageContent.carriageStatus == 1) {
                infoText = kLocalizedTableString(@"Already On Car", @"CPLocalizable");
            }
            else if (carriageContent.carriageStatus == 2) {
                if (model.message.direction == MessageDirection_Send) {
                    infoText = kLocalizedTableString(@"Me Already Arrive", @"CPLocalizable");
                }
                else if (model.message.direction == MessageDirection_Receive) {
                    infoText = kLocalizedTableString(@"Other Already Arrive", @"CPLocalizable");
                }
            }
        }
        else if ([[content class] getContentType] == MESSAGE_CONTENT_TYPE_CONTRACTHASSEND_TIP) {// contract has send
            if (model.message.direction == MessageDirection_Send) {
                infoText = kLocalizedTableString(@"waitingforreply", @"CPLocalizable");
            }
            else if (model.message.direction == MessageDirection_Receive) {
                infoText = kLocalizedTableString(@"MessageTypeSendContract", @"CPLocalizable");
            }

        }
        else if ([[content class] getContentType] == MESSAGE_CONTENT_TYPE_CONTRACT_ATTITUDE_TIP) {// contract attitude result
            WFCCContractAttitudeTipPushNotificationMessageContent *contractAttitudeContent = (WFCCContractAttitudeTipPushNotificationMessageContent *)content;

            if (contractAttitudeContent.contractAttitude == 1) {
                infoText = kLocalizedTableString(@"Already Agree Contract", @"CPLocalizable");
            }
            else if (contractAttitudeContent.contractAttitude == 2) {
                infoText = kLocalizedTableString(@"Already Reject Contract", @"CPLocalizable");
            }

        }
        else if ([[content class] getContentType] == MESSAGE_CONTENT_TYPE_REALTIMELOCATION_TIP) {// realtime Location Notification
            WFCCRealtimeLocationNotificationMessageContent *realtimeLocationTipContent = (WFCCRealtimeLocationNotificationMessageContent *)content;
            if (realtimeLocationTipContent.shareLocationStatus == 0) {
                //
                if (model.message.direction == MessageDirection_Send) {
                    infoText = kLocalizedTableString(@"send Realtime Location Start tip", @"CPLocalizable");
                }
                else if (model.message.direction == MessageDirection_Receive) {
                    infoText = kLocalizedTableString(@"receive Realtime Location Start tip", @"CPLocalizable");
                }
            }
            else if (realtimeLocationTipContent.shareLocationStatus == 1) {
                if (model.message.direction == MessageDirection_Send) {
                    infoText = kLocalizedTableString(@"send Realtime Location End tip", @"CPLocalizable");
                }
                else if (model.message.direction == MessageDirection_Receive) {
                    infoText = kLocalizedTableString(@"receive Realtime Location End tip", @"CPLocalizable");
                }
            }

        }
        else {
            NSString *str = [content formatNotification:model.message];
            if ([str containsString:@"That's the greeting message"]) {
                NSArray *languages = [NSLocale preferredLanguages];
                NSString *systemLanguage = @"";
                if (languages.count > 0) {
                    systemLanguage = languages.firstObject;
                }
                NSString *currentLanguage = [[BWLocalizableHelper shareInstance] currentLanguage];
                
                if ([currentLanguage isEqualToString:systemLanguage]) {
                    infoText = kLocalizedTableString(@"greeting message", @"CPLocalizable");
                }
                else if ([currentLanguage isEqualToString:@"zh-Hans-CN"]) {
                    infoText = @"以上是打招呼消息";
                }
                else if ([currentLanguage isEqualToString:@"en-CN"]) {
                    infoText = @"That's the greeting message.";
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
                     infoText = kLocalizedTableString(@"Addfriend Result agree", @"CPLocalizable");
                }
                else if ([currentLanguage isEqualToString:@"zh-Hans-CN"]) {
                    infoText = @"你们现在是好友啦";
                }
                else if ([currentLanguage isEqualToString:@"en-CN"]) {
                    infoText = @"You've become good friends";
                }
            }
            else {
                infoText = [content formatNotification:model.message];
            }
        }
        
    } else {
        infoText = [model.message digest];
    }
    
    CGFloat width = self.contentView.bounds.size.width;
    
    CGSize size = [WFCUUtilities getTextDrawingSize:infoText font:[UIFont systemFontOfSize:14] constrainedSize:CGSizeMake(width - TEXT_LABEL_LEFT_PADDING - TEXT_LABEL_RIGHT_PADDING - TEXT_LEFT_PADDING - TEXT_RIGHT_PADDING, 8000)];
    
    
    self.infoLabel.text = infoText;
    self.infoLabel.layoutMargins = UIEdgeInsetsMake(TEXT_TOP_PADDING, TEXT_LEFT_PADDING, TEXT_BUTTOM_PADDING, TEXT_RIGHT_PADDING);
    CGFloat timeLableEnd = 0;
    if (!self.timeLabel.hidden) {
        timeLableEnd = self.timeLabel.frame.size.height + self.timeLabel.frame.origin.y;
    }
    self.infoLabel.frame = CGRectMake((width - size.width)/2 - 8, timeLableEnd + TEXT_LABEL_TOP_PADDING, size.width + 16, size.height + TEXT_TOP_PADDING + TEXT_BUTTOM_PADDING);
//    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([[model.message.content class] getContentType] == MESSAGE_CONTENT_TYPE_CONTRACTHASSEND_TIP) {// contract has send
        if (model.message.direction == MessageDirection_Receive) {
            self.infoLabel.frame = CGRectZero;
        }
    }

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
        
        [self.contentView addSubview:_infoLabel];
    }
    return _infoLabel; 
}
@end
