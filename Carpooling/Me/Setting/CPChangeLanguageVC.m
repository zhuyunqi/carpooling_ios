//
//  CPChangeLanguageVC.m
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPChangeLanguageVC.h"
#import "CPChangeLanguageCell.h"
#import "BWLocalizableHelper.h"

@interface CPChangeLanguageVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *currentLanguage;
@property (nonatomic, copy) NSString *systemLanguage;
@end

@implementation CPChangeLanguageVC

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
    
    self.title = kLocalizedTableString(@"Language", @"CPLocalizable");
    [self initRightBarItem];
    
    NSArray *languages = [NSLocale preferredLanguages];
    self.systemLanguage = @"";
    if (languages.count>0) {
        self.systemLanguage = languages.firstObject;
    }
    
    _currentLanguage = [[BWLocalizableHelper shareInstance] currentLanguage];
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Confirm", @"CPLocalizable") style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CPREGULARCELLHEIGHT;
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
    CPChangeLanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPChangeLanguageCell1"];
    if (indexPath.row == 0) {
        cell.titleLbl.text = kLocalizedTableString(@"Follow system language", @"CPLocalizable");
        if ([_currentLanguage isEqualToString:self.systemLanguage]) {
            cell.icon.image = [UIImage imageNamed:@"comment_state1"];
        }
    }
    else if (indexPath.row == 1) {
        cell.titleLbl.text = kLocalizedTableString(@"Follow Chinese", @"CPLocalizable");
        if ([_currentLanguage isEqualToString:@"zh-Hans-CN"]) {
            cell.icon.image = [UIImage imageNamed:@"comment_state1"];
        }
    }
    else if (indexPath.row == 2) {
        cell.titleLbl.text = kLocalizedTableString(@"Follow English", @"CPLocalizable");
        if (![self.systemLanguage isEqualToString:@"en-CN"]) {
            if ([_currentLanguage isEqualToString:@"en-CN"]) {
                cell.icon.image = [UIImage imageNamed:@"comment_state1"];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *currentLanguage = @"";
        if (languages.count>0) {
            currentLanguage = languages.firstObject;
            [[BWLocalizableHelper shareInstance] setUserlanguage:currentLanguage];
        }
        
    }
    else if (indexPath.row == 1) {
        [[BWLocalizableHelper shareInstance] setUserlanguage:@"zh-Hans-CN"];
    }
    else if (indexPath.row == 2) {
        [[BWLocalizableHelper shareInstance] setUserlanguage:@"en-CN"];
    }
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
