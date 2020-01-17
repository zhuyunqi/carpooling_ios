//
//  CPMyAddressCell1.m
//  Carpooling
//
//  Created by bw on 2019/5/23.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPMyAddressCell1.h"
#import "CPAddressModel.h"

@implementation CPMyAddressCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            }
            else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
        
        self.backgroundColor = dyColor;
        _bgView.backgroundColor = dyColor;
        
        UIColor *dyColor2 = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor blackColor];
            }
            else {
                return [UIColor secondaryLabelColor];
            }
        }];
        _titleLbl.textColor = dyColor2;
        
        
    } else {
        // Fallback on earlier versions
        self.backgroundColor = [UIColor whiteColor];
        _titleLbl.textColor = [UIColor blackColor];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    
    
    _titleLbl.font = [UIFont systemFontOfSize:15.f];
    
    [_bgView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressed:)]];
//    tap.cancelsTouchesInView = NO;
    [_bgView setUserInteractionEnabled:YES];
}

- (void)onLongPressed:(id)sender {
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer *)sender;
        if(recognizer.state == UIGestureRecognizerStateBegan) {
            [self.delegate addressCell1LongPress:self atIndexPath:_indexPath];
        }
    }
}

- (void)setAddressModel:(CPAddressModel *)addressModel{
//    if (_addressModel != addressModel) {
    _addressModel = addressModel;
    
//    if (self.showType == 0) {
//        _confirmBtn.hidden = YES;
//        
//    }
//    else {
//        _confirmBtn.hidden = NO;
//    }
    
    if (addressModel.isCollect) {
        _markIcon.image = [UIImage imageNamed:@"me_collected"];
    }
    else {
        _markIcon.image = [UIImage imageNamed:@"me_collect"];
    }
    
    _titleLbl.text = addressModel.address;
//    }
}


- (void)setIndexPath:(NSIndexPath *)indexPath{
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
    }
}

- (IBAction)collectAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressCell1CollectActionAtIndexPath:)]) {
        [self.delegate addressCell1CollectActionAtIndexPath:self.indexPath];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
