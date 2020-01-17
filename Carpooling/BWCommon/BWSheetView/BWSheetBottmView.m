//
//  BWSheetBottmView.m
//  SSC
//
//  Created by __ on 2019/3/14.
//  Copyright © 2019 __. All rights reserved.
//

#import "BWSheetBottmView.h"
#import "BWSheetViewController.h"
#import "LTSCalendarContentView.h"
#import "LTSCalendarAppearance.h"
#import "LTSCalendarManager.h"

@interface BWSheetBottmView ()<LTSCalendarEventSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, strong) BWSheetViewController *actionSheetController;
@property (nonatomic, strong) LTSCalendarManager *manager;
@property (nonatomic, strong) LTSCalendarContentView *calendarView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *switchBtn;
@property(nonatomic, strong) NSDate *customSelectedDate; // custom calendar selected date

@property(nonatomic, strong) UIPickerView *pickerView;
@property(nonatomic, strong) UIDatePicker *datePicker;
@end



@implementation BWSheetBottmView

@synthesize actionSheetPickerStyle  = _actionSheetPickerStyle;
@synthesize titlesForComponents     = _titlesForComponents;
@synthesize widthsForComponents     = _widthsForComponents;
@synthesize heightForComponents     = _heightForComponents;
@synthesize isRangePickerView       = _isRangePickerView;
@synthesize delegate                = _delegate;
@synthesize date                    = _date;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<BWSheetBottmViewDelegate>)delegate
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        //UIToolbar
        {
            _actionToolbar = [[IQActionSheetToolbar alloc] init];
            [_actionToolbar sizeToFit];
//            _actionToolbar.barTintColor = [UIColor redColor];
            _actionToolbar.barStyle = UIBarStyleDefault;
            _actionToolbar.cancelButton.target = self;
            _actionToolbar.cancelButton.action = @selector(pickerCancelClicked:);
            _actionToolbar.doneButton.target = self;
            _actionToolbar.doneButton.action = @selector(pickerDoneClicked:);
            _actionToolbar.titleButton.title = title;
        }
        
        // calendar
        {
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((width-150)/2, 12, 150, 20)];
            label.font = [UIFont systemFontOfSize:15.f];
            label.textColor = [UIColor darkGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            [self.actionToolbar addSubview:label];
            self.dateLabel = label;
            
            
            // LTSCalendar
            [LTSCalendarAppearance share].weeksToDisplay = 6;
            [LTSCalendarAppearance share].weekDayHeight = 50;
            [LTSCalendarAppearance share].weekDayFormat = LTSCalendarWeekDayFormatShort;
            [LTSCalendarAppearance share].isShowSingleWeek = false;
            [LTSCalendarAppearance share].defaultSelected = false;
            
            self.manager = [LTSCalendarManager new];
            self.manager.eventSource = self;
            self.manager.weekDayView = [[LTSCalendarWeekDayView alloc]initWithFrame:CGRectMake(0, 0, width, 30)];
            [self addSubview:self.manager.weekDayView];
            
            _calendarView = [[LTSCalendarContentView alloc]initWithFrame:CGRectMake(0, 30, width, [LTSCalendarAppearance share].weekDayHeight*[LTSCalendarAppearance share].weeksToDisplay)];
            _calendarView.currentDate = [NSDate date];
            _calendarView.eventSource = self.manager.eventSource;
            [self addSubview:_calendarView];
            
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.frame = CGRectMake(width-130, CGRectGetMaxY(_calendarView.frame)-15, 113, 30);
            [btn setTitle:kLocalizedTableString(@"Select time", @"CPLocalizable") forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:38/255.f green:96/255.f blue:111/255.f alpha:1] forState:UIControlStateNormal];
            if (@available(iOS 8.2, *)) {
                btn.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
            } else {
                // Fallback on earlier versions
                btn.titleLabel.font = [UIFont systemFontOfSize:16.f];
            }
