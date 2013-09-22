//
//  CPRootManager.m
//  Passtars
//
//  Created by wangyw on 9/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRootManager.h"

#import "CPMainViewManager.h"

#import "CPAppearanceManager.h"

@interface CPRootManager ()

@property (strong, nonatomic) CPMainViewManager *mainViewManager;

@property (strong, nonatomic) UIView *mainView;
 
@end

@implementation CPRootManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.mainView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.mainView edgesAlignToView:self.superview]];
    [self.mainViewManager loadAnimated:NO];
}

#pragma mark - lazy init

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _mainView;
}

- (CPMainViewManager *)mainViewManager {
    if (!_mainViewManager) {
        _mainViewManager = [[CPMainViewManager alloc] initWithSupermanager:self andSuperview:self.mainView];
    }
    return _mainViewManager;
}

@end
