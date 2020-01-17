//
//  CPCommentContractVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPCommentContractVC.h"
#import "CPInitShortTermContractCell1.h"
#import "CPCommentContractCell.h"

@interface CPCommentContractVC ()<CPInitShortTermContractCell1Delegate, CPCommentContractCellDelegate>
@property (nonatomic, assign) NSInteger passengerType;
@property (nonatomic, strong) NSString *comment;
@end

@implementation CPCommentContractVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initRightBarItem];
    
    _passengerType = 1;
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    NSString *tips = @"";
    if (!_comment) {
        tips = kLocalizedTableString(@"Please enter theme", @"CPLocalizable");
    }
    
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    
    
    [self requestCommentContract];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return CPREGULARCELLHEIGHT;
    }
    return 300;
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
    if (indexPath.row == 0) {
        CPInitShortTermContractCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPInitShortTermContractCell1"];
        cell.delegate = self;
        cell.leftLbl.text = kLocalizedTableString(@"Five Star", @"CPLocalizable");
        cell.rightLbl.text = kLocalizedTableString(@"Not Happy", @"CPLocalizable");
        return cell;
    }
    else {
        CPCommentContractCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPCommentContractCell"];
        cell.delegate = self;
        
        return cell;
    }
}

- (void)contractCellSelectPassengerType:(NSInteger)type{
    if (type == 0) {
        _passengerType = 1;
    }
    else if (type == 1) {
        _passengerType = 2;
    }
}

- (void)commentContractCellTVDidEditing:(NSString *)text{
    NSLog(@"commentContractCellTVDidEditing text:%@", text);
    _comment = text;
}

- (void)requestCommentContract{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/markContract", BaseURL] parameters:@{@"contractId":[NSNumber numberWithInteger:_contractId], @"markValue":[NSNumber numberWithInteger:_passengerType], @"remark":_comment}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPCommentContractVC requestCommentContract responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPCommentContractVC requestCommentContract 失败");
            }
        }
        else {
            NSLog(@"CPCommentContractVC requestCommentContract 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPCommentContractVC requestCommentContract error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
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
