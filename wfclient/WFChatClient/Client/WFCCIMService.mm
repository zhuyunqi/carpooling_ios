//
//  WFCCIMService.mm
//  WFChatClient
//
//  Created by heavyrain on 2017/11/5.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCIMService.h"
#import "WFCCMediaMessageContent.h"
#import <mars/proto/MessageDB.h>
#import <objc/runtime.h>
#import "WFCCNetworkService.h"
#import <mars/app/app.h>
#import "WFCCGroupSearchInfo.h"
#import "WFCCUnknownMessageContent.h"
#import "WFCCRecallMessageContent.h"


NSString *kSendingMessageStatusUpdated = @"kSendingMessageStatusUpdated";
NSString *kConnectionStatusChanged = @"kConnectionStatusChanged";
NSString *kReceiveMessages = @"kReceiveMessages";
NSString *kRecallMessages = @"kRecallMessages";

class IMSendMessageCallback : public mars::stn::SendMsgCallback {
private:
    void(^m_successBlock)(long long messageUid, long long timestamp);
    void(^m_errorBlock)(int error_code);
    void(^m_progressBlock)(long uploaded, long total);
    WFCCMessage *m_message;
public:
    IMSendMessageCallback(WFCCMessage *message, void(^successBlock)(long long messageUid, long long timestamp), void(^progressBlock)(long uploaded, long total), void(^errorBlock)(int error_code)) : mars::stn::SendMsgCallback(), m_message(message), m_successBlock(successBlock), m_progressBlock(progressBlock), m_errorBlock(errorBlock) {};
     void onSuccess(long long messageUid, long long timestamp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            m_message.messageUid = messageUid;
            m_message.serverTime = timestamp;
            m_message.status = Message_Status_Sent;
            if (m_successBlock) {
                m_successBlock(messageUid, timestamp);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kSendingMessageStatusUpdated object:@(m_message.messageId) userInfo:@{@"status":@(Message_Status_Sent), @"messageUid":@(messageUid), @"timestamp":@(timestamp)}];
            delete this;

        });
     }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            m_message.status = Message_Status_Send_Failure;
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kSendingMessageStatusUpdated object:@(m_message.messageId) userInfo:@{@"status":@(Message_Status_Send_Failure)}];
            delete this;
        });
    }
    void onPrepared(long messageId, int64_t savedTime) {
        m_message.messageId = messageId;
        m_message.serverTime = savedTime;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendingMessageStatusUpdated object:@(m_message.messageId) userInfo:@{@"status":@(Message_Status_Sending), @"message":m_message}];
    }
    void onMediaUploaded(std::string remoteUrl) {
        if ([m_message.content isKindOfClass:[WFCCMediaMessageContent class]]) {
            WFCCMediaMessageContent *mediaContent = (WFCCMediaMessageContent *)m_message.content;
            mediaContent.remoteUrl = [NSString stringWithUTF8String:remoteUrl.c_str()];
        }
    }
    
    void onProgress(int uploaded, int total) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_progressBlock) {
                m_progressBlock(uploaded, total);
            }
        });
    }
    
    virtual ~IMSendMessageCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
        m_progressBlock = nil;
        m_message = nil;
    }
};
extern WFCCUserInfo* convertUserInfo(const mars::stn::TUserInfo &tui);


class IMCreateGroupCallback : public mars::stn::CreateGroupCallback {
private:
    void(^m_successBlock)(NSString *groupId);
    void(^m_errorBlock)(int error_code);
public:
    IMCreateGroupCallback(void(^successBlock)(NSString *groupId), void(^errorBlock)(int error_code)) : mars::stn::CreateGroupCallback(), m_successBlock(successBlock), m_errorBlock(errorBlock) {};
    void onSuccess(std::string groupId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock([NSString stringWithUTF8String:groupId.c_str()]);
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }

    virtual ~IMCreateGroupCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};

class IMGeneralOperationCallback : public mars::stn::GeneralOperationCallback {
private:
    void(^m_successBlock)();
    void(^m_errorBlock)(int error_code);
public:
    IMGeneralOperationCallback(void(^successBlock)(), void(^errorBlock)(int error_code)) : mars::stn::GeneralOperationCallback(), m_successBlock(successBlock), m_errorBlock(errorBlock) {};
    void onSuccess() {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock();
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }

    virtual ~IMGeneralOperationCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};

class RecallMessageCallback : public mars::stn::GeneralOperationCallback {
private:
    void(^m_successBlock)();
    void(^m_errorBlock)(int error_code);
    WFCCMessage *message;
public:
    RecallMessageCallback(WFCCMessage *msg, void(^successBlock)(), void(^errorBlock)(int error_code)) : mars::stn::GeneralOperationCallback(), m_successBlock(successBlock), m_errorBlock(errorBlock), message(msg) {};
    void onSuccess() {
        WFCCRecallMessageContent *recallCnt = [[WFCCRecallMessageContent alloc] init];
        recallCnt.operatorId = [WFCCNetworkService sharedInstance].userId;
        recallCnt.messageUid = message.messageUid;
        message.content = recallCnt;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock();
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }
    
    virtual ~RecallMessageCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};

class IMGetChatroomInfoCallback : public mars::stn::GetChatroomInfoCallback {
private:
    NSString *chatroomId;
    void(^m_successBlock)(WFCCChatroomInfo *chatroomInfo);
    void(^m_errorBlock)(int error_code);
public:
    IMGetChatroomInfoCallback(NSString *cid, void(^successBlock)(WFCCChatroomInfo *chatroomInfo), void(^errorBlock)(int error_code)) : mars::stn::GetChatroomInfoCallback(), chatroomId(cid),  m_successBlock(successBlock), m_errorBlock(errorBlock) {};
    void onSuccess(const mars::stn::TChatroomInfo &info) {
        WFCCChatroomInfo *chatroomInfo = [[WFCCChatroomInfo alloc] init];
        chatroomInfo.chatroomId = chatroomId;
        chatroomInfo.title = [NSString stringWithUTF8String:info.title.c_str()];
        chatroomInfo.desc = [NSString stringWithUTF8String:info.desc.c_str()];
        chatroomInfo.portrait = [NSString stringWithUTF8String:info.portrait.c_str()];
        chatroomInfo.extra = [NSString stringWithUTF8String:info.extra.c_str()];
        chatroomInfo.state = info.state;
        chatroomInfo.memberCount = info.memberCount;
        chatroomInfo.createDt = info.createDt;
        chatroomInfo.updateDt = info.updateDt;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock(chatroomInfo);
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }
    
    virtual ~IMGetChatroomInfoCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};

extern NSMutableArray* convertProtoMessageList(const std::list<mars::stn::TMessage> &messageList, BOOL reverse);

