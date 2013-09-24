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

#import "CPMainViewController.h"
#import "CPPasswordView.h"

#import "CPProcessManager.h"
#import "CPDraggingPassViewProcess.h"

static float g_positioningArray[MAX_PASSWORD_COUNT * 2] = {-1.0};

@interface CPPassContainerManager ()

@property (strong, nonatomic) NSMutableArray *passwordViews;
@property (strong, nonatomic) NSMutableArray *passwordConstraints;

@property (weak, nonatomic) CPPasswordView *draggingView;

@end

@implementation CPPassContainerManager

+ (CGPoint)positionForPasswordAtIndex:(int)index {
    if (g_positioningArray[0] == -1.0) {
        [CPPassContainerManager refreshPositions];
    }
    return CGPointMake(g_positioningArray[index * 2], g_positioningArray[index * 2 + 1]);
}

+ (void)refreshPositions {
    [CPPassContainerManager refreshPositionsWithOrientation:CURRENT_ORIENTATION];
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
    memcpy(g_positioningArray, positioningArray, sizeof(g_positioningArray) * sizeof(float));
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

- (CPPasswordView *)passwordViewInLocation:(CGPoint)location {
    CPPasswordView *foundPasswordView = nil;
    for (CPPasswordView *passwordView in self.passwordViews) {
        if ([passwordView containsPoint:location]) {
            foundPasswordView = passwordView;
            break;
        }
    }
    return foundPasswordView;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.draggingView = [self passwordViewInLocation:[gesture locationInView:gesture.view]];
        if (self.draggingView) {
            NSLog(@"Long press in %@", self.draggingView);
            [CPProcessManager startProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
            }];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS) /* && [self.delegate canStopDragPasswordView:self] */) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            CGPoint location = [gesture locationInView:gesture.view];
            [gesture setTranslation:CGPointZero inView:gesture.view];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS) /* && [self.delegate canStopDragPasswordView:self] */) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
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
