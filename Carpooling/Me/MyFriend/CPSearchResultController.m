//
//  CPSearchResultController.m
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSearchResultController.h"
#import "CPMyFriendCell1.h"
#import "CPUserInfoModel.h"


@interface CPSearchResultController ()

@end

@implementation CPSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.tableView.estimatedRowHeight = 0;
//    self.tableView.estimatedSectionFooterHeight = 0;
//    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.rowHeight = 80;
    [self.tableView registerNib:[UINib nibWithNibName:@"CPMyFriendCell1" bundle:nil] forCellReuseIdentifier:@"CPMyFriendCell1"];
}

- (void)configureCell:(CPMyFriendCell1 *)cell forModel:(CPUserInfoModel *)model
{
    if (model.remarkname) {
        cell.titleLbl.text = model.remarkname;
    }
    else if (model.nickname) {
        cell.titleLbl.text = model.nickname;
    }
    else if (model.username) {
        cell.titleLbl.text = model.username;
    }
    [cell.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
    
    if (model.contractCount >= 0) {
        cell.subTitleLbl.text = [NSString stringWithFormat:@"%@ %ld", kLocalizedTableString(@"Completed contract", @"CPLocalizable"), model.contractCount];
    }
    if (model.creditScore >= 0) {
        cell.subDetailLbl.text = [NSString stringWithFormat:@"%@", kLocalizedTableString(@"Score", @"CPLocalizable")];
        cell.detailLbl.text = [NSString stringWithFormat:@"%ld", model.creditScore];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPMyFriendCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CPMyFriendCell1"];
    
    // Configure the cell...
    CPUserInfoModel *model = [self.filteredModels objectAtIndex:indexPath.row];
    [self configureCell:cell forModel:model];
    return cell;
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
