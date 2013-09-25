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

- (BOOL)containsPoint:(CGPoint)point {
    return (point.x - self.center.x) * (point.x - self.center.x) + (point.y - self.center.y) * (point.y - self.center.y) <= self.radius * self.radius;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    UIColor *passwordColor = password.realColor;
    CGFloat r, g, b, a;
    [passwordColor getRed:&r green:&g blue:&b alpha:&a];

    size_t count = 11;
    CGFloat locations[count];
    CGFloat components[count * 4];
    
    for (int i = 0; i < count; i++) {
        locations[i] = i / (count - 1.0);
        components[i * 4] = r;
        components[i * 4 + 1] = g;
        components[i * 4 + 2] = b;
        components[i * 4 + 3] = 1.0 - powf(i / (count - 1.0), PASSWORD_GRADIENT_EXPONENT);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startCenter = CGPointMake(self.radius, self.radius);
    CGPoint endCenter = CGPointMake(self.radius, self.radius);
    CGFloat startRadius = 0.0, endRadius = self.radius;
    
    CGContextDrawRadialGradient(context, gradient, startCenter, startRadius, endCenter, endRadius, 0);
}

#pragma mark - lazy init

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
