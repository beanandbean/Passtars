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

#define MAX_PASSWORD_COUNT 7

#define PASSWORD_DEVICE_SEPCIFIED_ORIENTATION_RELATED_INDEX(orientation) \
    (DEVICE_RELATED_OBJ(0, 1) + SPECIFIED_ORIENTATION_RELATED_OBJ(orientation, 1, 0))
    // This was defined to get index for the array _PASSWORD_RADIUS[] according to current devide and orientation

#define PASSWORD_DEVICE_ORIENTATION_RELATED_INDEX \
    PASSWORD_DEVICE_SEPCIFIED_ORIENTATION_RELATED_INDEX(CURRENT_ORIENTATION)

#define PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation) \
    _PASSWORD_RADIUS[PASSWORD_DEVICE_SEPCIFIED_ORIENTATION_RELATED_INDEX(orientation)]

#define PASSWORD_RADIUS \
    PASSWORD_SPECIFIED_ORIENTATION_RADIUS(CURRENT_ORIENTATION)

#define PASSWORD_HORIZON_DISTANCE_MULTIPLIER 1.732 // = sqrt(3)
    // distance between left and center passwords: multiplier * radius

#define PASSWORD_SIZE_MULTIPLIER  0.95 // normal size = RADIUS * size multiplier
#define PASSWORD_DRAG_SIZE_MULTIPLIER 1.15 // drag size = RADIUS * drag multiplier

#define PASSWORD_GRADIENT_EXPONENT 1.75

extern const float _PASSWORD_RADIUS[];

extern const float DEFAULT_PASSWORD_COLORS[];

extern const char *PASSWORD_ICON_NAMES[];

#pragma mark - SECTION: Help

#define HELP_PAGE_DELAY_TIME 3.0

#define HELP_BUTTON_VIEW_HEIGHT  DEVICE_RELATED_OBJ(60.0, 60.0)
#define HELP_START_BUTTON_HEIGHT DEVICE_RELATED_OBJ(44.0, 44.0)
#define HELP_START_BUTTON_WIDTH  DEVICE_RELATED_OBJ(200.0, 200.0)
#define HELP_PAGE_CONTROL_HEIGHT DEVICE_RELATED_OBJ(44.0, 44.0)
#define HELP_TEXT_HEIGHT         DEVICE_RELATED_OBJ(60.0, 60.0)
#define HELP_TITLE_HEIGHT        DEVICE_RELATED_OBJ(50.0, 50.0)

#endif
