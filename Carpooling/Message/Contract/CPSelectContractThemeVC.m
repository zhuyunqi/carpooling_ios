//
//  CPSelectContractThemeVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/1.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSelectContractThemeVC.h"
#import "CPSelectContractThemeCell1.h"
#import "CPSelectContractThemeCell2.h"


@interface CPSelectContractThemeVC ()<CPSelectContractThemeCell1Delegate, CPSelectContractThemeCell2Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *placeholder1;
@end

@implementation CPSelectContractThemeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_titleType == 0) {
        self.title = kLocalizedTableString(@"Enter Theme", @"CPLocalizable");
        
    }
    else if (_titleType == 1) {
        self.title = kLocalizedTableString(@"Enter Remark", @"CPLocalizable");
    }
    
    [self initRightBarItem];
    
    _placeholder1 = kLocalizedTableString(@"Please enter theme", @"CPLocalizable");
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    
    if (!_aString || [_aString isEqualToString:@""]) {
        NSLog(@"主题或备注不能为空，请输入主题");
    }
    else{
        [self.view endEditing:YES];
        if (self.passValueblock) {
            self.passValueblock(_aString);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_titleType == 0) {
        return 70;
        
    }
    else if (_titleType == 1) {
        return 140;
    }
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 10)];
    //    return view;
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (_titleType == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSelectContractThemeCell1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ((CPSelectContractThemeCell1*)cell).delegate = self;
        ((CPSelectContractThemeCell1*)cell).titleTF.placeholder = _placeholder1;
        if (_aString) {
            ((CPSelectContractThemeCell1*)cell).titleTF.text = _aString;
        }
        
    }
    else if (_titleType == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSelectContractThemeCell2"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ((CPSelectContractThemeCell2*)cell).delegate = self;
        if (_aString) {
            ((CPSelectContractThemeCell2*)cell).titleTV.text = _aString;
        }
    }
    
    return cell;
}


#pragma mark - CPSelectContractThemeCell1Delegate
- (void)selectContractThemeCell1TFDidEndEditing:(NSString *)text{
    _aString = text;
}

- (void)selectContractThemeCell1TFShouldReturn:(NSString *)text{
    _aString = text;
    if (self.passValueblock) {
        self.passValueblock(_aString);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CPSelectContractThemeCell2Delegate
- (void)selectContractThemeCell2TVDidEndEditing:(NSString *)text{
    _aString = text;
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
