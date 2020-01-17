//
//  CPSetupActivityVC.m
//  Carpooling
//
//  Created by bw on 2019/5/21.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPSetupActivityVC.h"
#import "CPSetupActivityCell1.h"
#import "CPSetupActivityCell2.h"
#import "CPInitShortTermContractCell2.h"
#import "CPUserInfoCell2.h"
#import "BWSheetBottmView.h"
#import "CPSelectContractThemeVC.h"
#import "SSChatLocationController.h"
#import "CPMyAddressPageVC.h"
#import "CPActivityMJModel.h"
#import "CPAddressModel.h"

#import <AVFoundation/AVFoundation.h>

#import "TOCropViewController.h"


@interface CPSetupActivityVC ()<BWSheetBottmViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CPSetupActivityCell2Delegate, TOCropViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSIndexPath *addressSelectIndexPath; // 选择地址时的indexpath
@property (nonatomic, assign) CGFloat tableViewOriginContentOffsetY;
@property (nonatomic, assign) BOOL canAdjustTableFrame;
@property(nonatomic, strong) NSString *theme;
@property(nonatomic, strong) NSDictionary *locationDict1;
@property (nonatomic, assign) BOOL isCalendarSelected;
@property(nonatomic, strong) NSString *calendarSelectedDateString;
@property(nonatomic, strong) NSString *selectedTimeString;
@property(nonatomic, strong) NSString *startTimeString;
@property(nonatomic, strong) NSString *remark;
@property(nonatomic, strong) NSString *imageUrl;


@property (nonatomic, strong) UIImage *cropImage;           // The image we'll be cropping
@end

@implementation CPSetupActivityVC

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
    
    
    self.title = kLocalizedTableString(@"Initiation Activity", @"CPLocalizable");
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self initRightBarItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //注册并登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectContractAddress:) name:@"SELECTCONTRACTADDRESSSUCCESS" object:nil];
}

- (void)selectContractAddress:(NSNotification*)notification{
    NSDictionary *dict = notification.userInfo;
    _locationDict1 = dict;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:_addressSelectIndexPath.section];
    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SELECTCONTRACTADDRESSSUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated{
    _canAdjustTableFrame = NO;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _canAdjustTableFrame = YES;
}

- (void)initRightBarItem{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedTableString(@"Publish", @"CPLocalizable")style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightItemClick:(id)sender{
    [self requestSetupOrEditActivity];
}

//键盘通知的方法
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    if (_canAdjustTableFrame) {
        //键盘高度
        CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect tableViewRect = self.tableView.frame;
        //    CGFloat diffHeight = self.tableView.frame.size.height-self.tableView.contentSize.height;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.tableView.frame = CGRectMake(0, -keyBoardFrame.size.height+kNAVIBARANDSTATUSBARHEIGHT+kBOTTOMSAFEHEIGHT, tableViewRect.size.width, tableViewRect.size.height);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (_canAdjustTableFrame) {
        self.tableView.frame = CGRectMake(0, 0, self.tableView.size.width, self.tableView.size.height);
    }
}


// !!!: //
- (void)setActivityModel:(CPActivityMJModel *)activityModel{
    _activityModel = activityModel;
    
    _imageUrl = activityModel.imgUrl;
    
    _theme = activityModel.name;
    _locationDict1 = [activityModel.addressVo mj_keyValues];
    
    NSDate *date = [Utils getDateWithTimestamp:self.activityModel.date];
    NSString *dateStr = [Utils dateToString:date withDateFormat:@"YYYY/MM/dd HH:mm"];
    _startTimeString = dateStr;
    
    _remark = activityModel.describe;
    
    [self.tableView reloadData];
}

