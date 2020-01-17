//
//  CPNoticeMessage1VC.m
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPNoticeMessage1VC.h"
#import "CPNoticeMessageCell1.h"
#import "CPNoticeModel.h"

@interface CPNoticeMessage1VC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation CPNoticeMessage1VC

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
    [self requestNoticeByCurrentIndex:_currIndex];
}

- (void)footerLoadMore{
    [self requestNoticeByCurrentIndex:_currIndex];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    CPNoticeMessageCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPNoticeMessageCell1"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        CPActivitysVC *activitysVC = [storyboard instantiateViewControllerWithIdentifier:@"CPActivitysVC"];
        //        [self.navigationController pushViewController:activitysVC animated:YES];
    }
}


- (void)requestNoticeByCurrentIndex:(NSUInteger)index{
    NSMutableDictionary *param = @{
                                   @"contractType":@2,
                                   @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                   @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                                   }.mutableCopy;
    
    NSLog(@"requestMyInProgressContractByCurrentIndex self.currIndex:%lu", self.currIndex);
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/contract/v1/getContractList.json", BaseURL] parameters:param success:^(id responseObject) {
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPNoticeMessage1VC requestMyInProgressContract responseObject:%@", responseObject);
        if (responseObject) {
//            CPContractReqResultModel *masterModel = [CPContractReqResultModel mj_objectWithKeyValues:responseObject];
//            CPContractReqResultSubModel *subModel = masterModel.data;
//
//            if (masterModel.code == 200) {
//                [weakSelf.dataSource addObjectsFromArray:subModel.data];
//                for (int i = 0; i < subModel.data.count; i++) {
//                    CPContractMJModel *model = [subModel.data objectAtIndex:i];
//
//                    CGSize size1 = W_GET_STRINGSIZE(model.fromAddress, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
//                    CGFloat height1 =  size1.height;
//
//                    CGSize size2 = W_GET_STRINGSIZE(model.toAddress, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
//                    CGFloat height2 = size2.height;
//
//                    NSString *time = [NSString stringWithFormat:@"%@~%@", model.beginTime, model.endTime];
//                    CGSize size3 = W_GET_STRINGSIZE(time, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:14.f]);
//                    CGFloat height3 = size3.height;
//
//                    CGFloat totalHeight = height1 +height2 +height3 +250;
//                    model.cellHeight = totalHeight;
//                }
//
//                weakSelf.currIndex++;
//                [weakSelf.tableView reloadData];
//            }
//            else{
//                NSLog(@"CPMyInProgressContractVC requestMyInProgressContract requestRegister 失败");
//            }
        }
        else {
            NSLog(@"CPNoticeMessage1VC requestMyInProgressContract requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPNoticeMessage1VC  requestMyInProgressContract error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
