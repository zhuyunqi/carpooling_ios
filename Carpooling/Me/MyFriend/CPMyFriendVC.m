//
//  CPMyFriendVC.m
//  Carpooling
//
//  Created by bw on 2019/5/19.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyFriendVC.h"
#import "CPSearchResultController.h"
#import "CPMyFriendCell1.h"
#import "CPUserInfoModel.h"


// realm object
#import <Realm.h>

#import "CPUserLoginVC.h"
#import "WFCUMessageListViewController.h"
#import <WFChatClient/WFCChatClient.h>

#import "KxMenu.h"
#import "WFCUAddFriendViewController.h"


@interface CPMyFriendVC ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, CPMyFriendCell1Delegate>

@property (nonatomic, strong) CPSearchResultController *resultsTableController;
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *noDataLbl;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *sectionTitleArray;
@property (nonatomic, strong) UILocalizedIndexedCollation *localizedCollection;

// for state restoration
@property (nonatomic, assign) BOOL searchControllerWasActive;
@property (nonatomic, assign) BOOL searchControllerSearchFieldWasFirstResponder;

@property(nonatomic,strong) NSMutableDictionary *dicts;
@property(nonatomic,assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *models;

@property (nonatomic, strong) NSIndexPath *selectIndexPath; // 设置好友备注名
@property (nonatomic, copy) NSString *notename; // 新设置的好友备注名
@end

@implementation CPMyFriendVC

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
                return [UIColor systemBackgroundColor];
            }
        }];
        self.tableView.separatorColor = dyColor2;
        
    } else {
        // Fallback on earlier versions
        self.tableView.backgroundColor = RGBA(243, 244, 246, 1);
    }

    if (@available(iOS 11.0, *)) {
        // fix bug iOS 11 click cancel causes searchbar flutters
        self.edgesForExtendedLayout = UIRectEdgeNone;
    } else {
        // Fallback on earlier versions
    }
    self.title = kLocalizedTableString(@"My Friend", @"CPLocalizable");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_plus"] style:UIBarButtonItemStyleDone target:self action:@selector(onRightBarBtn:)];

    
    _resultsTableController = [[CPSearchResultController alloc] init];
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    _resultsTableController.tableView.delegate = self;
//    _resultsTableController.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsTableController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = TRUE; // default is YES

    if (@available(iOS 13.0, *)) {
    
    } else {
        [self.searchController.searchBar setValue:kLocalizedTableString(@"Cancel", @"CPLocalizable") forKey:@"_cancelButtonText"];
    }
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
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
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = TRUE;  // know where you want UISearchController to be displayed
    
    
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.rowHeight = 80;
    [self.tableView registerNib:[UINib nibWithNibName:@"CPMyFriendCell1" bundle:nil] forCellReuseIdentifier:@"CPMyFriendCell1"];
    self.tableView.sectionIndexColor = RGBA(23, 23, 23, 1);
//    self.tableView.allowsSelectionDuringEditing = YES;
    
    
    UILabel *noDataLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, (kSCREENHEIGHT-kNAVIBARANDSTATUSBARHEIGHT-kTABBARHEIGHT-40)/2, kSCREENWIDTH-30, 40)];
    noDataLbl.textAlignment = NSTextAlignmentCenter;
    noDataLbl.font = [UIFont boldSystemFontOfSize:17.f];
    noDataLbl.textColor = noDataLbl.textColor = RGBA(150, 150, 150, 1);
    noDataLbl.text = kLocalizedTableString(@"has NO Result", @"CPLocalizable");
    [self.tableView addSubview:noDataLbl];
    self.noDataLbl = noDataLbl;
    self.noDataLbl.hidden = YES;
    

    
    self.models = @[].mutableCopy;
