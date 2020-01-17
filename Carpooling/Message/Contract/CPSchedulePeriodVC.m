//
//  CPSchedulePeriodVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/2.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSchedulePeriodVC.h"
#import "CPSchedulePeriodCell1.h"

@interface CPSchedulePeriodVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedWeekStrArray;
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSMutableArray *weekArray;
@property (nonatomic, strong) NSString *aString;
@end

@implementation CPSchedulePeriodVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(243, 244, 246, 1);
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        
        self.tableView.backgroundColor = dyColor;
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(243, 244, 246, 1);
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        self.tableView.separatorColor = dyColor2;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }
    
    
    [self initRightBarItem];
    
    if (nil == _selectedWeekStrArray) {
        _selectedWeekStrArray = @[@"", @"", @"", @"", @"", @"", @""].mutableCopy;
    }
    
    if (nil == _weekArray) {
        _weekArray = @[
                       kLocalizedTableString(@"SundayLong", @"CPLocalizable"),             kLocalizedTableString(@"MondayLong", @"CPLocalizable"), kLocalizedTableString(@"TuesdayLong", @"CPLocalizable"), kLocalizedTableString(@"WednesdayLong", @"CPLocalizable"), kLocalizedTableString(@"ThursdayLong", @"CPLocalizable"),
                       kLocalizedTableString(@"FridayLong", @"CPLocalizable"),
                       kLocalizedTableString(@"SaturdayLong", @"CPLocalizable")].mutableCopy;
    }
    
    
    if (nil == _selectedWeekNum) {
        _selectedWeekNum = @"";
    }
    
    
    if (nil == _dict) {
        _dict = @{}.mutableCopy;
    }
}


- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    
    // 1 星期日, 2 星期一, 3 星期二, 4 星期三, 5 星期四, 6 星期五, 7 星期六
    NSString *str = @"";
    NSString *str2 = @"";
    for (int i = 0; i < _selectedWeekStrArray.count; i++) {
        NSString *type = [_selectedWeekStrArray objectAtIndex:i];
        if ([type isEqualToString:@""]) {
            continue;
        }
        else{
            if ([str isEqualToString:@""]) {
                str = [self.dict valueForKey:type];
                str2 = type;
            }
            else{
                str = [NSString stringWithFormat:@"%@,%@", str, [self.dict valueForKey:type]];
                str2 = [NSString stringWithFormat:@"%@,%@", str2, type];
            }
        }
    }
    
    _aString = str;
    _selectedWeekNum = str2;
    NSLog(@"CPSchedulePeriodVC rightItemClick _aString:%@, _selectedWeekNum:%@", _aString, _selectedWeekNum);
    if (self.passValueblock) {
        self.passValueblock(_aString, _selectedWeekNum);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSelectedWeekNum:(NSString *)selectedWeekNum{
    
    if (selectedWeekNum && selectedWeekNum.length > 0) {
        _selectedWeekNum = selectedWeekNum;
        
        _selectedWeekStrArray = @[@"", @"", @"", @"", @"", @"", @""].mutableCopy;
        _weekArray = @[
                       kLocalizedTableString(@"SundayLong", @"CPLocalizable"),             kLocalizedTableString(@"MondayLong", @"CPLocalizable"), kLocalizedTableString(@"TuesdayLong", @"CPLocalizable"), kLocalizedTableString(@"WednesdayLong", @"CPLocalizable"), kLocalizedTableString(@"ThursdayLong", @"CPLocalizable"),
                       kLocalizedTableString(@"FridayLong", @"CPLocalizable"),
                       kLocalizedTableString(@"SaturdayLong", @"CPLocalizable")].mutableCopy;
        _dict = @{}.mutableCopy;
        
        
        NSArray *arr2 = [selectedWeekNum componentsSeparatedByString:@","];
        for (int j = 0; j < arr2.count; j++) {
            NSInteger weeknumI = [[arr2 objectAtIndex:j] integerValue];
            
            [_selectedWeekStrArray replaceObjectAtIndex:weeknumI-1 withObject:[NSString stringWithFormat:@"%ld", (long)weeknumI]];
            
            [self.dict setValue:[_weekArray objectAtIndex:weeknumI-1] forKey:[NSString stringWithFormat:@"%ld", (long)weeknumI]];
        }
        
        NSLog(@"setSelectedWeekNum _selectedWeekStrArray:%@", _selectedWeekStrArray);
        [self.tableView reloadData];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 50)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kSCREENWIDTH-30, 50)];
    label.textColor = RGBA(200, 200, 200, 1);
    label.text = kLocalizedTableString(@"Multiple choices", @"CPLocalizable");
    [view addSubview:label];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        
        label.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        label.backgroundColor = RGBA(240, 240, 240, 1);
    }
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPSchedulePeriodCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPSchedulePeriodCell1"];
    ((CPSchedulePeriodCell1*)cell).titleLbl.text = [_weekArray objectAtIndex:indexPath.row];
    
    if (_selectedWeekStrArray) {
        BOOL customSelected = [[_selectedWeekStrArray objectAtIndex:indexPath.row] boolValue];
        ((CPSchedulePeriodCell1*)cell).customSelected = customSelected;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CPSchedulePeriodCell1 *cell = (CPSchedulePeriodCell1*)[tableView cellForRowAtIndexPath:indexPath];
    cell.customSelected = !cell.customSelected;
    
    if (cell.customSelected) {
        [_selectedWeekStrArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%ld", indexPath.row+1]];
        [self.dict setValue:cell.titleLbl.text forKey:[NSString stringWithFormat:@"%ld", indexPath.row+1]];
    }
    else{
        [_selectedWeekStrArray replaceObjectAtIndex:indexPath.row withObject:@""];
        [self.dict removeObjectForKey:[NSString stringWithFormat:@"%ld", indexPath.row+1]];
    }
    
    NSLog(@"CPSchedulePeriodVC cell.customSelected:%d, self.dict:%@, self.selectedWeekStrArray:%@",  cell.customSelected, self.dict, self.selectedWeekStrArray);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