//            btn.layer.borderColor = [UIColor redColor].CGColor;
//            btn.layer.borderWidth = 1;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            btn.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            self.switchBtn = btn;
        }
    
        
        //UIPickerView
        {
            _pickerView = [[UIPickerView alloc] init];
            [_pickerView sizeToFit];
            [_pickerView setShowsSelectionIndicator:YES];
            [_pickerView setDelegate:self];
            [_pickerView setDataSource:self];
            _pickerView.hidden = YES;
            [self addSubview:_pickerView];
        }
        
        //UIDatePicker
        {
            _datePicker = [[UIDatePicker alloc] init];
            [_datePicker sizeToFit];
            [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            [_datePicker setDatePickerMode:UIDatePickerModeDate];
            _datePicker.hidden = YES;
            [self addSubview:_datePicker];
        }
        
        NSDictionary *viewDict = NSDictionaryOfVariableBindings(_pickerView, _datePicker);
        _pickerView.translatesAutoresizingMaskIntoConstraints = NO;
        _datePicker.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray<NSLayoutConstraint*>*horizontalPickerConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[_pickerView]|" options:0 metrics:nil views:viewDict];
        NSArray<NSLayoutConstraint*>*verticalPickerConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_pickerView]-|" options:NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing metrics:nil views:viewDict];
        
        NSArray<NSLayoutConstraint*>*horizontalDateConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[_datePicker]|" options:0 metrics:nil views:viewDict];
        NSArray<NSLayoutConstraint*>*verticalDateConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_datePicker]-|" options:0 metrics:nil views:viewDict];
        
        [self addConstraints:horizontalPickerConstraints];
        [self addConstraints:verticalPickerConstraints];
        [self addConstraints:horizontalDateConstraints];
        [self addConstraints:verticalDateConstraints];
        
        //Initial settings
        {
            
//            [self setActionSheetPickerStyle:IQActionSheetPickerStyleTextPicker];
        }
        
        if (@available(iOS 13.0, *)) {
            UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor whiteColor];
                }
                else {
                    return [UIColor secondarySystemBackgroundColor];
                }
            }];
            _actionToolbar.backgroundColor = dyColor;
            
            UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor whiteColor];
                }
                else {
                    return [UIColor tertiarySystemBackgroundColor];
                }
            }];
            _pickerView.backgroundColor = dyColor2;
            self.backgroundColor = dyColor2;
            self.manager.weekDayView.backgroundColor = dyColor2;
            
        } else {
            // Fallback on earlier versions
            _actionToolbar.backgroundColor = [UIColor whiteColor];
            self.manager.weekDayView.backgroundColor = [UIColor whiteColor];
            _pickerView.backgroundColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor whiteColor];
        }
    }
    
    _delegate = delegate;
    
    return self;
}

#pragma mark - switch select date or time
- (void)btnAction:(UIButton*)btn{
    if (self.actionSheetPickerStyle == BWActionSheetPickerStyleOnlyDatePicker) {
        return;
    }
    
    NSLog(@"BWSheetBottmView select time btnAction");
    [self bringSubviewToFront:btn];
    
    if (self.calendarView.isHidden) {
        self.calendarView.hidden = NO;
        self.manager.weekDayView.hidden = NO;
        
        _datePicker.hidden = YES;
        _pickerView.hidden = YES;
        
        [self setActionSheetPickerStyle:BWActionSheetPickerStyleCalendarDateAndTimePicker];
        [btn setTitle:kLocalizedTableString(@"Select a time", @"CPLocalizable") forState:UIControlStateNormal];
    }
    else if (!self.calendarView.isHidden) {
        self.calendarView.hidden = YES;
        self.manager.weekDayView.hidden = YES;
        
        [self setActionSheetPickerStyle:BWActionSheetPickerStyleOnlyTimePicker];
        [btn setTitle:kLocalizedTableString(@"Choose a date", @"CPLocalizable") forState:UIControlStateNormal];
    }
}

- (void)setHeight:(CGFloat)height{
    // max height 460
    height = MIN(height, 384);
    CGFloat screentHeight = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"screentHeight:%f", screentHeight);
    if (screentHeight <= 480) {
        height = 350;
    }
    
    _height = height;
}



