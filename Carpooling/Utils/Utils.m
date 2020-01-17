//
//  Utils.m
//  SSC
//
//  Created by __ on 2018/12/17.
//  Copyright © 2018 __. All rights reserved.
//

#import "Utils.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@implementation Utils

//获得UIView所在的ViewController
//如果你有base viewcontroller，则UIViewController对应的是你的base viewcontroller
+ (UIViewController *)getSupreViewController:(UIView*)view
{
//此处的self.view指的是：如果你想获取的是控制器所在的父控制器，传入的是你当前控制器的view；如果想获取的是一个view的父控制器，直接传当前view本身就可以了
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

//注意考虑几种特殊情况：①A present B, B present C，参数vc为A时候的情况
/* 完整的描述请参见文件头部 */
+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    //方法1：递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) { //注要优先判断vc是否有弹出其他视图，如有则当前显示的视图肯定是在那上面
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }
    
    return currentShowingVC;
    
    /*
    //方法2：遍历方法
    while (1)
    {
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
            
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
            
        } else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
            
        //} else if (vc.childViewControllers.count > 0) {
        //    //如果是普通控制器，找childViewControllers最后一个
        //    vc = [vc.childViewControllers lastObject];
        } else {
            break;
        }
    }
    return vc;
    //*/
}

#pragma mark - 根据CIImage生成指定大小的UIImage
/** 根据CIImage生成指定大小的UIImage */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGSize)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.height/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

/** 等比例压缩图片UIImage */
+ (NSData *)compressImage:(UIImage *)image withSize:(CGSize)size{
    CGFloat hfactor = image.size.width / size.width;
    CGFloat vfactor = image.size.height / size.height;
    CGFloat factor = fmax(hfactor, vfactor);
    //画布大小
    CGFloat newWith = image.size.width / factor;
    CGFloat newHeigth = image.size.height / factor;
    CGSize newSize = CGSizeMake(newWith, newHeigth);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newWith, newHeigth)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //图像压缩
    NSData *newImageData = UIImageJPEGRepresentation(newImage, 0.5);
    return newImageData;
}

/*
 周边加阴影，并且同时圆角
 */
+ (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius
{
    //////// shadow /////////
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.frame = view.layer.frame;
    
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    shadowLayer.shadowOffset = CGSizeMake(0, 0);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    shadowLayer.shadowOpacity = shadowOpacity;//0.8;//阴影透明度，默认0
    shadowLayer.shadowRadius = shadowRadius;//8;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = shadowLayer.bounds.size.width;
    float height = shadowLayer.bounds.size.height;
    float x = shadowLayer.bounds.origin.x;
    float y = shadowLayer.bounds.origin.y;
    
    CGPoint topLeft      = shadowLayer.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offset = -1.f;
    [path moveToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + cornerRadius, topLeft.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(topRight.x - cornerRadius, topRight.y - offset)];
    [path addArcWithCenter:CGPointMake(topRight.x - cornerRadius, topRight.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomRight.x + offset, bottomRight.y - cornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - cornerRadius, bottomRight.y - cornerRadius) radius:(cornerRadius + offset) startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y + offset)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y - cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    
    //设置阴影路径
    shadowLayer.shadowPath = path.CGPath;
    
    //////// cornerRadius /////////
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [view.superview.layer insertSublayer:shadowLayer below:view.layer];
}



#pragma mark - md5 加密
//md5 encode
+ (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return output;
}

#pragma mark - sha1 加密
//sha1 encode
+ (NSString*) sha1:(NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

#pragma mark - 去掉特殊符号和标点
+ (NSString *)deleteSpecialCharacters:(NSString *)targetString{
    
    if (targetString.length==0 || !targetString) {
        return nil;
    }
    
    NSError *error = nil;
    NSString *pattern = @"[^a-zA-Z0-9\u4e00-\u9fa5]";//正则取反
    NSRegularExpression *regularExpress = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];//这个正则可以去掉所有特殊字符和标点
    NSString *string = [regularExpress stringByReplacingMatchesInString:targetString options:0 range:NSMakeRange(0, [targetString length]) withTemplate:@""];
    
    return string;
}

#pragma mark - 验证邮箱格式
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - is same day
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day] == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year] == [comp2 year];
}

