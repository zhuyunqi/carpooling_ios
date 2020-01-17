//
//  CPMyHistoryAddressVC.m
//  Carpooling
//
//  Created by bw on 2019/8/8.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyHistoryAddressVC.h"
#import "CPMyAddressCell1.h"
#import "CPAddressReqResultModel.h"
#import "CPAddressReqResultSubModel.h"
#import "CPAddressModel.h"

@interface CPMyHistoryAddressVC ()<CPMyAddressCell1Delegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CPAddressModel *targetAddressModel;// for copy address
@end

@implementation CPMyHistoryAddressVC

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
                return [UIColor tertiarySystemBackgroundColor];
            }
        }];
        self.tableView.separatorColor = dyColor2;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }
    
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMore)];
    
    //删除、收藏地址成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefreshAddressTableView:) name:@"NeedRefreshAddressTableView" object:nil];
    
    [SVProgressHUD show];
    [self requestMyAddressByCurrentIndex:_currIndex];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NeedRefreshAddressTableView" object:nil];
}

- (void)needRefreshAddressTableView:(NSNotification*)notification{
    _currIndex = 1;
    [self requestMyAddressByCurrentIndex:_currIndex];
}

- (void)setNeedRefresh:(BOOL)needRefresh{
    if (needRefresh) {
        [SVProgressHUD show];
        _currIndex = 1;
        [self requestMyAddressByCurrentIndex:_currIndex];
    }
}

- (void)footerLoadMore{
    [self requestMyAddressByCurrentIndex:_currIndex];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPAddressModel *addressModel = [self.dataSource objectAtIndex:indexPath.row];
    return addressModel.cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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
    CPMyAddressCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPMyAddressCell1"];
    cell.indexPath = indexPath;
    cell.delegate = self;
//    cell.showType = self.showType;
    cell.addressModel = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_fromMeVC) {
        CPAddressModel *addressModel = [self.dataSource objectAtIndex:indexPath.row];
        NSDictionary *dict = [addressModel mj_keyValues];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECTCONTRACTADDRESSSUCCESS" object:nil userInfo:dict];
        [[Utils getSupreViewController:self.view].navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(performCopy:)) {
        return YES; //显示自定义的菜单项
    }
    return NO;//[super canPerformAction:action withSender:sender];
}

#pragma mark - 左滑删除, 单个删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self requestDeleteAddressByIndexPath:indexPath];
        //        completionHandler (YES);
    }];
    //    deleteRowAction.image = [UIImage imageNamed:@"icon_del"];
    //    deleteRowAction.backgroundColor = [UIColor blueColor];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    config.performsFirstActionWithFullSwipe = NO;
    
    return config;
}

//2
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

//3
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kLocalizedTableString(@"Delete", @"CPLocalizable");
}

//4
//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"tableView editingStyle forRowAtIndexPath indexPath.row %ld",(long)indexPath.row);
        [self requestDeleteAddressByIndexPath:indexPath];
    }
}


