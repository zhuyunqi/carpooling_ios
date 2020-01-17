//
//  CPUserInfoVC.m
//  Carpooling
//
//  Created by bw on 2019/5/18.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPUserInfoVC.h"
#import "CPUserInfoCell1.h"
#import "CPUserInfoCell2.h"
#import "CPChangeIDVC.h"
#import "CPBindingPhoneVC.h"
#import "CPUserLoginVC.h"
#import "CPUserReqResultModel.h"
#import "CPUserReqResultSubModel.h"
#import "CPUserInfoModel.h"

#import <AVFoundation/AVFoundation.h>

#import <WFChatClient/WFCChatClient.h>


@interface CPUserInfoVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSString *imageUrl;
@end

@implementation CPUserInfoVC

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
    
    self.title = kLocalizedTableString(@"User Info", @"CPLocalizable");
//    [self requestUserInfo];
}

- (void)setUser:(CPUserInfoModel *)user{
    _user = user;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    }
    return 50;
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
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserInfoCell1"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (_imageUrl) {
            [((CPUserInfoCell1*)cell).imgView sd_setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        }
        else{
            [((CPUserInfoCell1*)cell).imgView sd_setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:[UIImage imageNamed:@"messege_no_icon"]];
        }
        
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserInfoCell2"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        ((CPUserInfoCell2*)cell).titleLbl.text = _user.nickname == nil ? kLocalizedTableString(@"Change Nickname", @"CPLocalizable") : _user.nickname;
    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserInfoCell3"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (_user.mobile) {
            ((CPUserInfoCell2*)cell).titleLbl.text = [NSString stringWithFormat:@"%@ %@", kLocalizedTableString(@"Phonenumber", @"CPLocalizable"), _user.mobile];
        }
        else{
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Phonenumber", @"CPLocalizable");
        }
        
    }
    else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CPUserInfoCell4"];
        if (_user.username) {
            ((CPUserInfoCell2*)cell).titleLbl.text = [NSString stringWithFormat:@"%@ %@", kLocalizedTableString(@"Current Account", @"CPLocalizable"), _user.username];
        }
        else{
            ((CPUserInfoCell2*)cell).titleLbl.text = kLocalizedTableString(@"Current Account", @"CPLocalizable");
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (nil == [[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginAccount]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPUserLoginVC *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"CPUserLoginVC"];
        [self.navigationController pushViewController:userLoginVC animated:YES];
        
        return;
    }
    
    if (indexPath.row == 0) {
        [self setupAlert];
    }
    else if (indexPath.row == 1) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPChangeIDVC *changeIDVC = [storyboard instantiateViewControllerWithIdentifier:@"CPChangeIDVC"];
        changeIDVC.passValueblock = ^(NSString * _Nonnull nickname) {
            self.user.nickname = nickname;
            [self.tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:changeIDVC animated:YES];
    }
    else if (indexPath.row == 2) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CPBindingPhoneVC *bindingPhoneVC = [storyboard instantiateViewControllerWithIdentifier:@"CPBindingPhoneVC"];
        bindingPhoneVC.passValueblock = ^(NSString * _Nonnull phone) {
            self.user.mobile = phone;
            [self.tableView reloadRow:2 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:bindingPhoneVC animated:YES];
    }
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
    imagePickerController.allowsEditing = YES;
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
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadImage:image imageName:@""];
    }];
}

//当用户取消选择的时候，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - 上传图片
- (void)uploadImage:(UIImage *)image imageName:(NSString *)imageName{
    [SVProgressHUD show];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    WS(weakSelf)
    [[NetworkManager shareNetworkManager] UploadImageWithUrl:[NSString stringWithFormat:@"%@/api/upload/v1/upload/hdavatarByFile", BaseURL] parameters:@{}.mutableCopy pictureData:imageData pictureKey:@"file" progress:^(NSProgress *progress) {

    } success:^(id responseObject) {
        NSLog(@"CPSetupActivityVC uploadImage responseObject:%@", responseObject);
        if (responseObject) {
            if ([[responseObject valueForKey:@"code"] integerValue] == 200) {
                NSDictionary *dict = [responseObject valueForKey:@"data"];
                weakSelf.imageUrl = [dict valueForKey:@"avatar"];
                
                //
                [[WFCCIMService sharedWFCIMService] modifyMyInfo:@{@(Modify_Portrait):weakSelf.imageUrl} success:^{
                    [SVProgressHUD dismiss];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSUserDefaults standardUserDefaults] setValue:[dict valueForKey:@"avatar"] forKey:kUserAvatar];
                        [weakSelf.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
                    });
                    
                } error:^(int error_code) {
                    [SVProgressHUD dismiss];
                    NSLog(@"[WFCCIMService sharedWFCIMService] modifyMyInfo:修改个人资料失败");
                }];

            }
            else{
                [SVProgressHUD dismiss];
                NSLog(@"uploadImage uploadImage 失败");
            }
        }
        else {
            [SVProgressHUD dismiss];
            NSLog(@"uploadImage uploadImage 失败");
        }

    } failure:^(NSError *error, ParamtersJudgeCode judgeCode) {
//        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }];
    

//    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
//    [[WFCCIMService sharedWFCIMService] uploadMedia:imageData mediaType:Media_Type_PORTRAIT success:^(NSString *remoteUrl) {
//        NSLog(@"[WFCCIMService sharedWFCIMService] uploadMedia:上传头像成功:%@", remoteUrl);
//        [[WFCCIMService sharedWFCIMService] modifyMyInfo:@{@(Modify_Portrait):remoteUrl} success:^{
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//            });
//
//        } error:^(int error_code) {
//            NSLog(@"[WFCCIMService sharedWFCIMService] modifyMyInfo:修改个人资料失败");
//        }];
//
//    } progress:^(long uploaded, long total) {
//
//    } error:^(int error_code) {
//        NSLog(@"[WFCCIMService sharedWFCIMService] uploadMedia:上传头像失败");
//    }];
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
