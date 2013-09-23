//
//  CPRootManager.m
//  Passtars
//
//  Created by wangyw on 9/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRootManager.h"

#import "CPAppearanceManager.h"
#import "CPUserDefaultManager.h"

#import "CPHelpManager.h"
#import "CPMainViewManager.h"

@interface CPRootManager ()

@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) CPMainViewManager *mainViewManager;

@property (strong, nonatomic) UIView *helpView;
@property (strong, nonatomic) CPHelpManager *helpManager;

@end

@implementation CPRootManager

- (void)loadAnimated:(BOOL)animated {
    /*if ([CPUserDefaultManager isFirstRunning]) {
        [self.superview addSubview:self.helpView];
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.helpView edgesAlignToView:self.superview]];
        [self.helpManager loadAnimated:animated];
        
        [CPUserDefaultManager setFirstRuning:NO];
    } else {*/
        [self loadMainViewManager];
    //}
}

- (void)submanagerDidUnload:(CPViewManager *)submanager {
    if (submanager == self.helpManager) {
        [self loadMainViewManager];
        [self.superview bringSubviewToFront:self.helpView];
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.helpView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.helpView removeFromSuperview];
            self.helpView = nil;
            self.helpManager = nil;
        }];
    }
}

- (void)loadMainViewManager {
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

- (UIView *)helpView {
    if (!_helpView) {
        _helpView = [[UIView alloc] init];
        _helpView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _helpView;
}

- (CPHelpManager *)helpManager {
    if (!_helpManager) {
        _helpManager = [[CPHelpManager alloc] initWithSupermanager:self andSuperview:self.helpView];
    }
    return _helpManager;
}

@end