class IMLoadRemoteMessagesCallback : public mars::stn::LoadRemoteMessagesCallback {
private:
    void(^m_successBlock)(NSArray<WFCCMessage *> *messages);
    void(^m_errorBlock)(int error_code);
public:
    IMLoadRemoteMessagesCallback(void(^successBlock)(NSArray<WFCCMessage *> *messages), void(^errorBlock)(int error_code)) : mars::stn::LoadRemoteMessagesCallback(), m_successBlock(successBlock), m_errorBlock(errorBlock) {};
    void onSuccess(const std::list<mars::stn::TMessage> &messageList) {
        NSMutableArray *messages = convertProtoMessageList(messageList, NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock(messages);
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }
    
    virtual ~IMLoadRemoteMessagesCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};
class IMGetChatroomMemberInfoCallback : public mars::stn::GetChatroomMemberInfoCallback {
private:
    void(^m_successBlock)(WFCCChatroomMemberInfo *chatroomMemberInfo);
    void(^m_errorBlock)(int error_code);
public:
    IMGetChatroomMemberInfoCallback(void(^successBlock)(WFCCChatroomMemberInfo *chatroomMemberInfo), void(^errorBlock)(int error_code)) : mars::stn::GetChatroomMemberInfoCallback(), m_successBlock(successBlock), m_errorBlock(errorBlock) {};
    void onSuccess(const mars::stn::TChatroomMemberInfo &info) {
        WFCCChatroomMemberInfo *memberInfo = [[WFCCChatroomMemberInfo alloc] init];
        memberInfo.memberCount = info.memberCount;
        NSMutableArray *members = [[NSMutableArray alloc] init];
        for (std::list<std::string>::const_iterator it = info.olderMembers.begin(); it != info.olderMembers.end(); it++) {
            [members addObject:[NSString stringWithUTF8String:it->c_str()]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock(memberInfo);
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }
    
    virtual ~IMGetChatroomMemberInfoCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};

class IMGetGroupInfoCallback : public mars::stn::GetGroupInfoCallback {
private:
    void(^m_successBlock)(NSArray<WFCCGroupInfo *> *);
    void(^m_errorBlock)(int error_code);
public:
    IMGetGroupInfoCallback(void(^successBlock)(NSArray<WFCCGroupInfo *> *), void(^errorBlock)(int error_code)) : mars::stn::GetGroupInfoCallback(), m_successBlock(successBlock), m_errorBlock(errorBlock) {};
    void onSuccess(const std::list<const mars::stn::TGroupInfo> &groupInfoList) {
        
        NSMutableArray *ret = nil;
        if (m_successBlock) {
            NSMutableArray *ret = [[NSMutableArray alloc] init];
            for (std::list<const mars::stn::TGroupInfo>::const_iterator it = groupInfoList.begin(); it != groupInfoList.end(); it++) {
                WFCCGroupInfo *gi = [[WFCCGroupInfo alloc] init];
                const mars::stn::TGroupInfo &tgi = *it;
                gi.target = [NSString stringWithUTF8String:tgi.target.c_str()];
                gi.type = (WFCCGroupType)tgi.type;
                gi.memberCount = tgi.memberCount;
                gi.name = [NSString stringWithUTF8String:tgi.name.c_str()];
                gi.owner = [NSString stringWithUTF8String:tgi.owner.c_str()];
                gi.extra = [NSData dataWithBytes:(const void *)tgi.extra.c_str() length:tgi.extra.length()];
                [ret addObject:gi];
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock(ret);
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }
    
    virtual ~IMGetGroupInfoCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};

class GeneralUpdateMediaCallback : public mars::stn::UpdateMediaCallback {
public:
  void(^m_successBlock)(NSString *remoteUrl);
  void(^m_errorBlock)(int error_code);
  void(^m_progressBlock)(long uploaded, long total);
  
  GeneralUpdateMediaCallback(void(^successBlock)(NSString *remoteUrl), void(^progressBlock)(long uploaded, long total), void(^errorBlock)(int error_code)) : mars::stn::UpdateMediaCallback(), m_successBlock(successBlock), m_progressBlock(progressBlock), m_errorBlock(errorBlock) {}
  
  void onSuccess(const std::string &remoteUrl) {
      NSString *url = [NSString stringWithUTF8String:remoteUrl.c_str()];
      dispatch_async(dispatch_get_main_queue(), ^{
          if (m_successBlock) {
              m_successBlock(url);
          }
          delete this;
      });
  }
  
  void onFalure(int errorCode) {
      dispatch_async(dispatch_get_main_queue(), ^{
          if (m_errorBlock) {
              m_errorBlock(errorCode);
          }
          delete this;
      });
  }
  
    void onProgress(int current, int total) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_progressBlock) {
                m_progressBlock(current, total);
            }
        });
    }
    