//    [self registerNoti];
    
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    
    NSLog(@"CPMyFriendVC savedUserId:%@, [WFCCNetworkService sharedInstance].userId:%@, [WFCCNetworkService sharedInstance].currentConnectionStatus:%ld", savedUserId, [WFCCNetworkService sharedInstance].userId, (long)[WFCCNetworkService sharedInstance].currentConnectionStatus);
    
    if (savedToken.length > 0 && savedUserId.length > 0) {
        if (![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]) {
            NSLog(@"CPMyFriendVC ![[WFCCNetworkService sharedInstance].userId isEqualToString:savedUserId]");
            [[WFCCNetworkService sharedInstance] disconnect:YES];
            [[WFCCNetworkService sharedInstance] connect:savedUserId token:savedToken];
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
            if (nil != deviceToken){
                [[WFCCNetworkService sharedInstance] setDeviceToken:deviceToken];
            }
            //connect im notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IMCONNECTEDONOTHERVIEWCONTROLLER" object:nil];
        }
    }
    
    
    // 
    [self netWorking];
    
    
    // for self.backgroundHeader.alpha
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)onRightBarBtn:(UIBarButtonItem *)sender {
    CGFloat searchExtra = 0;
    CGFloat offsetY = 5;
    if (@available(iOS 11.0, *)) {
        
    }
    else if (@available(iOS 8.0, *)) {
        offsetY = kNAVIBARANDSTATUSBARHEIGHT;
    }
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(self.view.bounds.size.width - 56, 0 + searchExtra, 48, offsetY)
                 menuItems:@[
//                             [KxMenuItem menuItem:@"创建聊天"
//                                            image:[UIImage imageNamed:@"menu_start_chat"]
//                                           target:self
//                                           action:@selector(startChatAction:)],
                             [KxMenuItem menuItem:kLocalizedTableString(@"Add Friend title", @"CPLocalizable")
                                            image:[UIImage imageNamed:@"menu_add_friends"]
                                           target:self
                                           action:@selector(addFriendsAction:)],
//                             [KxMenuItem menuItem:@"收听频道"
//                                            image:[UIImage imageNamed:@"menu_listen_channel"]
//                                           target:self
//                                           action:@selector(listenChannelAction:)],
//                             [KxMenuItem menuItem:@"扫二维码"
//                                            image:[UIImage imageNamed:@"menu_scan_qr"]
//                                           target:self
//                                           action:@selector(scanQrCodeAction:)]


                             ]];
}

- (void)addFriendsAction:(id)sender {
//    UIViewController *addFriendVC = [[WFCUFriendRequestViewController alloc] init];
//    addFriendVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:addFriendVC animated:YES];
    
    UIViewController *addFriendVC = [[WFCUAddFriendViewController alloc] init];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidHide:(NSNotification*)aNotification
{
    //键盘高度
//    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    __weak typeof(self) weakSelf = self;
//    [UIView animateWithDuration:0.2 animations:^{
//
//    }];
}


-(void)registerNoti{

}



-(void)netWorking{
    [self requestMyAllFriends];
}


#pragma mark - set up UIAlertController
- (void)setupAlertView{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Set note name", @"CPLocalizable") message:nil preferredStyle:UIAlertControllerStyleAlert];
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor darkGrayColor];
            }
            else {
                return [UIColor colorWithRed:133./256. green:205./256. blue:243./256. alpha:1.0];
            }
        }];
        
        alertController.view.tintColor = dyColor;
        
    } else {
        // Fallback on earlier versions
        alertController.view.tintColor = [UIColor darkGrayColor];
    }
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        CGRect rect = textField.frame;
        rect.size.height = 40;
        textField.frame = rect;
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = kLocalizedTableString(@"enter note name", @"CPLocalizable");
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
    
        NSMutableArray *tempArray = self.dataArray[self.selectIndexPath.section];
        CPUserInfoModel *model = tempArray[self.selectIndexPath.row];
        // 保存备注名
        [self requestSetNoteNameWithFriendName:model.username noteName:textField.text];

    }];
        
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _sectionTitleArray.count-1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tempArray = _dataArray[section];
    return tempArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPMyFriendCell1 *cell =  (CPMyFriendCell1 *)[tableView dequeueReusableCellWithIdentifier:@"CPMyFriendCell1" forIndexPath:indexPath];
    cell.selectIndexPath = indexPath;
    cell.delegate = self;
    // Configure the cell...
    NSMutableArray *tempArray = _dataArray[indexPath.section];
    CPUserInfoModel *model = tempArray[indexPath.row];
    
    [cell.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
    
    if (self.notename && self.notename.length > 0) {
        cell.titleLbl.text = self.notename;
    }
    else if (model.remarkname && model.remarkname.length > 0) {
        cell.titleLbl.text = model.remarkname;
    }
    else if (model.nickname && model.nickname.length > 0) {
        cell.titleLbl.text = model.nickname;
    }
    else{
        cell.titleLbl.text = model.username;
    }

    if (model.contractCount >= 0) {
        cell.subTitleLbl.text = [NSString stringWithFormat:@"%@ %ld", kLocalizedTableString(@"Completed contract", @"CPLocalizable"), model.contractCount];
    }
    if (model.creditScore >= 0) {
        cell.subDetailLbl.text = [NSString stringWithFormat:@"%@", kLocalizedTableString(@"Score", @"CPLocalizable")];
        cell.detailLbl.text = [NSString stringWithFormat:@"%ld", model.creditScore];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return _sectionTitleArray[section+1];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    //background color of section
//    view.tintColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    //color of text in header
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:RGBA(150, 150, 150, 1)];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionTitleArray;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(index == 0)
    {
        //index是索引条的序号。从0开始，所以第0个是放大镜。如果是放大镜坐标就移动到搜索框处
        [tableView scrollRectToVisible:self.searchController.searchBar.frame animated:NO];
        return -1;
    }else{
        //因为返回的值是section的值。所以减1就是与section对应的值了
        return index-1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *tempArray = _dataArray[indexPath.section];
    CPUserInfoModel *model = tempArray[indexPath.row];
    
    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    mvc.conversation = [WFCCConversation conversationWithType:Single_Type target:model.imUserId line:0];
    if (self.fromMatchikngScheduleMJModel) {
        mvc.scheduleMJModel = self.fromMatchikngScheduleMJModel;
    }
    
    [self.navigationController pushViewController:mvc animated:YES];
}


#pragma mark - 左滑删除, 单个删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    
    WS(weakSelf)
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:kLocalizedTableString(@"Delete", @"CPLocalizable") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
         NSMutableArray *tempArray = self.dataArray[indexPath.section];
         CPUserInfoModel *model = tempArray[indexPath.row];
         
         [[WFCCIMService sharedWFCIMService] deleteFriend:model.imUserId success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestMyAllFriends];
            });
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Delete Friend error", @"CPLocalizable")];
            });
        }];
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
    
    WS(weakSelf)
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"tableView editingStyle forRowAtIndexPath indexPath.row %ld",(long)indexPath.row);
        NSMutableArray *tempArray = _dataArray[indexPath.section];
        CPUserInfoModel *model = tempArray[indexPath.row];
        
        [[WFCCIMService sharedWFCIMService] deleteFriend:model.imUserId success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf requestMyAllFriends];
            });
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Delete Friend error", @"CPLocalizable")];
            });
        }];
    }
}


