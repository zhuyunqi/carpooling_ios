//
//  IQActionSheetDoneBarButtonItem.m
//  IQActionSheetPickerView
//
//  Created by __ on 2018/12/17.
//

#import "IQActionSheetDoneBarButtonItem.h"
#import <UIKit/UIButton.h>
#import <UIKit/UILabel.h>
#import <UIKit/UIDatePicker.h>
#import <UIKit/UIPickerView.h>
#import <Foundation/NSDate.h>

@implementation IQActionSheetDoneBarButtonItem
{
    UIView *_titleView;
    UIButton *_doneButton;
}
@synthesize titleFont = _titleFont;

-(nonnull instancetype)initWithTitle:(nullable NSString *)title
{
    self = [super init];
    if (self)
    {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_doneButton setBackgroundColor:[UIColor clearColor]];
        [_doneButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self setTitle:title];
        [self setTitleFont:[UIFont systemFontOfSize:13.0]];
        [_titleView addSubview:_doneButton];
        
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 11)
        {
            _titleView.translatesAutoresizingMaskIntoConstraints = NO;
            [_titleView setContentHuggingPriority:UILayoutPriorityDefaultLow-1 forAxis:UILayoutConstraintAxisVertical];
            [_titleView setContentHuggingPriority:UILayoutPriorityDefaultLow-1 forAxis:UILayoutConstraintAxisHorizontal];
            [_titleView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh-1 forAxis:UILayoutConstraintAxisVertical];
            [_titleView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh-1 forAxis:UILayoutConstraintAxisHorizontal];
            
            _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_doneButton setContentHuggingPriority:UILayoutPriorityDefaultLow-1 forAxis:UILayoutConstraintAxisVertical];
            [_doneButton setContentHuggingPriority:UILayoutPriorityDefaultLow-1 forAxis:UILayoutConstraintAxisHorizontal];
            [_doneButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh-1 forAxis:UILayoutConstraintAxisVertical];
            [_doneButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh-1 forAxis:UILayoutConstraintAxisHorizontal];
            
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_doneButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_doneButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_doneButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_doneButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            [_titleView addConstraints:@[top,bottom,leading,trailing]];
        }
        else
        {
            _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            _doneButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        
        self.customView = _titleView;
    }
    return self;
}

-(void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    
    if (titleFont)
    {
        _doneButton.titleLabel.font = titleFont;
    }
    else
    {
        _doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    }
}

-(void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    if (titleColor)
    {
        [_doneButton setTitleColor:titleColor forState:UIControlStateDisabled];
    }
    else
    {
        [_doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [_doneButton setTitle:title forState:UIControlStateNormal];
}

@end
