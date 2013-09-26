//
//  CPPassContainerManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "CPAppearanceManager.h"
#import "CPPasstarsConfig.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPMainViewController.h"
#import "CPPasswordView.h"

#import "CPProcessManager.h"
#import "CPDraggingPassViewProcess.h"

static float g_positioningArray[MAX_PASSWORD_COUNT * 2] = {-1.0};

@interface CPPassContainerManager ()

@property (strong, nonatomic) NSMutableArray *passwordViews;
@property (strong, nonatomic) NSMutableArray *passwordConstraints;

@property (strong, nonatomic) CPPasswordView *dragView;
@property (strong, nonatomic) NSLayoutConstraint *dragViewCenterXConstraint;
@property (strong, nonatomic) NSLayoutConstraint *dragViewCenterYConstraint;
@property (weak, nonatomic) CPPasswordView *dragSourceView;
@property (weak, nonatomic) CPPasswordView *dragDestinationView;

@end

@implementation CPPassContainerManager

+ (CGPoint)positionForPasswordAtIndex:(int)index {
    if (g_positioningArray[0] == -1.0) {
        [CPPassContainerManager refreshPositions];
    }
    return CGPointMake(g_positioningArray[index * 2], g_positioningArray[index * 2 + 1]);
}

+ (void)refreshPositions {
    [CPPassContainerManager refreshPositionsWithOrientation:currentOrientation()];
}

+ (void)refreshPositionsWithOrientation:(UIInterfaceOrientation)orientation {
    float r = PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation), m = PASSWORD_HORIZON_DISTANCE_MULTIPLIER;
    float positioningArray[] = {
        0.0, 0.0,
        0.0, -2 * r,
        -m * r, -r,
        -m * r, r,
        0.0, 2 * r,
        m * r, r,
        m * r, -r
    };
    NSAssert(sizeof(g_positioningArray) == sizeof(positioningArray), @"positioningArray and g_positioningArray should be the same size.");
    memcpy(g_positioningArray, positioningArray, sizeof(g_positioningArray));
}

- (id)initWithSupermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        [CPPassDataManager defaultManager].passwordsController.delegate = self;
        
        [CPMainViewController startDeviceOrientationWillChangeNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:CPDeviceOrientationWillChangeNotification object:nil];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.delegate = self;
        [self.superview addGestureRecognizer:longPress];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self.superview addGestureRecognizer:pan];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CPDeviceOrientationWillChangeNotification object:nil];
    [CPMainViewController stopDeviceOrientationWillChangeNotifier];
}

- (void)loadAnimated:(BOOL)animated {
    float radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
    for (int i = 0; i < MAX_PASSWORD_COUNT; i++) {
        CPPasswordView *passwordView = [[CPPasswordView alloc] initWithIndex:i andRadius:radius];
        [self.superview addSubview:passwordView];
        [self.passwordViews addObject:passwordView];
    }
    [self refreshConstraints];
}

- (void)refreshConstraints {
    if (_passwordConstraints) {
        [self.superview removeConstraints:_passwordConstraints];
        _passwordConstraints = nil;
    }
    
    for (int i = 0; i < MAX_PASSWORD_COUNT; i++) {
        CPPasswordView *passwordView = [self.passwordViews objectAtIndex:i];
        CGPoint position = [CPPassContainerManager positionForPasswordAtIndex:i];
        [self.passwordConstraints addObject:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:position.x]];
        [self.passwordConstraints addObject:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:position.y]];
    }
    [self.superview addConstraints:self.passwordConstraints];
}

- (void)refreshRadiusWithOrientation:(UIInterfaceOrientation)orientation {
    float radius = PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation) * PASSWORD_SIZE_MULTIPLIER;
    for (CPPasswordView *passwordView in self.passwordViews) {
        passwordView.radius = radius;
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = ((NSNumber *)notification.object).integerValue;
    [CPPassContainerManager refreshPositionsWithOrientation:orientation];
    [self refreshConstraints];
    [self refreshRadiusWithOrientation:orientation];
}

- (CPPasswordView *)passwordViewAtLocation:(CGPoint)location {
    CPPasswordView *foundPasswordView = nil;
    for (CPPasswordView *passwordView in self.passwordViews) {
        if ([passwordView containsPoint:location]) {
            foundPasswordView = passwordView;
            break;
        }
    }
    return foundPasswordView;
}

- (void)startDragPasswordView {
    self.dragView = [[CPPasswordView alloc] initWithIndex:self.dragSourceView.index andRadius:PASSWORD_RADIUS * PASSWORD_DRAG_SIZE_MULTIPLIER];
    [self.superview addSubview:self.dragView];
    
    self.dragViewCenterXConstraint = [CPAppearanceManager constraintWithView:self.dragView alignToView:self.dragSourceView attribute:NSLayoutAttributeCenterX];
    [self.superview addConstraint:self.dragViewCenterXConstraint];
    self.dragViewCenterYConstraint = [CPAppearanceManager constraintWithView:self.dragView alignToView:self.dragSourceView attribute:NSLayoutAttributeCenterY];
    [self.superview addConstraint:self.dragViewCenterYConstraint];
    
    self.dragSourceView.hidden = YES;
}

