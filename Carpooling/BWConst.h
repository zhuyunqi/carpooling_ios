//
//  BWConst.h
//  BWPageViewController
//
//  Created by __ on 2019/4/9.
//  Copyright © 2019 __. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface BWConst : NSObject
//
//
//
//@end
//
//NS_ASSUME_NONNULL_END



#import <UIKit/UIKit.h>


#define BaseURL @"http://mgsfc.172u.win:888"


#define kKeychainAnonymousChatAccountService @"com.bw.Carpooling"
#define kKeychainAnonymousChatAccount @"kKeychainAnonymousChatAccount"
#define kUserLoginAccount @"kUserLoginAccount"
#define kUserIsRegisterChatAccount @"kUserIsRegisterChatAccount"
#define kUserIsRegisterAnonymousChatAccount @"kUserIsRegisterAnonymousChatAccount"
#define kUserToken @"kUserToken"
#define kUserID @"kUserID"
#define kUserAvatar @"kUserAvatar"
#define kUserNickname @"kUserNickname"
#define kIsFirstOpen @"kIsFirstOpen"
#define kDeviceToken @"kDeviceToken"

#define kAnonymousUserId @"kAnonymousUserId"
#define kAnonymousUserToken @"kAnonymousUserToken"

#define kHasChangeLanguage @"kChangeLanguage"


/**********屏幕的宽高***************/
#define kSCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define kSCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
/**********状态栏导航栏相关**********/
#define kIS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIS_IPHONEX kSCREENWIDTH >=375.0f && kSCREENHEIGHT >=812.0f&& kIS_IPHONE
/*状态栏高度*/
#define kSTATUSBARHEIGHT (CGFloat)(kIS_IPHONEX?(44.0):(20.0))
/*导航栏高度*/
#define kNAVIBARHEIGHT (44)
/*状态栏和导航栏总高度*/
#define kNAVIBARANDSTATUSBARHEIGHT (CGFloat)(kIS_IPHONEX?(88.0):(64.0))
/*TabBar高度*/
#define kTABBARHEIGHT (CGFloat)(kIS_IPHONEX?(49.0 + 34.0):(49.0))
/*顶部安全区域远离高度*/
#define kTOPBARSAFEHEIGHT (CGFloat)(kIS_IPHONEX?(44.0):(0))
/*底部安全区域远离高度*/
#define kBOTTOMSAFEHEIGHT (CGFloat)(kIS_IPHONEX?(34.0):(0))
/*iPhoneX的状态栏高度差值*/
#define kTOPBARDIFHEIGHT (CGFloat)(kIS_IPHONEX?(24.0):(0))
/*导航条和Tabbar总高度*/
#define kNAVIBARANDSTATUSBARANDTABBARHEIGHT (kNAVIBARANDSTATUSBARHEIGHT + kTABBARHEIGHT)


#define RGBA(r,g,b,a) [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]
#define TABLEVIEWBACKGROUNDCOLOR   [UIColor whiteColor]
#define SECTIONHEADERVIEWBACKGROUNDCOLOR   RGBA(244, 245, 250, 1)

#define CPREGULARCELLHEIGHT 50


//根据内容、宽度、最大高度、字号，返回CGsize值
#define W_GET_STRINGSIZE(_text_,_width_,_height_,_font_)           [_text_ boundingRectWithSize:CGSizeMake(_width_,_height_) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _font_} context:nil].size;

/**
 *  device system version
 */
#define DEVICE_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
///////////////////////////End: Device Macro definition///////////////////////////
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
///////////////////////////Begin: Function Macro definition/////////////////////////
/**
 *  __weak self define
 */
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

/**
 *  object is not nil and null
 */
#define NotNilAndNull(_ref)  (((_ref) != nil) && (![(_ref) isEqual:[NSNull null]]))

/**
 *  object is nil or null
 */
#define IsNilOrNull(_ref)   (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) || ([(_ref) isEqual:[NSNull class]]))

/**
 *  string is nil or null or empty
 */
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))

/**
 *  Array is nil or null or empty
 */
#define IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))

/**
 *  validate string
 */
#define VALIDATE_STRING(str) (IsNilOrNull(str) ? @"" : str)

/**
 *  update string
 */
#define UPDATE_STRING(old, new) ((IsNilOrNull(new) || IsStrEmpty(new)) ? old : new)

/**
 *  validate NSNumber
 */
#define VALIDATE_NUMBER(number) (IsNilOrNull(number) ? @0 : number)

/**
 *  update NSNumber
 */
#define UPDATE_NUMBER(old, new) (IsNilOrNull(new) ? old : new)

/**
 *  validate NSArray
 */
#define VALIDATE_ARRAY(arr) (IsNilOrNull(arr) ? [NSArray array] : arr)


/**
 *  validate NSMutableArray
 */
#define VALIDATE_MUTABLEARRAY(arr) (IsNilOrNull(arr) ? [NSMutableArray array] :     [NSMutableArray arrayWithArray: arr])



/**
 *  update NSArray
 */
#define UPDATE_ARRAY(old, new) (IsNilOrNull(new) ? old : new)

/**
 *  update NSDate
 */
#define UPDATE_DATE(old, new) (IsNilOrNull(new) ? old : new)

/**
 *  validate bool
 */
#define VALIDATE_BOOL(value) ((value > 0) ? YES : NO)

/**
 *  Url transfer
 */
#define String_To_URL(str) [NSURL URLWithString: str]

/**
 *  nil turn to null
 */
#define Nil_TURNTO_Null(objc) (objc == nil ? [NSNull null] : objc)
///////////////////////////End: Function Macro definition/////////////////////////
//////////////////////////////////////////////////////////////////////////////////


#define IOS_SYSTEM_VERSION_LESS_THAN(v)                                     \
([[[UIDevice currentDevice] systemVersion]                                   \
compare:v                                                               \
options:NSNumericSearch] == NSOrderedAscending)


#define RGBCOLOR(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1]
#define RGBACOLOR(r, g, b, a) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:(a)]
#define HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]


#define SDColor(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]

#define Global_tintColor [UIColor colorWithRed:0 green:(190 / 255.0) blue:(12 / 255.0) alpha:1]

#define Global_mainBackgroundColor SDColor(248, 248, 248, 1)

#define TimeLineCellHighlightedColor [UIColor colorWithRed:92/255.0 green:140/255.0 blue:193/255.0 alpha:1.0]

#define DAY @"day"

#define NIGHT @"night"

//是否iPhoneX YES:iPhoneX屏幕 NO:传统屏幕
#define kIs_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812.0f ||[UIScreen mainScreen].bounds.size.height == 896.0f )

#define kStatusBarAndNavigationBarHeight (kIs_iPhoneX ? 88.f : 64.f)

#define  kTabbarSafeBottomMargin        (kIs_iPhoneX ? 34.f : 0.f)

#define kMessageListChanged  @"kMessageListChanged"

#define WFCU_SUPPORT_VOIP 0