#pragma mark - 日期格式转字符串
//日期格式转字符串
+ (NSString *)dateToString:(NSDate *)date withDateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

//字符串转日期格式
+ (NSDate *)stringToDate:(NSString *)dateString withDateFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];    
    [dateFormatter setDateFormat:format];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
//    return [self worldTimeToChinaTime:date];
}

//将世界时间转化为中国区时间
+ (NSDate *)worldTimeToChinaTime:(NSDate *)date
{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval:interval];
    return localeDate;
}


// @"yyyy-MM-dd HH:mm:ss"
+ (NSString *)getDateWithDateString:(NSString *)dateStr
                       inputFormat:(NSString *)inputFormat
                      andOutFormat:(NSString *)outFormat{
    
    NSDateFormatter* inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:inputFormat];
    
    NSDate *date = [inputFormatter dateFromString:dateStr];
    
    NSDateFormatter* outputFormatter = [[NSDateFormatter alloc] init];
    //    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:outFormat];
    
    return [outputFormatter stringFromDate:date];
}

//获取当前时间戳, 精确到秒
+ (NSTimeInterval)getCurrentTimestampSecond{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    //    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSTimeInterval timestamp = [date timeIntervalSince1970];// *1000 是精确到毫秒，不乘就是精确到秒
    return timestamp;
}

//获取当前时间戳, 精确到毫秒
+ (NSTimeInterval)getCurrentTimestampMillisecond{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval timestamp = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    return timestamp;
}

//传入时间字符串生成UTC时间戳, 毫秒或秒
+ (NSTimeInterval)getTimeStampUTCWithTimeString:(NSString *)timeString format:(NSString*)format{
    // 精确到毫秒
    //format :@"2018-01-01T08:00:00.261" @"yyyy-MM-dd'T'HH:mm:ss.SSS"
    // 精确到秒
    //format :@"2018-01-01T08:00:00"  @"yyyy-MM-dd'T'HH:mm:ss"

    
    NSDate *anyDate = [self stringToDate:timeString withDateFormat:format];
    //    NSDate *anyDate = [NSDate dateFromString:timeString];//format :@"2018-01-01T08:00:00"
    NSTimeInterval timestamp = [anyDate timeIntervalSince1970];
    NSLog(@"getTimeStampUTCWithTimeString:format:%@\n ====%lu\n", anyDate, (unsigned long)timestamp);
    return timestamp;
}

//传入时间生成UTC时间戳, 毫秒或秒
+ (NSTimeInterval)getTimeStampUTCWithDate:(NSDate *)date{
    //    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
//    NSTimeInterval time = [date timeIntervalSince1970];// *1000 是精确到毫秒，不乘就是精确到秒
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    NSLog(@"getTimeStampUTCWithDate: ====%lu\n", (unsigned long)timestamp);
    return timestamp;
}

+ (NSString *) getWeekDayStringWithDate:(NSDate *) date{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
    // 1 是周日，2是周一 3.以此类推
    NSNumber * weekNumber = @([comps weekday]);
    NSInteger weekInt = [weekNumber integerValue];
    NSString *weekDayString = kLocalizedTableString(@"MondayLong", @"CPLocalizable");
    switch (weekInt) {
        case 1:{weekDayString = kLocalizedTableString(@"SundayLong", @"CPLocalizable");}
        break;
        case 2:{weekDayString = kLocalizedTableString(@"MondayLong", @"CPLocalizable");}
        break;
        case 3:{weekDayString = kLocalizedTableString(@"TuesdayLong", @"CPLocalizable");}
        break;
        case 4:{weekDayString = kLocalizedTableString(@"WednesdayLong", @"CPLocalizable");}
        break;
        case 5:{weekDayString = kLocalizedTableString(@"ThursdayLong", @"CPLocalizable");}
        break;
        case 6:{weekDayString = kLocalizedTableString(@"FridayLong", @"CPLocalizable");}
        break;
        case 7:{weekDayString = kLocalizedTableString(@"SaturdayLong", @"CPLocalizable");}
        break;
            
        default:
        break;
    }
    
    return weekDayString;
}

