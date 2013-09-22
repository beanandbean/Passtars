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

- (UIColor *)realColor {
    return [[UIColor alloc] initWithRed:DEFAULT_PASSWORD_COLORS[self.colorIndex.intValue * 3] green:DEFAULT_PASSWORD_COLORS[self.colorIndex.intValue * 3 + 1] blue:DEFAULT_PASSWORD_COLORS[self.colorIndex.intValue * 3 + 2] alpha:1.0];
}

- (UIColor *)displayColor {
    return self.isUsed.boolValue ? self.realColor : [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
}

- (UIColor *)reversedColor {
    return self.isUsed.boolValue ? [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0] : self.realColor;
}

- (NSString *)realIcon {
    return DEVICE_RELATED_PNG(self.icon);
}

- (NSString *)displayIcon {
    return DEVICE_RELATED_PNG(self.isUsed.boolValue ? self.icon : @"add");
}

- (NSString *)reversedIcon {
    return DEVICE_RELATED_PNG(self.isUsed.boolValue ? @"add" : self.icon);
}

@end
