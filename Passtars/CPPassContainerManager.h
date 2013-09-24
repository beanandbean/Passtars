//
//  CPPassContainerManager.h
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

#import "CPPasswordView.h"

#import "CPPassDataManager.h"

@interface CPPassContainerManager : CPViewManager <CPPasswordViewDelegate, NSFetchedResultsControllerDelegate>

@end
