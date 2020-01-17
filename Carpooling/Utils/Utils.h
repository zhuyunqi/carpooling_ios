//
//  Utils.h
//  SSC
//
//  Created by __ on 2018/12/17.
//  Copyright © 2018 __. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

//获得UIView所在的ViewController
//如果你有base viewcontroller，则UIViewController对应的是你的base viewcontroller
+ (UIViewController *)getSupreViewController:(UIView*)view;

//注意考虑几种特殊情况：①A present B, B present C，参数vc为A时候的情况
/* 完整的描述请参见文件头部 */
+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc;

/** 根据CIImage生成指定大小的UIImage */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGSize)size;

/** 等比例压缩图片UIImage */
+ (NSData *)compressImage:(UIImage *)image withSize:(CGSize)size;

/*
 周边加阴影，并且同时圆角
 */
+ (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius;


+ (NSString *)getImageTypeWithImageUrl:(NSString *)imageUrl;

/*
 加密实现MD5和SHA1
 */
+ (NSString *) md5:(NSString *)str;
+ (NSString*) sha1:(NSString *)str;


// 去掉特殊符号和标点 过滤特殊符号、标点
+ (NSString *)deleteSpecialCharacters:(NSString *)targetString;

// 验证邮箱格式
+ (BOOL)isValidateEmail:(NSString *)email;


// is same day
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

//日期格式转字符串
+ (NSString *)dateToString:(NSDate *)date withDateFormat:(NSString *)format;

//字符串转日期格式
+ (NSDate *)stringToDate:(NSString *)dateString withDateFormat:(NSString *)format;

//将世界时间转化为中国区时间
+ (NSDate *)worldTimeToChinaTime:(NSDate *)date;

+ (NSString*)getChineseWeek:(NSInteger)week;


+ (NSString *)getDateWithDateString:(NSString *)dateStr
                       inputFormat:(NSString *)inputFormat
                      andOutFormat:(NSString *)outFormat;

//获取当前时间戳, 精确到秒
+ (NSTimeInterval)getCurrentTimestampSecond;
//获取当前时间戳, 精确到毫秒
+ (NSTimeInterval)getCurrentTimestampMillisecond;

//传入时间字符串生成UTC时间戳, 毫秒或秒
+ (NSTimeInterval)getTimeStampUTCWithTimeString:(NSString *)timeString format:(NSString*)format;
+ (NSTimeInterval)getTimeStampUTCWithDate:(NSDate *)date;

// 传入日期，返回星期
+ (NSString *) getWeekDayStringWithDate:(NSDate *) date;

//传入UTC时间戳, 转换成时间
+ (NSDate *)getDateWithTimestamp:(NSUInteger)timestamp;

// 两个时间相差 NSDateComponents
+ (NSDateComponents*)comparedifferenceWithDate1:(NSDate*)date1 toADate2:(NSDate*)date2;
//    [dateComponent setYear:1]; // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
+ (NSDate*)expectDateByCurrentDate:(NSInteger)num;

//传入 秒  得到时间 xx:xx:xx
+ (NSString *)getMMSSFromSS:(NSInteger)totalSeconds;

+ (NSInteger)getAgeWithBirthDay:(NSString*)birthDay;



/**
 *  number转string
 */
// e.g. NSNumberFormatterDecimalStyle
// e.g. @"###,##0.00"
+ (NSString*)convertNumberToFormatString:(NSNumber *)number numberStyle:(NSNumberFormatterStyle)style format:(NSString *)format;
/**
 *  string转number
 */
+ (NSNumber*)convertNumberStringToNumber:(NSString *)numberString;


@end

NS_ASSUME_NONNULL_END
