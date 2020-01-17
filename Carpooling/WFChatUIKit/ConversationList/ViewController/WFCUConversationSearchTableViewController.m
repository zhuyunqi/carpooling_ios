//
//  ConversationSearchTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationSearchTableViewController.h"
#import "WFCUContactListViewController.h"
#import "WFCUCreateGroupViewController.h"
#import "WFCUFriendRequestViewController.h"

#import "WFCUMessageListViewController.h"

#import "SDWebImage.h"
#import "WFCUUtilities.h"
#import "UITabBar+badge.h"
#import "KxMenu.h"
#import "UIImage+ERCategory.h"
#import "MBProgressHUD.h"

#import "WFCUConversationSearchTableViewCell.h"

#import "VHLNavigation.h"

@interface WFCUConversationSearchTableViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray<WFCCMessage* > *messages;
@property (nonatomic, strong)  UISearchController       *searchController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *searchViewContainer;
@end

@implementation WFCUConversationSearchTableViewController
- (void)initSearchUIAndTableView {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    if (@available(iOS 9.1, *)) {
        self.searchController.obscuresBackgroundDuringPresentation = NO;
    }

    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor blackColor];
            }
            else {
                return [UIColor placeholderTextColor];
            }
        }];
        self.searchController.searchBar.tintColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        [self.searchController.searchBar setValue:kLocalizedTableString(@"Cancel", @"CPLocalizable") forKey:@"_cancelButtonText"];
        
        self.searchController.searchBar.tintColor = [UIColor blackColor];
    }
    
    
    self.searchController.searchBar.placeholder = kLocalizedTableString(@"Search", @"CPLocalizable");
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    self.tableView.tableHeaderView = _searchController.searchBar;
    
    self.definesPresentationContext = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        // fix bug iOS 11 click cancel causes searchbar flutters
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //        self.tabBarController.tabBar.translucent = NO;
    } else {
        // Fallback on earlier versions
    }
    
    [self vhl_setNavBarBackgroundColor:[UIColor colorWithRed:120/255.f green:202/255.f blue:195/255.f alpha:1]];
    [self vhl_setNavBarTintColor:[UIColor whiteColor]];
    [self vhl_setNavBarTitleColor:[UIColor whiteColor]];
    
    
    self.messages = [[NSMutableArray alloc] init];
    [self initSearchUIAndTableView];

    
    [self.searchController.searchBar setText:self.keyword];
    self.searchController.active = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WFCUConversationSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[WFCUConversationSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    WFCCMessage *msg = [self.messages objectAtIndex:indexPath.row];
    cell.keyword = self.keyword;
    cell.message = msg;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 68;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    UIImageView *portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 32, 32)];
    portraitView.layer.cornerRadius = 3.f;
    portraitView.layer.masksToBounds = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.tableView.frame.size.width, 40)];
    
    label.font = [UIFont boldSystemFontOfSize:18];
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
    
    
    if (self.conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.conversation.target refresh:NO];
        [portraitView sd_setImageWithURL:[NSURL URLWithString:userInfo.portrait] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        label.text = [NSString stringWithFormat:@"\"%@\"%@", userInfo.displayName, kLocalizedTableString(@"Chat Records", @"CPLocalizable")];
    } else if (self.conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:NO];
        [portraitView sd_setImageWithURL:[NSURL URLWithString:groupInfo.portrait] placeholderImage:[UIImage imageNamed:@"GroupChatRound"]];
        label.text = [NSString stringWithFormat:@"\"%@\"%@", groupInfo.name, kLocalizedTableString(@"Chat Records", @"CPLocalizable")];
    } else if(self.conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:NO];
        [portraitView sd_setImageWithURL:[NSURL URLWithString:channelInfo.portrait] placeholderImage:[UIImage imageNamed:@"GroupChatRound"]];
        label.text = [NSString stringWithFormat:@"\"%@\"%@", channelInfo.name, kLocalizedTableString(@"Chat Records", @"CPLocalizable")];
    }
    
    [header addSubview:label];
    [header addSubview:portraitView];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    
    mvc.conversation = self.messages[indexPath.row].conversation;
    mvc.highlightMessageId = self.messages[indexPath.row].messageId;
    mvc.highlightText = self.keyword;
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchController.active) {
        [self.searchController.searchBar resignFirstResponder];
    }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
    _searchController = nil;
}

#pragma mark - UISearchControllerDelegate
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];
    if (searchString.length) {
        self.messages = [[[WFCCIMService sharedWFCIMService] searchMessage:self.conversation keyword:searchString] mutableCopy];
        self.keyword = searchString;
    } else {
        [self.messages removeAllObjects];
    }
    
    //刷新表格
    [self.tableView reloadData];
}
@end
