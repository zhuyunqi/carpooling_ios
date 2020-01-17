//
//  CPNationCodeVC.m
//  Carpooling
//
//  Created by Yang on 2019/6/17.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPNationCodeVC.h"
#import "CPNationCodeCell.h"
#import "CPNationCodeModel.h"

@interface CPNationCodeVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *sectionTitleArray;
@property (nonatomic, strong) UILocalizedIndexedCollation *localizedCollection;
@end

@implementation CPNationCodeVC

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
    
//    NSArray *nationCodeArray = @[
//                       @{@"country":@"中国大陆", @"code":@"+86"},
//                       @{@"country":@"美国", @"code":@"+1"},
//                       @{@"country":@"美利坚", @"code":@"+99"},
//                       @{@"country":@"英国", @"code":@"+44"},
//                       @{@"country":@"香港", @"code":@"+852"},
//                       @{@"country":@"加拿大", @"code":@"+1"}
//                       ];
    
    self.models = @[].mutableCopy;
    
    [self requestNationCode];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _sectionTitleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tempArray = _dataArray[section];
    return tempArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CPREGULARCELLHEIGHT;
}


-(NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return _sectionTitleArray[section];
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
    return index;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPNationCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPNationCodeCell"];
    NSMutableArray *tempArray = _dataArray[indexPath.section];
    CPNationCodeModel *nationCodeModel = tempArray[indexPath.row];
    cell.titleLbl.text = nationCodeModel.country;
    cell.subtitleLbl.text = nationCodeModel.code;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *tempArray = _dataArray[indexPath.section];
    CPNationCodeModel *nationCodeModel = tempArray[indexPath.row];
    NSDictionary *dict = [nationCodeModel mj_keyValues];
    self.passValueblock(dict);
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)requestNationCode{
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@/api/register/v1/getCountryCode", BaseURL] parameters:@{}.mutableCopy success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPNationCodeVC requestNationCode responseObject:%@", responseObject);
        WS(weakSelf);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSDictionary *dict = [responseObject valueForKey:@"data"];
                NSArray *nationCodeArray = [dict valueForKey:@"countryCode"];
                
                for (int i = 0; i < nationCodeArray.count; i++) {
                    NSDictionary *dict = [nationCodeArray objectAtIndex:i];
                    CPNationCodeModel *nationCodeModel = [CPNationCodeModel mj_objectWithKeyValues:dict];
                    [weakSelf.models addObject:nationCodeModel];
                }
                
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
                for (CPNationCodeModel *nationCodeModel in weakSelf.models) {
                    //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
                    NSInteger sectionNumber = [weakSelf.localizedCollection sectionForObject:nationCodeModel collationStringSelector:@selector(country)];
                    NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
                    [sectionNames addObject:nationCodeModel];
                }
                
                //对每个section中的数组按照name属性排序
                for (int index = 0; index < sectionTitlesCount; index++) {
                    NSMutableArray *personArrayForSection = newSectionsArray[index];
                    NSArray *sortedPersonArrayForSection = [weakSelf.localizedCollection sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(country)];
                    newSectionsArray[index] = sortedPersonArrayForSection;
                }
                
                
                //section title
                weakSelf.sectionTitleArray = [NSMutableArray array];
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
                
                [weakSelf.tableView reloadData];
                
                
            }
            else{
                NSLog(@"CPNationCodeVC requestNationCode 失败");
            }
        }
        else {
            NSLog(@"CPNationCodeVC requestNationCode 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPNationCodeVC requestNationCode error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
