//
//  CPPasswordView.h
//  Passtars
//
//  Created by wangsw on 9/23/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@class CPPasswordView;

@protocol CPPasswordViewDelegate <NSObject>

- (void)startDragPasswordView:(CPPasswordView *)passwordView;
- (void)dragPasswordView:(CPPasswordView *)passwordView location:(CGPoint)location translation:(CGPoint)translation;
- (BOOL)canStopDragPasswordView:(CPPasswordView *)passwordView;
- (void)stopDragPasswordView:(CPPasswordView *)passwordView;

@end

@interface CPPasswordView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) float radius;

- (id)initWithIndex:(int)index radius:(float)radius andDelegate:(id<CPPasswordViewDelegate>)delegate;

@end
