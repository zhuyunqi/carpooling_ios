//
//  CPAddressModel.m
//  Carpooling
//
//  Created by Yang on 2019/6/16.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPAddressModel.h"

@implementation CPAddressModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"desc":@"description",
             @"dataid":@"id",
             
             // 左边代表 NHYHCGetHospitalsResult的属性NSArray *hospitals
             // 右边代表 服务器返回的数据中的字段名
             // 服务器返回的hospital_info是一个数组
             };
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    //告诉系统归档的属性是哪些
    unsigned int count = 0;//表示对象的属性个数
    Ivar *ivars = class_copyIvarList([CPAddressModel class], &count);
    for (int i = 0; i<count; i++) {
        //拿到Ivar
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);//获取到属性的C字符串名称
        NSString *key = [NSString stringWithUTF8String:name];//转成对应的OC名称
        //归档 -- 利用KVC
        [coder encodeObject:[self valueForKey:key] forKey:key];
    }
    free(ivars);//在OC中使用了Copy、Creat、New类型的函数，需要释放指针！！（注：ARC管不了C函数）
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        //解档
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([CPAddressModel class], &count);
        for (int i = 0; i<count; i++) {
            //拿到Ivar
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            //解档
            id value = [coder decodeObjectForKey:key];
            // 利用KVC赋值
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}

//+ (NSString *)handleAddressFormatWithModel:(CPAddressModel*)model{
//    // system language
//    BOOL isSystemLanguageEnglish = YES;
//    NSArray *languages = [NSLocale preferredLanguages];
//    NSString *currentLanguage = @"";
//    if (languages.count>0) {
//        currentLanguage = languages.firstObject;
//        if ([currentLanguage hasPrefix:@"en"]) {
//            isSystemLanguageEnglish = YES;
//        }
//        else if ([currentLanguage hasPrefix:@"zh"]) {
//            isSystemLanguageEnglish = NO;
//        }
//        else {
//            isSystemLanguageEnglish = YES;
//        }
//    }
//    else {
//        isSystemLanguageEnglish = YES;
//    }
//
//
//    // local language
//    BOOL isLocalLanguageEnglish = YES;
//    if ([[[BWLocalizableHelper shareInstance] currentLanguage] isEqualToString:@"zh-Hans-CN"]) {
//        isLocalLanguageEnglish = NO;
//    }
//    else if ([[[BWLocalizableHelper shareInstance] currentLanguage] isEqualToString:@"en-CN"]) {// system
//        if (!isSystemLanguageEnglish) {
//            isLocalLanguageEnglish = NO;
//        }
//    }
//
//
//    NSString *mixLocality = @"";
//    NSString *locality = nil;
//    NSString *sublocality = nil;
//    if (![model.locality isEqualToString:@""]) {
//        locality = model.locality;
//    }
//
//    if (![model.subLocality isEqualToString:@""]) {
//        sublocality = model.subLocality;
//    }
//
//    if (locality && sublocality) {
//        if (![locality isEqualToString:sublocality]) {
//            if (isSystemLanguageEnglish || isLocalLanguageEnglish) {
//                mixLocality = [NSString stringWithFormat:@"%@ %@", locality, sublocality];
//            }
//            else {
//                mixLocality = [NSString stringWithFormat:@"%@%@", locality, sublocality];
//            }
//
//        }
//        else {
//            mixLocality = locality;
//        }
//    }
//    else {
//        if (locality) {
//            mixLocality = locality;
//        }
//        else if (sublocality) {
//            mixLocality = sublocality;
//        }
//    }
//
//
//    NSString *address = @"";
//    if (isSystemLanguageEnglish || isLocalLanguageEnglish) {
//        address = [NSString stringWithFormat:@"%@ %@ %@", model.administrativeArea, mixLocality, model.thoroughfare];
//    }
//    else {
//        address = [NSString stringWithFormat:@"%@%@%@", model.administrativeArea, mixLocality, model.thoroughfare];
//    }
//
//    return address;
//}
@end
