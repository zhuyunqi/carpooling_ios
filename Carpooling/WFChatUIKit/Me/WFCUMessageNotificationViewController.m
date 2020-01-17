//
//  MessageNotificationViewController.m
//  WildFireChat
//
//  Created by heavyrain lee on 07/01/2018.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import "WFCUMessageNotificationViewController.h"
#import "WFCUSwitchTableViewCell.h"


@interface WFCUMessageNotificationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation WFCUMessageNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新消息通知";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

//#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCUSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"styleSwitch"];
    if(cell == nil) {
        cell = [[WFCUSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"styleSwitch" conversation:nil];
    }
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"接收新消息通知";
        cell.type = SwitchType_Setting_Global_Silent;
    } else {
        cell.textLabel.text = @"通知显示消息详情";
        cell.type = SwitchType_Setting_Show_Notification_Detail;
    }
    
    
    return cell;
}

@end
