//
//  CPPasstarsConfig.h
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPHelperMacros.h"

#ifndef _CPPasstarsConfig_h_
#define _CPPasstarsConfig_h_

#pragma mark - SECTION: Password

static const int MAX_PASSWORD_COUNT = 7;

static const float DEFAULT_PASSWORD_COLORS[] = {
    1.000, 0.000, 0.000,
    1.000, 0.647, 0.000,
    1.000, 1.000, 0.000,
    0.000, 0.502, 0.000,
    0.000, 0.000, 1.000,
    0.294, 0.510, 0.000,
    0.502, 0.000, 0.502,
};

#define PASSWORD_DEVICE_RELATED_INDEX (DEVICE_RELATED_OBJ(0, 1) + ORIENTATION_RELATED_OBJ(1, 0))
    // This was defined to get index for the following array according to current devide and orientation

static const float _PASSWORD_RADIUS[] = {
     58.564, // iPhone
    140.554, // iPad portrait
    117.000, // iPad landscape
};

#define PASSWORD_RADIUS _PASSWORD_RADIUS[PASSWORD_DEVICE_RELATED_INDEX]

static const float PASSWORD_HORIZON_DISTANCE_MULTIPLIER = 1.732; // = sqrt(3)
    // distance between left and center passwords: multiplier * radius

#endif