  ~GeneralUpdateMediaCallback() {
    m_successBlock = nil;
    m_errorBlock = nil;
  }
};

static WFCCMessage *convertProtoMessage(const mars::stn::TMessage *tMessage) {
    if (tMessage->target.empty()) {
        return nil;
    }
    WFCCMessage *ret = [[WFCCMessage alloc] init];
    ret.fromUser = [NSString stringWithUTF8String:tMessage->from.c_str()];
    ret.conversation = [[WFCCConversation alloc] init];
    ret.conversation.type = (WFCCConversationType)tMessage->conversationType;
    ret.conversation.target = [NSString stringWithUTF8String:tMessage->target.c_str()];
    ret.conversation.line = tMessage->line;
    ret.messageId = tMessage->messageId;
    ret.messageUid = tMessage->messageUid;
    ret.serverTime = tMessage->timestamp;
    
    NSMutableArray *toUsers = [[NSMutableArray alloc] init];
    for (std::list<std::string>::const_iterator it = tMessage->to.begin(); it != tMessage->to.end(); ++it) {
        NSString *user = [NSString stringWithUTF8String:(*it).c_str()];
        [toUsers addObject:user];
    }
    ret.toUsers = toUsers;
    ret.direction = (WFCCMessageDirection)tMessage->direction;
    ret.status = (WFCCMessageStatus)tMessage->status;
    
    WFCCMediaMessagePayload *payload = [[WFCCMediaMessagePayload alloc] init];
    payload.contentType = tMessage->content.type;
    payload.searchableContent = [NSString stringWithUTF8String:tMessage->content.searchableContent.c_str()];
    payload.pushContent = [NSString stringWithUTF8String:tMessage->content.pushContent.c_str()];
    
    payload.content = [NSString stringWithUTF8String:tMessage->content.content.c_str()];
    payload.binaryContent = [NSData dataWithBytes:tMessage->content.binaryContent.c_str() length:tMessage->content.binaryContent.length()];
    payload.localContent = [NSString stringWithUTF8String:tMessage->content.localContent.c_str()];
    payload.mediaType = (WFCCMediaType)tMessage->content.mediaType;
    payload.remoteMediaUrl = [NSString stringWithUTF8String:tMessage->content.remoteMediaUrl.c_str()];
    payload.localMediaPath = [NSString stringWithUTF8String:tMessage->content.localMediaPath.c_str()];
    payload.mentionedType = tMessage->content.mentionedType;
  NSMutableArray *mentionedType = [[NSMutableArray alloc] init];
  for (std::list<std::string>::const_iterator it = tMessage->content.mentionedTargets.begin(); it != tMessage->content.mentionedTargets.end(); it++) {
    [mentionedType addObject:[NSString stringWithUTF8String:(*it).c_str()]];
  }
  
    ret.content = [[WFCCIMService sharedWFCIMService] messageContentFromPayload:payload];
    return ret;
}


NSMutableArray* convertProtoMessageList(const std::list<mars::stn::TMessage> &messageList, BOOL reverse) {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (std::list<mars::stn::TMessage>::const_iterator it = messageList.begin(); it != messageList.end(); it++) {
        const mars::stn::TMessage &tmsg = *it;
        WFCCMessage *msg = convertProtoMessage(&tmsg);
        if (msg) {
            if (reverse) {
                [messages insertObject:msg atIndex:0];
            } else {
                [messages addObject:msg];
            }
        }
    }
    return messages;
}

static WFCCConversationInfo* convertConversationInfo(const mars::stn::TConversation &tConv) {
    WFCCConversationInfo *info = [[WFCCConversationInfo alloc] init];
    info.conversation = [[WFCCConversation alloc] init];
    info.conversation.type = (WFCCConversationType)tConv.conversationType;
    info.conversation.target = [NSString stringWithUTF8String:tConv.target.c_str()];
    info.conversation.line = tConv.line;
    info.lastMessage = convertProtoMessage(&tConv.lastMessage);
    info.draft = [NSString stringWithUTF8String:tConv.draft.c_str()];
    info.timestamp = tConv.timestamp;
    info.unreadCount = [WFCCUnreadCount countOf:tConv.unreadCount.unread mention:tConv.unreadCount.unreadMention mentionAll:tConv.unreadCount.unreadMentionAll];
    info.isTop = tConv.isTop;
    info.isSilent = tConv.isSilent;
    return info;
}

static WFCCIMService * sharedSingleton = nil;

static void fillTMessageContent(mars::stn::TMessageContent &tmsgcontent, WFCCMessageContent *content) {
    WFCCMessagePayload *payload = [content encode];
    tmsgcontent.type = payload.contentType;
    tmsgcontent.searchableContent = [payload.searchableContent UTF8String] ? [payload.searchableContent UTF8String] : "";
    tmsgcontent.pushContent = [payload.pushContent UTF8String] ? [payload.pushContent UTF8String] : "";
    
    tmsgcontent.content = [payload.content UTF8String] ? [payload.content UTF8String] : "";
    if (payload.binaryContent != nil) {
        tmsgcontent.binaryContent = std::string((const char *)payload.binaryContent.bytes, payload.binaryContent.length);
    }
    tmsgcontent.localContent = [payload.localContent UTF8String] ? [payload.localContent UTF8String] : "";
    if ([payload isKindOfClass:[WFCCMediaMessagePayload class]]) {
        WFCCMediaMessagePayload *mediaPayload = (WFCCMediaMessagePayload *)payload;
        tmsgcontent.mediaType = mediaPayload.mediaType;
        tmsgcontent.remoteMediaUrl = [mediaPayload.remoteMediaUrl UTF8String] ? [mediaPayload.remoteMediaUrl UTF8String] : "";
        tmsgcontent.localMediaPath = [mediaPayload.localMediaPath UTF8String] ? [mediaPayload.localMediaPath UTF8String] : "";
    }
    
    tmsgcontent.mentionedType = payload.mentionedType;
    for (NSString *target in payload.mentionedTargets) {
        tmsgcontent.mentionedTargets.insert(tmsgcontent.mentionedTargets.end(), [target UTF8String]);
    }
}


static void fillTMessage(mars::stn::TMessage &tmsg, WFCCConversation *conv, WFCCMessageContent *content) {
    tmsg.conversationType = conv.type;
    tmsg.target = conv.target ? [conv.target UTF8String] : "";
    tmsg.line = conv.line;
    tmsg.from = mars::app::GetAccountUserName();
    tmsg.status = mars::stn::MessageStatus::Message_Status_Sending;
    tmsg.timestamp = time(NULL)*1000;
    tmsg.direction = 0;
    fillTMessageContent(tmsg.content, content);
}

@interface WFCCIMService ()
@property(nonatomic, strong)NSMutableDictionary<NSNumber *, Class> *MessageContentMaps;
@end
@implementation WFCCIMService
+ (WFCCIMService *)sharedWFCIMService {
    if (sharedSingleton == nil) {
        @synchronized (self) {
            if (sharedSingleton == nil) {
                sharedSingleton = [[WFCCIMService alloc] init];
                sharedSingleton.MessageContentMaps = [[NSMutableDictionary alloc] init];
            }
        }
    }

    return sharedSingleton;
}

- (WFCCMessage *)send:(WFCCConversation *)conversation
              content:(WFCCMessageContent *)content
              success:(void(^)(long long messageUd, long long timestamp))successBlock
                error:(void(^)(int error_code))errorBlock {
    return [self sendMedia:conversation content:content expireDuration:0 success:successBlock progress:nil error:errorBlock];
}

- (WFCCMessage *)sendMedia:(WFCCConversation *)conversation
                   content:(WFCCMessageContent *)content
                   success:(void(^)(long long messageUid, long long timestamp))successBlock
                  progress:(void(^)(long uploaded, long total))progressBlock
                     error:(void(^)(int error_code))errorBlock {
    return [self sendMedia:conversation content:content expireDuration:0 success:successBlock progress:progressBlock error:errorBlock];
}

- (WFCCMessage *)send:(WFCCConversation *)conversation
              content:(WFCCMessageContent *)content
       expireDuration:(int)expireDuration
              success:(void(^)(long long messageUid, long long timestamp))successBlock
                error:(void(^)(int error_code))errorBlock {
    return [self sendMedia:conversation content:content expireDuration:0 success:successBlock progress:nil error:errorBlock];
}

- (WFCCMessage *)send:(WFCCConversation *)conversation
              content:(WFCCMessageContent *)content
               toUsers:(NSArray<NSString *> *)toUsers
       expireDuration:(int)expireDuration
              success:(void(^)(long long messageUid, long long timestamp))successBlock
                error:(void(^)(int error_code))errorBlock {
    return [self sendMedia:conversation content:content toUsers:toUsers expireDuration:0 success:successBlock progress:nil error:errorBlock];
}
- (WFCCMessage *)sendMedia:(WFCCConversation *)conversation
                   content:(WFCCMessageContent *)content
            expireDuration:(int)expireDuration
                   success:(void(^)(long long messageUid, long long timestamp))successBlock
                  progress:(void(^)(long uploaded, long total))progressBlock
                     error:(void(^)(int error_code))errorBlock {
    return [self sendMedia:conversation content:content toUsers:nil expireDuration:expireDuration success:successBlock progress:progressBlock error:errorBlock];
}

- (WFCCMessage *)sendMedia:(WFCCConversation *)conversation
                   content:(WFCCMessageContent *)content
                   toUsers:(NSArray<NSString *>*)toUsers
            expireDuration:(int)expireDuration
                   success:(void(^)(long long messageUid, long long timestamp))successBlock
                  progress:(void(^)(long uploaded, long total))progressBlock
                     error:(void(^)(int error_code))errorBlock {
    
    WFCCMessage *message = [[WFCCMessage alloc] init];
    message.conversation = conversation;
    message.content = content;
    message.toUsers = toUsers;
    mars::stn::TMessage tmsg;
    if (toUsers.count) {
        for (NSString *obj in toUsers) {
            tmsg.to.push_back([obj UTF8String]);
        }
    }
    
    fillTMessage(tmsg, conversation, content);
    mars::stn::sendMessage(tmsg, new IMSendMessageCallback(message, successBlock, progressBlock, errorBlock), expireDuration);
    message.fromUser = [WFCCNetworkService sharedInstance].userId;
    
    return message;
}

- (void)recall:(WFCCMessage *)msg
       success:(void(^)(void))successBlock
         error:(void(^)(int error_code))errorBlock {
    if (msg == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"recall msg failure, message not exist");
            errorBlock(-1);
        });
        return;
    }
    
    mars::stn::recallMessage(msg.messageUid, new RecallMessageCallback(msg, successBlock, errorBlock));
}
- (NSArray<WFCCConversationInfo *> *)getConversationInfos:(NSArray<NSNumber *> *)conversationTypes lines:(NSArray<NSNumber *> *)lines{
    std::list<int> types;
    for (NSNumber *type in conversationTypes) {
        types.push_back([type intValue]);
    }
    
    std::list<int> ls;
    for (NSNumber *type in lines) {
        ls.push_back([type intValue]);
    }
    std::list<mars::stn::TConversation> convers = mars::stn::MessageDB::Instance()->GetConversationList(types, ls);
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (std::list<mars::stn::TConversation>::iterator it = convers.begin(); it != convers.end(); it++) {
        mars::stn::TConversation &tConv = *it;
        WFCCConversationInfo *info = convertConversationInfo(tConv);
        [ret addObject:info];
    }
    return ret;
}

- (WFCCConversationInfo *)getConversationInfo:(WFCCConversation *)conversation {
    mars::stn::TConversation tConv = mars::stn::MessageDB::Instance()->GetConversation(conversation.type, [conversation.target UTF8String], conversation.line);
    return convertConversationInfo(tConv);
}
- (NSArray<WFCCMessage *> *)getMessages:(WFCCConversation *)conversation contentTypes:(NSArray<NSNumber *> *)contentTypes from:(NSUInteger)fromIndex count:(NSInteger)count withUser:(NSString *)user {
    std::list<int> types;
    for (NSNumber *num in contentTypes) {
        types.push_back(num.intValue);
    }
    bool direction = true;
    if (count < 0) {
        direction = false;
        count = -count;
    }
    
    std::list<mars::stn::TMessage> messages = mars::stn::MessageDB::Instance()->GetMessages(conversation.type, [conversation.target UTF8String], conversation.line, types, direction, (int)count, fromIndex, user ? [user UTF8String] : "");
    return convertProtoMessageList(messages, YES);
}

