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

@interface CPPasswordView ()

@property (nonatomic) int index;
@property (nonatomic) float radius;

@end

@implementation CPPasswordView

- (id)initWithIndex:(int)index andRadius:(float)radius
{
    self = [super init];
    if (self) {
        self.index = index;
        self.radius = radius;
        
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraint:[CPAppearanceManager constraintWithView:self height:radius * 2]];
        [self addConstraint:[CPAppearanceManager constraintWithView:self width:radius * 2]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat r = DEFAULT_PASSWORD_COLORS[self.index * 3], g = DEFAULT_PASSWORD_COLORS[self.index * 3 + 1], b = DEFAULT_PASSWORD_COLORS[self.index * 3 + 2];
    
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

@end