//
//  CPPassDataManager.h
//  Passtars
//
//  Created by wangyw on 6/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CPMemo;

@interface CPPassDataManager : NSObject

@property (strong, nonatomic) NSFetchedResultsController *passwordsController;

+ (CPPassDataManager *)defaultManager;

- (void)setPasswordText:(NSString *)text atIndex:(NSUInteger)index;

- (CPMemo *)newMemoText:(NSString *)text inIndex:(NSUInteger)index;
- (void)removeMemo:(CPMemo *)memo;

- (BOOL)canRemovePasswordAtIndex:(NSUInteger)index;
- (void)removePasswordAtIndex:(NSUInteger)index;

- (BOOL)canRecoverPasswordAtIndex:(NSUInteger)index;
- (void)recoverPasswordAtIndex:(NSUInteger)index;

- (void)exchangePasswordBetweenIndex1:(NSUInteger)index1 andIndex2:(NSUInteger)index2;

- (NSArray *)memosContainText:(NSString *)text;

- (void)saveContext;

@end
