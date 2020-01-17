//
//  CPUserInfoModel.h
//  Carpooling
//
//  Created by Yang on 2019/6/3.
//  Copyright © 2019 bw. All rights reserved.
//

#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPUserInfoModel : RLMObject
@property (nonatomic, assign) long long userId; // 拼车平台id
@property (nonatomic, copy) NSString *imUserId;
@property (nonatomic, strong) NSString *username; // 账号
@property (nonatomic, strong) NSString *nickname; // 昵称
@property (nonatomic, strong) NSString *remarkname; // 好友备注名
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *chatId; // 聊天id
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *user_level_id;
@property (nonatomic, strong) NSString *register_time;



// 信誉分
@property (nonatomic, assign) NSInteger creditScore;
// 已完成的合约数量
@property (nonatomic, assign) NSInteger contractCount;
@end

NS_ASSUME_NONNULL_END
