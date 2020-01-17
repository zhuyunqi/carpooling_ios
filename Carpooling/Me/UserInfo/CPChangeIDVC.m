//
//  CPChangeIDVC.m
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPChangeIDVC.h"
#import "CPChangeIDCell.h"

@interface CPChangeIDVC ()<CPChangeIDCellDelegate>
@property (nonatomic, strong) NSString *nickName;
@end

@implementation CPChangeIDVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = kLocalizedTableString(@"Change Nickname", @"CPLocalizable");
    [self initRightBarItem];
}

- (void)initRightBarItem{
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    NSString *tips = @"";
    if (!_nickName) {
        tips = kLocalizedTableString(@"Enter Nickname", @"CPLocalizable");
    }
    
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    [self requestChangeName];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    CPChangeIDCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPChangeIDCell"];
    cell.delegate = self;
    
    return cell;
}


#pragma mark - CPChangeIDCellDelegate
- (void)changeIDCellTFDidEndEditing:(NSString *)text{
    _nickName = text;
}

- (void)changeIDCellTFShouldReturn:(NSString *)text{
    _nickName = text;
//    self.passValueblock(_theme);
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)requestChangeName{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/updateName.json", BaseURL] parameters:@{@"nickName":_nickName}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPChangeIDVC requestChangeName responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(weakSelf.nickName);
                }
                [[NSUserDefaults standardUserDefaults] setValue:weakSelf.nickName forKey:kUserNickname];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSLog(@"CPChangeIDVC requestChangeName 失败");
            }
        }
        else {
            NSLog(@"CPChangeIDVC requestChangeName 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPChangeIDVC requestChangeName error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
