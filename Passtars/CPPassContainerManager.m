//
//  CPPassContainerManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "CPPasswordView.h"

#import "CPPasstarsConfig.h"

#import "CPAppearanceManager.h"

#import "CPMainViewController.h"

static float g_positioningArray[14] = {-1.0};

@interface CPPassContainerManager ()

@property (strong, nonatomic) NSMutableArray *passwordViews;
@property (strong, nonatomic) NSMutableArray *passwordConstraints;

@end

@implementation CPPassContainerManager

+ (CGPoint)positionForPasswordAtIndex:(int)index {
    if (g_positioningArray[0] == -1.0) {
        [CPPassContainerManager refreshPositions];
    }
    return CGPointMake(g_positioningArray[index * 2], g_positioningArray[index * 2 + 1]);
}

+ (void)refreshPositions {
    [CPPassContainerManager refreshPositionsWithOrientation:CURRENT_ORIENTATION];
}

+ (void)refreshPositionsWithOrientation:(UIInterfaceOrientation)orientation {
    float r = PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation), m = PASSWORD_HORIZON_DISTANCE_MULTIPLIER;
    float positioningArray[] = {
        0.0, 0.0,
        0.0, -2 * r,
        -m * r, -r,
        -m * r, r,
        0.0, 2 * r,
        m * r, r,
        m * r, -r
    };
    memcpy(g_positioningArray, positioningArray, sizeof(g_positioningArray) * sizeof(float));
}

- (id)initWithSupermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        [CPMainViewController startDeviceOrientationWillChangeNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:CPDeviceOrientationWillChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CPDeviceOrientationWillChangeNotification object:nil];
    [CPMainViewController stopDeviceOrientationWillChangeNotifier];
}

- (void)loadAnimated:(BOOL)animated {
    float radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
    for (int i = 0; i < MAX_PASSWORD_COUNT; i++) {
        CPPasswordView *passwordView = [[CPPasswordView alloc] initWithIndex:i andRadius:radius];
        [self.superview addSubview:passwordView];
        [self.passwordViews addObject:passwordView];
    }
    [self refreshConstraints];
}

- (void)refreshConstraints {
    if (_passwordConstraints) {
        [self.superview removeConstraints:_passwordConstraints];
        _passwordConstraints = nil;
    }
    
    for (int i = 0; i < MAX_PASSWORD_COUNT; i++) {
        CPPasswordView *passwordView = [self.passwordViews objectAtIndex:i];
        CGPoint position = [CPPassContainerManager positionForPasswordAtIndex:i];
        [self.passwordConstraints addObject:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:position.x]];
        [self.passwordConstraints addObject:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:position.y]];
    }
    [self.superview addConstraints:self.passwordConstraints];
}

- (void)refreshRadiusWithOrientation:(UIInterfaceOrientation)orientation {
    float radius = PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation) * PASSWORD_SIZE_MULTIPLIER;
    for (CPPasswordView *passwordView in self.passwordViews) {
        passwordView.radius = radius;
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = ((NSNumber *)notification.object).integerValue;
    [CPPassContainerManager refreshPositionsWithOrientation:orientation];
    [self refreshConstraints];
    [self refreshRadiusWithOrientation:orientation];
}

#pragma mark - lazy init

- (NSMutableArray *)passwordViews {
    if (!_passwordViews) {
        _passwordViews = [[NSMutableArray alloc] initWithCapacity:MAX_PASSWORD_COUNT];
    }
    return _passwordViews;
}

- (NSMutableArray *)passwordConstraints {
    if (!_passwordConstraints) {
        _passwordConstraints = [[NSMutableArray alloc] initWithCapacity:MAX_PASSWORD_COUNT * 2];
    }
    return _passwordConstraints;
}

@end
