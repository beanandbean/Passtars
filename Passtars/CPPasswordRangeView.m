//
//  CPPasswordRangeView.m
//  Passtars
//
//  Created by wangsw on 9/26/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPasswordRangeView.h"

#import "CPPasstarsConfig.h"

#import "CPAppearanceManager.h"

@implementation CPPasswordRangeView

- (id)init {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        float radius = PASSWORD_RADIUS;
        
        self.layer.cornerRadius = radius * 3;
        
        [self addConstraint:[CPAppearanceManager constraintWithView:self height:radius * 6]];
        [self addConstraint:[CPAppearanceManager constraintWithView:self width:radius * 6]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float radius = PASSWORD_RADIUS;
    
    CGPoint center = CGPointMake(radius * 3, radius * 3);
    CGFloat ellipseRadius = radius * 3 - PASSWORD_RANGE_DASH_LINE_WIDTH / 2;
    CGFloat patternLength = M_PI * ellipseRadius / PASSWORD_RANGE_DASH_REPEAT_COUNT;
    CGFloat lengths[] = {patternLength, patternLength};
    
    CGContextSetLineDash(context, 0.0, lengths, 2);
    CGContextSetLineWidth(context, PASSWORD_RANGE_DASH_LINE_WIDTH);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextAddEllipseInRect(context, rectContainingCircle(center, ellipseRadius));
    CGContextStrokePath(context);
}

@end