- (NSArray<WFCCConversationInfo *> *)getMessages:(NSArray<NSNumber *> *)conversationTypes
                                           lines:(NSArray<NSNumber *> *)lines
                                    contentTypes:(NSArray<NSNumber *> *)contentTypes
                                            from:(NSUInteger)fromIndex
                                           count:(NSInteger)count
                                        withUser:(NSString *)user {
    std::list<int> convtypes;
    for (NSNumber *ct in conversationTypes) {
        convtypes.push_back([ct intValue]);
    }
    
    std::list<int> ls;
    for (NSNumber *type in lines) {
        ls.push_back([type intValue]);
    }
    
    
    std::list<int> types;
    for (NSNumber *num in contentTypes) {
        types.push_back(num.intValue);
    }
    bool direction = true;
    if (count < 0) {
        direction = false;
        count = -count;
    }
    
    std::list<mars::stn::TMessage> messages = mars::stn::MessageDB::Instance()->GetMessages(convtypes, ls, types, direction, (int)count, fromIndex, user ? [user UTF8String] : "");
    return convertProtoMessageList(messages, YES);
}

- (NSArray<WFCCConversationInfo *> *)getMessages:(NSArray<NSNumber *> *)conversationTypes
                                           lines:(NSArray<NSNumber *> *)lines
                                   messageStatus:(WFCCMessageStatus)messageStatus
                                            from:(NSUInteger)fromIndex
                                           count:(NSInteger)count
                                        withUser:(NSString *)user {
    std::list<int> convtypes;
    for (NSNumber *ct in conversationTypes) {
        convtypes.push_back([ct intValue]);
    }
    
    std::list<int> ls;
    for (NSNumber *type in lines) {
        ls.push_back([type intValue]);
    }
    
    

    bool direction = true;
    if (count < 0) {
        direction = false;
        count = -count;
    }
    
    std::list<mars::stn::TMessage> messages = mars::stn::MessageDB::Instance()->GetMessages(convtypes, ls, messageStatus, direction, (int)count, fromIndex, user ? [user UTF8String] : "");
    return convertProtoMessageList(messages, YES);
}

- (void)getRemoteMessages:(WFCCConversation *)conversation
                   before:(long long)beforeMessageUid
                    count:(NSUInteger)count
                  success:(void(^)(NSArray<WFCCMessage *> *messages))successBlock
                    error:(void(^)(int error_code))errorBlock {
    mars::stn::TConversation conv;
    conv.target = [conversation.target UTF8String];
    conv.line = conversation.line;
    conv.conversationType = conversation.type;
    mars::stn::loadRemoteMessages(conv, beforeMessageUid, (int)count, new IMLoadRemoteMessagesCallback(successBlock, errorBlock));
}

- (WFCCMessage *)getMessage:(long)messageId {
  mars::stn::TMessage tMsg = mars::stn::MessageDB::Instance()->GetMessageById(messageId);
  return convertProtoMessage(&tMsg);
}

- (WFCCMessage *)getMessageByUid:(long long)messageUid {
  mars::stn::TMessage tMsg = mars::stn::MessageDB::Instance()->GetMessageByUid(messageUid);
  return convertProtoMessage(&tMsg);
}

- (WFCCUnreadCount *)getUnreadCount:(WFCCConversation *)conversation {
    mars::stn::TUnreadCount tcount = mars::stn::MessageDB::Instance()->GetUnreadCount(conversation.type, [conversation.target UTF8String], conversation.line);
    return [WFCCUnreadCount countOf:tcount.unread mention:tcount.unreadMention mentionAll:tcount.unreadMentionAll];
}

- (WFCCUnreadCount *)getUnreadCount:(NSArray<NSNumber *> *)conversationTypes lines:(NSArray<NSNumber *> *)lines {
    std::list<int> types;
    std::list<int> ls;
    for (NSNumber *type in conversationTypes) {
        types.insert(types.end(), type.intValue);
    }
    
    for (NSNumber *line in lines) {
        ls.insert(ls.end(), line.intValue);
    }
    mars::stn::TUnreadCount tcount =  mars::stn::MessageDB::Instance()->GetUnreadCount(types, ls);
    return [WFCCUnreadCount countOf:tcount.unread mention:tcount.unreadMention mentionAll:tcount.unreadMentionAll];
}

- (void)clearUnreadStatus:(WFCCConversation *)conversation {
    mars::stn::MessageDB::Instance()->ClearUnreadStatus(conversation.type, [conversation.target UTF8String], conversation.line);
}

- (void)clearAllUnreadStatus {
    mars::stn::MessageDB::Instance()->ClearAllUnreadStatus();
}


- (void)setMediaMessagePlayed:(long)messageId {
    WFCCMessage *message = [self getMessage:messageId];
    if (!message || ![message.content isKindOfClass:[WFCCMediaMessageContent class]] || message.direction == MessageDirection_Send) {
        return;
    }
    
    mars::stn::MessageDB::Instance()->updateMessageStatus(messageId, mars::stn::Message_Status_Played);
}

- (void)removeConversation:(WFCCConversation *)conversation clearMessage:(BOOL)clearMessage {
    mars::stn::MessageDB::Instance()->RemoveConversation(conversation.type, [conversation.target UTF8String], conversation.line, clearMessage);
}

- (void)clearMessages:(WFCCConversation *)conversation {
    mars::stn::MessageDB::Instance()->ClearMessages(conversation.type, [conversation.target UTF8String], conversation.line);
}

- (void)setConversation:(WFCCConversation *)conversation top:(BOOL)top
                success:(void(^)(void))successBlock
                  error:(void(^)(int error_code))errorBlock {
//    mars::stn::MessageDB::Instance()->updateConversationIsTop(conversation.type, [conversation.target UTF8String], conversation.line, top);
    
    [self setUserSetting:(UserSettingScope)mars::stn::kUserSettingConversationTop key:[NSString stringWithFormat:@"%zd-%d-%@", conversation.type, conversation.line, conversation.target] value:top ? @"1" : @"0" success:successBlock error:errorBlock];
}

- (void)setConversation:(WFCCConversation *)conversation draft:(NSString *)draft {
    mars::stn::MessageDB::Instance()->updateConversationDraft(conversation.type, [conversation.target UTF8String], conversation.line, draft ? [draft UTF8String] : "");
}

class IMSearchUserCallback : public mars::stn::SearchUserCallback {
private:
    void(^m_successBlock)(NSArray<WFCCUserInfo *> *machedUsers);
    void(^m_errorBlock)(int errorCode);
public:
    IMSearchUserCallback(void(^successBlock)(NSArray<WFCCUserInfo *> *machedUsers), void(^errorBlock)(int errorCode)) : m_successBlock(successBlock), m_errorBlock(errorBlock) {}
    
    void onSuccess(const std::list<mars::stn::TUserInfo> &users, const std::string &keyword, int page) {
        NSMutableArray *outUsers = [[NSMutableArray alloc] initWithCapacity:users.size()];
        for(std::list<mars::stn::TUserInfo>::const_iterator it = users.begin(); it != users.end(); it++) {
            [outUsers addObject:convertUserInfo(*it)];
        }
        m_successBlock(outUsers);
        delete this;
    }
    void onFalure(int errorCode) {
        m_errorBlock(errorCode);
        delete this;
    }
    
    ~IMSearchUserCallback() {}
};

- (void)searchUser:(NSString *)keyword success:(void(^)(NSArray<WFCCUserInfo *> *machedUsers))successBlock error:(void(^)(int errorCode))errorBlock {
    
    if (self.userSource) {
        [self.userSource searchUser:keyword success:successBlock error:errorBlock];
        return;
    }
    
    mars::stn::searchUser([keyword UTF8String], YES, 0, new IMSearchUserCallback(successBlock, errorBlock));
}

- (BOOL)isMyFriend:(NSString *)userId {
    return mars::stn::MessageDB::Instance()->isMyFriend([userId UTF8String]);
}

- (NSArray<NSString *> *)getMyFriendList:(BOOL)refresh {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    std::list<std::string> friendList = mars::stn::MessageDB::Instance()->getMyFriendList(refresh);
    for (std::list<std::string>::iterator it = friendList.begin(); it != friendList.end(); it++) {
        [ret addObject:[NSString stringWithUTF8String:(*it).c_str()]];
    }
    return ret;
}