-(void)setActionSheetPickerStyle:(BWActionSheetPickerStyle)actionSheetPickerStyle
{
    _actionSheetPickerStyle = actionSheetPickerStyle;
    
    switch (actionSheetPickerStyle) {
        case BWActionSheetPickerStyleTextPicker:
            if (self.calendarView.isHidden) {
                [_pickerView setHidden:NO];
                [_datePicker setHidden:YES];
            }

            break;
        case BWActionSheetPickerStyleDatePicker:
            if (self.calendarView.isHidden) {
                [_pickerView setHidden:YES];
                [_datePicker setHidden:NO];
            }

            [_datePicker setDatePickerMode:UIDatePickerModeDate];
            break;
        case BWActionSheetPickerStyleDateTimePicker:
            if (self.calendarView.isHidden) {
                [_pickerView setHidden:YES];
                [_datePicker setHidden:NO];
            }
            [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
            break;
        case BWActionSheetPickerStyleOnlyTimePicker:
            self.switchBtn.hidden = NO;
            if (self.calendarView.isHidden) {
                [_pickerView setHidden:YES];
                [_datePicker setHidden:NO];
            }
            [_datePicker setDatePickerMode:UIDatePickerModeTime];
            break;
        
        case BWActionSheetPickerStyleOnlyDatePicker:
            self.switchBtn.hidden = YES;

            break;
        case BWActionSheetPickerStyleCalendarDateAndTimePicker:
            self.switchBtn.hidden = NO;
            
            break;
            

        default:
            break;
    }
}

- (void)setDatePickerTimelimit:(BOOL)datePickerTimelimit{
    _datePickerTimelimit = datePickerTimelimit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:0];//设置最大时间为：当前年份推后0年
    [comps setMonth:0];//设置最大时间为：当前月份推后0月
    [comps setDay:0];//设置最大时间为：当前日推后0日
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [_datePicker setMaximumDate:maxDate];
}

/**
 *  Set Picker View Background Color
 *
 *  @param pickerViewBackgroundColor Picker view custom background color
 */
-(void)setPickerViewBackgroundColor:(UIColor *)pickerViewBackgroundColor{
    _pickerView.backgroundColor = pickerViewBackgroundColor;
}

#pragma mark - Done/Cancel

-(void)pickerCancelClicked:(UIBarButtonItem*)barButton
{
    if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerViewWillCancel:)])
    {
        [self.delegate bwActionSheetPickerViewWillCancel:self];
    }
    
    [self dismissWithCompletion:^{
        
        if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerViewDidCancel:)])
        {
            [self.delegate bwActionSheetPickerViewDidCancel:self];
        }
    }];
}

#pragma mark - pickerDoneClicked
-(void)pickerDoneClicked:(UIBarButtonItem*)barButton
{
    switch (_actionSheetPickerStyle)
    {
        case BWActionSheetPickerStyleTextPicker:
        {
            NSMutableArray<NSNumber*> *selectedIndexes = [[NSMutableArray alloc] init];
            
            for (NSInteger component = 0; component<_pickerView.numberOfComponents; component++)
            {
                NSInteger row = [_pickerView selectedRowInComponent:component];
                
                [selectedIndexes addObject:@(row)];
            }
            
            [self setSelectedIndexes:selectedIndexes];
            
            if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerView:didSelectTitlesAtIndexes:)])
            {
                [self.delegate bwActionSheetPickerView:self didSelectTitlesAtIndexes:selectedIndexes];
            }
            else
            {
                NSMutableArray<NSString*> *selectedTitles = [[NSMutableArray alloc] init];
                
                for (NSUInteger component = 0; component<selectedIndexes.count; component++)
                {
                    NSInteger row = [selectedIndexes[component] integerValue];
                    
                    if (row != -1)
                    {
                        [selectedTitles addObject:_titlesForComponents[component][row]];
                    }
                    else
                    {
                        [selectedTitles addObject:@""];
                    }
                }
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerView:didSelectTitles:)])
                {
                    [self.delegate bwActionSheetPickerView:self didSelectTitles:selectedTitles];
                }
