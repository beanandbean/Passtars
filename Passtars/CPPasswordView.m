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

#import "CPProcessManager.h"
#import "CPDraggingPassViewProcess.h"

@interface CPPasswordView ()

@property (nonatomic) int index;
@property (nonatomic, weak) id<CPPasswordViewDelegate> delegate;

@property (nonatomic, strong) NSArray *sizeConstraints;

@end

@implementation CPPasswordView

- (id)initWithIndex:(int)index radius:(float)radius andDelegate:(id<CPPasswordViewDelegate>)delegate {
    self = [super init];
    if (self) {
        self.index = index;
        self.radius = radius;
        self.delegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.delegate = self;
        [self addGestureRecognizer:longPress];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
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

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [CPProcessManager startProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
            [self.delegate startDragPasswordView:self];
        }];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS) && [self.delegate canStopDragPasswordView:self]) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self.delegate startDragPasswordView:self];
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            CGPoint location = [gesture locationInView:gesture.view];
            [self.delegate dragPasswordView:self location:location translation:translation];
            [gesture setTranslation:CGPointZero inView:gesture.view];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS) && [self.delegate canStopDragPasswordView:self]) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self.delegate stopDragPasswordView:self];
            }];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate implement

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) || ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])) {
        return YES;
    } else {
        return NO;
    }
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
