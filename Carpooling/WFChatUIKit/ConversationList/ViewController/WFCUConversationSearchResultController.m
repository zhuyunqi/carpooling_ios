//
//  WFCUConversationSearchResultController.m
//  Carpooling
//
//  Created by bw on 2019/8/10.
//  Copyright © 2019 bw. All rights reserved.
//

#import "WFCUConversationSearchResultController.h"
#import "WFCUContactTableViewCell.h"
#import "WFCUSearchGroupTableViewCell.h"
#import "WFCUConversationTableViewCell.h"
#import "WFCUMessageListViewController.h"
#import "WFCUConversationSearchTableViewController.h"

@interface WFCUConversationSearchResultController ()

@end

@implementation WFCUConversationSearchResultController

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
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sec = 0;
    if (self.searchFriendList.count) {
        sec++;
    }
    
    if (self.searchGroupList.count) {
        sec++;
    }
    
    if (self.searchConversationList.count) {
        sec++;
    }
    
    return sec;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int sec = 0;
    if (self.searchFriendList.count) {
        sec++;
        if (section == sec-1) {
            return self.searchFriendList.count;
        }
    }
    
    if (self.searchGroupList.count) {
        sec++;
        if (section == sec-1) {
            return self.searchGroupList.count;
        }
    }
    
    if (self.searchConversationList.count) {
        sec++;
        if (sec-1 == section) {
            return self.searchConversationList.count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int sec = 0;
    if (self.searchFriendList.count) {
        sec++;
        if (indexPath.section == sec-1) {
            WFCUContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
            if (cell == nil) {
                cell = [[WFCUContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendCell"];
                cell.big = YES;
            }
            cell.userId = self.searchFriendList[indexPath.row].userId;
            return cell;
        }
    }
    
    if (self.searchGroupList.count) {
        sec++;
        if (indexPath.section == sec-1) {
            WFCUSearchGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
            if (cell == nil) {
                cell = [[WFCUSearchGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupCell"];
            }
            cell.groupSearchInfo = self.searchGroupList[indexPath.row];
            return cell;
        }
    }
    
    if (self.searchConversationList.count) {
        sec++;
        if (sec-1 == indexPath.section) {
            WFCUConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationCell"];
            if (cell == nil) {
                cell = [[WFCUConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationCell"];
            }
            cell.searchInfo = self.searchConversationList[indexPath.row];
            return cell;
        }
    }
    
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.searchConversationList.count + self.searchGroupList.count + self.searchFriendList.count > 0) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, self.tableView.frame.size.width-20, 20)];
        label.font = [UIFont systemFontOfSize:14.f];
        label.textAlignment = NSTextAlignmentLeft;
        
        if (@available(iOS 13.0, *)) {
            UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1.0f];
                }
                else {
                    return [UIColor tertiarySystemBackgroundColor];
                }
            }];
            
            header.backgroundColor = dyColor;
            
            UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor grayColor];
                }
                else {
                    return [UIColor placeholderTextColor];
                }
            }];
            label.textColor = dyColor2;
            
        } else {
            // Fallback on earlier versions
            header.backgroundColor = [UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1.0f];
            label.textColor = [UIColor grayColor];
        }
        
        
        int sec = 0;
        if (self.searchFriendList.count) {
            sec++;
            if (section == sec-1) {
                label.text = kLocalizedTableString(@"Contact", @"CPLocalizable");
            }
        }
        
        if (self.searchGroupList.count) {
            sec++;
            if (section == sec-1) {
                label.text = kLocalizedTableString(@"Group", @"CPLocalizable");
            }
        }
        
        if (self.searchConversationList.count) {
            sec++;
            if (sec-1 == section) {
                label.text = kLocalizedTableString(@"Message", @"CPLocalizable");
            }
        }
        
        [header addSubview:label];
        return header;
    } else {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
        return header;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int sec = 0;
    if (self.searchFriendList.count) {
        sec++;
        if (indexPath.section == sec-1) {
            WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
            WFCCUserInfo *info = self.searchFriendList[indexPath.row];
            mvc.conversation = [[WFCCConversation alloc] init];
            mvc.conversation.type = Single_Type;
            mvc.conversation.target = info.userId;
            mvc.conversation.line = 0;
            
            mvc.hidesBottomBarWhenPushed = YES;
            [self.presentingViewController.navigationController pushViewController:mvc animated:YES];
        }
    }
    
    if (self.searchGroupList.count) {
        sec++;
        if (indexPath.section == sec-1) {
            WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
            WFCCGroupSearchInfo *info = self.searchGroupList[indexPath.row];
            mvc.conversation = [[WFCCConversation alloc] init];
            mvc.conversation.type = Group_Type;
            mvc.conversation.target = info.groupInfo.target;
            mvc.conversation.line = 0;
            
            mvc.hidesBottomBarWhenPushed = YES;
            [self.presentingViewController.navigationController pushViewController:mvc animated:YES];
        }
    }
    
    if (self.searchConversationList.count) {
        sec++;
        if (sec-1 == indexPath.section) {
            WFCCConversationSearchInfo *info = self.searchConversationList[indexPath.row];
            if (info.marchedCount == 1) {
                WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
                
                mvc.conversation = info.conversation;
                mvc.highlightMessageId = info.marchedMessage.messageId;
                mvc.highlightText = info.keyword;
                mvc.hidesBottomBarWhenPushed = YES;
                
                [self.presentingViewController.navigationController pushViewController:mvc animated:YES];
                
            } else {
                WFCUConversationSearchTableViewController *mvc = [[WFCUConversationSearchTableViewController alloc] init];
                mvc.conversation = info.conversation;
                mvc.keyword = info.keyword;
                mvc.hidesBottomBarWhenPushed = YES;
                [self.presentingViewController.navigationController pushViewController:mvc animated:YES];
            }
        }
    }
}

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