#pragma clang diagnostic pop
            }
        }
            break;
        case BWActionSheetPickerStyleDatePicker:
        case BWActionSheetPickerStyleDateTimePicker:
        case BWActionSheetPickerStyleOnlyTimePicker:
        {
            [self setDate:_datePicker.date];
            
            if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerView:didSelectDate:)])
            {
                [self.delegate bwActionSheetPickerView:self didSelectDate:_datePicker.date];
            }
        }
            break;
            
        case BWActionSheetPickerStyleOnlyDatePicker:
        {
//            [self setDate:_datePicker.date];
            
            if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerView:didSelectDate:)])
            {
                [self.delegate bwActionSheetPickerView:self didSelectDate:self.customSelectedDate];
            }
        }
            break;
        case BWActionSheetPickerStyleCalendarDateAndTimePicker:
        {
            [self setDate:_datePicker.date];
            
            if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerView:didSelectDate:)])
            {
                [self.delegate bwActionSheetPickerView:self didSelectDate:_datePicker.date];
            }
        }
            break;
            
            
        default:
            break;
    }
    
    [self dismiss];
}


#pragma mark - show/Hide
-(void)dismiss
{
    [_actionSheetController dismissWithCompletion:nil];
    _actionSheetController = nil;
}

-(void)dismissWithCompletion:(void (^)(void))completion
{
    [_actionSheetController dismissWithCompletion:completion];
    _actionSheetController = nil;
}

-(void)setDisableDismissOnTouchOutside:(BOOL)disableDismissOnTouchOutside
{
    _disableDismissOnTouchOutside = disableDismissOnTouchOutside;
    _actionSheetController.disableDismissOnTouchOutside = _disableDismissOnTouchOutside;
}

-(void)show
{
    [self showWithCompletion:nil];
}

-(void)showWithCompletion:(void (^)(void))completion
{
    if (_actionSheetController == nil)
    {
        _actionSheetController = [[BWSheetViewController alloc] init];
        _actionSheetController.disableDismissOnTouchOutside = self.disableDismissOnTouchOutside;
        [_actionSheetController showBottomView:self viewHeight:self.height completion:completion];
        
    }
}





#pragma mark - BWActionSheetPickerStyleDatePicker / BWActionSheetPickerStyleDateTimePicker / BWActionSheetPickerStyleTimePicker

-(void)dateChanged:(UIDatePicker*)datePicker
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) setDate:(NSDate *)date
{
    [self setDate:date animated:NO];
}

-(void)setDate:(NSDate *)date animated:(BOOL)animated
{
    _date = date;
    if (_date != nil)   [_datePicker setDate:_date animated:animated];
}

-(void)setMinimumDate:(NSDate *)minimumDate
{
    _minimumDate = minimumDate;
    
    _datePicker.minimumDate = minimumDate;
}

-(void)setMaximumDate:(NSDate *)maximumDate
{
    _maximumDate = maximumDate;
    
    _datePicker.maximumDate = maximumDate;
}

#pragma mark - BWActionSheetPickerStyleTextPicker

-(void)reloadComponent:(NSInteger)component
{
    [_pickerView reloadComponent:component];
}

-(void)reloadAllComponents
{
    [_pickerView reloadAllComponents];
}

-(void)setSelectedIndexes:(NSArray<NSNumber *> *)selectedIndexes
{
    [self setSelectedIndexes:selectedIndexes animated:NO];
}

-(NSArray<NSNumber *> *)selectedIndexes
{
    if (_actionSheetPickerStyle == BWActionSheetPickerStyleTextPicker)
    {
        NSMutableArray<NSNumber*> *selectedIndexes = [[NSMutableArray alloc] init];
        
        for (NSInteger component = 0; component<_pickerView.numberOfComponents; component++)
        {
            NSInteger row = [_pickerView selectedRowInComponent:component];
            
            [selectedIndexes addObject:@(row)];
        }
        
        return selectedIndexes;
    }
    else
    {
        return nil;
    }
}

-(void)setSelectedIndexes:(NSArray<NSNumber *> *)selectedIndexes animated:(BOOL)animated
{
    if (_actionSheetPickerStyle == BWActionSheetPickerStyleTextPicker)
    {
        NSUInteger totalComponent = MIN(MIN(selectedIndexes.count, _pickerView.numberOfComponents),_titlesForComponents.count);
        
        for (NSInteger component = 0; component<totalComponent; component++)
        {
            NSArray *items = _titlesForComponents[component];
            NSUInteger selectIndex = [selectedIndexes[component] unsignedIntegerValue];
            
            if (selectIndex < items.count)
            {
                [_pickerView selectRow:selectIndex inComponent:component animated:animated];
            }
        }
    }
}