#pragma mark - UITableView UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {

    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 5;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 200;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return CPREGULARCELLHEIGHT;
        }
        else if (indexPath.row == 1) {
            return CPREGULARCELLHEIGHT;
        }
        else if (indexPath.row == 2) {
            return 90;
        }
        else if (indexPath.row == 3) {
            return CPREGULARCELLHEIGHT;
        }
        else if (indexPath.row == 4) {
            return 200;
        }
    }
    return CPREGULARCELLHEIGHT;
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
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupActivityCell1"];
        ((CPSetupActivityCell1*)cell).descLbl.text = kLocalizedTableString(@"Activity Picture Desc", @"CPLocalizable");
        if (_cropImage) {
            ((CPSetupActivityCell1*)cell).activityImageView.image = self.cropImage;
            ((CPSetupActivityCell1*)cell).someView.hidden = YES;
            ((CPSetupActivityCell1*)cell).addIcon.hidden = YES;
            ((CPSetupActivityCell1*)cell).descLbl.hidden = YES;
        }
        else if (self.activityModel) {
            if (self.activityModel.imgUrl && self.activityModel.imgUrl.length > 0) {
                [((CPSetupActivityCell1*)cell).activityImageView sd_setImageWithURL:[NSURL URLWithString:self.activityModel.imgUrl]];
                ((CPSetupActivityCell1*)cell).someView.hidden = YES;
                ((CPSetupActivityCell1*)cell).addIcon.hidden = YES;
                ((CPSetupActivityCell1*)cell).descLbl.hidden = YES;
            }
        }
        
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupActivityCell2"];
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Theme", @"CPLocalizable");
            ((CPUserInfoCell2*)cell).subTitleLbl.text =  _theme == nil ? @"" : _theme;
            
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupActivityCell3"];
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Activity Address", @"CPLocalizable");
        }
        else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupActivityCell4"];
            NSLog(@"CPSetupActivityVC cellForRowAtIndexPath address:%@", [_locationDict1 valueForKey:@"address"]);
            ((CPInitShortTermContractCell2*)cell).titleLbl.text = [_locationDict1 valueForKey:@"address"];
            
        }
        else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupActivityCell5"];
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Activity Time", @"CPLocalizable");
            NSDate *date = [Utils stringToDate:_startTimeString withDateFormat:@"YYYY-MM-dd HH:mm"];
            NSString *dateStr = [Utils dateToString:date withDateFormat:@"YYYY/MM/dd EEE HH:mm"];
            ((CPUserInfoCell2*)cell).subTitleLbl.text = dateStr;
            
        }
        else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CPSetupActivityCell6"];
            ((CPSetupActivityCell2*)cell).descLbl.text = kLocalizedTableString(@"Description Activity", @"CPLocalizable");
            ((CPSetupActivityCell2*)cell).delegate = self;
            
            ((CPSetupActivityCell2*)cell).remark = self.remark;
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self setupAlert];
        
    }
    else {
        if (indexPath.row == 0) {
            [self.view endEditing:YES];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPSelectContractThemeVC *selectContractThemeVC = [storyboard instantiateViewControllerWithIdentifier:@"CPSelectContractThemeVC"];
            selectContractThemeVC.titleType = 0;
            if (self.theme) {
                selectContractThemeVC.aString = self.theme;
            }
            selectContractThemeVC.passValueblock = ^(NSString * _Nonnull aSting) {
                //
                self.theme = aSting;
                NSLog(@"selectContractThemeVC 0 result:%@", aSting);
                [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:selectContractThemeVC animated:YES];
            
        }
        else if (indexPath.row == 1) {
            // 通过我的地址列表选择
            self.addressSelectIndexPath = indexPath;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CPMyAddressPageVC *myAddressPageVC = [storyboard instantiateViewControllerWithIdentifier:@"CPMyAddressPageVC"];
            [self.navigationController pushViewController:myAddressPageVC animated:YES];
            
        }
        else if (indexPath.row == 2) {
            // 通过地图选择地址
            SSChatLocationController *chatLocationController = [[SSChatLocationController alloc] init];
            chatLocationController.locationBlock = ^(NSDictionary *locationDict, WFCULocationPoint *point) {
                self.locationDict1 = locationDict;
                [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:chatLocationController animated:YES];
            
        }
        else if (indexPath.row == 3) {
            [self.view endEditing:YES];
//            _adjustTableFrame = NO;
            
            BWSheetBottmView *bottomView = [[BWSheetBottmView alloc] initWithTitle:@"" delegate:self];
            bottomView.actionSheetPickerStyle = BWActionSheetPickerStyleOnlyTimePicker;
            [bottomView.actionToolbar.cancelButton setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBA(100, 100, 100, 1), NSFontAttributeName:[UIFont systemFontOfSize:17.f]} forState:UIControlStateNormal];
            if (@available(iOS 13.0, *)) {
                UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                    if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                        return RGBA(37, 37, 37, 1);
                    }
                    else {
                        return [UIColor labelColor];
                    }
                    
                }];
                
                [bottomView.actionToolbar.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:dyColor, NSFontAttributeName:[UIFont boldSystemFontOfSize:17.f]} forState:UIControlStateNormal];
                
            } else {
                // Fallback on earlier versions
                [bottomView.actionToolbar.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBA(37, 37, 37, 1), NSFontAttributeName:[UIFont boldSystemFontOfSize:17.f]} forState:UIControlStateNormal];
            }
            
            //            bottomView.actionToolbar.cancelButton = nil;
            bottomView.actionToolbar.doneButton.title = kLocalizedTableString(@"Confirm", @"CPLocalizable");
            bottomView.height = 350+kBOTTOMSAFEHEIGHT;
            [bottomView setTag:10001];
            [bottomView show];
        }
    }
}


