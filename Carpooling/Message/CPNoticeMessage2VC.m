//
//  CPNoticeMessage2VC.m
//  Carpooling
//
//  Created by Yang on 2019/6/7.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPNoticeMessage2VC.h"
#import "CPNoticeMessageCell2.h"
#import "CPNoticeReqResultModel.h"
#import "CPNoticeReqResultSubModel.h"
#import "CPNoticeModel.h"

@interface CPNoticeMessage2VC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *url;
@end

@implementation CPNoticeMessage2VC

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
}

- (void)footerLoadMore{
    [self requestNoticeByCurrentIndex:_currIndex];
}

- (void)setShowType:(CPNoticeShowType)showType{
    _showType = showType;
    _pageSize = 10;
    _currIndex = 1;
    if (_showType == CPNoticeShowTypeBranding) {
        _url = @"/api/index/v1/popularizeMessage";
    }
    else if (_showType == CPNoticeShowTypeSystem) {
        _url = @"/api/index/v1/systemMessage";
    }
    
    [SVProgressHUD show];
    [self requestNoticeByCurrentIndex:_currIndex];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPNoticeModel *noticeModel = [self.dataSource objectAtIndex:indexPath.row];
    return noticeModel.cellHeight;
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
    CPNoticeMessageCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPNoticeMessageCell2"];
    cell.noticeModel = [self.dataSource objectAtIndex:indexPath.row];
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
                                   @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                                   @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                                   }.mutableCopy;
    
    NSLog(@"requestNoticeByCurrentIndex self.currIndex:%lu", self.currIndex);
    
    WS(weakSelf);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@%@", BaseURL, _url] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPNoticeMessage2VC requestNoticeByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPNoticeReqResultModel *masterModel = [CPNoticeReqResultModel mj_objectWithKeyValues:responseObject];
            CPNoticeReqResultSubModel *subModel = masterModel.data;
            if (masterModel.code == 200) {
                if (weakSelf.currIndex == 1) {
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                for (int i = 0; i < subModel.data.count; i++) {
                    CPNoticeModel *model = [subModel.data objectAtIndex:i];
                    
                    CGSize size1 = W_GET_STRINGSIZE(model.content, kSCREENWIDTH-50, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height1 =  size1.height;
                    
                    CGFloat totalHeight = height1 +70;
                    
                    model.cellHeight = totalHeight;
                    NSLog(@"CPNoticeMessage2VC requestNoticeByCurrentIndex totalHeight:%f", totalHeight);
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
            NSLog(@"CPNoticeMessage2VC requestNoticeByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPNoticeMessage2VC  requestNoticeByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
