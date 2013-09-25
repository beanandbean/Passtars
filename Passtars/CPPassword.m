//
//  CPPassword.m
//  Passtars
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"

#import "CPHelperMacros.h"
#import "CPPasstarsConfig.h"

@implementation CPPassword

@dynamic index;
@dynamic text;
@dynamic isUsed;
@dynamic colorIndex;
@dynamic icon;
@dynamic memos;

- (UIColor *)color {
    return [[UIColor alloc] initWithRed:DEFAULT_PASSWORD_COLORS[self.colorIndex.intValue * 3] green:DEFAULT_PASSWORD_COLORS[self.colorIndex.intValue * 3 + 1] blue:DEFAULT_PASSWORD_COLORS[self.colorIndex.intValue * 3 + 2] alpha:1.0];
}

- (NSString *)displayIcon {
    return self.isUsed.boolValue ? self.icon : @"Add";
}

- (NSString *)reversedIcon {
    return self.isUsed.boolValue ? @"Add" : self.icon;
}

@end