#pragma mark - 时间戳转时间, 精确到秒
+ (NSDate *)getDateWithTimestamp:(NSUInteger)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

    return date;
}

// 比较两个时间 相差
+ (NSDateComponents*)comparedifferenceWithDate1:(NSDate*)date1 toADate2:(NSDate*)date2{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date1 toDate:date2 options:0];
    
//    NSInteger sec = [d hour]*3600+[d minute]*60+[d second];
//    NSLog(@"difference second = %ld", [d hour]*3600 +[d minute]*60 +[d second]);
//    return sec;
    return dateComponents;
}

//    [dateComponent setYear:1]; // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
+ (NSDate*)expectDateByCurrentDate:(NSInteger)num{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    //    [dateComponent setYear:1]; // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
    [dateComponent setMonth:num];
    NSDate *expectDate = [calendar dateByAddingComponents:dateComponent toDate:currentDate options:0];
    
    return expectDate;
}

//传入 秒  得到时间 xx:xx:xx
+ (NSString *)getMMSSFromSS:(NSInteger)totalSeconds{
    //format of hour
    NSString *hour = [NSString stringWithFormat:@"%02ld", totalSeconds/3600];
    //format of minute
    NSString *minute = [NSString stringWithFormat:@"%02ld", (totalSeconds%3600)/60];
    //format of second
    NSString *second = [NSString stringWithFormat:@"%02ld", totalSeconds%60];
    //format of time
    NSString *formatTime = [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];
    
    return formatTime;
}

+ (NSInteger)getAgeWithBirthDay:(NSString *)birthDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    NSDate *nowDate = [NSDate date];
//    NSString *birth = @"2016-10-30";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //生日
    NSDate *birthDate = [dateFormatter dateFromString:birthDay];
    //用来得到详细的时差
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:birthDate toDate:nowDate options:0];
    
    return dateComponents.year;
}







+ (NSString *)getImageTypeWithImageUrl:(NSString *)imageUrl{
    
    NSRange range = [imageUrl rangeOfString:@".(png|PNG|jpg|jpeg|JPG|JPEG)" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return [imageUrl substringFromIndex:range.location];
    }
    
    return @" ";
}


+ (NSString*)getChineseWeek:(NSInteger)week{
    
    NSString *weekStr = nil;
    if(week == 1)
    {
        weekStr = @"周日";
    }else if(week == 2){
        weekStr = @"周一";
        
    }else if(week == 3){
        weekStr = @"周二";
        
    }else if(week == 4){
        weekStr = @"周三";
        
    }else if(week == 5){
        weekStr = @"周四";
        
    }else if(week == 6){
        weekStr = @"周五";
        
    }else if(week == 7){
        weekStr = @"周六";
    }
    
    return weekStr;
}





#pragma mark - number转 想要的格式的string
// e.g. NSNumberFormatterDecimalStyle
// e.g. @"###,##0.00"
+ (NSString*)convertNumberToFormatString:(NSNumber *)number numberStyle:(NSNumberFormatterStyle)style format:(NSString *)format{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    //    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.numberStyle = style;
    if (nil != format && format.length != 0) {
        [numberFormatter setPositiveFormat:format];
    }
    
    return (nil == number) ? @"" : [numberFormatter stringFromNumber:number];
}

#pragma mark - string转number
+ (NSNumber*)convertNumberStringToNumber:(NSString *)numberString{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    return [numberFormatter numberFromString:numberString];
}



#pragma mark - 获取tableview当前点击的 cell NSIndexPath
+ (NSIndexPath*)findIndexPathWithView:(UITableView *)tableview event:(id)event{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:tableview];
    
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:touchPoint];
    if (nil != indexPath)
    {
        return indexPath;
    }
    return nil;
}



@end