- (void)dragPasswordViewByTranslation:(CGPoint)translation toLocation:(CGPoint)location {
    self.dragViewCenterXConstraint.constant += translation.x;
    self.dragViewCenterYConstraint.constant += translation.y;
    [self.superview layoutIfNeeded];
    
    CPPasswordView *newDestinationView = [self passwordViewAtLocation:location];
    if (newDestinationView != self.dragSourceView && newDestinationView != self.dragDestinationView) {
        if (self.dragDestinationView && self.dragDestinationView.password.isUsed.boolValue) {
            self.dragDestinationView.radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
        }
        if (newDestinationView && newDestinationView.password.isUsed.boolValue) {
            newDestinationView.radius = PASSWORD_RADIUS * PASSWORD_DRAG_SIZE_MULTIPLIER;
        }
        
        self.dragDestinationView = newDestinationView;
    }
}

- (void)stopDragPasswordView {
    if (self.dragDestinationView) {
        if (self.dragDestinationView.password.isUsed.boolValue) {
            self.dragDestinationView.radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
            self.dragDestinationView.hidden = YES;
            
            CPPasswordView *destinationMoveView = [[CPPasswordView alloc] initWithIndex:self.dragDestinationView.index andRadius:PASSWORD_RADIUS * PASSWORD_DRAG_SIZE_MULTIPLIER];
            [self.superview addSubview:destinationMoveView];
            
            NSArray *destinationMoveViewCenterConstraints = [CPAppearanceManager constraintsWithView:destinationMoveView centerAlignToView:self.dragDestinationView];
            [self.superview addConstraints:destinationMoveViewCenterConstraints];
            
            [self.superview bringSubviewToFront:self.dragView];
            [self.superview sendSubviewToBack:destinationMoveView];
            [self.superview layoutIfNeeded];
            
            [self.superview removeConstraint:self.dragViewCenterXConstraint];
            [self.superview removeConstraint:self.dragViewCenterYConstraint];
            [self.superview removeConstraints:destinationMoveViewCenterConstraints];
            
            [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.dragView centerAlignToView:self.dragDestinationView]];
            [self.superview addConstraints:[CPAppearanceManager constraintsWithView:destinationMoveView centerAlignToView:self.dragSourceView]];
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superview layoutIfNeeded];
            } completion:^(BOOL finished) {
                [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceView.index andIndex2:self.dragDestinationView.index];
                
                self.dragSourceView.hidden = NO;
                self.dragDestinationView.hidden = NO;
                
                [self.dragView removeFromSuperview];
                [destinationMoveView removeFromSuperview];
                
                self.dragView = nil;
                self.dragViewCenterXConstraint = nil;
                self.dragViewCenterYConstraint = nil;
                self.dragSourceView = nil;
                self.dragDestinationView = nil;
            }];
        } else {
            [self.superview removeConstraint:self.dragViewCenterXConstraint];
            [self.superview removeConstraint:self.dragViewCenterYConstraint];
            
            [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.dragView centerAlignToView:self.dragDestinationView]];
            
            self.dragSourceView.used = NO;
            self.dragSourceView.hidden = NO;
            self.dragSourceView.alpha = 0.0;
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.superview layoutIfNeeded];
                self.dragSourceView.alpha = 1.0;
                self.dragDestinationView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceView.index andIndex2:self.dragDestinationView.index];
                
                self.dragDestinationView.alpha = 1.0;
                [self.dragView removeFromSuperview];
            }];
        }
    } else {
        [self.superview removeConstraint:self.dragViewCenterXConstraint];
        [self.superview removeConstraint:self.dragViewCenterYConstraint];
        
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.dragView centerAlignToView:self.dragSourceView]];
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.dragSourceView.hidden = NO;
            
            [self.dragView removeFromSuperview];
            
            self.dragView = nil;
            self.dragViewCenterXConstraint = nil;
            self.dragViewCenterYConstraint = nil;
            self.dragSourceView = nil;
        }];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.dragSourceView = [self passwordViewAtLocation:[gesture locationInView:gesture.view]];
        if (self.dragSourceView && self.dragSourceView.password.isUsed.boolValue) {
            [CPProcessManager startProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self startDragPasswordView];
            }];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self stopDragPasswordView];
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            [self dragPasswordViewByTranslation:[gesture translationInView:gesture.view] toLocation:[gesture locationInView:gesture.view]];
            [gesture setTranslation:CGPointZero inView:gesture.view];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self stopDragPasswordView];
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

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeUpdate:
            [(CPPasswordView *)[self.passwordViews objectAtIndex:indexPath.row] setNeedsDisplay];
            break;
        case NSFetchedResultsChangeMove:
            [(CPPasswordView *)[self.passwordViews objectAtIndex:indexPath.row] setNeedsDisplay];
            [(CPPasswordView *)[self.passwordViews objectAtIndex:newIndexPath.row] setNeedsDisplay];
            break;
        default:
            NSAssert(NO, @"Unknowed change reported by NSFetchResultsController!");
            break;
    }
}

#pragma mark - lazy init

- (NSMutableArray *)passwordViews {
    if (!_passwordViews) {
        _passwordViews = [[NSMutableArray alloc] initWithCapacity:MAX_PASSWORD_COUNT];
    }
    return _passwordViews;
}

- (NSMutableArray *)passwordConstraints {
    if (!_passwordConstraints) {
        _passwordConstraints = [[NSMutableArray alloc] initWithCapacity:MAX_PASSWORD_COUNT * 2];
    }
    return _passwordConstraints;
}

@end
