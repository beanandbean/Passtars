//
//  CPPassEditViewManager.m
//  Locor
//
//  Created by wangyw on 6/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditManager.h"

#import "CPPasstarsConfig.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPMemo.h"

#import "CPAppearanceManager.h"

#import "CPProcessManager.h"

@interface CPPassEditManager ()

@property (weak, nonatomic) CPPassword *password;

@property (nonatomic) BOOL allowEdit;

@property (strong, nonatomic) UITextField *passwordTextField;

@end

@implementation CPPassEditManager

- (id)initWithSupermanager:(CPViewManager *)supermanager superview:(UIView *)superview andPassword:(CPPassword *)password {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        self.password = password;
        self.allowEdit = password.isUsed.boolValue;
    }
    return self;
}

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.passwordTextField];

    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passwordTextField edgesAlignToView:self.superview]];
    
    if (self.allowEdit) {
        self.passwordTextField.text = self.password.text;
        self.passwordTextField.secureTextEntry = YES;
    } else {
        self.passwordTextField.text = @"";
        self.passwordTextField.secureTextEntry = NO;
        [self.passwordTextField becomeFirstResponder];
    }
}

- (void)unloadAnimated:(BOOL)animated {
    
}

#pragma mark - Touch handler

- (void)handleTouchOnPasswordTextFieldContainer {
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - CPIconPickerDelegate implement

/*- (void)iconSelected:(NSString *)iconName {
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    password.icon = iconName;
    [[CPPassDataManager defaultManager] saveContext];
}*/

#pragma mark - CPMemoCollectionViewManagerDelegate implement

/*- (CPMemo *)newMemo {
    return [[CPPassDataManager defaultManager] newMemoText:@"" inIndex:self.index];
}

#pragma mark - UITextFieldDelegate implement

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.secureTextEntry = NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.secureTextEntry = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!range.location && range.length == textField.text.length && [string isEqualToString:@""]) {
        if (self.allowEdit) {
            self.allowEdit = NO;
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.cellIcon.enabled = self.memoCollectionViewManager.enabled = NO;
            }];
        }
    } else if ([textField.text isEqualToString:@""]) {
        if (!self.allowEdit) {
            self.allowEdit = YES;
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.cellIcon.enabled = self.memoCollectionViewManager.enabled = YES;
            }];
        }
    }
    
    return YES;
}*/

#pragma mark - lazy init

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.textColor = [UIColor whiteColor];
        _passwordTextField.font = [UIFont boldSystemFontOfSize:24.0];
        _passwordTextField.backgroundColor = [UIColor grayColor];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.delegate = self;
    }
    return _passwordTextField;
}

@end
