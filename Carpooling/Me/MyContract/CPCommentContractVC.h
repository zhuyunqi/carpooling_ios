//
//  CPCommentContractVC.h
//  Carpooling
//
//  Created by Yang on 2019/6/11.
//  Copyright © 2019 bw. All rights reserved.
//

#import "CPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^CommentContractVCPassValueBlock)(BOOL success);

@interface CPCommentContractVC : CPBaseViewController
@property (nonatomic, assign) NSUInteger contractId;
@property (nonatomic, copy) CommentContractVCPassValueBlock passValueblock;//声明block
@end

NS_ASSUME_NONNULL_END
