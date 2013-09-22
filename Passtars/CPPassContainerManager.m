//
//  CPPassContainerManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "CPPasstarsConfig.h"

static float g_positioningArray[14];

@implementation CPPassContainerManager

+ (void)refreshPositioningArray {
    float r = PASSWORD_RADIUS, m = PASSWORD_HORIZON_DISTANCE_MULTIPLIER;
    float positioningArray[] = {
        0.0, 0.0,
        0.0, -3 * r,
        -m * r, -r,
        -m * r, r,
        3 * r, 0.0,
        m * r, r,
        m * r, -r
    };
    memcpy(g_positioningArray, positioningArray, sizeof(g_positioningArray) * sizeof(float));
}

- (void)loadAnimated:(BOOL)animated {
    [CPPassContainerManager refreshPositioningArray];
}

@end
