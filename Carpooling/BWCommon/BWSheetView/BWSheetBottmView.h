//
//  BWSheetBottmView.h
//  SSC
//
//  Created by __ on 2019/3/14.
//  Copyright © 2019 __. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQActionSheetToolbar.h"

/**
 Action Sheet style settings.
 
 `BWActionSheetPickerStyleTextPicker`
 Show pickerView with provided text data.
 
 `BWActionSheetPickerStyleDatePicker`
 Show UIDatePicker.
 */
typedef NS_ENUM(NSUInteger, BWActionSheetPickerStyle) {
    
    BWActionSheetPickerStyleTextPicker,
    
    BWActionSheetPickerStyleDatePicker,  // apple default style
    
    BWActionSheetPickerStyleDateTimePicker,
    
    
    
    BWActionSheetPickerStyleOnlyTimePicker,
    
    BWActionSheetPickerStyleOnlyDatePicker, // custom calendar style

    BWActionSheetPickerStyleCalendarDateAndTimePicker,
};


@class BWSheetBottmView;
NS_ASSUME_NONNULL_BEGIN

@protocol BWSheetBottmViewDelegate <NSObject>

@optional
- (void)bwActionSheetPickerView:(nonnull BWSheetBottmView *)pickerView didSelectTitlesAtIndexes:(nonnull NSArray<NSNumber*>*)indexes;
- (void)bwActionSheetPickerView:(nonnull BWSheetBottmView *)pickerView didSelectTitles:(nonnull NSArray<NSString*>*)titles  __attribute__((deprecated("This is replaced by `actionSheetPickerView:didSelectTitlesAtIndexes`.")));    //If you implemented `actionSheetPickerView:didSelectTitlesAtIndexes:` delegate method then this method will not get called.


- (void)bwActionSheetPickerView:(nonnull BWSheetBottmView *)pickerView didSelectDate:(nonnull NSDate*)date;


- (void)bwActionSheetPickerView:(nonnull BWSheetBottmView *)pickerView didChangeRow:(NSInteger)row inComponent:(NSInteger)component;


- (void)bwActionSheetPickerViewDidCancel:(nonnull BWSheetBottmView *)pickerView;
- (void)bwActionSheetPickerViewWillCancel:(nonnull BWSheetBottmView *)pickerView;

- (void)bwActionSheetPickerView:(nonnull BWSheetBottmView *)pickerView calendarDidSelectDate:(nonnull NSDate*)date;
@end







//@interface BWSheetBottmView : UIView
@interface BWSheetBottmView : UIControl

@property(nullable, nonatomic, readonly) IQActionSheetToolbar *actionToolbar;
@property (nonatomic, assign) CGFloat height;


/*!
 Initialization method with a title for toolbar and a callback delegate
 */
- (nonnull instancetype)initWithTitle:(nullable NSString *)title delegate:(nullable id<BWSheetBottmViewDelegate>)delegate;

/*!
 delegate(weak reference) object to inform about the selected values in pickerView. Delegate method will be called on Done click.
 */
@property(nullable, nonatomic, weak) id<BWSheetBottmViewDelegate> delegate;


///----------------------
/// @name Show / Hide
///----------------------


/*!
 Show picker view with slide up animation.
 */
-(void)show;

/*!
 Show picker view with slide up animation, completion block will be called on animation completion.
 */
-(void)showWithCompletion:(nullable void (^)(void))completion;

/*!
 Dismiss picker view with slide down animation.
 */
-(void)dismiss;

/*!
 Dismiss picker view with slide down animation, completion block will be called on animation completion.
 */
-(void)dismissWithCompletion:(nullable void (^)(void))completion;

/*!
 Disable dismiss action sheet when touching blank area at the top.
 */
@property(nonatomic, assign) BOOL disableDismissOnTouchOutside;





/*!
 actionSheetPickerStyle to show in picker. Default is IQActionSheetPickerStyleTextPicker.
 */
@property(nonatomic, assign) BWActionSheetPickerStyle actionSheetPickerStyle;   //


/*!
 limit the datePicker selecte time
 */
@property(nonatomic, assign) BOOL datePickerTimelimit;

///-----------------------------------------
/// @name IQActionSheetPickerStyleTextPicker
///-----------------------------------------

/*!
 selected indexes for each component. (Not Animated)
 */
@property(nullable, nonatomic, strong) NSArray<NSNumber*> *selectedIndexes;

/*!
 Select the provided index row for each component. Ignore if actionSheetPickerStyle is IQActionSheetPickerStyleDatePicker.
 */
-(void)setSelectedIndexes:(nonnull NSArray<NSNumber*> *)selectedIndexes animated:(BOOL)animated;


/*!
 get selected row in component.
 */
-(NSInteger)selectedRowInComponent:(NSUInteger)component;

/*!
 Select a row in pickerView.
 */
-(void)selectRowAtIndexPath:(nonnull NSIndexPath*)indexPath;
-(void)selectRowAtIndexPath:(nonnull NSIndexPath*)indexPath animated:(BOOL)animated;

/*!
 Titles to show for component. For example. @[ @[ @"1", @"2", @"3", ], @[ @"11", @"12", @"13", ], @[ @"21", @"22", @"23", ]].
 */
@property(nullable, nonatomic, strong) NSArray<NSArray<NSString*> *> *titlesForComponents;

/*!
 Width to adopt for each component. If you don't want to specify a row width then use @(0) to calculate row width automatically.
 */
@property(nullable, nonatomic, strong) NSArray<NSNumber*> *widthsForComponents;

/*!
 Height to adopt for all component.
 */
@property(nonatomic, assign) CGFloat heightForComponents;

/*!
 Font for the UIPickerView components
 */
@property(nullable, nonatomic, strong) UIFont *pickerComponentsFont UI_APPEARANCE_SELECTOR;
/*!
 Background color for the `UIPickerView`
 */
@property(nullable, nonatomic, strong) UIColor *pickerViewBackgroundColor UI_APPEARANCE_SELECTOR;
/*!
 *  Color for the UIPickerView
 */
@property(nullable, nonatomic, strong) UIColor *pickerComponentsColor UI_APPEARANCE_SELECTOR;

/*!
 If YES then it will force to scroll third picker component to pick equal or larger row then the first.
 */
@property(nonatomic, assign) BOOL isRangePickerView;

/*!
 Reload a component in pickerView.
 */
-(void)reloadComponent:(NSInteger)component;

/*!
 Reload all components in pickerView.
 */
-(void)reloadAllComponents;


///-------------------------------------------------------------------------------------------------------------------
/// @name BWActionSheetPickerStyleDatePicker/BWActionSheetPickerStyleDateTimePicker/BWActionSheetPickerStyleTimePicker
///-------------------------------------------------------------------------------------------------------------------

/*!
 selected date. Can also be use as setter method (not animated).
 */
@property(nullable, nonatomic, assign) NSDate *date; //get/set date.

/*!
 set selected date.
 */
-(void)setDate:(nonnull NSDate *)date animated:(BOOL)animated;

/*!
 Minimum selectable date in UIDatePicker. Default is nil.
 */
@property (nullable, nonatomic, retain) NSDate *minimumDate;

/*!
 Maximum selectable date in UIDatePicker. Default is nil.
 */
@property (nullable, nonatomic, retain) NSDate *maximumDate;
@end

NS_ASSUME_NONNULL_END
