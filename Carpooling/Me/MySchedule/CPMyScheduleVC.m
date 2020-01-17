//
//  CPMyScheduleVC.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyScheduleVC.h"
#import "CPMyScheduleCell.h"
#import "CPSetupScheduleVC.h"
#import "CPScheduleReqResultModel.h"
#import "CPScheduleReqResultSubModel.h"
#import "CPScheduleMJModel.h"
#import "CPMatchingScheduleVC.h"
#import "CPAddressModel.h"


@interface CPMyScheduleVC ()<CPMyScheduleCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *noDataLbl;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger currIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation CPMyScheduleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                return RGBA(243, 244, 246, 1);
            }
            else {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                return [UIColor systemBackgroundColor];
            }
        }];
        
        self.tableView.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }

    
    self.title = kLocalizedTableString(@"My Schedule", @"CPLocalizable");
    [self initRightBarItem];
    
    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, (kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-kTABBARHEIGHT-40)/2, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = noDataLbl.textColor = RGBA(150, 150, 150, 1);
    noDataLbl.text = kLocalizedTableString(@"has NO Result", @"CPLocalizable");
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
    
    
    _pageSize = 10;
    _currIndex = 1;
    _dataSource = @[].mutableCopy;
    
    [SVProgressHUD show];
    [self requestMyScheduleByCurrentIndex:_currIndex];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.mj_footer = [NHYRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMore)];
}

- (void)footerLoadMore{
    [self requestMyScheduleByCurrentIndex:_currIndex];
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"schedule_btn"] style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPSetupScheduleVC *setupScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupScheduleVC"];
    setupScheduleVC.showType = ScheduleVCShowTypeSetup;
    setupScheduleVC.passValueblock = ^(BOOL success) {
        [SVProgressHUD show];
        self.currIndex = 1;
        [self requestMyScheduleByCurrentIndex:self.currIndex];
    };
    [self.navigationController pushViewController:setupScheduleVC animated:YES];
}

#pragma mark - UITableView UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    NSLog(@"CPMyScheduleVC _dataSource.count:%lu", (unsigned long)_dataSource.count);
    return _dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPScheduleMJModel *model = [self.dataSource objectAtIndex:indexPath.section];
    NSLog(@"CPMyScheduleVC heightForRowAtIndexPath model.cellHeight:%f, indexPath.section:%ld", model.cellHeight, (long)indexPath.section);
    return model.cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 10)];
    
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return RGBA(240, 240, 240, 1);
            }
            else {
                return [UIColor systemBackgroundColor];
            }
        }];
        
        view.backgroundColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        view.backgroundColor = RGBA(240, 240, 240, 1);
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
    CPMyScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPMyScheduleCell"];
    cell.delegate = self;
    cell.scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    cell.indexPath = indexPath;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
}

#pragma mark - 左滑删除, 单个删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    if (scheduleMJModel.status != 0) {
        return NO;
    }
    return YES;
}


- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self requestDeleteScheduleByIndexPath:indexPath];
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
        [self requestDeleteScheduleByIndexPath:indexPath];
    }
}


- (void)myScheduleCellEditBtnAction:(NSIndexPath *)indexPath{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPSetupScheduleVC *setupScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSetupScheduleVC"];
    setupScheduleVC.showType = ScheduleVCShowTypeEdit;
    setupScheduleVC.scheduleMJModel = scheduleMJModel;
    setupScheduleVC.passValueblock = ^(BOOL success) {
        [SVProgressHUD show];
        [self requestMyScheduleByCurrentIndex:self.currIndex];
    };
    [self.navigationController pushViewController:setupScheduleVC animated:YES];
}

- (void)myScheduleCellMatchingBtnAction:(NSIndexPath *)indexPath{
    
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CPMatchingScheduleVC *matchingScheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMatchingScheduleVC"];
    matchingScheduleVC.scheduleMJModel = scheduleMJModel;
    matchingScheduleVC.requestParams = [scheduleMJModel mj_keyValues];
    [matchingScheduleVC.requestParams removeObjectForKey:@"userVo"];
    [self.navigationController pushViewController:matchingScheduleVC animated:YES];
}

- (void)myScheduleCellDeleteBtnAction:(NSIndexPath *)indexPath{
    [self requestDeleteScheduleByIndexPath:indexPath];
}

