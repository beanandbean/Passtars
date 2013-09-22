//
//  CPMainViewManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewManager.h"

#import "CPAppContentManager.h"

#import "CPAppearanceManager.h"

@interface CPMainViewManager ()

@property (strong, nonatomic) CPAppContentManager *appContentManager;

@property (strong, nonatomic) UIView *appContentView;

@end

@implementation CPMainViewManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.appContentView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.appContentView edgesAlignToView:self.superview]];
    [self.appContentManager loadAnimated:NO];
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

@end
