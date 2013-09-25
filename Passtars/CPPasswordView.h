//
//  CPPasswordView.h
//  Passtars
//
//  Created by wangsw on 9/23/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPPasswordView : UIView

@property (nonatomic) int index;
@property (nonatomic) float radius;

- (id)initWithIndex:(int)index andRadius:(float)radius;


// 'point' is relative to self.superview
- (BOOL)containsPoint:(CGPoint)point;

@end
