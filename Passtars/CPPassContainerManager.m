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

static float g_positioningArray[14] = {-1.0};

@interface CPPassContainerManager ()

@property (strong, nonatomic) NSMutableArray *passwordViews;

@end

@implementation CPPassContainerManager

+ (CGPoint)positionForPasswordAtIndex:(int)index {
    if (g_positioningArray[0] == -1.0) {
        float r = PASSWORD_RADIUS, m = PASSWORD_HORIZON_DISTANCE_MULTIPLIER;
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
    return CGPointMake(g_positioningArray[index * 2], g_positioningArray[index * 2 + 1]);
}

- (void)loadAnimated:(BOOL)animated {
    float radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
    for (int i = 0; i < MAX_PASSWORD_COUNT; i++) {
        CPPasswordView *passwordView = [[CPPasswordView alloc] initWithIndex:i andRadius:radius];
        
        [self.superview addSubview:passwordView];
        [self.passwordViews addObject:passwordView];
        
        CGPoint position = [CPPassContainerManager positionForPasswordAtIndex:i];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:position.x]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:position.y]];
    }
}

#pragma mark - lazy init

- (NSMutableArray *)passwordViews {
    if (!_passwordViews) {
        _passwordViews = [[NSMutableArray alloc] initWithCapacity:MAX_PASSWORD_COUNT];
    }
    return _passwordViews;
}

@end
