//
//  BWLocalizableHelper.h
//  Carpooling
//
//  Created by Yang on 2019/6/5.
//  Copyright © 2019 bw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ChangeLanguageNotificationName @"changeLanguage"
#define kLocalizedString(key) [kLanguageManager localizedStringForKey:key]
#define kLocalizedTableString(key,tableN) [kLanguageManager localizedStringForKey:key tableName:tableN]

NS_ASSUME_NONNULL_BEGIN

//@"zh-Hans-CN", //中文简体
//@"zh-Hant-CN", //中文繁体
//@"en-CN", //英语

@interface BWLocalizableHelper : NSObject

@property (nonatomic,copy) void (^completion)(NSString *currentLanguage);

- (NSString *)currentLanguage; //当前语言
- (NSString *)languageFormat:(NSString*)language;
- (void)setUserlanguage:(NSString *)language;//设置当前语言

- (NSString *)localizedStringForKey:(NSString *)key;

- (NSString *)localizedStringForKey:(NSString *)key tableName:(NSString *)tableName;

- (UIImage *)ittemInternationalImageWithName:(NSString *)name;

+ (instancetype)shareInstance;

#define kLanguageManager [BWLocalizableHelper shareInstance]

@end

NS_ASSUME_NONNULL_END
