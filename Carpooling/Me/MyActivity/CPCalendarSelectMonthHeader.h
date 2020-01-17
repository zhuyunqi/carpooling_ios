//
//  CPCalendarSelectMonthHeader.h
//  Carpooling
//
//  Created by bw on 2019/5/20.
//  Copyright © 2019 bw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CPCalendarSelectMonthHeaderDelegate <NSObject>
@required
-(void)selectMonthLeftBtnAction:(id)sender;
-(void)selectMonthRightBtnAction:(id)sender;
@end

@interface CPCalendarSelectMonthHeader : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *line;
@property (nonatomic, weak) id<CPCalendarSelectMonthHeaderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