-(NSInteger)selectedRowInComponent:(NSUInteger)component
{
    if (_actionSheetPickerStyle == BWActionSheetPickerStyleTextPicker)
    {
        NSUInteger totalComponent = MIN(_titlesForComponents.count, _pickerView.numberOfComponents);
        
        if (component < totalComponent)
        {
            return [_pickerView selectedRowInComponent:component];
        }
    }
    
    return -1;
}

-(void)selectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectRowAtIndexPath:indexPath animated:NO];
}

-(void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    if (_actionSheetPickerStyle == BWActionSheetPickerStyleTextPicker)
    {
        NSUInteger totalComponent = MIN(_titlesForComponents.count, _pickerView.numberOfComponents);
        
        if (indexPath.section < totalComponent)
        {
            NSArray *items = _titlesForComponents[indexPath.section];
            
            if (indexPath.row < items.count)
            {
                [_pickerView selectRow:indexPath.row inComponent:indexPath.section animated:animated];
            }
        }
    }
}

#pragma mark - UIPickerView delegate/dataSource

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    //If having widths
    if (_widthsForComponents)
    {
        CGFloat width = [_widthsForComponents[component] floatValue];
        
        //If width is 0, then calculating it's size.
        if (width <= 0)
            return ((pickerView.bounds.size.width-20)-2*(_titlesForComponents.count-1))/_titlesForComponents.count;
        //Else returning it's width.
        else
            return width;
    }
    //Else calculating it's size.
    else
    {
        return ((pickerView.bounds.size.width-20)-2*(_titlesForComponents.count-1))/_titlesForComponents.count;
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    // only BWActionSheetPickerStyleTextPicker
    if (_actionSheetPickerStyle == BWActionSheetPickerStyleTextPicker)
    {
        if (_heightForComponents) {
            return _heightForComponents;
        }
        return 30; // default
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [_titlesForComponents count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_titlesForComponents[component] count];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *labelText = [[UILabel alloc] init];
    if(self.pickerComponentsColor != nil) {
        labelText.textColor = self.pickerComponentsColor;
    }
    if(self.pickerComponentsFont == nil){
        labelText.font = [UIFont boldSystemFontOfSize:20.0];
    }else{
        labelText.font = self.pickerComponentsFont;
    }
    labelText.backgroundColor = [UIColor clearColor];
    [labelText setTextAlignment:NSTextAlignmentCenter];
    [labelText setText:_titlesForComponents[component][row]];
    return labelText;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_isRangePickerView && pickerView.numberOfComponents == 3)
    {
        if (component == 0)
        {
            [pickerView selectRow:MAX([pickerView selectedRowInComponent:2], row) inComponent:2 animated:YES];
        }
        else if (component == 2)
        {
            [pickerView selectRow:MIN([pickerView selectedRowInComponent:0], row) inComponent:0 animated:YES];
        }
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerView:didChangeRow:inComponent:)]) {
        [self.delegate bwActionSheetPickerView:self didChangeRow:row inComponent:component];
    }
}




- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMMM yyyy";
    }
    
    return dateFormatter;
}

//当前 选中的日期  执行的方法
- (void)calendarDidSelectedDate:(NSDate *)date {
    if (nil == self.dateLabel.text) {
        NSString *key = [[self dateFormatter] stringFromDate:date];
        NSLog(@"BWSheetBottmView calendarDidSelectedDate key:%@", key);
        self.dateLabel.text = key;
    }
    
    self.customSelectedDate = date; // only for BWActionSheetPickerStyleOnlyDatePicker

    if ([self.delegate respondsToSelector:@selector(bwActionSheetPickerView:calendarDidSelectDate:)]) {
        [self.delegate bwActionSheetPickerView:self calendarDidSelectDate:date];
    }
}

- (void)calendarDidLoadPageCurrentDate:(NSDate *)date {
    NSLog(@"BWSheetBottmView calendarDidLoadPageCurrentDate %@", [NSString stringWithFormat:@"%@",date]);
    NSString *key = [[self dateFormatter] stringFromDate:date];
    self.dateLabel.text = key;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