- (void)myScheduleCellNaviAction:(NSIndexPath *)indexPath location:(CLLocationCoordinate2D)coordinate destination:(NSString *)destination{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Navi by map", @"CPLocalizable") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Start Navi", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //当前位置
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
        //传入目的地，会显示在苹果自带地图上面目的地一栏
        toLocation.name = destination;
        //导航方式选择walking
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)requestMyScheduleByCurrentIndex:(NSUInteger)index{
    NSMutableDictionary *param = @{
                            @"pageSize":[NSNumber numberWithUnsignedInteger:self.pageSize],
                            @"page":[NSNumber numberWithUnsignedInteger:self.currIndex],
                            }.mutableCopy;
    
    WS(weakSelf);
    NSLog(@"CPMyScheduleVC requestMyScheduleByCurrentIndex currIndex:%lu", (unsigned long)_currIndex);
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/scheduling/v1/myScheduling.json", BaseURL] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyScheduleVC requestMyScheduleByCurrentIndex responseObject:%@", responseObject);
        if (responseObject) {
            CPScheduleReqResultModel *masterModel = [CPScheduleReqResultModel mj_objectWithKeyValues:responseObject];
            CPScheduleReqResultSubModel *subModel = masterModel.data;

            if (masterModel.code == 200) {
                if (weakSelf.currIndex == 1) {
                    if (subModel.data.count == 0) {
                        weakSelf.noDataLbl.hidden = NO;
                    }
                    [weakSelf.dataSource removeAllObjects];
                }
                
                [weakSelf.dataSource addObjectsFromArray:subModel.data];
                for (int i = 0; i < subModel.data.count; i++) {
                    CPScheduleMJModel *model = [subModel.data objectAtIndex:i];
                    
                    CGSize size1 = W_GET_STRINGSIZE(model.fromAddressVo.address, kSCREENWIDTH-72, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height1 =  size1.height;
                    
                    CGSize size2 = W_GET_STRINGSIZE(model.toAddressVo.address, kSCREENWIDTH-72, MAXFLOAT, [UIFont systemFontOfSize:15.f]);
                    CGFloat height2 = size2.height;
                    
                    NSDate *date = [Utils getDateWithTimestamp:model.arriveTime];
                    NSString *time = [Utils dateToString:date withDateFormat:@"MM/dd EEE HH:mm"];
                    NSString *str = time;
                    if (model.schedulingCycle && model.schedulingCycle.length > 0) {
                        str = [NSString stringWithFormat:@"%@ %@(%@)", time, kLocalizedTableString(@"repeat", @"CPLocalizable"), model.schedulingCycle];
                    }

                    CGSize size3 = W_GET_STRINGSIZE(str, kSCREENWIDTH-86, MAXFLOAT, [UIFont systemFontOfSize:14.f]);
                    CGFloat height3 = size3.height;
                    
                    CGFloat totalHeight = height1 +height2 +height3 +150;
                    model.cellHeight = totalHeight;
                    NSLog(@"CPMyScheduleVC requestMyScheduleByCurrentIndex totalHeight:%f", totalHeight);
                }
                
                if (subModel.data.count >= weakSelf.pageSize) {
                    weakSelf.currIndex++;
                }
                else {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                
                if (weakSelf.dataSource.count > 0) {
                    weakSelf.noDataLbl.hidden = YES;
                }
                [weakSelf.tableView reloadData];
                
            }
            else{
                NSLog(@"CPMyScheduleVC requestMyScheduleByCurrentIndex requestRegister 失败");
            }
        }
        else {
            NSLog(@"CPMyScheduleVC requestMyScheduleByCurrentIndex requestRegister 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSLog(@"CPMyScheduleVC  requestMyScheduleByCurrentIndex error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
    }];
}


- (void)requestDeleteScheduleByIndexPath:(NSIndexPath*)indexPath{
    CPScheduleMJModel *scheduleMJModel = [self.dataSource objectAtIndex:indexPath.section];
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/scheduling/v1/deleteScheduling", BaseURL] parameters:@{@"id":[NSNumber numberWithInteger:scheduleMJModel.dataid]}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyScheduleVC requestDeleteSchedule responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ScheduleUpdateSuccess" object:nil];
                //删除数据，和删除动画
                [weakSelf.dataSource removeObjectAtIndex:indexPath.section];
                [weakSelf.tableView deleteSection:indexPath.section withRowAnimation:UITableViewRowAnimationTop];
            }
            else{
                NSLog(@"CPMyScheduleVC requestDeleteSchedule 失败");
            }
        }
        else {
            NSLog(@"CPMyScheduleVC requestDeleteSchedule 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyScheduleVC requestDeleteSchedule error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
