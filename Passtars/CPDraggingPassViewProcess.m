//
//  CPDraggingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPDraggingPassViewProcess.h"

static CPDraggingPassViewProcess *g_process;

@implementation CPDraggingPassViewProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPDraggingPassViewProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