- (NSArray<WFCCUserInfo *> *)searchFriends:(NSString *)keyword {
    std::list<mars::stn::TUserInfo> friends = mars::stn::MessageDB::Instance()->SearchFriends([keyword UTF8String], 50);
    NSMutableArray<WFCCUserInfo *> *ret = [[NSMutableArray alloc] init];
    for (std::list<mars::stn::TUserInfo>::iterator it = friends.begin(); it != friends.end(); it++) {
        WFCCUserInfo *userInfo = convertUserInfo(*it);
        if (userInfo) {
            [ret addObject:userInfo];
        }
    }
  return ret;
}
WFCCChannelInfo *convertProtoChannelInfo(const mars::stn::TChannelInfo &tci) {
    if (tci.channelId.empty()) {
        return nil;
    }
    WFCCChannelInfo *channelInfo = [[WFCCChannelInfo alloc] init];
    channelInfo.channelId = [NSString stringWithUTF8String:tci.channelId.c_str()];
    channelInfo.desc = [NSString stringWithUTF8String:tci.desc.c_str()];
    channelInfo.name = [NSString stringWithUTF8String:tci.name.c_str()];
    channelInfo.extra = [NSString stringWithUTF8String:tci.extra.c_str()];
    channelInfo.portrait = [NSString stringWithUTF8String:tci.portrait.c_str()];
    channelInfo.owner = [NSString stringWithUTF8String:tci.owner.c_str()];
    channelInfo.secret = [NSString stringWithUTF8String:tci.secret.c_str()];
    channelInfo.callback = [NSString stringWithUTF8String:tci.callback.c_str()];
    channelInfo.status = tci.status;
    channelInfo.updateDt = tci.updateDt;
    return channelInfo;
}


class IMCreateChannelCallback : public mars::stn::CreateChannelCallback {
private:
    void(^m_successBlock)(WFCCChannelInfo *channelInfo);
    void(^m_errorBlock)(int error_code);
public:
    IMCreateChannelCallback(void(^successBlock)(WFCCChannelInfo *channelInfo), void(^errorBlock)(int error_code)) : mars::stn::CreateChannelCallback(), m_successBlock(successBlock), m_errorBlock(errorBlock) {};
    void onSuccess(const mars::stn::TChannelInfo &channelInfo) {
        WFCCChannelInfo *ci = convertProtoChannelInfo(channelInfo);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_successBlock) {
                m_successBlock(ci);
            }
            delete this;
        });
    }
    void onFalure(int errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (m_errorBlock) {
                m_errorBlock(errorCode);
            }
            delete this;
        });
    }
    
    virtual ~IMCreateChannelCallback() {
        m_successBlock = nil;
        m_errorBlock = nil;
    }
};

class IMSearchChannelCallback : public mars::stn::SearchChannelCallback {
private:
    void(^m_successBlock)(NSArray<WFCCChannelInfo *> *machedChannels);
    void(^m_errorBlock)(int errorCode);
public:
    IMSearchChannelCallback(void(^successBlock)(NSArray<WFCCChannelInfo *> *machedUsers), void(^errorBlock)(int errorCode)) : m_successBlock(successBlock), m_errorBlock(errorBlock) {}
    
    void onSuccess(const std::list<mars::stn::TChannelInfo> &users, const std::string &keyword) {
        NSMutableArray *outUsers = [[NSMutableArray alloc] initWithCapacity:users.size()];
        for(std::list<mars::stn::TChannelInfo>::const_iterator it = users.begin(); it != users.end(); it++) {
            [outUsers addObject:convertProtoChannelInfo(*it)];
        }
        m_successBlock(outUsers);
        delete this;
    }
    void onFalure(int errorCode) {
        m_errorBlock(errorCode);
        delete this;
    }
    
    ~IMSearchChannelCallback() {}
};

WFCCGroupInfo *convertProtoGroupInfo(mars::stn::TGroupInfo tgi) {
    if (tgi.target.empty()) {
        return nil;
    }
    WFCCGroupInfo *groupInfo = [[WFCCGroupInfo alloc] init];
    groupInfo.type = (WFCCGroupType)tgi.type;
    groupInfo.target = [NSString stringWithUTF8String:tgi.target.c_str()];
    groupInfo.name = [NSString stringWithUTF8String:tgi.name.c_str()];
    groupInfo.extra = [NSData dataWithBytes:tgi.extra.c_str() length:tgi.extra.length()];
    groupInfo.portrait = [NSString stringWithUTF8String:tgi.portrait.c_str()];
    groupInfo.owner = [NSString stringWithUTF8String:tgi.owner.c_str()];
    groupInfo.memberCount = tgi.memberCount;
    return groupInfo;
}


- (NSArray<WFCCGroupSearchInfo *> *)searchGroups:(NSString *)keyword {
    std::list<mars::stn::TGroupSearchResult> groups = mars::stn::MessageDB::Instance()->SearchGroups([keyword UTF8String], 50);
    NSMutableArray<WFCCGroupSearchInfo *> *ret = [[NSMutableArray alloc] init];
    for (std::list<mars::stn::TGroupSearchResult>::iterator it = groups.begin(); it != groups.end(); it++) {
        WFCCGroupSearchInfo *searchGroupInfo = [[WFCCGroupSearchInfo alloc] init];
        searchGroupInfo.groupInfo = convertProtoGroupInfo(it->groupInfo);
        searchGroupInfo.marchType = it->marchedType;
        if (!it->marchedMemberNames.empty()) {
            NSMutableArray *members = [[NSMutableArray alloc] init];
            for (std::string name : it->marchedMemberNames) {
                [members addObject:[NSString stringWithUTF8String:name.c_str()]];
            }
            searchGroupInfo.marchedMemberNames = [members copy];
        }
        searchGroupInfo.keyword = keyword;
        [ret addObject:searchGroupInfo];
    }
    return ret;
}


- (NSArray<WFCCFriendRequest *> *)convertFriendRequest:(std::list<mars::stn::TFriendRequest>)tRequests {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (std::list<mars::stn::TFriendRequest>::iterator it = tRequests.begin(); it != tRequests.end(); it++) {
        WFCCFriendRequest *request = [[WFCCFriendRequest alloc] init];
        mars::stn::TFriendRequest *tRequest = &(*it);
        request.direction = tRequest->direction;
        request.target = [NSString stringWithUTF8String:tRequest->target.c_str()];
        request.reason = [NSString stringWithUTF8String:tRequest->reason.c_str()];
        request.status = tRequest->status;
        request.readStatus = tRequest->readStatus;
        request.timestamp = tRequest->timestamp;
        [ret addObject:request];
    }
    return ret;
}

- (void)loadFriendRequestFromRemote {
    mars::stn::loadFriendRequestFromRemote();
}

- (NSArray<WFCCFriendRequest *> *)getIncommingFriendRequest {
    std::list<mars::stn::TFriendRequest> tRequests = mars::stn::MessageDB::Instance()->getFriendRequest(1);
    return [self convertFriendRequest:tRequests];
}

- (NSArray<WFCCFriendRequest *> *)getOutgoingFriendRequest {
    std::list<mars::stn::TFriendRequest> tRequests = mars::stn::MessageDB::Instance()->getFriendRequest(0);
    return [self convertFriendRequest:tRequests];
}

- (void)clearUnreadFriendRequestStatus {
    mars::stn::MessageDB::Instance()->clearUnreadFriendRequestStatus();
}

- (int)getUnreadFriendRequestStatus {
    return mars::stn::MessageDB::Instance()->unreadFriendRequest();
}

- (void)sendFriendRequest:(NSString *)userId
                   reason:(NSString *)reason
                  success:(void(^)())successBlock
                    error:(void(^)(int error_code))errorBlock {
    mars::stn::sendFriendRequest([userId UTF8String], [reason UTF8String], new IMGeneralOperationCallback(successBlock, errorBlock));
}