- (void)bwActionSheetPickerViewDidCancel:(BWSheetBottmView *)pickerView{
    _canAdjustTableFrame = YES;
}

#pragma mark - BWSheetBottmViewDelegate
// date time
- (void)bwActionSheetPickerView:(BWSheetBottmView *)pickerView didSelectDate:(NSDate *)date{
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView didSelectDate:%@", date);
    //创建一个日期格式
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
    if (!_isCalendarSelected) {
        fmt.dateFormat = @"YYYY-MM-dd";
        _calendarSelectedDateString = [fmt stringFromDate:date];
    }
    
    fmt.dateFormat = @"HH:mm";
    _selectedTimeString = [fmt stringFromDate:date];
    
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView didSelectDate _calendarSelectedDateString:%@, _selectedTimeString:%@", _calendarSelectedDateString, _selectedTimeString);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
    _startTimeString = [NSString stringWithFormat:@"%@ %@", _calendarSelectedDateString, _selectedTimeString];
    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}

// date
- (void)bwActionSheetPickerView:(BWSheetBottmView *)pickerView calendarDidSelectDate:(NSDate *)date{
    _isCalendarSelected = YES;
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView calendarDidSelectDate:%@", date);
    //    _calendarSelectedDate = date;
    //创建一个日期格式
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"YYYY-MM-dd";
    _calendarSelectedDateString = [fmt stringFromDate:date];
    NSLog(@"CPInitShortTermContractVC actionSheetPickerView calendarDidSelectDate _calendarSelectedDateString:%@, _selectedTimeString:%@", _calendarSelectedDateString, _selectedTimeString);
}


- (void)setupAlert{
    UIAlertController *alertSheet = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Upload Image", @"CPLocalizable") message:kLocalizedTableString(@"Please Select Photo", @"CPLocalizable") preferredStyle:UIAlertControllerStyleActionSheet];

    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:kLocalizedTableString(@"Upload Image", @"CPLocalizable")];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, alertControllerStr.length)];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, alertControllerStr.length)];
    [alertSheet setValue:alertControllerStr forKey:@"attributedTitle"];

    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:kLocalizedTableString(@"Please Select Photo", @"CPLocalizable")];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertSheet setValue:alertControllerMessageStr forKey:@"attributedMessage"];


    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self; //设置代理
//    imagePickerController.allowsEditing = YES;
    // 定制UIImagePickerController导航栏颜色
    imagePickerController.navigationBar.barStyle = UIBarStyleBlack;
    imagePickerController.navigationBar.barTintColor = RGBA(33, 202, 138, 1);
    imagePickerController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;


    [alertSheet addAction:[UIAlertAction actionWithTitle:kLocalizedTableString(@"Photo Album", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }]];

    [alertSheet addAction:[UIAlertAction actionWithTitle:kLocalizedTableString(@"Take Photo", @"CPLocalizable") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

            //读取媒体类型
            NSString *mediaType = AVMediaTypeVideo;
            //读取设备授权状态
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){

                NSString *errorStr = kLocalizedTableString(@"Auth Camera Desc", @"CPLocalizable");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:kLocalizedTableString(@"Tips", @"CPLocalizable") message:errorStr preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    //
                }]];

                [self presentViewController:alert animated:YES completion:nil];
                return;
            }

            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }]];

    [alertSheet addAction:[UIAlertAction actionWithTitle:kLocalizedTableString(@"Cancel", @"CPLocalizable") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //
    }]];

    [self presentViewController:alertSheet animated:YES completion:^{
        //
    }];
}

#pragma mark - UIImagePickerController 选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:image];
    cropController.delegate = self;
    
//    self.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:cropController animated:YES completion:nil];
        
        
    }];
}

//当用户取消选择的时候，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.cropImage = nil;
    }];
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{

    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    //将图片转为data数据
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    UIImage *afterImage = [UIImage imageWithData: imageData];
    self.cropImage = afterImage;
    
    [cropViewController dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        
        // upload
        [self uploadImage:image imageName:@""];
    }];
}

//#pragma mark - 更改系统相册导航栏按钮颜色 tintColor
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//#warning runtime更改系统相册导航栏按钮颜色 tintColor
//    viewController.navi = self.navigationController.navigationBar.tintColor;
//}