- (void)myFriendCell1SetNotenameAction:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    [self setupAlertView];
}



#pragma mark - UISearchBarDelegate (which you use ,which you choose!!)
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                   // return NO to not become first responder
{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                    // called when text starts editing
{
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar                       // return NO to not resign first responder
{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                     // called when text ends editing
{
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0) // called before text changes
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                    // called when keyboard search button pressed
{
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar                   // called when bookmark button pressed
{
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar                     // called when cancel button pressed
{
}
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2) // called when search results button pressed
{
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0){
    
}



#pragma mark - UISearchControllerDelegate  (which you use ,which you choose!!)
// These methods are called when automatic presentation or dismissal occurs. They will not be called if you present or dismiss the search controller yourself.
- (void)willPresentSearchController:(UISearchController *)searchController{
    // do something before the search controller is presented
}
- (void)didPresentSearchController:(UISearchController *)searchController{
}
- (void)willDismissSearchController:(UISearchController *)searchController{
}
- (void)didDismissSearchController:(UISearchController *)searchController{
}

// Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
- (void)presentSearchController:(UISearchController *)searchController{
    
}


#pragma mark - UISearchResultsUpdating  (which you use ,which you choose!!)
// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.models mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, id
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "lanmaq"
        //      id CONTAINS[c] "1568689942"
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // use NSExpression represent expressions in predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // username field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"username"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        
        // nickname field matching
        lhs = [NSExpression expressionForKeyPath:@"nickname"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        
        // remarkname field matching
        lhs = [NSExpression expressionForKeyPath:@"remarkname"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    // hand over the filtered results to our search results table
    CPSearchResultController *tableController = (CPSearchResultController *)self.searchController.searchResultsController;
    tableController.filteredModels = searchResults;
    [tableController.tableView reloadData];
    
}


//#pragma mark - 请求保存好友, 自己的后台服务器
//- (void)requestSaveFriendByFriendChatId:(NSString*)friendChatId{
//    NSString *myAccount = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
//
//    if (nil != myAccount) {
//        [SVProgressHUD show];
//        [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/saveUserFriend", BaseURL] parameters:@{@"fuserName":friendChatId, @"userName":myAccount}.mutableCopy success:^(id responseObject) {
//            [SVProgressHUD dismiss];
//            NSLog(@"CPMyFriendVC requestSaveFriend responseObject:%@", responseObject);
//            if (responseObject) {
//                if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
//
//                }
//                else{
//                    NSLog(@"CPMyFriendVC requestSaveFriend 失败");
//                }
//            }
//            else {
//                NSLog(@"CPMyFriendVC requestSaveFriend 失败");
//            }
//
//
//        } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
//            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
//            NSLog(@"CPMyFriendVC requestSaveFriend error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
//        }];
//
//    }
//    else {
//        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please Login", @"CPLocalizable")];
//    }
//}



#pragma mark - 获取好友列表
- (void)requestMyAllFriends{
    NSString *myAccount = [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount];
    if (nil != myAccount) {
        [SVProgressHUD show];
        [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/getUserFriends", BaseURL] parameters:@{}.mutableCopy success:^(id responseObject) {
            [SVProgressHUD dismiss];
            NSLog(@"CPMyFriendVC requestMyAllFriends responseObject:%@", responseObject);
            if (responseObject) {
                if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                    [self.models removeAllObjects];
                    [self.sectionTitleArray removeAllObjects];

                    NSDictionary *dict = [responseObject valueForKey:@"data"];
                    NSArray *result = [dict valueForKey:@"imUserFriends"];
                    for (int i = 0; i < result.count; i++) {
                        NSDictionary *dict = [result objectAtIndex:i];
                        CPUserInfoModel *friendModel = [CPUserInfoModel mj_objectWithKeyValues:dict];
                        [self.models addObject:friendModel];
                    }
                    
                    WS(weakSelf)
                    if (self.models.count > 0) {
                        //初始化UILocalizedIndexedCollation
                        weakSelf.localizedCollection = [UILocalizedIndexedCollation currentCollation];
                        //得出collation索引的数量，这里是27个（26个字母和1个#）
                        NSInteger sectionTitlesCount = [[weakSelf.localizedCollection sectionTitles] count];
                        //初始化一个数组newSectionsArray用来存放最终的数据
                        NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
                        //初始化27个空数组加入newSectionsArray
                        for (NSInteger index = 0; index < sectionTitlesCount; index++) {
                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [newSectionsArray addObject:array];
                        }
                        //将每个人按name分到某个section下
                        for (CPUserInfoModel *friendModel in weakSelf.models) {
                            //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
                            NSInteger sectionNumber = [weakSelf.localizedCollection sectionForObject:friendModel collationStringSelector:@selector(username)];
                            NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
                            [sectionNames addObject:friendModel];
                        }
                        
                        //对每个section中的数组按照name属性排序
                        for (int index = 0; index < sectionTitlesCount; index++) {
                            NSMutableArray *personArrayForSection = newSectionsArray[index];
                            NSArray *sortedPersonArrayForSection = [weakSelf.localizedCollection sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(username)];
                            newSectionsArray[index] = sortedPersonArrayForSection;
                        }
                        
                        
                        //section title
                        weakSelf.sectionTitleArray = [NSMutableArray array];
                        [weakSelf.sectionTitleArray addObject:UITableViewIndexSearch];
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [newSectionsArray enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            if (array.count == 0) {
                                [tempArr addObject:array];
                            }else{
                                [self->_sectionTitleArray addObject:[self->_localizedCollection sectionTitles][idx]];
                            }
                        }];
                        [newSectionsArray removeObjectsInArray:tempArr];
                        
                        weakSelf.dataArray = newSectionsArray.copy;
                    }
                    
                    
                    [weakSelf.tableView reloadData];
                }
                else{
                    NSLog(@"CPMyFriendVC requestMyAllFriends 失败");
                }
            }
            else {
                NSLog(@"CPMyFriendVC requestMyAllFriends 失败");
            }
            
            
        } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            NSLog(@"CPMyFriendVC requestMyAllFriends error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
        }];
        
    }
    else {
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Please Login", @"CPLocalizable")];
    }
}


- (void)requestSetNoteNameWithFriendName:(NSString*)friendName noteName:(NSString*)noteName{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/user/v1/updateRemarkName", BaseURL] parameters:@{@"userName":friendName, @"remarkName":noteName}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPMyFriendVC requestSetNoteName responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                weakSelf.notename = noteName;
                [weakSelf.tableView reloadRow:weakSelf.selectIndexPath.row inSection:weakSelf.selectIndexPath.section withRowAnimation:UITableViewRowAnimationNone];
            }
            else{
                NSLog(@"CPMyFriendVC requestSetNoteName 失败");
            }
        }
        else {
            NSLog(@"CPMyFriendVC requestSetNoteName 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPMyFriendVC requestSetNoteName error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