- (void)handleFriendRequest:(NSString *)userId
                     accept:(BOOL)accpet
                    success:(void(^)())successBlock
                      error:(void(^)(int error_code))errorBlock {
    mars::stn::handleFriendRequest([userId UTF8String], accpet, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)deleteFriend:(NSString *)userId
             success:(void(^)())successBlock
               error:(void(^)(int error_code))errorBlock {
    mars::stn::deleteFriend([userId UTF8String], new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (NSString *)getFriendAlias:(NSString *)friendId {
    std::string strAlias = mars::stn::MessageDB::Instance()->GetFriendAlias([friendId UTF8String]);
    return [NSString stringWithUTF8String:strAlias.c_str()];
}

- (void)setFriend:(NSString *)friendId
            alias:(NSString *)alias
          success:(void(^)(void))successBlock
            error:(void(^)(int error_code))errorBlock {
    mars::stn::setFriendAlias([friendId UTF8String], alias ? [alias UTF8String] : "", new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (BOOL)isBlackListed:(NSString *)userId {
    return mars::stn::MessageDB::Instance()->isBlackListed([userId UTF8String]);
}

- (NSArray<NSString *> *)getBlackList:(BOOL)refresh {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    std::list<std::string> friendList = mars::stn::MessageDB::Instance()->getBlackList(refresh);
    for (std::list<std::string>::iterator it = friendList.begin(); it != friendList.end(); it++) {
        [ret addObject:[NSString stringWithUTF8String:(*it).c_str()]];
    }
    return ret;
}

- (void)setBlackList:(NSString *)userId
       isBlackListed:(BOOL)isBlackListed
             success:(void(^)(void))successBlock
               error:(void(^)(int error_code))errorBlock {
    mars::stn::blackListRequest([userId UTF8String], isBlackListed, new IMGeneralOperationCallback(successBlock, errorBlock));
}
- (WFCCUserInfo *)getUserInfo:(NSString *)userId refresh:(BOOL)refresh {
    return [self getUserInfo:userId inGroup:nil refresh:refresh];
}

- (WFCCUserInfo *)getUserInfo:(NSString *)userId inGroup:(NSString *)groupId refresh:(BOOL)refresh {
    if (!userId) {
        return nil;
    }
    
    if (self.userSource) {
        return [self.userSource getUserInfo:userId refresh:refresh];
    }
    
    mars::stn::TUserInfo tui = mars::stn::MessageDB::Instance()->getUserInfo([userId UTF8String], groupId ? [groupId UTF8String] : "", refresh);
    if (!tui.uid.empty()) {
        WFCCUserInfo *userInfo = convertUserInfo(tui);
        return userInfo;
    }
    return nil;
}

- (NSArray<WFCCUserInfo *> *)getUserInfos:(NSArray<NSString *> *)userIds inGroup:(NSString *)groupId {
    if ([userIds count] == 0) {
        return nil;
    }
    
    std::list<std::string> strIds;
    for (NSString *userId in userIds) {
        strIds.insert(strIds.end(), [userId UTF8String]);
    }
    std::list<mars::stn::TUserInfo> tuis = mars::stn::MessageDB::Instance()->getUserInfos(strIds, groupId ? [groupId UTF8String] : "");
    
    NSMutableArray<WFCCUserInfo *> *ret = [[NSMutableArray alloc] init];
    for (std::list<mars::stn::TUserInfo>::iterator it = tuis.begin(); it != tuis.end(); it++) {
        WFCCUserInfo *userInfo = convertUserInfo(*it);
        [ret addObject:userInfo];
    }
    return ret;
}

- (void)uploadMedia:(NSData *)mediaData
          mediaType:(WFCCMediaType)mediaType
            success:(void(^)(NSString *remoteUrl))successBlock
           progress:(void(^)(long uploaded, long total))progressBlock
              error:(void(^)(int error_code))errorBlock {
    mars::stn::uploadGeneralMedia(std::string((char *)mediaData.bytes, mediaData.length), mediaType, new GeneralUpdateMediaCallback(successBlock, progressBlock, errorBlock));
}

-(void)modifyMyInfo:(NSDictionary<NSNumber */*ModifyMyInfoType*/, NSString *> *)values
            success:(void(^)())successBlock
              error:(void(^)(int error_code))errorBlock {
    if (self.userSource) {
        [self.userSource modifyMyInfo:values success:successBlock error:errorBlock];
        return;
    }
    
    std::list<std::pair<int, std::string>> infos;
    for(NSNumber *key in values.allKeys) {
        infos.push_back(std::pair<int, std::string>([key intValue], [values[key] UTF8String]));
    }
    mars::stn::modifyMyInfo(infos, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (BOOL)isGlobalSlient {
    NSString *strValue = [[WFCCIMService sharedWFCIMService] getUserSetting:UserSettingScope_Global_Silent key:@""];
    return [strValue isEqualToString:@"1"];
}

- (void)setGlobalSlient:(BOOL)slient
                success:(void(^)(void))successBlock
                  error:(void(^)(int error_code))errorBlock {
    [[WFCCIMService sharedWFCIMService] setUserSetting:UserSettingScope_Global_Silent key:@"" value:slient?@"1":@"0" success:^{
        if (successBlock) {
            successBlock();
        }
    } error:^(int error_code) {
        if (errorBlock) {
            errorBlock(error_code);
        }
    }];
}
//UserSettingScope_Global_Silent = 2,
//
- (BOOL)isHiddenNotificationDetail {
    NSString *strValue = [[WFCCIMService sharedWFCIMService] getUserSetting:UserSettingScope_Hidden_Notification_Detail key:@""];
    return [strValue isEqualToString:@"1"];
}

- (void)setHiddenNotificationDetail:(BOOL)hidden
                success:(void(^)(void))successBlock
                  error:(void(^)(int error_code))errorBlock {
    [[WFCCIMService sharedWFCIMService] setUserSetting:UserSettingScope_Hidden_Notification_Detail key:@"" value:hidden?@"1":@"0" success:^{
        if (successBlock) {
            successBlock();
        }
    } error:^(int error_code) {
        if (errorBlock) {
            errorBlock(error_code);
        }
    }];
}

//UserSettingScope_Hidden_Notification_Detail = 4,
- (BOOL)isHiddenGroupMemberName:(NSString *)groupId {
    NSString *strValue = [[WFCCIMService sharedWFCIMService] getUserSetting:UserSettingScope_Group_Hide_Nickname key:groupId];
    return [strValue isEqualToString:@"1"];
}

- (void)setHiddenGroupMemberName:(BOOL)hidden
                           group:(NSString *)groupId
                            success:(void(^)(void))successBlock
                              error:(void(^)(int error_code))errorBlock {
    [[WFCCIMService sharedWFCIMService] setUserSetting:UserSettingScope_Group_Hide_Nickname key:groupId value:hidden?@"1":@"0" success:^{
        if (successBlock) {
            successBlock();
        }
    } error:^(int error_code) {
        if (errorBlock) {
            errorBlock(error_code);
        }
    }];
}
//UserSettingScope_Group_Hide_Nickname = 5,


- (BOOL)deleteMessage:(long)messageId {
    return mars::stn::MessageDB::Instance()->DeleteMessage(messageId);
}

- (NSArray<WFCCConversationSearchInfo *> *)searchConversation:(NSString *)keyword inConversation:(NSArray<NSNumber *> *)conversationTypes lines:(NSArray<NSNumber *> *)lines {
    if (keyword.length == 0) {
        return nil;
    }
    
    std::list<int> types;
    std::list<int> ls;
    for (NSNumber *type in conversationTypes) {
        types.insert(types.end(), type.intValue);
    }
    
    for (NSNumber *line in lines) {
        ls.insert(ls.end(), line.intValue);
    }
    
    if(lines.count == 0) {
        ls.insert(ls.end(), 0);
    }
    
    std::list<mars::stn::TConversationSearchresult> tresult = mars::stn::MessageDB::Instance()->SearchConversations(types, ls, [keyword UTF8String], 50);
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (std::list<mars::stn::TConversationSearchresult>::iterator it = tresult.begin(); it != tresult.end(); it++) {
        WFCCConversationSearchInfo *info = [[WFCCConversationSearchInfo alloc] init];
        [results addObject:info];
        info.conversation = [[WFCCConversation alloc] init];
        info.conversation.type = (WFCCConversationType)(it->conversationType);
        info.conversation.target = [NSString stringWithUTF8String:it->target.c_str()];
        info.conversation.line = it->line;
        info.marchedCount = it->marchedCount;
        info.marchedMessage = convertProtoMessage(&(it->marchedMessage));
        info.keyword = keyword;
    }
    return results;
}

- (NSArray<WFCCMessage *> *)searchMessage:(WFCCConversation *)conversation keyword:(NSString *)keyword {
    if (keyword.length == 0) {
        return nil;
    }
    std::list<mars::stn::TMessage> tmessages = mars::stn::MessageDB::Instance()->SearchMessages(conversation.type, [conversation.target UTF8String], conversation.line, [keyword UTF8String], 500);
    return convertProtoMessageList(tmessages, YES);
}

- (void)createGroup:(NSString *)groupId
               name:(NSString *)groupName
           portrait:(NSString *)groupPortrait
            members:(NSArray *)groupMembers
        notifyLines:(NSArray<NSNumber *> *)notifyLines
      notifyContent:(WFCCMessageContent *)notifyContent
            success:(void(^)(NSString *groupId))successBlock
              error:(void(^)(int error_code))errorBlock {

    std::list<std::string> memberList;
    for (NSString *member in groupMembers) {
        memberList.push_back([member UTF8String]);
    }
    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    mars::stn::createGroup(groupId == nil ? "" : [groupId UTF8String], groupName == nil ? "" : [groupName UTF8String], groupPortrait == nil ? "" : [groupPortrait UTF8String], memberList, lines, tcontent, new IMCreateGroupCallback(successBlock, errorBlock));
}

- (void)addMembers:(NSArray *)members
           toGroup:(NSString *)groupId
       notifyLines:(NSArray<NSNumber *> *)notifyLines
     notifyContent:(WFCCMessageContent *)notifyContent
           success:(void(^)())successBlock
             error:(void(^)(int error_code))errorBlock {

    std::list<std::string> memberList;
    for (NSString *member in members) {
        memberList.push_back([member UTF8String]);
    }

    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    
    mars::stn::addMembers([groupId UTF8String], memberList, lines, tcontent, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)kickoffMembers:(NSArray *)members
             fromGroup:(NSString *)groupId
           notifyLines:(NSArray<NSNumber *> *)notifyLines
         notifyContent:(WFCCMessageContent *)notifyContent
               success:(void(^)())successBlock
                 error:(void(^)(int error_code))errorBlock {

    std::list<std::string> memberList;
    for (NSString *member in members) {
        memberList.push_back([member UTF8String]);
    }

    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    
    mars::stn::kickoffMembers([groupId UTF8String], memberList, lines, tcontent, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)quitGroup:(NSString *)groupId
      notifyLines:(NSArray<NSNumber *> *)notifyLines
    notifyContent:(WFCCMessageContent *)notifyContent
          success:(void(^)())successBlock
            error:(void(^)(int error_code))errorBlock {

    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    
    mars::stn::quitGroup([groupId UTF8String], lines, tcontent, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)dismissGroup:(NSString *)groupId
         notifyLines:(NSArray<NSNumber *> *)notifyLines
       notifyContent:(WFCCMessageContent *)notifyContent
             success:(void(^)())successBlock
               error:(void(^)(int error_code))errorBlock {

    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    
    mars::stn::dismissGroup([groupId UTF8String], lines, tcontent, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)modifyGroupInfo:(NSString *)groupId
                   type:(ModifyGroupInfoType)type
               newValue:(NSString *)newValue
            notifyLines:(NSArray<NSNumber *> *)notifyLines
          notifyContent:(WFCCMessageContent *)notifyContent
                success:(void(^)(void))successBlock
                  error:(void(^)(int error_code))errorBlock {
    
    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    
    mars::stn::modifyGroupInfo([groupId UTF8String], (int)type, [newValue UTF8String], lines, tcontent, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)modifyGroupAlias:(NSString *)groupId
                   alias:(NSString *)newAlias
             notifyLines:(NSArray<NSNumber *> *)notifyLines
           notifyContent:(WFCCMessageContent *)notifyContent
                 success:(void(^)())successBlock
                   error:(void(^)(int error_code))errorBlock {
    
    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    
    mars::stn::modifyGroupAlias([groupId UTF8String], [newAlias UTF8String], lines, tcontent, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (NSArray<WFCCGroupMember *> *)getGroupMembers:(NSString *)groupId
                             forceUpdate:(BOOL)forceUpdate {
    std::list<mars::stn::TGroupMember> tmembers = mars::stn::MessageDB::Instance()->GetGroupMembers([groupId UTF8String], forceUpdate);
    NSMutableArray *output = [[NSMutableArray alloc] init];
    for(std::list<mars::stn::TGroupMember>::iterator it = tmembers.begin(); it != tmembers.end(); it++) {
        WFCCGroupMember *member = [WFCCGroupMember new];
        member.groupId = [NSString stringWithUTF8String:it->groupId.c_str()];
        member.memberId = [NSString stringWithUTF8String:it->memberId.c_str()];
        member.alias = [NSString stringWithUTF8String:it->alias.c_str()];
        member.type = (WFCCGroupMemberType)it->type;
        [output addObject:member];
    }
    return output;
}

- (WFCCGroupMember *)getGroupMember:(NSString *)groupId
                           memberId:(NSString *)memberId {
    mars::stn::TGroupMember tmember = mars::stn::MessageDB::Instance()->GetGroupMember([groupId UTF8String], [memberId UTF8String]);
    if (tmember.memberId == [memberId UTF8String]) {
        WFCCGroupMember *member = [WFCCGroupMember new];
        member.groupId = groupId;
        member.memberId = memberId;
        member.alias = [NSString stringWithUTF8String:tmember.alias.c_str()];
        member.type = (WFCCGroupMemberType)tmember.type;
        return member;
    }
    return nil;
}

- (void)transferGroup:(NSString *)groupId
                   to:(NSString *)newOwner
          notifyLines:(NSArray<NSNumber *> *)notifyLines
        notifyContent:(WFCCMessageContent *)notifyContent
              success:(void(^)())successBlock
                error:(void(^)(int error_code))errorBlock {
    mars::stn::TMessageContent tcontent;
    fillTMessageContent(tcontent, notifyContent);
    
    std::list<int> lines;
    for (NSNumber *number in notifyLines) {
        lines.push_back([number intValue]);
    }
    
    mars::stn::transferGroup([groupId UTF8String], [newOwner UTF8String], lines, tcontent, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (NSArray<NSString *> *)getFavGroups {
    NSDictionary *favGroupDict = [[WFCCIMService sharedWFCIMService] getUserSettings:UserSettingScope_Favourite_Group];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    [favGroupDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"1"]) {
            [ids addObject:key];
        }
    }];
    return ids;
}

- (BOOL)isFavGroup:(NSString *)groupId {
    NSString *strValue = [[WFCCIMService sharedWFCIMService] getUserSetting:UserSettingScope_Favourite_Group key:groupId];
    if ([strValue isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (void)setFavGroup:(NSString *)groupId fav:(BOOL)fav success:(void(^)(void))successBlock error:(void(^)(int errorCode))errorBlock {
    [[WFCCIMService sharedWFCIMService] setUserSetting:UserSettingScope_Favourite_Group key:groupId value:fav? @"1" : @"0" success:successBlock error:errorBlock];
}
- (WFCCGroupInfo *)getGroupInfo:(NSString *)groupId refresh:(BOOL)refresh {
    mars::stn::TGroupInfo tgi = mars::stn::MessageDB::Instance()->GetGroupInfo([groupId UTF8String], refresh);
    return convertProtoGroupInfo(tgi);
}

- (NSString *)getUserSetting:(UserSettingScope)scope key:(NSString *)key {
    if (!key) {
        key = @"";
    }
    std::string str = mars::stn::MessageDB::Instance()->GetUserSetting(scope, [key UTF8String]);
    return [NSString stringWithUTF8String:str.c_str()];
}

- (NSDictionary<NSString *, NSString *> *)getUserSettings:(UserSettingScope)scope {
    std::map<std::string, std::string> settings = mars::stn::MessageDB::Instance()->GetUserSettings(scope);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (std::map<std::string, std::string>::iterator it = settings.begin() ; it != settings.end(); it++) {
        NSString *key = [NSString stringWithUTF8String:it->first.c_str()];
        NSString *value = [NSString stringWithUTF8String:it->second.c_str()];
        [result setObject:value forKey:key];
    }
    return result;
}

- (void)setUserSetting:(UserSettingScope)scope key:(NSString *)key value:(NSString *)value
               success:(void(^)())successBlock
                 error:(void(^)(int error_code))errorBlock {
    mars::stn::modifyUserSetting(scope, [key UTF8String], [value UTF8String], new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)setConversation:(WFCCConversation *)conversation silent:(BOOL)silent
                success:(void(^)())successBlock
                  error:(void(^)(int error_code))errorBlock {
    [self setUserSetting:(UserSettingScope)mars::stn::kUserSettingConversationSilent key:[NSString stringWithFormat:@"%zd-%d-%@", conversation.type, conversation.line, conversation.target] value:silent ? @"1" : @"0" success:successBlock error:errorBlock];
}

- (WFCCMessageContent *)messageContentFromPayload:(WFCCMessagePayload *)payload {
    int contenttype = payload.contentType;
    Class contentClass = self.MessageContentMaps[@(contenttype)];
    if (contentClass != nil) {
        id messageInstance = [[contentClass alloc] init];
        
        if ([contentClass conformsToProtocol:@protocol(WFCCMessageContent)]) {
            if ([messageInstance respondsToSelector:@selector(decode:)]) {
                [messageInstance performSelector:@selector(decode:)
                                      withObject:payload];
            }
        }
        return messageInstance;
    }
    WFCCUnknownMessageContent *unknownMsg = [[WFCCUnknownMessageContent alloc] init];
    [unknownMsg decode:payload];
    return unknownMsg;
}

- (WFCCMessage *)insert:(WFCCConversation *)conversation
                 sender:(NSString *)sender
                content:(WFCCMessageContent *)content
                 status:(WFCCMessageStatus)status
                 notify:(BOOL)notify
             serverTime:(long long)serverTime {
    WFCCMessage *message = [[WFCCMessage alloc] init];
    message.conversation = conversation;
    message.content = content;
    mars::stn::TMessage tmsg;
    fillTMessage(tmsg, conversation, content);
    
    if(status >= Message_Status_Unread) {
        tmsg.direction = 1;
        if(conversation.type == Single_Type) {
            tmsg.from = [conversation.target UTF8String];
        } else {
            tmsg.from = [sender UTF8String];
        }
    }
    tmsg.status = (mars::stn::MessageStatus)status;
    
    if(serverTime > 0) {
        tmsg.timestamp = serverTime;
    }
    
    long msgId = mars::stn::MessageDB::Instance()->InsertMessage(tmsg);
    message.messageId = msgId;
    if(msgId > 0) {
        mars::stn::MessageDB::Instance()->updateConversationTimestamp(tmsg.conversationType, tmsg.target, tmsg.line, tmsg.timestamp);
    }
    
    message.fromUser = sender;
    if (notify) {
        [[WFCCNetworkService sharedInstance].receiveMessageDelegate onReceiveMessage:@[message] hasMore:NO];
    }
    return message;
}

- (void)updateMessage:(long)messageId
              content:(WFCCMessageContent *)content {
    mars::stn::TMessageContent tmc;
    fillTMessageContent(tmc, content);
    mars::stn::MessageDB::Instance()->UpdateMessageContent(messageId, tmc);
}

- (void)registerMessageContent:(Class)contentClass {
    int contenttype;
    if (class_getClassMethod(contentClass, @selector(getContentType))) {
        contenttype = [contentClass getContentType];
        self.MessageContentMaps[@(contenttype)] = contentClass;
        int contentflag = [contentClass getContentFlags];
        mars::stn::MessageDB::Instance()->RegisterMessageFlag(contenttype, contentflag);
    } else {
        return;
    }
}

- (void)joinChatroom:(NSString *)chatroomId
             success:(void(^)(void))successBlock
               error:(void(^)(int error_code))errorBlock {
    mars::stn::joinChatroom([chatroomId UTF8String], new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)quitChatroom:(NSString *)chatroomId
             success:(void(^)(void))successBlock
               error:(void(^)(int error_code))errorBlock {
    mars::stn::quitChatroom([chatroomId UTF8String], new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)getChatroomInfo:(NSString *)chatroomId
                upateDt:(long long)updateDt
                success:(void(^)(WFCCChatroomInfo *chatroomInfo))successBlock
                  error:(void(^)(int error_code))errorBlock {
    mars::stn::getChatroomInfo([chatroomId UTF8String], updateDt, new IMGetChatroomInfoCallback(chatroomId, successBlock, errorBlock));
}

- (void)getChatroomMemberInfo:(NSString *)chatroomId
                     maxCount:(int)maxCount
                      success:(void(^)(WFCCChatroomMemberInfo *memberInfo))successBlock
                        error:(void(^)(int error_code))errorBlock {
    if (maxCount <= 0) {
        maxCount = 30;
    }
    mars::stn::getChatroomMemberInfo([chatroomId UTF8String], maxCount, new IMGetChatroomMemberInfoCallback(successBlock, errorBlock));
}

- (void)createChannel:(NSString *)channelName
             portrait:(NSString *)channelPortrait
               status:(int)status
                 desc:(NSString *)desc
                extra:(NSString *)extra
              success:(void(^)(WFCCChannelInfo *channelInfo))successBlock
                error:(void(^)(int error_code))errorBlock {
    if (!extra) {
        extra = @"";
    }
    mars::stn::createChannel("", [channelName UTF8String], [channelPortrait UTF8String], status, [desc UTF8String], [extra UTF8String], "", "", new IMCreateChannelCallback(successBlock, errorBlock));
}

- (void)destoryChannel:(NSString *)channelId
              success:(void(^)(void))successBlock
                error:(void(^)(int error_code))errorBlock {
    mars::stn::destoryChannel([channelId UTF8String], new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (WFCCChannelInfo *)getChannelInfo:(NSString *)channelId
                            refresh:(BOOL)refresh {
    mars::stn::TChannelInfo tgi = mars::stn::MessageDB::Instance()->GetChannelInfo([channelId UTF8String], refresh);
    
    return convertProtoChannelInfo(tgi);
}

- (void)modifyChannelInfo:(NSString *)channelId
                     type:(ModifyChannelInfoType)type
                 newValue:(NSString *)newValue
                  success:(void(^)(void))successBlock
                    error:(void(^)(int error_code))errorBlock {
    mars::stn::modifyChannelInfo([channelId UTF8String], type, [newValue UTF8String], new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (void)searchChannel:(NSString *)keyword success:(void(^)(NSArray<WFCCChannelInfo *> *machedChannels))successBlock error:(void(^)(int errorCode))errorBlock {
    
    mars::stn::searchChannel([keyword UTF8String], YES, new IMSearchChannelCallback(successBlock, errorBlock));
}

- (BOOL)isListenedChannel:(NSString *)channelId {
    if([@"1" isEqualToString:[self getUserSetting:UserSettingScope_Listened_Channel key:channelId]]) {
        return YES;
    }
    return NO;
}

- (void)listenChannel:(NSString *)channelId listen:(BOOL)listen success:(void(^)(void))successBlock error:(void(^)(int errorCode))errorBlock {
    mars::stn::listenChannel([channelId UTF8String], listen, new IMGeneralOperationCallback(successBlock, errorBlock));
}

- (NSArray<NSString *> *)getMyChannels {
    NSDictionary *myChannelDict = [[WFCCIMService sharedWFCIMService] getUserSettings:UserSettingScope_My_Channel];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    [myChannelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"1"]) {
            [ids addObject:key];
        }
    }];
    return ids;
}
- (NSArray<NSString *> *)getListenedChannels {
    NSDictionary *myChannelDict = [[WFCCIMService sharedWFCIMService] getUserSettings:UserSettingScope_Listened_Channel];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    [myChannelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"1"]) {
            [ids addObject:key];
        }
    }];
    return ids;
}
@end
