//
//  IQActionSheetDoneBarButtonItem.h
//  IQActionSheetPickerView
//
//  Created by __ on 2018/12/17.
//

#import <UIKit/UIBarButtonItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface IQActionSheetDoneBarButtonItem : UIBarButtonItem

/**
 Font to be used in bar button. Default is (system font 12.0 bold).
 */
@property(nullable, nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

/**
 Title color to be used.
 */
@property(nullable, nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;

/**
 Initialize with frame and title.
 
 @param title Title of barButtonItem.
 */
-(nonnull instancetype)initWithTitle:(nullable NSString *)title NS_DESIGNATED_INITIALIZER;

/**
 Unavailable. Please use initWithFrame:title: method
 */
-(nonnull instancetype)init NS_UNAVAILABLE;

/**
 Unavailable. Please use initWithFrame:title: method
 */
-(nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Unavailable. Please use initWithFrame:title: method
 */
+ (nonnull instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
