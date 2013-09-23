//
//  CPMainViewManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewManager.h"

#import "CPAppearanceManager.h"

#import "CPAdManager.h"
#import "CPAppContentManager.h"

@interface CPMainViewManager ()

@property (strong, nonatomic) UIView *appContentView;
@property (strong, nonatomic) CPAppContentManager *appContentManager;

@property (strong, nonatomic) UIView *adView;
@property (strong, nonatomic) CPAdManager *adManager;

@end

@implementation CPMainViewManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.appContentView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.appContentView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, ATTR_END]];
    
    [self.superview addSubview:self.adView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.adView alignToView:self.superview attribute:NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.appContentView attribute:NSLayoutAttributeBottom alignToView:self.adView attribute:NSLayoutAttributeTop]];

    [self.appContentManager loadAnimated:NO];
    [self.adManager loadAnimated:NO];
}

#pragma mark - lazy init

- (UIView *)appContentView {
    if (!_appContentView) {
        _appContentView = [[UIView alloc] init];
        _appContentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _appContentView;
}

- (CPAppContentManager *)appContentManager {
    if (!_appContentManager) {
        _appContentManager = [[CPAppContentManager alloc] initWithSupermanager:self andSuperview:self.appContentView];
    }
    return _appContentManager;
}

- (UIView *)adView {
    if (!_adView) {
        _adView = [[UIView alloc] init];
        _adView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _adView;
}

- (CPAdManager *)adManager {
    if (!_adManager) {
        _adManager = [[CPAdManager alloc] initWithSupermanager:self andSuperview:self.adView];
    }
    return _adManager;
}

@end
