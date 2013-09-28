//
//  CPPassEditViewManager.h
//  Locor
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

#import "CPPassword.h"

//#import "CPIconPicker.h"

//#import "CPMemoCollectionViewManager.h"

@interface CPPassEditManager : CPViewManager <UITextFieldDelegate>

- (id)initWithSupermanager:(CPViewManager *)supermanager superview:(UIView *)superview andPassword:(CPPassword *)password;

@end
