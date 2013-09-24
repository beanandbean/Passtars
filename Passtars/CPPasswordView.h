//
//  CPPasswordView.h
//  Passtars
//
//  Created by wangsw on 9/23/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPPasswordView : UIView

@property (nonatomic) float radius;

- (id)initWithIndex:(int)index andRadius:(float)radius;

/*
 * point is for superview
 */
- (BOOL)containsPoint:(CGPoint)point;

@end