- (void)requestMyAddressByCurrentIndex:(NSUInteger)index{
    NSMutableDictionary *param = @{
                                   @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                   @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                                   }.mutableCopy;
    
    WS(weakSelf);
    NSLog(@"CPMyAddressVC requestMyAddressByCurrentIndex currIndex:%lu", (unsigned long)_currIndex);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/address/v1/getAddress", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyAddressVC requestMyAddressByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPAddressReqResultModel *masterModel = [CPAddressReqResultModel mj_objectWithKeyValues:responseObject];
            CPAddressReqResultSubModel *subModel = masterModel.data;
            
            if (masterModel.code == 200) {
//                if (weakSelf.showType != MyAddressShowTypeCollect) {
//                    // postnoti
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedRefreshAddressTableView" object:nil userInfo:@{@"needrefresh":[NSNumber numberWithBool:NO], @"index":[NSNumber numberWithUnsignedInteger:self.showType]}];
//                }
                
                if (weakSelf.currIndex == 1) {
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                for (int i = 0; i < subModel.data.count; i++) {
                    CPAddressModel *model = [subModel.data objectAtIndex:i];
                    
                    CGSize size1 = W_GET_STRINGSIZE(model.address, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height1 =  size1.height;
                    
                    CGFloat totalHeight = height1 +50;
                    model.cellHeight = totalHeight;
                    NSLog(@"CPMyAddressVC requestMyAddressByCurrentIndex totalHeight:%f", totalHeight);
                }
                
                if (subModel.data.count >= weakSelf.pageSize) {
                    weakSelf.currIndex++;
                }
                else {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                [weakSelf.tableView reloadData];
                
            }
            else{
                NSLog(@"CPMyAddressVC requestMyAddressByCurrentIndex requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPMyAddressVC requestMyAddressByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyAddressVC  requestMyAddressByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)requestDeleteAddressByIndexPath:(NSIndexPath*)indexPath{
    CPAddressModel *addressModel = [self.dataSource objectAtIndex:indexPath.row];
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/address/v1/delete", BaseURL] parameters:@{@"id":[NSNumber numberWithInteger:addressModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyAddressVC requestDeleteAddress responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {

                [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedRefreshAddressTableView" object:nil userInfo:@{@"needrefresh":[NSNumber numberWithBool:YES]}];
                
                //删除数据，和删除动画
                [weakSelf.dataSource removeObjectAtIndex:indexPath.row];
                [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            }
            else{
                NSLog(@"CPMyAddressVC requestDeleteAddress 失败");
            }
        }
        else {
            NSLog(@"CPMyAddressVC requestDeleteAddress 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyAddressVC requestDeleteAddress error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
    
}

- (void)addressCell1CollectActionAtIndexPath:(NSIndexPath *)indexPath{
    CPAddressModel *addressModel = [self.dataSource objectAtIndex:indexPath.row];
    if (addressModel.isCollect) {
        [self requestCancelCollectAddress:indexPath];
    }
    else {
        [self requestCollectAddress:indexPath];
    }
}

- (void)addressCell1LongPress:(CPMyAddressCell1 *)cell atIndexPath:(NSIndexPath *)indexPath{
    [self becomeFirstResponder];
    self.targetAddressModel = [self.dataSource objectAtIndex:indexPath.row];
    [self displayCopyMenu:(CPMyAddressCell1 *)cell];
}

#pragma mark - menu
- (void)displayCopyMenu:(CPMyAddressCell1*)cell {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:kLocalizedTableString(@"Copy", @"CPLocalizable") action:@selector(performCopy:)];
    
    CGRect menuPos;
    menuPos = cell.bgView.frame;
    [menu setTargetRect:menuPos inView:cell];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:copyItem];
    [menu setMenuItems:items];
    
    [menu setMenuVisible:YES];
}

-(void)performCopy:(UIMenuItem *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.targetAddressModel.address;
}

- (void)requestCollectAddress:(NSIndexPath *)indexPath{
    [SVProgressHUD show];
    CPAddressModel *addressModel = [self.dataSource objectAtIndex:indexPath.row];
    NSInteger addressId = addressModel.dataid;
    
    NSMutableDictionary *param = @{
                                   @"id":[NSNumber numberWithInteger:addressId]
                                   }.mutableCopy;
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/address/v1/collectAddress", BaseURL] parameters:param.mutableCopy success:^(id responseObject) {
        NSLog(@"CPMyAddressVC requestCollectAddress responseObject:%@", responseObject);
        [SVProgressHUD dismiss];
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSLog(@"CPMyAddressVC requestCollectAddress 成功");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedRefreshAddressTableView" object:nil userInfo:@{@"needrefresh":[NSNumber numberWithBool:YES]}];
                
                addressModel.isCollect = YES;
                [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                NSLog(@"CPMyAddressVC requestCollectAddress 失败");
            }
        }
        else {
            NSLog(@"CPMyAddressVC requestCollectAddress 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyAddressVC requestCollectAddress error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}

- (void)requestCancelCollectAddress:(NSIndexPath *)indexPath{
    [SVProgressHUD show];
    CPAddressModel *addressModel = [self.dataSource objectAtIndex:indexPath.row];
    NSInteger addressId = addressModel.dataid;
    
    NSMutableDictionary *param = @{
                                   @"id":[NSNumber numberWithInteger:addressId]
                                   }.mutableCopy;
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/address/v1/cancelCollectAddress", BaseURL] parameters:param.mutableCopy success:^(id responseObject) {
        NSLog(@"CPMyAddressVC requestCancelCollectAddress responseObject:%@", responseObject);
        [SVProgressHUD dismiss];
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSLog(@"CPMyAddressVC requestCancelCollectAddress 成功");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedRefreshAddressTableView" object:nil userInfo:@{@"needrefresh":[NSNumber numberWithBool:YES]}];
                
                addressModel.isCollect = NO;
                [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                NSLog(@"CPMyAddressVC requestCancelCollectAddress 失败");
            }
        }
        else {
            NSLog(@"CPMyAddressVC requestCancelCollectAddress 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyAddressVC requestCancelCollectAddress error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