#pragma mark - 上传图片
- (void)uploadImage:(UIImage *)image imageName:(NSString *)imageName{
    [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Image Uploading Waiting", @"CPLocalizable")];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    WS(weakSelf)
    [[NetworkManager shareNetworkManager] UploadImageWithUrl:[NSString stringWithFormat:@"%@/api/upload/v1/upload", BaseURL] parameters:nil pictureData:imageData pictureKey:@"file"
    progress:^(NSProgress *progress) {
        [SVProgressHUD showInfoWithStatus:kLocalizedTableString(@"Image Uploading Waiting", @"CPLocalizable")];
        NSLog(@"CPSetupActivityVC uploadImage progress");
        weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
        
    } success:^(id responseObject) {
        [SVProgressHUD dismiss];
        
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                weakSelf.imageUrl = [responseObject valueForKey:@"data"];
                NSLog(@"CPSetupActivityVC uploadImage weakSelf.imageUrl:%@", weakSelf.imageUrl);
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            }
            else{
                NSLog(@"CPSetupActivityVC uploadImage uploadImage 失败");
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            }
        }
        else {
            NSLog(@"CPSetupActivityVC uploadImage uploadImage 失败");
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
//        [SVProgressHUD dismiss];
        [SVProgressHUD showInfoWithStatus:[error localizedDescription]];
        NSLog(@"CPSetupActivityVC uploadImage failure");
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
//        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }];
}

- (void)setupActivityCell2TVDidEditing:(NSString *)text{
    _remark = text;
}

- (void)requestSetupOrEditActivity{
    NSLog(@"_locationDict1:%@", _locationDict1);

    NSString *tips = @"";
    if (!self.theme) {
        tips = kLocalizedTableString(@"Please enter theme", @"CPLocalizable");
    }
    else if (nil == [_locationDict1 valueForKey:@"address"]) {
        tips = kLocalizedTableString(@"Please choice activity adress", @"CPLocalizable");
    }
    else if (!self.startTimeString) {
        tips = kLocalizedTableString(@"Please choice activity time", @"CPLocalizable");
    }
    else if (!self.remark) {
        tips = kLocalizedTableString(@"Please desc activity", @"CPLocalizable");
    }
    
    if (![tips isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:tips];
        return;
    }
    
    NSTimeInterval timestamp = [Utils getTimeStampUTCWithTimeString:self.startTimeString format:@"yyyy-MM-dd HH:mm"];
    self.imageUrl = self.imageUrl == nil ? @"" : self.imageUrl;
    
    [self.imageUrl stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSLog(@"CPInitShortTermContractVC requestSetupOrEditActivity self.imageUrl:%@", self.imageUrl);
    
    NSMutableDictionary *param = @{
                                   
                            @"name":self.theme,
                            @"addressVo":@{
                                    @"address":[_locationDict1 valueForKey:@"address"],
                                    @"addressName":[_locationDict1 valueForKey:@"addressName"],
                                    @"latitude":[_locationDict1 valueForKey:@"latitude"],
                                    @"longitude":[_locationDict1 valueForKey:@"longitude"],
                                    @"thoroughfare":[_locationDict1 valueForKey:@"thoroughfare"],
                                    @"subThoroughfare":[_locationDict1 valueForKey:@"subThoroughfare"],
                                    @"locality":[_locationDict1 valueForKey:@"locality"],
                                    @"subLocality":[_locationDict1 valueForKey:@"subLocality"],
                                    @"administrativeArea":[_locationDict1 valueForKey:@"administrativeArea"],
                                    @"subAdministrativeArea":[_locationDict1 valueForKey:@"subAdministrativeArea"],
                            },
                            @"describe":self.remark,
                            @"imgUrl":self.imageUrl,
                            @"date":[NSNumber numberWithUnsignedInteger:timestamp],
                            }.mutableCopy;
    
    NSString *url = @"";
    if (self.showType == SetupActivityVCTypeSetup) {
        url = @"/api/activity/v1/launchActivity.json";
    }
    else if (self.showType == SetupActivityVCTypeEdit) {
        url = @"/api/activity/v1/updateActivity";
        [param setValue:[NSNumber numberWithInteger:self.activityModel.dataid] forKey:@"id"];
    }
    
    
    WS(weakSelf);
    [SVProgressHUD show];
    [[NetworkManager shareNetworkManager] POSTUrl:[NSString stringWithFormat:@"%@%@", BaseURL, url] parameters:param success:^(id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"CPInitShortTermContractVC requestSetupActivity responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                // postnoti
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupActivitySuccess" object:nil];

                if (weakSelf.passValueblock) {
                    weakSelf.passValueblock(YES);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                [SVProgressHUD showInfoWithStatus:[responseObject valueForKey:@"msg"]];
                NSLog(@"CPInitShortTermContractVC requestSetupActivity 失败");
            }
        }
        else {
            NSLog(@"CPInitShortTermContractVC requestSetupActivity 失败");
        }
        
        
    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        NSLog(@"CPInitShortTermContractVC requestSetupActivity error:%@, judgeCode:%lu", [error localizedDescription], (unsigned long)judgeCode);
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
