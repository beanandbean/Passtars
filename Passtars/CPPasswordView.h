//
//  CPPasswordView.h
//  Passtars
//
//  Created by wangsw on 9/23/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//
@class CPPassword;

@interface CPPasswordView : UIView

@property (nonatomic) int index;
@property (nonatomic) float radius;

@property (nonatomic) BOOL isShining; // Shining is to glow when unused. It is an interaction to dragging.


@property (nonatomic, weak) CPPassword *password;

- (id)initWithIndex:(int)index andRadius:(float)radius;

// 'point' is relative to self.superview
- (BOOL)containsPoint:(CGPoint)point;

- (void)setUsed:(BOOL)isUsed;

@end
