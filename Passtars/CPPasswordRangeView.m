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

#import "CPMainViewController.h"

@interface CPPasswordRangeView ()

@property (nonatomic) float radius;

@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation CPPasswordRangeView

- (id)init {
    self = [super init];
    if (self) {
        self.rangeVisibility = NO;
        self.userInteractionEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = [UIColor blackColor];
        
        [self addConstraint:self.widthConstraint];
        [self addConstraint:self.heightConstraint];
        
        [self refreshRadiusWithOrientation:currentOrientation()];
        
        [CPMainViewController startDeviceOrientationWillChangeNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:CPDeviceOrientationWillChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CPDeviceOrientationWillChangeNotification object:nil];
    [CPMainViewController stopDeviceOrientationWillChangeNotifier];
}
         
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = ((NSNumber *)notification.object).integerValue;
    [self refreshRadiusWithOrientation:orientation];
}

- (void)refreshRadiusWithOrientation:(UIInterfaceOrientation)orientation {
    self.radius = PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation) * 3;
    
    self.layer.cornerRadius = self.radius;
    
    self.widthConstraint.constant = self.radius * 2;
    self.heightConstraint.constant = self.radius * 2;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (self.rangeVisibility) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGPoint center = CGPointMake(self.radius, self.radius);
        CGFloat ellipseRadius = self.radius - PASSWORD_RANGE_DASH_LINE_WIDTH / 2;
        CGFloat patternLength = M_PI * ellipseRadius / PASSWORD_RANGE_DASH_REPEAT_COUNT;
        CGFloat lengths[] = {patternLength, patternLength};
        
        CGContextSetLineDash(context, 0.0, lengths, 2);
        CGContextSetLineWidth(context, PASSWORD_RANGE_DASH_LINE_WIDTH);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextAddEllipseInRect(context, rectContainingCircle(center, ellipseRadius));
        CGContextStrokePath(context);
    }
}

- (void)setRangeVisibility:(BOOL)rangeVisibility {
    _rangeVisibility = rangeVisibility;
    [self setNeedsDisplay];
}

#pragma mark - lazy init

- (NSLayoutConstraint *)widthConstraint {
    if (!_widthConstraint) {
        _widthConstraint = [CPAppearanceManager constraintWithView:self width:0.0];
    }
    return _widthConstraint;
}

- (NSLayoutConstraint *)heightConstraint {
    if (!_heightConstraint) {
        _heightConstraint = [CPAppearanceManager constraintWithView:self height:0.0];
    }
    return _heightConstraint;
}

@end
