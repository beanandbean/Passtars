//
//  CPPasswordView.m
//  Passtars
//
//  Created by wangsw on 9/23/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPasswordView.h"

#import "CPPasstarsConfig.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPasswordView ()

@property (nonatomic, strong) NSNumber *isUsed;

@property (nonatomic, strong) NSArray *sizeConstraints;

@end

@implementation CPPasswordView

- (id)initWithIndex:(int)index andRadius:(float)radius {
    self = [super init];
    if (self) {
        self.index = index;
        self.radius = radius;
        
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)setRadius:(float)radius {
    _radius = radius;
    
    if (_sizeConstraints) {
        [self removeConstraints:_sizeConstraints];
        _sizeConstraints = nil;
    }
    
    [self addConstraints:self.sizeConstraints];
    
    [self setNeedsDisplay];
}

- (void)setUsed:(BOOL)isUsed {
    self.isUsed = [NSNumber numberWithBool:isUsed];
    [self setNeedsDisplay];
}

- (void)setIsShining:(BOOL)isShining {
    _isShining = isShining;
    [self setNeedsDisplay];
}

- (BOOL)containsPoint:(CGPoint)point {
    return isPointInCircle(self.center, self.radius, point);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.password = nil; // Remove the password obj, so it will be refreshed at next access.
    
    CGPoint center = CGPointMake(self.radius, self.radius);
    
    UIImage *icon;
    if (self.isUsed.boolValue) {
        UIColor *passwordColor = self.password.color;
        CGFloat r, g, b, a;
        [passwordColor getRed:&r green:&g blue:&b alpha:&a];
        
        CGFloat locations[PASSWORD_GRADIENT_LEVEL_COUNT + 1];
        CGFloat components[PASSWORD_GRADIENT_LEVEL_COUNT * 4 + 4];
        
        for (int i = 0; i <= PASSWORD_GRADIENT_LEVEL_COUNT; i++) {
            locations[i] = i / PASSWORD_GRADIENT_LEVEL_COUNT;
            components[i * 4] = r;
            components[i * 4 + 1] = g;
            components[i * 4 + 2] = b;
            components[i * 4 + 3] = 1.0 - powf(i / PASSWORD_GRADIENT_LEVEL_COUNT, PASSWORD_GRADIENT_EXPONENT);
        }
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, PASSWORD_GRADIENT_LEVEL_COUNT + 1);
        CGColorSpaceRelease(colorSpace);
        CGFloat startRadius = 0.0, endRadius = self.radius;
        
        CGContextDrawRadialGradient(context, gradient, center, startRadius, center, endRadius, 0);
        
        icon = [UIImage imageNamed:self.password.icon];
    } else {
        if (self.isShining) {
            CGFloat r = 0.8, g = 0.8, b = 0.8;
            CGFloat locations[PASSWORD_GRADIENT_LEVEL_COUNT + 1];
            CGFloat components[PASSWORD_GRADIENT_LEVEL_COUNT * 4 + 4];
            
            for (int i = 0; i <= PASSWORD_GRADIENT_LEVEL_COUNT; i++) {
                locations[i] = i / PASSWORD_GRADIENT_LEVEL_COUNT;
                components[i * 4] = r;
                components[i * 4 + 1] = g;
                components[i * 4 + 2] = b;
                components[i * 4 + 3] = 1.0 - powf(i / PASSWORD_GRADIENT_LEVEL_COUNT, PASSWORD_GRADIENT_EXPONENT);
            }
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, PASSWORD_GRADIENT_LEVEL_COUNT + 1);
            CGColorSpaceRelease(colorSpace);
            CGFloat startRadius = 0.0, endRadius = self.radius * PASSWORD_SHINING_SIZE_MULTIPLIER;
            
            CGContextDrawRadialGradient(context, gradient, center, startRadius, center, endRadius, 0);
        }
        
        CGFloat ellipseRadius = self.radius * PASSWORD_UNUSED_CIRCLE_SIZE_MULTIPLIER;
        CGFloat patternLength = M_PI * ellipseRadius / PASSWORD_DASH_REPEAT_COUNT;
        CGFloat lengths[] = {patternLength, patternLength};
        
        CGContextSetLineDash(context, 0.0, lengths, 2);
        CGContextSetLineWidth(context, PASSWORD_DASH_LINE_WIDTH);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextAddEllipseInRect(context, rectContainingCircle(center, ellipseRadius));
        CGContextStrokePath(context);
        
        icon = [UIImage imageNamed:PASSWORD_DEFAULT_ICON];
    }
    
    [icon drawInRect:rectWithCenterAndSize(center, icon.size)];
    
    self.isUsed = nil;
}

#pragma mark - lazy init

- (CPPassword *)password {
    if (!_password) {
        _password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    }
    return _password;
}

- (NSNumber *)isUsed {
    if (!_isUsed) {
        _isUsed = self.password.isUsed;
    }
    return _isUsed;
}

- (NSArray *)sizeConstraints {
    if (!_sizeConstraints) {
        _sizeConstraints = [NSArray arrayWithObjects:
                            [CPAppearanceManager constraintWithView:self height:self.radius * 2],
                            [CPAppearanceManager constraintWithView:self width:self.radius * 2],
                            nil];
    }
    return _sizeConstraints;
}

@end
